class CreateExpenseEvents < ActiveRecord::Migration[8.0]
  def change
    create_table :expense_events do |t|
      t.string :name
      t.string :icon
      t.timestamps
    end
  end
end
