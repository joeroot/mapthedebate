require 'active_record'
require 'composite_primary_keys'

module WordNet
  
  class SemanticLink < ActiveRecord::Base

    # Link types = [1, 2, 3, 4, 11, 12, 13, 14, 15, 16, 21, 23, 40, 50, 60, 70, 91, 92, 93, 94, 95, 96]

    set_primary_keys :synset_from_id, :synset_to_id

    def synset_from
      Synset.find_by_id self.synset_from_id
    end
    
    def synset_to
      Synset.find_by_id self.synset_to_id
    end
    
  end
  
end