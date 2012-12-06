class Candidate < ActiveRecord::Base
  has_many :ballots
  has_many :voters, through: :ballots
  
  attr_accessible :name, :table_position, :points
  
  class << self
    
    def create_candidates_from_table!(table)
      create_candidates_from_cells!(table.css('tr').first.css('td'))
    end
    
    def create_candidates_from_cells!(cells)
      cells.each_with_index do |cell, index|
        if index > 2
          self.create(name: cell.content, table_position: index)
        end
      end
    end
    
    def formatted_points_array
      all.inject([['Candidate', 'Points']]) do |the_array, candidate|
        the_array << [candidate.name, candidate.points]
        the_array
      end
    end
    
  end
  
  def calculate_points!
    self.points = points_array_from_placements_array.sum
    self.save
  end
  
  def placements_array
    ballots.pluck(:placement)
  end
  
  def points_array_from_placements_array
    placements_array.map do |placement|
      Ballot.points_hash[placement]
    end
  end
  
  def points_from_region(region)
    ballots.where(voter_id: voters.where(region: region).map(&:id)).map(&:points).sum
  end
  
end
