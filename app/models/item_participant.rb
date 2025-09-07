class ItemParticipant < ApplicationRecord
  belongs_to :expense_item
  belongs_to :event_participant
end
