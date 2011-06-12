require 'mongo_mapper'
require "#{File.dirname(__FILE__)}/classified_status.rb"
require "#{File.dirname(__FILE__)}/trained_status.rb"
require "#{File.dirname(__FILE__)}/../core/tweet_tagger.rb"

module Status
  class Status
    include MongoMapper::Document
    @@tagger = TweetTagger.new

    # Keys
    key :text, String           # textual content of status
    key :source, String         # source of status, e.g. "twitter"
    key :posted_at, String      # time/date the status was posted to micro-blog
    key :pos_data, Array  # an array of the status' part of speech tags
    timestamps!
  
    # Relationships
    key :classified_status, ClassifiedStatus    # class containing classification data
    key :trained_status, TrainedStatus          # class containing training data
  
    # Validations
    validates_presence_of :text

    # Override setup_modifications in order to initialize part of speech tags
    def parts_of_speech 
      if self.pos_data.nil? or self.pos_data.empty?
         self.pos_data = @@tagger.fetch_tags self.text
         self.save
      end
      return self.pos_data
    end

    def hashtags
      self.parts_of_speech.select{|pos| pos["tag"] == "hsh"}
    end

    def urls
      self.parts_of_speech.select{|pos| pos["tag"] == "url"}
    end
    
    def mentions
      self.parts_of_speech.select{|pos| pos["tag"] == "mntn"}
    end
    
    def adjectives
      self.parts_of_speech.select{|pos| TweetTagger.general(pos["tag"]) == "adj"}
    end
    
    def adverbs
      self.parts_of_speech.select{|pos| TweetTagger.general(pos["tag"]) == "adverb"}
    end
    
    def nouns
      self.parts_of_speech.select{|pos| TweetTagger.general(pos["tag"]) == "noun"}
    end
    
    def verbs
      self.parts_of_speech.select{|pos| TweetTagger.general(pos["tag"]) == "verb"}
    end
  
    def is_classified?
      not self.classified_status.nil?
    end
  
    def is_trained?
      not self.trained_status.nil?
    end
    
    def strong_subjective_clues
      self.parts_of_speech.select{|p| Core::ClueFinder.is_strong_clue? p["word"], p["tag"]}
    end
    
    def weak_subjective_clues
      self.parts_of_speech.select{|p| Core::ClueFinder.is_weak_clue? p["word"], p["tag"]}
    end
    
    def positive_clues
      self.parts_of_speech.select{|p| Core::ClueFinder.is_positive_clue? p["word"], p["tag"]}
    end
    
    def strong_positive_clues
      self.positive_clues.select{|p| Core::ClueFinder.is_strong_clue? p["word"], p["tag"]}
    end
    
    def weak_positive_clues
      self.positive_clues.select{|p| Core::ClueFinder.is_weak_clue? p["word"], p["tag"]}
    end
    
    def negative_clues
      self.parts_of_speech.select{|p| Core::ClueFinder.is_negative_clue? p["word"], p["tag"]}
    end
    
    def strong_negative_clues
      self.negative_clues.select{|p| Core::ClueFinder.is_strong_clue? p["word"], p["tag"]}
    end
    
    def weak_negative_clues
      self.negative_clues.select{|p| Core::ClueFinder.is_weak_clue? p["word"], p["tag"]}
    end
    
  end
end