class CreateActivities < ActiveRecord::Migration
  def change
  	create_table :activities do |t|
  	    t.string :name
  	    t.integer :destination_id
  	    t.integer :user_id
    end
  end
end
