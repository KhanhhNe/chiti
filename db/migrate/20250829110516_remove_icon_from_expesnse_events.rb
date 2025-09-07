class RemoveIconFromExpesnseEvents < ActiveRecord::Migration[8.0]
  def change
    remove_column :expense_events, :icon, :string
  end
end
