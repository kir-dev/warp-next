class CreateMemberships < ActiveRecord::Migration[6.1]
  def change
    create_table :memberships do |t|
      t.references :user, null: false, foreign_key: true
      t.references :circle, null: false, foreign_key: true
      t.boolean :admin, null: false, default: false
      t.boolean :accepted, null: false, default: false
      
      t.timestamps
    end
  end
end
