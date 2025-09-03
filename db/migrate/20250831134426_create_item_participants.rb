class CreateItemParticipants < ActiveRecord::Migration[8.0]
  def change
    create_table :item_participants do |t|
      t.references :expense_event, null: false, foreign_key: true
      t.references :expense_item, null: false, foreign_key: true
      t.references :event_participant, null: false, foreign_key: true
      t.float :amount, null: false, default: 0

      t.timestamps
    end
  end
end
