class EventParticipant < ApplicationRecord
  belongs_to :user, optional: true
  belongs_to :expense_event
  has_many :paid_items, class_name: "ExpenseItem", foreign_key: "paid_by_id", inverse_of: :paid_by

  def participant_name
    name.presence || user&.name
  end
end
