class AddExpenseEventHashKey < ActiveRecord::Migration[8.0]
  def change
    add_column :expense_events, :hash_key, :string
  end
end
