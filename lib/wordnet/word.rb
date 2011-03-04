require 'active_record'
require 'composite_primary_keys'

module WordNet
  
  class Word < ActiveRecord::Base
    
    has_many :senses
    has_many :synsets, :through => :senses
    
    def categories
      self.synsets.map{|s| s.category}      
    end
    
  end
  
end