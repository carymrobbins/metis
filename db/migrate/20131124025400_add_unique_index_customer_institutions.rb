class AddUniqueIndexCustomerInstitutions < ActiveRecord::Migration
  def change
    add_index :customer_institutions, [:customer_id, :institution_id],
              unique: true
  end
end
