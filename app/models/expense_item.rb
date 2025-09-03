class ExpenseItem < ApplicationRecord
  belongs_to :expense_event
  has_many :item_participants

  belongs_to :paid_by, class_name: "EventParticipant"
end
