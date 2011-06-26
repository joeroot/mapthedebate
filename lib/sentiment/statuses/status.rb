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
      self.parts_of_speech.select{|pos| pos["meta"]["hash"]}
    end
    
    def hashtag_words
      self.parts_of_speech.select{|pos| pos["meta"]["hash"] and pos["word"] == pos["meta"]["original"]}
    end

    def urls
      self.parts_of_speech.select{|pos| pos["tag"] == "url"}
    end
    
    def mentions
      self.parts_of_speech.select{|pos| pos["meta"]["mention"]}
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
    
    def clues
      self.parts_of_speech.select{|p| Core::ClueFinder.is_clue? p["word"], p["tag"]}
    end
    
    def strong_subjective_clues
      self.parts_of_speech.select{|p| Core::ClueFinder.is_strong_clue? p["word"], p["tag"]}
    end
    
    def weak_subjective_clues
      self.parts_of_speech.select{|p| Core::ClueFinder.is_weak_clue? p["word"], p["tag"]}
    end
    
    def polarised_clues
      polarised = {:positive => [], :negative => []}
      negate = false
      self.parts_of_speech.each do |p|
        negate = !negate if ["not", "n't", "never"].include? p["word"]
        negate = false if ["pp", "ppc"].include? p["tag"]
        positive = Core::ClueFinder.is_positive_clue? p["word"], p["tag"]
        negative = Core::ClueFinder.is_negative_clue? p["word"], p["tag"]
        polarised[:positive] << p if (!negate and positive) or (negate and negative)
        polarised[:negative] << p if (!negate and negative) or (negate and positive)
      end
      return polarised
    end
    
    def positive_clues
      self.polarised_clues[:positive]
    end
    
    def strong_positive_clues
      self.positive_clues.select{|p| Core::ClueFinder.is_strong_clue? p["word"], p["tag"]}
    end
    
    def weak_positive_clues
      self.positive_clues.select{|p| Core::ClueFinder.is_weak_clue? p["word"], p["tag"]}
    end
    
    def negative_clues
      self.polarised_clues[:negative]
    end
    
    def strong_negative_clues
      self.negative_clues.select{|p| Core::ClueFinder.is_strong_clue? p["word"], p["tag"]}
    end
    
    def weak_negative_clues
      self.negative_clues.select{|p| Core::ClueFinder.is_weak_clue? p["word"], p["tag"]}
    end
    
    def patterns
      rules = [
        ["adj", "noun", nil],
        ["adverb", "adj", "noun"],
        ["adj", "adj", "noun"],
        ["noun", "adj", "noun"],
        ["adverb", "verb", nil]
      ]
      
      pos = self.parts_of_speech
      triplets = (pos + [nil]).each_cons(3).to_a    
      
      patterns = triplets.select do |first, second, third|
        rules.map do |rule|
          rule[0] == TweetTagger.general(first["tag"]) and 
          rule[1] == TweetTagger.general(second["tag"]) and 
          (
            !rule[2] or 
            (!third.nil? and rule[2] != TweetTagger.general(third["tag"]))
          )
        end.inject(false){|m,n| m or n}
      end
      
      return patterns
    end
    
    def patterns_with_positive_clues
      positive = self.positive_clues
      self.patterns.select do |s|
        s.map{|w| !w.nil? and positive.include?(w)}.inject(false){|m,n| m or n}
      end
    end
    
    def patterns_with_negative_clues
      negative = self.negative_clues
      self.patterns.select do |s|
        s.map{|w| !w.nil? and negative.include?(w)}.inject(false){|m,n| m or n}
      end
    end
    
  end
end