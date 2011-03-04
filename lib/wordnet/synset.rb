require 'active_record'
require 'composite_primary_keys'

module WordNet
  
  class Synset < ActiveRecord::Base

    has_many :senses
    belongs_to :category
    
    def similar
      links = SemanticLink.find(:all, :conditions => {
        :synset_from_id => self.id,
        :link_id => 40
      })
      links.map{|l| l.synset_to}
    end
    
    # hyponym - more specific sysnsets
    def hyponyms
      links = SemanticLink.find(:all, :conditions => {
        :synset_from_id => self.id,
        :link_id => 2
      })
      links.map{|l| l.synset_to}
    end
    
    # hypernym - more generic synsets
    def hypernyms
      links = SemanticLink.find(:all, :conditions => {
        :synset_from_id => self.id,
        :link_id => 1
      })
      links.map{|l| l.synset_to}
    end
    
  end
  
end