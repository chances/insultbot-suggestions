class ChangeUserAddInsultCount < ActiveRecord::Migration
    def self.up
        change_table :insults_users do |t|
            t.integer :insult_count, :default => 0, :null => false
        end
    end

    def self.down
        change_table :insults_users do |t|
            t.remove :insult_count
        end
    end
end