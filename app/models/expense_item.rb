class ExpenseItem < ApplicationRecord
  belongs_to :expense_event
  has_many :item_participants, autosave: true

  belongs_to :paid_by, class_name: "EventParticipant", inverse_of: :paid_items
end
