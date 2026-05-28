class AddNotesToSchedules < ActiveRecord::Migration[8.1]
  def change
    add_column :schedules, :notes, :text
  end
end
