 require 'fileutils'

puts  '**************************************************************'
puts  '**************************************************************'

puts 'installing rcapl security plugin..............................'

here = File.dirname(__FILE__)
there = defined?(RAILS_ROOT) ? RAILS_ROOT : "#{here}/../../.."

FileUtils.cp "#{here}/lib/yaffle.rb", "#{there}/config/"
#FileUtils.cp "#{here}/lib/secure_rcapl.rb", "#{there}/lib/"
#FileUtils.cp "#{here}/lib/linklk.rb", "#{there}/lib/"
#FileUtils.cp "#{here}/lib/linklk_user.rb", "#{there}/lib/"

puts 'configuring...................................................'
puts 'Successfully Installed'
