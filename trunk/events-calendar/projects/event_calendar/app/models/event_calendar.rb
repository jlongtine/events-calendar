require 'uri'
class EventCalendar < ActiveRecord::Base
   
  def self.get_all_calendars
    qres=EventCalendar.find(:all)
    if qres[0].id.nil?
      raise ArgumentError
    end
    return qres
  end

  def self.insert_cal(c_id,title)   
    event_cal=EventCalendar.new
    event_cal.cal_id=URI.unescape(c_id)
    event_cal.cal_title=title
    event_cal.save
  end

  def self.delete_calendar(c_id)
    
    EventCalendar.delete_all("cal_id='#{c_id}'")
  end


  def self.update_cal(c_id,c_title)
    event_cal = find(:first,:conditions=>["cal_id=?",c_id] )
    event_cal.cal_name=c_title
    event_cal.save

  end

end
