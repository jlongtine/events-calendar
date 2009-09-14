require 'rubygems'
#require 'googlecalendar.rb'
require 'gcal4ruby'
require 'uri'
require 'time'

class EventsController < ApplicationController
  CONFIG = YAML::load(ERB.new(IO.read("config/calendar_config.yml")).result).freeze
  def index

    @month=Time.new.month
    @year=Time.new.year


    if(!params[:month].nil?)
      @month=params[:month]

    end


    if(!params[:year].nil?)
      @year=params[:year]

    end


    if(@month.to_i==13)
      @month=1
      @year=@year.to_i+1
    end

    if(@month.to_i==0)
      @month=12
      @year=@year.to_i-1
    end
        
    @cal_id=params[:cal_id]
    @cal_title=params[:title]
 
   
    current_month=get_month_str(@month.to_i)
    next_month=get_month_str(@month.to_i+1)    

    start_time="#{@year.to_s}-#{current_month}-01T00:00:00"
    end_time="#{@year.to_s}-#{next_month}-01T00:00:00"

    begin
    service=get_authenticated
  
    calendar=Gcal4rubyCalendar.new    
    calendar.init(@cal_id, service)

    @events=Gcal4rubyEvent.find_with_auth(calendar,'',{:scope=>:all,:max_results=>100, :range=>{:start=>start_time,:end=>end_time}})
    rescue GCal4Ruby::HTTPGetFailed => gcal4ruby_error
      puts "#{ gcal4ruby_error } (#{ gcal4ruby_error.class })!"
      redirect_to "/calendars?error=get_failed"
    rescue Exception => e
       puts "#{ e } (#{ e.class })!"
       redirect_to "/calendars?error=error"
    end
   
  end



  def get_month_str(month)
    if(month<10)
      month_str="0"+month.to_s
    else
      month_str=month.to_s
    end
    return month_str
  end


  def new
    @events_type=get_event_types
    @cal_id=params[:cal_id]
    @status=params[:status]
  end

  def create

    #  render :text=>Time.parse(params[:p_date_and_time])
    begin
       if params[:where]=="" or params[:title]==""
        raise ArgumentError
      end

      service=get_authenticated
    
     
      calendar=Gcal4rubyCalendar.new
      calendar.init(params[:cal_id], service)
      calendar.set_exist_false
      calendar.set_event_feed(params[:cal_id])

      new_event = Gcal4rubyEvent.new(calendar)

      #puts URI.escape params[:p_date_and_time]

      if params[:highlight]
        highlight="true"
      else
        highlight="false"
      end

      new_event.title = params[:title]
      new_event.start =Time.parse(params[:start_date])
      new_event.end =Time.parse(params[:end_date])
      new_event.where =params[:where]
      new_event.content="highlight-#{highlight},type-#{params[:event_type].downcase},webpage-#{params[:webpage]},#{params[:content]}"



      if not params[:repeats]=="No Repeats"

        param_arr=[]
        new_event.recurrence = Gcal4rubyRecurrence.new
        new_event.recurrence.start = Time.parse( params[:start_date])
        new_event.recurrence.end = Time.parse( params[:end_date])

        case params[:repeats]
        when "Daily":
            repeat_type="daily"
        when "Weekly":
            param_arr.push("SU") if(params[:c_b_sun])
          param_arr.push("MO") if(params[:c_b_mon])
          param_arr.push("TU") if(params[:c_b_tue])
          param_arr.push("WE") if(params[:c_b_wen])
          param_arr.push("TH") if(params[:c_b_thu])
          param_arr.push("FR") if(params[:c_b_fri])
          param_arr.push("SA") if(params[:c_b_sat])
          repeat_type="weekly"

        when "Monthly":
            day_of_the_month=Time.parse( params[:start_date]).strftime("%d")
          param_arr.push(day_of_the_month)
          repeat_type="by_month_day"
        when "Yearly":
            day_of_year =Time.parse( params[:start_date]).strftime("%j")
          param_arr.push(day_of_year.to_i)
          repeat_type="yearly"
        end

        new_event.recurrence.repeat_until=Date.parse( params[:repeat_until])
        interval=params[:repeat_every]

        new_event.recurrence.frequency = {repeat_type => param_arr,"interval"=>interval}
        #          new_event.recurrence.frequency = {"Monthly" => ["+2FR"],"interval"=>"1"}

      end
      new_event.save

      redirect_to "/events/new?cal_id=#{params[:cal_id]}&status=true"
    rescue
      redirect_to "/events/new?cal_id=#{params[:cal_id]}&status=false"
    end
  end
  

  def show
    @cal_id=params[:cal_id]
    @cal_title=params[:cal_title]
    @event_title=URI.escape(params[:id])
    @event_id=params[:event_id]
    @event=get_event(@cal_id,@event_title,@event_id)
    @rrule=@event.get_rrule_hash()

  end

  def get_event(cal_id,title,eve_id)
    
    service=get_authenticated

    eve_id=URI.escape(eve_id,"@")
 
    calendar=Gcal4rubyCalendar.new

    calendar.init(cal_id, service)
    event=Gcal4rubyEvent.find_without_auth(calendar,eve_id,{:scope=>:first})

   
    begin


      description=event.content.split(',',4)
      event.content=description[3]
      event.highlight=description[0].split('-',2)[1]
      event.event_type=description[1].split('-',2)[1]
      event.webpage=description[2].split('-',2)[1]

      
    rescue
      puts "Event Calendar-Event description format incorrect"
    end

    return event
  end

  
  def get_event_types
    events_type=[]
    begin      
      file = File.open(CONFIG['EVENT_TYPE_XML'],"r")
      doc = REXML::Document.new file

      doc.elements.each("events/event") { |eve|
        events_type.push(eve.elements["type"].text.titleize )
      }
      file.close
      return events_type
    rescue
      return events_type 
    end

  end

  def update
   

    @events_type=get_event_types
    @cal_id=params[:cal_id]   
    @cal_title=params[:cal_title]
    @event_title=URI.escape(params[:event_title])
    @event_id=params[:event_id]
    @update_status=params[:id]
    @event=get_event(@cal_id,@event_title,@event_id)

    @rrule=@event.get_rrule_hash()
  end

  def edit    

    begin

       if params[:where]=="" or params[:title]==""
        raise ArgumentError
      end

      service=get_authenticated

  
      event_id=params[:event_id]

      calendar=Gcal4rubyCalendar.new

      calendar.init(params[:cal_id], service)

      event_id=URI.escape(event_id,"@")

      new_event=Gcal4rubyEvent.find_with_auth(calendar,event_id,{:scope=>:first})


      updated_event=params[:event]

      if params[:highlight]
        highlight="true"
      else
        highlight="false"
      end

      new_event.title=updated_event[:title]
      new_event.content="highlight-#{highlight},type-#{params[:event_type].downcase},webpage-#{updated_event[:webpage]},#{updated_event[:content]}"
      new_event.where=updated_event[:where]
      new_event.start=Time.parse(params[:start_date])
      new_event.end=Time.parse(params[:end_date])


      if not params[:repeats]=="No Repeats"

        param_arr=[]
        new_event.recurrence = Gcal4rubyRecurrence.new
        new_event.recurrence.start = Time.parse( params[:start_date])
        new_event.recurrence.end = Time.parse( params[:end_date])

        case params[:repeats]
        when "Daily":
            repeat_type="daily"
        when "Weekly":
            param_arr.push("SU") if(params[:c_b_sun])
          param_arr.push("MO") if(params[:c_b_mon])
          param_arr.push("TU") if(params[:c_b_tue])
          param_arr.push("WE") if(params[:c_b_wen])
          param_arr.push("TH") if(params[:c_b_thu])
          param_arr.push("FR") if(params[:c_b_fri])
          param_arr.push("SA") if(params[:c_b_sat])
          repeat_type="weekly"

        when "Monthly":
          day_of_the_month=Time.parse( params[:start_date]).strftime("%d")
          param_arr.push(day_of_the_month)
          repeat_type="by_month_day"
        when "Yearly":
          day_of_year =Time.parse( params[:start_date]).strftime("%j")
          param_arr.push(day_of_year.to_i)
          repeat_type="yearly"
        end

        new_event.recurrence.repeat_until=Date.parse( params[:repeat_until])
        interval=params[:repeat_every]

        new_event.recurrence.frequency = {repeat_type => param_arr,"interval"=>interval}


      end

      new_event.save
      redirect_to "/events?title=#{params[:cal_title]}&cal_id=#{params[:cal_id]}"
    rescue
      redirect_to "/events/update/false?event_title=#{updated_event[:title]}&event_id=#{event_id}&cal_id=#{params[:cal_id]}&cal_title=#{params[:cal_title]}"
    end

  end


  def destroy

  
    service=get_authenticated
   

    event_id=params[:event_id].sub!("http://www.google.com/calendar/feeds/#{params[:cal_id]}/events/", '')
    
    ss =Gcal4rubyEvent.newdelete(params[:cal_id],service,event_id)
    

    redirect_to "/events?title=#{params[:cal_title]}&cal_id=#{params[:cal_id]}"

  end



  def range_select
     
    @cal_id=params[:cal_id]
    @cal_title=URI.escape(params[:cal_title])
    @event_title=URI.escape(params[:event_title])
    @event_id=params[:event_id]

  end

  def delete_instance

    begin
      
      if not params[:range].nil?
        delete_all= params[:range][:delete_all]
      else
        delete_all="false"
      end

      if delete_all =="true"

        redirect_to "/events/destroy/true?cal_title=#{params[:cal_title]}&cal_id=#{params[:cal_id]}&event_id=#{params[:event_id]}"

      else
        @cal_id=params[:cal_id]
        @cal_title=params[:cal_title]
        @event_title=URI.escape(params[:event_title])
        @event_id=params[:event_id]

        eve_title=URI.unescape(@event_title)
        @start=params[:start_date]
        @end=params[:end_date]

        service=get_authenticated

        calendar=Gcal4rubyCalendar.new
        calendar.init(params[:cal_id], service)

        @event_id=URI.escape(params[:event_id],"@")
        @events=Gcal4rubyEvent.find_with_auth(calendar,eve_title,{:scope=>:all,:max_results=>100, :range=>{:start=> Date.parse(@start).strftime("%Y-%m-%dT%H:%M:%S"),:end=>Date.parse(@end).strftime("%Y-%m-%dT%H:%M:%S")}})

      
        @events.each{|event|
          if(event.status.to_s=="confirmed")

            recurr_ob=event.get_recurrence
            @re=recurr_ob[:recurr_events]
            @event=event
            break

          end
        }


      end
    rescue Exception=>err
      puts "error : "+err
    end
  

  end

  def delete_single_instance  

    start_date=Date.parse(params[:start]).strftime("%Y-%m-%d")
    end_date=Date.parse(params[:end]).strftime("%Y-%m-%d")

    service=get_authenticated

 
    pattern="http://www.google.com/calendar/feeds/#{params[:cal_id]}/events/"
    pattern=URI.escape(pattern,"@")


    eve_id=params[:event_id].sub!(pattern, '')
 

    calendar=Gcal4rubyCalendar.new
    calendar.init(params[:cal_id], service)

    calendar.set_exist_false
    calendar.set_event_feed(params[:cal_id])

    event=Gcal4rubyEventDelete.new(calendar)

    event.status="canceled"
    event.start=Time.parse(params[:selection])
    event.id=eve_id
    event.cal_id=params[:cal_id]
    event.save
    redirect_to "/events/delete_instance/true?cal_title=#{params[:cal_title]}&cal_id=#{params[:cal_id]}"+
      "&event_id=#{params[:event_id]}&event_title=#{params[:event_title]}&start_date=#{start_date}&end_date=#{end_date}"
   
  end

  def get_authenticated
    #if(session["service"].nil?)

      service = GCal4Ruby::Service.new
      service.authenticate(CONFIG['ADMIN_CALENDAR_EMAIL_ADDRESS'],CONFIG['ADMIN_CALENDAR_PASSWORD'])
      session["service"]=service
    #else
    #  service=session["service"]
    #end
    return service
  end


end
