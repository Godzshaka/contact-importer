class AddImportToContacts < ActiveRecord::Migration[7.0]
  def change
    add_reference :contacts, :import, null: false, foreign_key: true
  end
end
