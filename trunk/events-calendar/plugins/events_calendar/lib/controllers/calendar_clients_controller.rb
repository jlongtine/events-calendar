require 'rubygems'
require 'gcal4ruby'


class CalendarClientsController < ApplicationController
  CONFIG = YAML::load(ERB.new(IO.read("config/calendar_config.yml")).result).freeze
  def client_page
    
    #    begin

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


    calendar=Gcal4rubyCalendar.new
    calendar.init_display_only(CONFIG['CLIENT_CAL_ID'])

    current_month=get_month_str(@month.to_i)
    next_month=get_month_str(@month.to_i+1)

    

    if(next_month=="13")
      next_month="01"
      year_end=@year.to_i+1
    else
      year_end=@year
    end


    start_time="#{@year.to_s}-#{current_month}-01T00:00:00"
    end_time="#{year_end.to_s}-#{next_month}-01T00:00:00"

    eve=Gcal4rubyEvent.find_without_auth(calendar,'',{:scope=>:all,:max_results=>100, :range=>{:start=>start_time,:end=>end_time}})


    @events_details=get_config_details


    @event_ob=[]
    @recurrence=true

    eve.each do |event|
      
      next if not event.status.to_s=="confirmed"
 
    
        recurr_ob=event.get_recurrence
        re=recurr_ob[:recurr_events]

        begin
           description=event.content.split(',',4)
            event.content=description[3]
            event.highlight=description[0].split('-',2)[1]
            event.event_type=description[1].split('-',2)[1]
            event.webpage=description[2].split('-',2)[1]

        rescue Exception=>err
            puts "Event Calendar-Event description format incorrect"
            next
        end

      begin
        next if event.highlight=="false"

        if recurr_ob[:startDate].nil?
          re_start_date=event.start
          re_end_date=event.end
        else
          re_start_date=recurr_ob[:startDate]
          re_end_date=recurr_ob[:endDate]
        end

        if event.event_type=="holiday"
          @events_details["holiday"]["array"].push(Date.parse(event.start.to_s))
          @event_ob.push(event)
          next
        end


        begin
          if  event.event_type=="film"
            event.start=Time.parse(re_start_date.to_s)
            event.end=Time.parse(re_end_date.to_s)
            event.title=event.title+" showing @ "+event.where+" from "+DateTime.parse(re_start_date.to_s).strftime("%B %d")+
              " to "+DateTime.parse(re_end_date.to_s).strftime("%B %d")

          end
        rescue Exception=>err
          puts err
        end
        
        if ((@events_details[event.event_type]["disply_first_only"]=="true") and (Date.parse(re_start_date.to_s).month==@month.to_i))

          @events_details[event.event_type]["array"].push(Date.parse(re_start_date.to_s))
          
        end

        if re.size>1

          re.each{|reccurence|

            begin

              @events_details[event.event_type]["array"].push(Date.parse(reccurence.start.to_s)) if not @events_details[event.event_type]["disply_first_only"]=="true"

              event_re=Gcal4rubyEvent.new(calendar)

              event_re.title=event.title
              event_re.where=event.where
              event_re.start=Time.parse(reccurence.start.to_s)
              event_re.end=Time.parse(reccurence.end.to_s)


              event_re.content=event.content
              event_re.event_type=event.event_type
              event_re.webpage=event.webpage
            rescue
              puts "Event Calendar-Event description format incorrect"
            end

            @event_ob.push(event_re) #if  !((Date.parse(event_re.start.to_s)==Date.parse(re_start_date.to_s)) and (@events_details[event.event_type]["disply_first_only"]=="true"))
          }
        else
          if not @events_details[event.event_type]["disply_first_only"]=="true"
            @events_details[event.event_type]["array"].push(Date.parse(event.start.to_s))
          end
          @event_ob.push(event)
        end

      rescue Exception => e
        puts "Error Occured..........."+e

      end 

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

  def get_config_details
    file = File.open(CONFIG['EVENT_TYPE_XML'],"r")
    doc = REXML::Document.new file
    events_type={}
    doc.elements.each("events/event") { |eve|
      event={}
#      event["type"]=eve.elements["type"].text
      event["colour"]=eve.elements["colour"].text
      event["disply_first_only"]=eve.elements["disply_first_only"].text
      event["array"]=Array.new
      events_type[eve.elements["type"].text]=event
      
    }
    file.close
    return events_type
  end

  def index
    
  end

  def detail_page
    
    @timeframe="day"
    begin
      @timeframe=params[:timeframe]
      date=Date.parse(params[:date])
    rescue
      date=Date.today
      @timeframe="day"
    end
    date1=date.to_s.split('-',3)

    @year=date1[0]
    @month=date1[1]
    @day=date1[2]


    calendar=Gcal4rubyCalendar.new
    #calendar.init_display_only("eventcalendarravin%40gmail.com")

    calendar.init_display_only(CONFIG['CLIENT_CAL_ID'])

    case @timeframe
    when "day"
      start_date=date
      end_date=date+1

    when "week"
      start_date=date-date.wday.to_i
      end_date=start_date+7

    when "month"

      start_date=date-date.day+1
      end_date=start_date >> 1

    when "next_month"
      start_date=date >> 1
      end_date=date >> 2
    else


    end


    start_time="#{start_date.to_s}T00:00:00"
    end_time="#{end_date.to_s}T00:00:00"

    start_date=date-date.day+1
    end_date=start_date >> 1

    month_begin="#{start_date.to_s}T00:00:00"
    month_end="#{end_date.to_s}T00:00:00"

    begin
      eve=Gcal4rubyEvent.find_without_auth(calendar,'',{:scope=>:all,:max_results=>100, :range=>{:start=>month_begin,:end=>month_end}})
      puts "finding done"

      @events_details=get_config_details

      @event_ob=[]
      @recurrence=true
      @tooltip_ob=[]

      eve.each do |event|

     #   if Date.parse(event.start.to_s).month<=@month.to_i and Date.parse(event.end.to_s).month>=@month.to_i


           next if not event.status.to_s=="confirmed"

          recurr_ob=event.get_recurrence
          re=recurr_ob[:recurr_events]

          begin
            description=event.content.split(',',4)
            event.content=description[3]
            event.highlight=description[0].split('-',2)[1]
            event.event_type=description[1].split('-',2)[1]
            event.webpage=description[2].split('-',2)[1]
          rescue Exception=>err
            puts "Event Calendar-Event description format incorrect"
            next
          end



          if recurr_ob[:startDate].nil?
            re_start_date=event.start
            re_end_date=event.end
          else
            re_start_date=recurr_ob[:startDate]
            re_end_date=recurr_ob[:endDate]
          end


          if event.event_type=="holiday"
            @events_details["holiday"]["array"].push(Date.parse(event.start.to_s))  if event.highlight=="true"
            @event_ob.push(event) if (Time.parse(start_time) <= event.start and event.start < Time.parse(end_time) )
            @tooltip_ob.push(event) if event.highlight=="true"
          next
          end



           begin
              if  event.event_type=="film"
                event.start=Time.parse(re_start_date.to_s)
                event.end=Time.parse(re_end_date.to_s)
                event.title=event.title+" showing @ "+event.where+" from "+DateTime.parse(re_start_date.to_s).strftime("%B %d")+
                " to "+DateTime.parse(re_end_date.to_s).strftime("%B %d")
               end
            rescue Exception => err
                puts err
            end


          if  ((@events_details[event.event_type]["disply_first_only"]=="true") and (Date.parse(re_start_date.to_s).month==@month.to_i))

              @events_details[event.event_type]["array"].push(Date.parse(re_start_date.to_s)) if event.highlight=="true"
          end

        
          if re.size>1
            re.each{|reccurence|
              begin
                @events_details[event.event_type]["array"].push(Date.parse(reccurence.start.to_s)) if not @events_details[event.event_type]["disply_first_only"]=="true" and event.highlight=="true"
                event_re=Gcal4rubyEvent.new(calendar)
                event_re.title=event.title
                event_re.where=event.where
                event_re.start=Time.parse(reccurence.start.to_s)
                event_re.end=Time.parse(reccurence.end.to_s)
                event_re.highlight=event.highlight
                #event_re.event_type="film"

                event_re.content=event.content
                event_re.event_type=event.event_type
                event_re.webpage=event.webpage
              rescue
                puts "Event Calendar-Event description format incorrect"
              end
             # @tooltip_ob.push(event_re) if  !((Date.parse(event_re.start.to_s)==Date.parse(re_start_date)) and (@events_details[event.event_type]["disply_first_only"]=="true")) and event.highlight=="true"
              @tooltip_ob.push(event_re) if event.highlight=="true"

            @event_ob.push(event_re) if (Time.parse(start_time) <= event_re.start and  event_re.start < Time.parse(end_time) )
            }
          else
       
            @events_details[event.event_type]["array"].push(Date.parse(event.start.to_s)) if not @events_details[event.event_type]["disply_first_only"]=="true" and event.highlight=="true"
            @event_ob.push(event) if (Time.parse(start_time) <= event.start and  event.start < Time.parse(end_time))
            @tooltip_ob.push(event) if event.highlight=="true"
            #@tooltip_ob.push(event) if not @events_details[event.event_type]["disply_first_only"]=="true" and event.highlight=="true"

        end


     #   end


      end

    rescue Exception=>error
      puts error

    end

  end


  
end
