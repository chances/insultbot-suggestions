class ChangeInsultAuthorToUserId < ActiveRecord::Migration
    def self.up
        change_table :insults do |t|
            t.remove :author
            t.integer :author_id, :null => false
        end
    end

    def self.down
        change_table :insults do |t|
            t.remove :author_id
            t.string :author, :limit => 20, :null => false
        end
    end
end