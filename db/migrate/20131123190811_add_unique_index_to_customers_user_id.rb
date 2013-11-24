class AddUniqueIndexToCustomersUserId < ActiveRecord::Migration
  def change
    remove_index :customers, :user_id
    add_index :customers, :user_id, unique: true
  end
end
