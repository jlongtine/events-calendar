require 'fileutils'

puts  '**************************************************************'
puts  '**************************************************************'

puts 'installing Events Calendar plugin..............................'

here = File.dirname(__FILE__)
there = defined?(RAILS_ROOT) ? RAILS_ROOT : "#{here}/../../.."

FileUtils.cp "#{here}/lib/controllers/calendar_clients_controller.rb", "#{there}/app/controllers/"
FileUtils.cp "#{here}/lib/controllers/calendars_controller.rb", "#{there}/app/controllers/"
FileUtils.cp "#{here}/lib/controllers/events_controller.rb", "#{there}/app/controllers/"

FileUtils.cp_r "#{here}/lib/views/calendar_clients", "#{there}/app/views/"
FileUtils.cp_r "#{here}/lib/views/calendars", "#{there}/app/views/"
FileUtils.cp_r "#{here}/lib/views/events", "#{there}/app/views/"

FileUtils.cp "#{here}/lib/calendar_details.xml", "#{there}/lib/"
FileUtils.cp "#{here}/lib/gcal4ruby_calendar.rb", "#{there}/lib/"
FileUtils.cp "#{here}/lib/gcal4ruby_event.rb", "#{there}/lib/"
FileUtils.cp "#{here}/lib/gcal4ruby_event_delete.rb", "#{there}/lib/"
FileUtils.cp "#{here}/lib/gcal4ruby_recurrence.rb", "#{there}/lib/"

FileUtils.cp "#{here}/lib/event_types.xml", "#{there}/config/"
FileUtils.cp "#{here}/lib/calendar_config.yml", "#{there}/config/"

FileUtils.cp_r "#{here}/lib/stylesheets/calendar", "#{there}/public/stylesheets/"
FileUtils.cp "#{here}/lib/stylesheets/tab_default.css", "#{there}/public/stylesheets/"
FileUtils.cp_r "#{here}/lib/calendar_images", "#{there}/public/images/"
FileUtils.cp_r "#{here}/lib/events_calendar_js", "#{there}/public/javascripts/"
FileUtils.cp_r "#{here}/lib/calendar_helper", "#{there}/vendor/plugins/"



puts 'configuring...................................................'
puts 'Successfully Installed'
