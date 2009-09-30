# To change this template, choose Tools | Templates
# and open the template in the editor.
require "rubygems"
require "gcal4ruby"


class Gcal4rubyEvent < GCal4Ruby::Event

  attr_accessor :event_type,:webpage,:highlight


  def initialize(calendar)
    super(calendar)
  end


  
  def self.newdelete(cal_id,service,event_id)
    edit_feed="http://www.google.com/calendar/feeds/#{cal_id}/private/full/#{event_id}"

    if service.send_delete(edit_feed,{"If-Match" => "*"})
      return true
    else
      return false
    end

  end




  def self.find_without_auth(calendar, query = '', params = {})
    query_string = ''
    
    begin
      test = URI.parse(query).scheme
    rescue Exception => e
      test = nil
    end

    if test
    
      puts "id passed, finding event by id" if calendar.service.debug
      es = calendar.service.send_get("http://www.google.com/calendar/feeds/#{calendar.id}/private/full")

      REXML::Document.new(es.read_body).root.elements.each("entry"){}.map do |entry|
        puts "element  = "+entry.name if calendar.service.debug
        id = ''
        entry.elements.each("id") {|v| id = v.text}
        puts "id = #{id}" if calendar.service.debug
        
        if id == query
          
          entry.attributes["xmlns:gCal"] = "http://schemas.google.com/gCal/2005"
          entry.attributes["xmlns:gd"] = "http://schemas.google.com/g/2005"
          entry.attributes["xmlns"] = "http://www.w3.org/2005/Atom"
          event = Gcal4rubyEvent.new(calendar)
          event.load("<?xml version='1.0' encoding='UTF-8'?>#{entry.to_s}")

          return event
        end
      end
    end


    #parse params hash for values
    range = params[:range] || nil
    max_results = params[:max_results] || nil
    sort_order = params[:sortorder] || nil
    single_events = params[:singleevents] || nil
    timezone = params[:ctz] || nil

    #set up query string
    query_string += "q=#{query}" if query
    if range
      if not range.is_a? Hash
        raise "The date range must be a hash including the :start and :end date values as Times"
      else
        date_range = ''
        if range.size > 0
          #puts  "&start-min=#{range[:start].xmlschema}&start-max=#{range[:end].xmlschema}"
          query_string += "&start-min=#{range[:start]}&start-max=#{range[:end]}"
        end
      end
    end
    query_string += "&max-results=#{max_results}" if max_results
    query_string += "&sortorder=#{sort_order}" if sort_order
    query_string += "&ctz=#{timezone.gsub(" ", "_")}" if timezone
    query_string += "&singleevents#{single_events}" if single_events
    if query_string
      

      puts "sending get request.........."

      url=URI.parse("http://www.google.com/calendar/feeds/#{calendar.id}/public/full?#{query_string}")
      request = Net::HTTP::Get.new(url.to_s)
      events = Net::HTTP.start(url.host, url.port) {|http| http.request(request)}

      if not events.is_a?(Net::HTTPSuccess)

        raise GCal4Ruby::HTTPGetFailed, events.body
      end
      puts "URL to String------->"
      puts url.to_s
    
      

      ret = []
      REXML::Document.new(events.read_body).root.elements.each("entry"){}.map do |entry|
        entry.attributes["xmlns:gCal"] = "http://schemas.google.com/gCal/2005"
        entry.attributes["xmlns:gd"] = "http://schemas.google.com/g/2005"
        entry.attributes["xmlns"] = "http://www.w3.org/2005/Atom"
        event = Gcal4rubyEvent.new(calendar)      
        
        event.load("<?xml version='1.0' encoding='UTF-8'?>#{entry.to_s}")
         
        ret << event
      end
    end
  
    if params[:scope] == :first
         return ret[0]           
    else 
      return ret
    end
    
  end



  def get_recurrence()
 
    xml = REXML::Document.new(@xml)
   
  
    recurr_events=[]
    recurr_ob=Hash.new
    xml.root.elements.each("gd:when"){}.map do |ele|
  
      @recurrence = GCal4Ruby::Recurrence.new
      @recurrence.start=Time.parse(ele.attributes['startTime'])
      @recurrence.end=Time.parse(ele.attributes['endTime'])
      @recurrence.repeat_until=Date.parse(ele.attributes['endTime'])

      recurr_events << @recurrence
    end

    if not xml.root.elements["gd:recurrence"].nil?

      re_string=xml.root.elements["gd:recurrence"].text
      lines = re_string.split("\n")

      lines.each{|line|
            
        pair = line.split(':')
     
        if(pair[0]=="RRULE")
          rrule = pair[1].split(';')
          rrule.each{|r|
            rule=r.split('=')
            if(rule[0]=="UNTIL")
              recurr_ob[:endDate]=rule[1]
            end
          }
        end
        if (pair[0].split(';')[0]=="DTSTART" and !pair[0].split(';')[1].nil?)
         
          recurr_ob[:startDate]=pair[1]
        else
          if (pair[0]=="DTSTART" and !(pair[1]=="19700101T000000"))
            temp_time=Time.parse(pair[1])+((60*60)*5.5)
            recurr_ob[:startDate]=temp_time.to_s
          end
        end
      }
      
    end
    recurr_ob[:recurr_events]=recurr_events
     return recurr_ob

  end


  def get_rrule_hash()
     xml = REXML::Document.new(@xml)
    if not xml.root.elements["gd:recurrence"].nil?
      
      re_string=xml.root.elements["gd:recurrence"].text
      lines = re_string.split("\n")
      rrule_hash={}
      lines.each{|line|
        pair = line.split(':')   
        break if(pair[0]=="BEGIN")
        if (pair[0].split(';')[0]=="DTSTART")
          rrule_hash["DTSTART"] = pair[1]  
        end
        if (pair[0].split(';')[0]=="DTEND")
          rrule_hash["DTEND"] = pair[1]  
        end
        
        if(pair[0]=="RRULE")
          array = pair[1].split(';')
          
          array.each{|r|           
            rrule_pair = r.split('=')
            rrule_hash[rrule_pair[0]] = rrule_pair[1]           
          }
        end           
      }
      return rrule_hash
      
    end
  end


  def to_xml()
   
    xml = REXML::Document.new(@xml)
    xml.root.elements.each(){}.map do |ele|
      case ele.name
      when 'id'
        ele.text = @id
      when "title"
        ele.text = @title
      when "content"
        ele.text = @content
      when "recurrence"
        ele.text = @recurrence.to_s
      when "when"
       
        if not @recurrence
        
          ele.attributes["startTime"] = @all_day ? @start.strftime("%Y-%m-%d") : @start.xmlschema
          ele.attributes["endTime"] = @all_day ? @end.strftime("%Y-%m-%d") : @end.xmlschema
          set_reminder(ele)
        else
          if not @reminder
       
            xml.root.delete_element("/entry/gd:when")
            xml.root.add_element("gd:recurrence").text = @recurrence.to_s
          else
        
            ele.delete_attribute('startTime')
            ele.delete_attribute('endTime')
            set_reminder(ele)
          end
        end
      when "eventStatus"
        ele.attributes["value"] = case @status
        when :confirmed
          "http://schemas.google.com/g/2005#event.confirmed"
        when :tentative
          "http://schemas.google.com/g/2005#event.tentative"
        when :cancelled
          "http://schemas.google.com/g/2005#event.canceled"
        else
          "http://schemas.google.com/g/2005#event.confirmed"
        end
      when "transparency"
        ele.attributes["value"] = case @transparency
        when :free
          "http://schemas.google.com/g/2005#event.transparent"
        when :busy
          "http://schemas.google.com/g/2005#event.opaque"
        else
          "http://schemas.google.com/g/2005#event.opaque"
        end
      when "where"
        ele.attributes["valueString"] = @where
      end
    end
    if not @attendees.empty?
      @attendees.each do |a|
        xml.root.add_element("gd:who", {"email" => a[:email], "valueString" => a[:name], "rel" => "http://schemas.google.com/g/2005#event.attendee"})
      end
    end
    xml.to_s
  end



  def self.find_with_auth(calendar, query = '', params = {})
    query_string = ''


    begin
      test = URI.parse(query).scheme
    rescue Exception => e
      test = nil
    end

    if test

      puts "id passed, finding event by id" if calendar.service.debug
      es = calendar.service.send_get("http://www.google.com/calendar/feeds/#{calendar.id}/private/full")

      REXML::Document.new(es.read_body).root.elements.each("entry"){}.map do |entry|
        puts "element  = "+entry.name if calendar.service.debug
        id = ''
        entry.elements.each("id") {|v| id = v.text}
        puts "id = #{id}" if calendar.service.debug

        if id == query

          entry.attributes["xmlns:gCal"] = "http://schemas.google.com/gCal/2005"
          entry.attributes["xmlns:gd"] = "http://schemas.google.com/g/2005"
          entry.attributes["xmlns"] = "http://www.w3.org/2005/Atom"
          event = Gcal4rubyEvent.new(calendar)
          event.load("<?xml version='1.0' encoding='UTF-8'?>#{entry.to_s}")
          return event
        end
      end
    end


    #parse params hash for values
    range = params[:range] || nil
    max_results = params[:max_results] || nil
    sort_order = params[:sortorder] || nil
    single_events = params[:singleevents] || nil
    timezone = params[:ctz] || nil

    #set up query string
    query_string += "q=#{query}" if query
    if range
      if not range.is_a? Hash
        raise "The date range must be a hash including the :start and :end date values as Times"
      else
        date_range = ''
        if range.size > 0
          #puts  "&start-min=#{range[:start].xmlschema}&start-max=#{range[:end].xmlschema}"
          query_string += "&start-min=#{range[:start]}&start-max=#{range[:end]}"
        end
      end
    end
    query_string += "&max-results=#{max_results}" if max_results
    query_string += "&sortorder=#{sort_order}" if sort_order
    query_string += "&ctz=#{timezone.gsub(" ", "_")}" if timezone
    query_string += "&singleevents#{single_events}" if single_events
    if query_string

      events = calendar.service.send_get("http://www.google.com/calendar/feeds/#{calendar.id}/private/full?"+query_string)

      ret = []
      REXML::Document.new(events.read_body).root.elements.each("entry"){}.map do |entry|
        entry.attributes["xmlns:gCal"] = "http://schemas.google.com/gCal/2005"
        entry.attributes["xmlns:gd"] = "http://schemas.google.com/g/2005"
        entry.attributes["xmlns"] = "http://www.w3.org/2005/Atom"
        event = Gcal4rubyEvent.new(calendar)

        event.load("<?xml version='1.0' encoding='UTF-8'?>#{entry.to_s}")

        ret << event
      end
    end

    if params[:scope] == :first
      return ret[0]
    else
      return ret
    end

  end

end
