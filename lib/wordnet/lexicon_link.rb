require 'active_record'
require 'composite_primary_keys'

module WordNet
  
  class LexiconLink < ActiveRecord::Base

    # Link types = [30, 50, 70, 71, 80, 81, 91, 92, 93, 94, 95, 96]

    set_primary_keys :word_from_id, :synset_from_id, :word_to_id, :synset_to_id
    
    def word_from
      Word.find_by_id self.word_from_id
    end
    
    def word_to
      Word.find_by_id self.word_to_id
    end
    
    def sense_from
      Sense.find_by_id([self.word_from_id, self.synset_from_id])
    end
    
    def sense_to
      Sense.find_by_id([self.word_to_id, self.synset_to_id])
    end
    
  end
  
end