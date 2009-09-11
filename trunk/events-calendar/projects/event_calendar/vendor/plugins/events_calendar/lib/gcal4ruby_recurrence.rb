# To change this template, choose Tools | Templates
# and open the template in the editor.
require "rubygems"
require "gcal4ruby"


class Gcal4rubyRecurrence < GCal4Ruby::Recurrence

  def initialize
    
  end

  def to_s

    output = ''
    if @all_day
      output += "DTSTART;VALUE=DATE:#{@start.utc.strftime("%Y%m%d")}\n"
    else
      output += "DTSTART;VALUE=DATE-TIME:#{@start.complete}\n"
    end
    if @all_day
      output += "DTEND;VALUE=DATE:#{@end.utc.strftime("%Y%m%d")}\n"
    else
      output += "DTEND;VALUE=DATE-TIME:#{@end.complete}\n"
    end
    output += "RRULE:"
    if @frequency
      f = 'FREQ='
      i = ''
      by = ''
      @frequency.each do |key, v|
        if v.is_a?(Array)
          if v.size > 0
            value = v.join(",")
          else
            value = nil
          end
        else
          value = v
        end
        if(key.downcase=="by_month_day")
          key_new="monthly"
        else
          key_new=key
        end
        
        f += "#{key_new.upcase};" if key != 'interval'
        case key.downcase
        when "secondly"
          by += "BYSECOND=#{value};"
        when "minutely"
          by += "BYMINUTE=#{value};"
        when "hourly"
          by += "BYHOUR=#{value};"
        when "weekly"
          by += "BYDAY=#{value};" if value
        when "monthly"
          by += "BYDAY=#{value};"
        when "by_month_day"
          by += "BYMONTHDAY=#{value};"
        when "yearly"
          by += "BYYEARDAY=#{value};"
        when 'interval'
          i += "INTERVAL=#{value};"
        end
      end
      output += f+i+by
    end
    if @repeat_until
      output += "UNTIL=#{@repeat_until.strftime("%Y%m%d")}"
    end

    output += "\n"
  end

end
