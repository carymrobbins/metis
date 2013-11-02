class List < ActiveRecord::Base
  belongs_to :user
  has_many :list_items, dependent: :destroy
  default_scope -> { order('name') }
  validates :user_id, presence: true
  validates :name, presence: true
  validates_uniqueness_of :name, scope: :user_id
end
