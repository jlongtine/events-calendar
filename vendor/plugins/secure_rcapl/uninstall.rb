require 'fileutils'

puts '**************************************************************'
puts '**************************************************************'

puts 'Removing rcapl security plugin..............................'

here = File.dirname(__FILE__)
there = defined?(RAILS_ROOT) ? RAILS_ROOT : "#{here}/../../.."

FileUtils.rm "#{there}/config/rcapl_conf.yml" 
FileUtils.rm "#{there}/lib/secure_rcapl.rb"
FileUtils.rm "#{there}/lib/linklk.rb"
FileUtils.rm "#{there}/lib/linklk_user.rb"

puts 'configuring...................................................'
puts 'done'


