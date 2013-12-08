class ChangeUserAliasDefault < ActiveRecord::Migration
    def self.up
        change_table :insults_users do |t|
            t.string :email, :null => false
        end
    end

    def self.down
        change_table :insults_users do |t|
            t.remove :email
        end
    end
end
