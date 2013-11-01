class CreateUsers < ActiveRecord::Migration
    def self.up
        create_table :insults_users do |t|
            t.string :username, :limit => 20, :null => false
            t.string :alias, :limit => 20, :default => nil
            t.string :password, :null => false

            t.timestamps
        end

        create_table :insults_users_insults, :id => false do |t|
            t.integer :insults_user_id
            t.integer :insult_id
        end
    end

    def self.down
        drop_table :insults_users_insults
        drop_table :insults_users
    end
end