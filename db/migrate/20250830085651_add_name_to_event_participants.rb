class AddNameToEventParticipants < ActiveRecord::Migration[8.0]
  def change
    add_column :event_participants, :name, :string
  end
end
