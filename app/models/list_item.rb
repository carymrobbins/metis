# == Schema Information
#
# Table name: list_items
#
#  id         :integer         not null, primary key
#  list_id    :integer
#  name       :string(255)
#  created_at :datetime
#  updated_at :datetime
#

class ListItem < ActiveRecord::Base
  belongs_to :list
  default_scope -> { order('name') }
  validates :list_id, presence: true
  validates :name, presence: true
end
