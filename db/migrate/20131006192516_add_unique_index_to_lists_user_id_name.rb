class AddUniqueIndexToListsUserIdName < ActiveRecord::Migration
  def change
    add_index :lists, [:name, :user_id]
  end
end
