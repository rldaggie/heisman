class Ballot < ActiveRecord::Base
  belongs_to :voter
  belongs_to :candidate
  
  after_save :update_points_for_candidate
  
  attr_accessible :candidate_id, :placement, :voter_id
  
  class << self
    
    def points_hash
      {1 => 3, 2 => 2, 3 => 1}
    end
    
  end
  
  def update_points_for_candidate
    candidate.calculate_points!
  end
  
  def points
    Ballot.points_hash[placement]
  end
end
