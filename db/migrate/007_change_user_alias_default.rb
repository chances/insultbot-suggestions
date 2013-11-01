class ChangeUserAliasDefault < ActiveRecord::Migration
    def self.up
        change_table :insults_users do |t|
            t.remove :alias
            t.string :alias, :limit => 20, :default => nil
        end
    end

    def self.down
        change_table :insults_users do |t|
            t.remove :alias
            t.string :alias, :limit => 20
        end
    end
end