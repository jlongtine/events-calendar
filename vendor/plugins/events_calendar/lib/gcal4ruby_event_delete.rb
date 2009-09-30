require "rubygems"
require "gcal4ruby"


class Gcal4rubyEventDelete < Gcal4rubyEvent

   attr_accessor :cal_id

  def initialize(calendar)
    super(calendar)
  end



 def to_xml()

    content = <<EOF
<?xml version="1.0"?>
<entry xmlns='http://www.w3.org/2005/Atom' xmlns:gd='http://schemas.google.com/g/2005'>
  <gd:eventStatus
    value='http://schemas.google.com/g/2005#event.#{@status}'>
  </gd:eventStatus>

<gd:originalEvent id="#{@id}" href="http://www.google.com/calendar/feeds/#{@cal_id}/events/#{@id}">
<gd:when startTime="#{Time.parse(@start.to_s).strftime("%Y-%m-%dT%H:%M:%S.000+05:30")}"/>


</gd:originalEvent>

</entry>
EOF


    return content
  end

end
