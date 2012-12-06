class AddPointsToCandidates < ActiveRecord::Migration
  def change
    add_column :candidates, :points, :integer, default: 0
  end
end
