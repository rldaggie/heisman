class CreateBallots < ActiveRecord::Migration
  def change
    create_table :ballots do |t|
      t.integer :voter_id
      t.integer :candidate_id
      t.integer :placement

      t.timestamps
    end
  end
end
