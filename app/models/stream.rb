class Stream < ApplicationRecord
  belongs_to :user

  validates :user, :title, :session_id, presence: true
end
