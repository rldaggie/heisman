require 'open-uri'

class Voter < ActiveRecord::Base
  has_many :ballots
  has_many :candidates, through: :ballots
  
  attr_accessible :name, :publication, :region
  
  class << self
    
    def create_votes_from_site!
      clear_records!
      table = get_table_from_site
      Candidate.create_candidates_from_table!(table)
      create_voters_from_table!(table)
    end
    
    def create_voters_from_table!(table)
      rows = table.css('tr')
      rows.shift
      rows.each do |row|
        cells = row.css('td')
        voter = Voter.create(name: cells[0].content.strip, publication: cells[1].content.strip, region: cells[2].content.strip)
        voter.create_ballots_from_cells!(cells)
      end
    end
    
    def get_table_from_site
      doc = Nokogiri::HTML(open('http://www.stiffarmtrophy.com/votes2012/'))
      doc.css('table.funky').first
    end
    
    def clear_records!
      Voter.all.each { |v| v.delete }
      Ballot.all.each { |b| b.delete }
      Candidate.all.each { |c| c.delete }
    end
    
    def formatted_region_array
      the_array = region_array
      region_hash = Voter.all.group_by(&:region)
      region_hash.keys.each do |region|
        the_array << region_array_from_region(region)
      end
      the_array
    end
    
    def region_array_from_region(region)
      Candidate.all.inject([region.upcase]) do |the_array, client|
        the_array << client.points_from_region(region)
        the_array
      end
    end
    
    def region_array
      [['Region'] + Candidate.pluck(:name)]
    end
    
    def table_array
      all.map do |voter|
        voter_array = [voter.name, voter.publication, voter.region]
        Candidate.all.each do |candidate|
          ballot = Ballot.where(voter_id: voter.id, candidate_id: candidate.id).first.try(:placement)
          voter_array << ballot
        end
        voter_array
      end
    end
    
  end
  
  def create_ballots_from_cells!(cells)
    cells.each_with_index do |cell, index|
      if index > 2
        create_ballot_from_table_position!(index, cell.content) unless cell.content.strip.blank?
      end
    end
  end
  
  def create_ballot_from_table_position!(table_position, placement)
    candidate_id = Candidate.where(table_position: table_position).first.try(:id)
    ballots.create(candidate_id: candidate_id, placement: placement)
  end
end
