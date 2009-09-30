class CreateEventCalendars < ActiveRecord::Migration
  def self.up
    create_table :event_calendars do |t|

      t.timestamps
    end
  end

  def self.down
    drop_table :event_calendars
  end
end
