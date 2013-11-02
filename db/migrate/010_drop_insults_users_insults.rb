class DropInsultsUsersInsults < ActiveRecord::Migration
    def self.up
        drop_table :insults_users_insults
    end

    def self.down
        create_table :insults_users_insults, :id => false do |t|
            t.integer :insults_user_id
            t.integer :insult_id
        end
    end
end