class User < ApplicationRecord
  has_many :auth_providers, dependent: :destroy
  has_many :articles, through: :comments
  has_many :comments, dependent: :destroy
end
