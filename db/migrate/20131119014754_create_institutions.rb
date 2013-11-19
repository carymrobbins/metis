class CreateInstitutions < ActiveRecord::Migration
  def change
    create_table :institutions do |t|
      t.string :name
      t.string :home_url
      t.string :phone_number

      t.timestamps
    end
  end
end
