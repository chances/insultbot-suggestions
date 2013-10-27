class CreateInsults < ActiveRecord::Migration
    def self.up
        create_table :insults do |t|
            t.string :insult, :null => false
            t.string :author, :limit => 20, :null => false
            t.boolean :approved, :default => false
            
            t.timestamps
        end
    end

    def self.down
        drop_table :insults
    end
end
