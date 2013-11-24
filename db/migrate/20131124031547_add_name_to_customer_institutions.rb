class AddNameToCustomerInstitutions < ActiveRecord::Migration
  def change
    add_column :customer_institutions, :name, :string
  end
end
