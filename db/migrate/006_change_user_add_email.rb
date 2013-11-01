class ChangeUserAliasDefault < ActiveRecord::Migration
    def self.up
        change_table :insults_users do |t|
            t.change :alias, :default => nil
        end
    end

    def self.down
        change_table :insults_users do |t|
            t.remove :email
        end
    end
end