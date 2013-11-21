# == Schema Information
#
# Table name: lists
#
#  id         :integer         not null, primary key
#  name       :string(255)
#  user_id    :integer
#  created_at :datetime
#  updated_at :datetime
#

class List < ActiveRecord::Base
  belongs_to :user
  has_many :list_items, dependent: :destroy
  default_scope -> { order('name') }
  validates :user_id, presence: true
  validates :name, presence: true
  validates_uniqueness_of :name, scope: :user_id
end
