class ListItem < ActiveRecord::Base
  belongs_to :list
  default_scope -> { order('name') }
  validates :list_id, presence: true
  validates :name, presence: true
  validates_uniqueness_of :name, scope: :list_id
end
