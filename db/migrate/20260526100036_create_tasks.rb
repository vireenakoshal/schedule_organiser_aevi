class CreateTasks < ActiveRecord::Migration[8.1]
  def change
    create_table :tasks do |t|
      t.references :schedule, null: false, foreign_key: true
      t.integer :duration_min
      t.string :category
      t.time :fixed_time
      t.time :preferred_time

      t.timestamps
    end
  end
end
