class CreateExpenseItems < ActiveRecord::Migration[8.0]
  def change
    create_table :expense_items do |t|
      t.string :name
      t.references :paid_by, null: false, foreign_key: { to_table: :event_participants }
      t.references :expense_event, null: false, foreign_key: true
      t.float :amount
      t.date :paid_on

      t.timestamps
    end
  end
end
