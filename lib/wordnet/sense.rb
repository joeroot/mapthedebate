require 'active_record'
require 'composite_primary_keys'

module WordNet
  
  class Sense < ActiveRecord::Base

    set_primary_keys :word_id, :synset_id

    belongs_to :word
    belongs_to :synset
    
    def definition
      self.synset.definition
    end
    
    def pos
      self.synset.pos
    end
    
    def pos_detailed
      self.synset.category.name
    end
    
  end
  
end