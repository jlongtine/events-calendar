# To change this template, choose Tools | Templates
# and open the template in the editor.
require "rubygems"
require "gcal4ruby"

class Gcal4rubyCalendar<GCal4Ruby::Calendar
  def initialize
  
  end

  def init(c_id,service)
    @id=c_id
    @service=service
    @editable=true
  end

  def set_exist_false
    @exists=false

  end


  def init_display_only(c_id)
    @id=c_id
    @editable=true
  end


  def self.newdelete(cal_id,service)
    if service.send_delete(CALENDAR_FEED+"/"+cal_id)
      return true
    else
      return false
    end

  end

  def set_event_feed(c_id)
    @event_feed = "http://www.google.com/calendar/feeds/#{c_id}/private/full"
  end




end
