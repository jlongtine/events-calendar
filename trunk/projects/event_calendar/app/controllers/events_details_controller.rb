require 'rubygems'
require 'gcal4ruby'
require 'googlecalendar.rb'
require 'date'

class EventsDetailsController < ApplicationController
  
  def index
      
    
    #    date=date1.split('-',3)
    #
    #    @year=date[0]
    #    @month=date[1]
    #    @day=date[2]

    
   
    begin
      timeframe=params[:timeframe]
      date=Date.parse(params[:date])
    rescue
      date=Date.parse('2009-7-1')
      timeframe="month"
    end
    date1=date.to_s.split('-',3)

    @year=date1[0]
    @month=date1[1]
    @day=date1[2]


    calendar=Gcal4rubyCalendar.new
    calendar.init_display_only("eventcalendarravin%40gmail.com")

    case timeframe
    when "day"
      start_date=date
      end_date=date+1

    when "this_week"
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
    begin
    eve=Gcal4rubyEvent.find_without_auth(calendar,'',{:scope=>:all,:max_results=>100, :range=>{:start=>start_time,:end=>end_time}})
    puts "finding done"

    @events = []
    @films=[]
    @event_ob=[]
    @recurrence=true

    eve.each do |event|

      #if Date.parse(event.start.to_s).month<=@month.to_i and Date.parse(event.end.to_s).month>=@month.to_i
        

        recurr_ob=event.get_recurrence
        re=recurr_ob[:recurr_events]

        if re.size>1
         
          re.each{|reccurence|
            #@events.push(Date.parse(reccurence.start.to_s))
            begin
              event_re=Gcal4rubyEvent.new(calendar)
              event_re.title=event.title
              event_re.where=event.where              
              event_re.start=Time.parse(reccurence.start.to_s)
              event_re.end=Time.parse(reccurence.end.to_s)
              #event_re.event_type="film"
              
              description=event.content.split(',',3)
              event_re.content=description[2]
              event_re.event_type=description[0].split('-',2)[1]
              event_re.webpage=description[1].split('-',2)[1]
            rescue 
              puts "Description format error"
            end
            @event_ob.push(event_re)
          }
          if Date.parse(recurr_ob[:startDate].to_s).month==@month.to_i
            @films.push(Date.parse(recurr_ob[:startDate]))
          end
          if Date.parse(recurr_ob[:endDate].to_s).month==@month.to_i
            @films.push(Date.parse(recurr_ob[:endDate]))
          end
        else
          begin
            event.event_type="Others"
            description=event.content.split(',',3)
            event.content=description[2]
            event.event_type=description[0].split('-',2)[1]
            event.webpage=description[1].split('-',2)[1]

          rescue
             puts "Description format error"
          end
          @events.push(Date.parse(event.start.to_s))
          @event_ob.push(event)
      
        end
       
      #end

    end
#    render :text=>  eve[0].get_recurrence
  rescue Exception=>error
      puts error
    end

  end


  def index2

  end

  def ticket_prices
    
  end

  
  
end
