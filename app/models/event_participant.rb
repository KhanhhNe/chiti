class EventParticipant < ApplicationRecord
  belongs_to :user, optional: true
  belongs_to :expense_event

  def participant_name
    name || user.name
  end
end
