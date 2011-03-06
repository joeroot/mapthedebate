require 'active_record'
require 'composite_primary_keys'

module WordNet
  
  class Word < ActiveRecord::Base
    
    has_many :senses
    has_many :synsets, :through => :senses
    
    def categories
      self.synsets.map{|s| s.category}      
    end
    
    def category_names
      self.categories.map{|c| c.name}.uniq
    end
    
  end
  
end