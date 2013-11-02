class AddUniqueIndexToListItemsListIdName < ActiveRecord::Migration
  def change
    add_index :list_items, [:list_id, :name], unique: true
  end
end
