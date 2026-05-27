class AddNameToSchedules < ActiveRecord::Migration[8.1]
  def change
    add_column :schedules, :name, :string
  end
end
