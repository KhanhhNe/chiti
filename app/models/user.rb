class User < ApplicationRecord
  has_secure_password
  has_many :sessions, dependent: :destroy

  has_many :event_participants, dependent: :destroy
  has_many :expense_events, through: :event_participants

  normalizes :email_address, with: ->(e) { e.strip.downcase }
end
