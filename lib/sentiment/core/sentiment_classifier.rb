require "ai4r"
require "#{File.dirname(__FILE__)}/classifier.rb"
require "#{File.dirname(__FILE__)}/clue_finder.rb"
require "#{File.dirname(__FILE__)}/tweet_tagger.rb"

include Ai4r::Classifiers
include Ai4r::Data

module Classifier
  class Polarity
  
    DEFAULT_OUTPUT = :polarity
    DEFAULT_FEATURES = [
      :positive_phrase_count,
      :negative_phrase_count,
      :unigrams
    ]
    
    extend Classifier
  
    attr_accessor :classifier, :statuses, :unigrams, :output, :features
    
    def classify status
      # data = self.parse_unigrams status
      # return self.unigram_classifier.eval(data)
      data = self.parse_status status
      return self.classifier.eval(data)
    end
    
    def initialize params = {}   
      self.output = params[:output] || DEFAULT_OUTPUT
      self.features = params[:features] || DEFAULT_FEATURES
      
      ss = params[:statuses] || Status::Status.where(:trained_status.ne => nil)
      statuses = {}
      ss.each{|s|
        l = s.trained_status.send(self.output.to_sym)
        statuses[l] = (statuses[l] || []) + [s]
      }
      
      max = statuses.values.map{|v| v.length}.min
      statuses.values.map!{|v| v.shuffle.sample(max)}
      
      self.statuses = statuses.values.sum
      self.unigrams = self.build_unigrams(self.statuses) if self.features.include?(:unigrams)
      self.classifier = self.build_classifier self.statuses
    end
    
    def build_unigrams statuses
      statuses.map{|s| s.parts_of_speech}.sum.map{|p| p["word"].downcase}.uniq
    end
    
    def parse_unigrams status
      words = status.parts_of_speech.map{|p| p["word"].downcase}
      self.unigrams.map{|u| words.include?(u).to_s[0]}
    end

    def build_classifier statuses
      training_set = self.build_training_set statuses
      NaiveBayes.new.set_parameters({:m=>3}).build training_set
    end

    def build_training_set statuses
      labels = []
      self.features.each do |f|
        (f != :unigrams) ? (labels << f) : (labels += self.unigrams)
      end
      labels = (labels + [self.output]).map{|f| f.to_s}
      items = self.parse_statuses statuses
      DataSet.new ({:data_labels => labels, :data_items => items})
    end

    def parse_statuses statuses
      return statuses.map{ |s| self.parse_status(s, true) }
    end

    def parse_status status, classified=false
      data = []
      self.features.each do |f|
        (f != :unigrams) ? (data << self.send(f.to_sym, status).to_s) : (data += self.parse_unigrams(status))
      end
      data << status.trained_status.send(self.output.to_sym).to_s if classified
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
