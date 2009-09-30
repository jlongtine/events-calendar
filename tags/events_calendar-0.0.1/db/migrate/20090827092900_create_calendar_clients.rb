class CreateCalendarClients < ActiveRecord::Migration
  def self.up
    create_table :calendar_clients do |t|

      t.timestamps
    end
  end

  def self.down
    drop_table :calendar_clients
  end
end
