class CreateVoters < ActiveRecord::Migration
  def change
    create_table :voters do |t|
      t.string :name
      t.string :publication
      t.string :region

      t.timestamps
    end
  end
end
