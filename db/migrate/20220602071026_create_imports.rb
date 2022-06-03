class CreateImports < ActiveRecord::Migration[7.0]
  def change
    create_table :imports do |t|
      t.string :status
      t.string :error
      t.string :filename
      t.belongs_to :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
