require "ai4r"
require "#{File.dirname(__FILE__)}/classifier.rb"
require "#{File.dirname(__FILE__)}/clue_finder.rb"
require "#{File.dirname(__FILE__)}/tweet_tagger.rb"

include Ai4r::Classifiers
include Ai4r::Data

module Classifier
  class Polarity
  
    OUTPUT = :polarity
    FEATURES = [
      :positive_phrase_count,
      :positive_phrase_count
    ]
    
    extend Classifier
    def self.output; return OUTPUT end
  
    attr_accessor :classifier, :phrase_subjectivity_classifier, :phrase_polarity_classifier, :statuses, :training_set
    
    def classify status
      data = self.parse_status status
      return self.classifier.eval(data)
    end
    
    def initialize params = {}   
      ss = params[:statuses] || Status::Status.where(:trained_status.ne => nil)
      statuses = {}
      ss.each{|s|
        l = s.trained_status.send(OUTPUT.to_sym)
        statuses[l] = (statuses[l] || []) + [s]
      }
      
      max = statuses.values.map{|v| v.length}.min
      statuses.values.map!{|v| v.shuffle.sample(max)}
      
      self.statuses = statuses.values.sum
      self.classifier = self.build_classifier self.statuses
    end

    def build_classifier statuses
      training_set = self.build_training_set statuses
      NaiveBayes.new.set_parameters({:m=>3}).build training_set
    end

    def build_training_set statuses
      labels = (FEATURES + [OUTPUT]).map{|f| f.to_s}
      items = self.parse_statuses statuses
      DataSet.new ({:data_labels => labels, :data_items => items})
    end

    def parse_statuses statuses
      return statuses.map{ |s| self.parse_status(s, true) }
    end

    def parse_status status, classified=false
      data = []
      FEATURES.each do |feature|
        data << self.send(feature.to_sym, status).to_s
      end
      data << status.trained_status.send(OUTPUT.to_sym).to_s if classified
      return data
    end
    
    # FEATURES
    
    def positive_phrase_count status
      status.positive_clues.length
    end
    
    def negative_phrase_count status
      status.negative_clues.length
    end
    
    def extract_patterns status
      rules = [
        ["adj", "noun", nil],
        ["adverb", "adj", "noun"],
        ["adj", "adj", "noun"],
        ["noun", "adj", "noun"],
        ["adverb", "verb", nil]
      ]
      
      pos = status.parts_of_speech
      
      patterns = []
      
      (0...(pos.length-2)).each do |i|
        first = TweetTagger.general pos[i]["tag"]
        second = TweetTagger.general pos[i+1]["tag"]
        third = TweetTagger.general pos[i+2]["tag"]
        match = rules.map { |rule|
          rule[0] == first and 
          rule[1] == second and 
          ((not rule[2]) or rule[2] != third)
        }.inject(false){|m,n| m or n}
        patterns << i if match
      end
      
      return patterns
    end
    
  end
end
