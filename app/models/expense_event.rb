class ExpenseEvent < ApplicationRecord
  has_many :event_participants, dependent: :destroy
  has_many :users, through: :event_participants

  has_many :expense_items, dependent: :destroy
  has_many :item_participants, through: :expense_items

  validates :name, presence: true

  after_initialize { self.hash_key ||= Digest::MD5.hexdigest(Random.random_number.to_s)[0..7] }

  def invitation_url
    Rails.application.routes.url_helpers.view_invitation_url(
      name: name.parameterize, hash_key: hash_key
    )
  end
end
