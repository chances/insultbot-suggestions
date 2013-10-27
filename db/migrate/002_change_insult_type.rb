class ChangeInsultType < ActiveRecord::Migration
    def self.up
        change_table :insults do |t|
            t.change :insult, :text, :null => false
        end
    end

    def self.down
        change_table :insults do |t|
            t.change :insult, :string, :null => false
        end
    end
end
