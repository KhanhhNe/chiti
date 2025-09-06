class ExpenseItem < ApplicationRecord
  belongs_to :expense_event
  has_many :item_participants, autosave: true

  belongs_to :paid_by, class_name: "EventParticipant", inverse_of: :paid_items

  def update_participants(participants_params)
    current_participants = self.item_participants.to_a
    # Only get participants of the current event, avoiding IDOR
    event_participants = self.expense_event.event_participants.to_a

    participants_params.each do |participant|
      item_participant = current_participants.find { |ip| ip.event_participant_id == participant[:id] }

      if item_participant.present?
        item_participant.amount = participant[:amount]
      else
        item_participant ||= ItemParticipant.new(
          expense_event_id: expense_item.expense_event_id,
          expense_item: expense_item,
          # Make sure to assign the model here, so ActiveRecord validate the presence of event_participant
          event_participant: event_participants.find { |ep| ep.id == participant[:id] },
          amount: participant[:amount]
        )
        expense_item.item_participants << item_participant
      end
    end
  end
end
