class CreateBlogtypes < ActiveRecord::Migration[5.2]
  def change
    create_table :blogtypes do |t|
      t.string :name
      t.datetime :created_on

      t.timestamps
    end
  end
end
