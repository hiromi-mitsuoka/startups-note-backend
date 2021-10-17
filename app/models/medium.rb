class Medium < ApplicationRecord
  has_many :articles

  validates :name,
    presence: true,
    uniqueness: true
  validates :url,
    presence: true,
    uniqueness: true
end
