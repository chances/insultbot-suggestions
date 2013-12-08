class ChangeInsultAddPublished < ActiveRecord::Migration
    def self.up
        change_table :insults do |t|
            t.boolean :published, :default => false
        end
    end

    def self.down
        change_table :insults do |t|
            t.remove :published
        end
    end
end
