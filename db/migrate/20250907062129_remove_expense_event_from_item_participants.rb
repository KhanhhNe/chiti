class RemoveExpenseEventFromItemParticipants < ActiveRecord::Migration[8.0]
  def change
    remove_reference :item_participants, :expense_event, foreign_key: true
  end
end
