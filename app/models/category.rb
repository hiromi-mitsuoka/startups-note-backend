class Category < ApplicationRecord
  acts_as_paranoid # Logical deletion
end