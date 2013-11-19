class CreateCustomers < ActiveRecord::Migration
  def change
    create_table :customers do |t|
      t.references :user, index: true

      t.timestamps
    end
  end
end
