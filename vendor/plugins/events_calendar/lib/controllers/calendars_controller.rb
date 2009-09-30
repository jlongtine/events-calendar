require "rubygems"
require "gcal4ruby"
#require 'googlecalendar.rb'
require "rexml/document"


class CalendarsController < ApplicationController
   CONFIG = YAML::load(ERB.new(IO.read("config/calendar_config.yml")).result).freeze
  def index
    
    if not params[:error].nil?
      if params[:error]=="get_failed"
        @error="Reading Evets details Failed. May not have the read privileges!"
      elsif params[:error]=="delete_failed"
        @error="Deleting failed. May not have the required privileges!"
      else
        @error="Error Occured !"
      end
    end
   
    @calendars=[]
    begin
      file = File.open(CONFIG['CALENDAR_XML'],"r")
      doc = REXML::Document.new file

      doc.elements.each("calendars/calendar") { |cal|
        calendar={}
        calendar["cal_id"]=cal.elements["cal_id"].text
        calendar["cal_title"]=cal.elements["cal_title"].text
        @calendars.push(calendar)
      }
      file.close
    rescue Exception=>err
      puts "Error:"+err
    end

 
  end

  def show

  end

  def refresh
    begin
      service=get_authenticated
      calendars = service.calendars
     
      doc = REXML::Document.new()
      doc.add_element("calendars")
      calendars.each{|calendar|       
        add_cal_element(doc,calendar.id,calendar.title,calendar.summary)
      }

      file = File.open(CONFIG['CALENDAR_XML'],"w")
      doc.write file
      file.close
    rescue
      puts "error in writing to the calendar_details.xml file"
    end
    redirect_to "/calendars"

  end

  def new

  end
  
 
  def create
    begin
      service=get_authenticated

      calendar = GCal4Ruby::Calendar.new(service)
      calendar.title = params["calendar"]["title"]
      calendar.summary = params["calendar"]["summary"]
      calendar.timezone="Asia/Colombo"


      @result=calendar.save
      calendar.public = true

      file = File.open(CONFIG['CALENDAR_XML'],"r")
      doc = REXML::Document.new file
      add_cal_element(doc,calendar.id,params["calendar"]["title"],params["calendar"]["summary"])
      file.close;

      file = File.open(CONFIG['CALENDAR_XML'],"w")
      doc.write file
      file.close

      #    re=EventCalendar.insert_cal(calendar.id,params["calendar"]["title"])
      redirect_to :action => 'new'
    rescue
      
    end
  end

  def update

    @cal_title=params[:id]
    @cal_id=params[:cal_id]
#    @calendar=get_calendars(@cal_id)
    @cal_id=URI.escape(@cal_id,"@")

    file = File.open(CONFIG['CALENDAR_XML'],"r")
    doc = REXML::Document.new file
    @calendars={}
    doc.elements.each("calendars/calendar") { |cal|
   
      if cal.elements["cal_id"].text==@cal_id      
        @calendars["cal_title"]=cal.elements["cal_title"].text
        @calendars["cal_summary"]=cal.elements["cal_summary"].text
       
      end
    }
    file.close

  end

  def edit

    calendar=get_calendars(params[:cal_id])
  
    calendar.title=params[:cal_title]
    calendar.summary=params[:cal_summary]
  
    calendar.save()
#    EventCalendar.update_cal(calendar.id,calendar.title)
    file = File.open(CONFIG['CALENDAR_XML'],"r")
    doc = REXML::Document.new file
    update_cal_element(doc,calendar.id,calendar.title,calendar.summary)
    file.close;

    file = File.open(CONFIG['CALENDAR_XML'],"w")
    doc.write file
    file.close
    redirect_to "/calendars"

  end



  def get_calendars(cal_id)
    cal_id=URI.escape(cal_id,"@")
    service=get_authenticated
    cal = GCal4Ruby::Calendar.find(service, cal_id,:first)


    return cal

  end



  def destroy

    service=get_authenticated

    begin
      Gcal4rubyCalendar.newdelete(params["cal_id"],service)

      file = File.open(CONFIG['CALENDAR_XML'],"r")
      doc = REXML::Document.new file
      delete_cal_element(doc,params["cal_id"])
      file.close;

      file = File.open(CONFIG['CALENDAR_XML'],"w")
      doc.write file
      file.close

      redirect_to :action => 'index'
    rescue GCal4Ruby::HTTPDeleteFailed=>error
      puts "Delete Failed !"
      redirect_to "/calendars?error=delete_failed"
    rescue Exception=>err
      puts "Error Occured.."+err
    end

  
  end

  def add_cal_element(doc,cal_id,cal_title,cal_summary)

    cal_element = doc.root.add_element "calendar"

    id_element=cal_element.add_element "cal_id"
    id_element.text=cal_id

    title_element=cal_element.add_element "cal_title"
    title_element.text=cal_title

    summary_element=cal_element.add_element "cal_summary"
    summary_element.text=cal_summary
  end

  def delete_cal_element(doc,cal_id)
    doc.elements.each("calendars/calendar") { |calendar|
      
      cal_id=URI.escape(cal_id,"@")
      if (calendar.elements["cal_id"].text==cal_id)

        doc.root.delete_element(calendar)
      end
    }
  end

  def update_cal_element(doc,cal_id,cal_title,cal_summary)
    doc.elements.each("calendars/calendar") { |calendar|

      if (calendar.elements["cal_id"].text==cal_id)
        calendar.elements["cal_title"].text=cal_title
        calendar.elements["cal_summary"].text=cal_summary
      end

    }
  end

  def get_authenticated
#    if(session["service"].nil?)

      service = GCal4Ruby::Service.new
      service.authenticate(CONFIG['ADMIN_CALENDAR_EMAIL_ADDRESS'],CONFIG['ADMIN_CALENDAR_PASSWORD'])
      session["service"]=service
#    else
#      service=session["service"]
#    end
    return service
  end




end
