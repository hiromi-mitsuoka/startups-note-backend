class Comment < ApplicationRecord
  # For checking in rails c. (https://qiita.com/junara/items/ca6f65d2f2a27f185f0e)
  belongs_to :user, optional: true
  belongs_to :comment, optional: true
  # belongs_to :user
  # belongs_to :comment
end
