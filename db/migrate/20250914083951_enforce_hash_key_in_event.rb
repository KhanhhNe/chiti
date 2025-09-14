class EnforceHashKeyInEvent < ActiveRecord::Migration[8.0]
  def change
    change_column_null :expense_events, :hash_key, false
    add_index :expense_events, :hash_key, unique: true
  end
end
