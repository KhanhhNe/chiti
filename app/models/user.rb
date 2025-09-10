class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  has_many :sessions, dependent: :destroy

  has_many :event_participants, dependent: :destroy
  has_many :expense_events, through: :event_participants
end
