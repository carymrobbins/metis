class CreateCustomerInstitutions < ActiveRecord::Migration
  def change
    create_table :customer_institutions do |t|
      t.references :customer, index: true
      t.references :institution, index: true

      t.timestamps
    end
  end
end
