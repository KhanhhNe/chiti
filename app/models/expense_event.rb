class ExpenseEvent < ApplicationRecord
  has_many :event_participants, dependent: :destroy
  has_many :users, through: :event_participants

  has_many :expense_items

  validates :name, presence: true
end
