class CreateFaqs < ActiveRecord::Migration[5.2]
  def change
    create_table :faqs do |t|
      t.string :goal
      t.text :prereqs
      t.text :steps
      t.datetime :created_on
      t.datetime :updated_on
      t.datetime :replied_on
      t.datetime :reviewed_on
      t.integer :user_id
      t.integer :staff_id
      t.boolean :reviewed, default: false

      t.timestamps
    end
  end
end
