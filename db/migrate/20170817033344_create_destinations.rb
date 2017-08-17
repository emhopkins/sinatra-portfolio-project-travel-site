class CreateDestinations < ActiveRecord::Migration
  def change
  	create_table :destinations do |t|
  	    t.string :name
  	    t.integer :user_id
    end
  end
end
