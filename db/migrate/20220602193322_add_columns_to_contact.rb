class AddColumnsToContact < ActiveRecord::Migration[7.0]
  def change
    add_column :contacts, :card_last_digits, :string
    add_column :contacts, :card_number_length, :integer
  end
end
