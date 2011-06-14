require "ai4r"
require "#{File.dirname(__FILE__)}/classifier.rb"
require "#{File.dirname(__FILE__)}/tests.rb"
require "#{File.dirname(__FILE__)}/clue_finder.rb"
require "#{File.dirname(__FILE__)}/tweet_tagger.rb"

include Ai4r::Classifiers
include Ai4r::Data

module Classifier
  class Subjectivity
  
    DEFAULT_OUTPUT = :subjective
    DEFAULT_FEATURES = [
      :has_adjectives?, 
      :has_urls?, 
      :has_strong_clues?, 
      :has_weak_clues?, 
      :capitalised_words_frequency
    ]
    
    extend Classifier::Tests
    def self.default_output; DEFAULT_OUTPUT end
    def self.default_features; DEFAULT_FEATURES end
  
    attr_accessor :classifier, :statuses, :output, :features
    
    def classify status
      data = self.parse_status status
      return self.classifier.eval(data)
    end
    
    def initialize params = {}   
      self.output = params[:output] || DEFAULT_OUTPUT
      self.features = params[:features] || DEFAULT_FEATURES
      
      ss = params[:statuses] || Status::Status.where(:trained_status.ne => nil)
      statuses = {}
      ss.each{|s|
        l = s.trained_status.subjective
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
      labels = (self.features + [self.output]).map{|f| f.to_s}
      items = self.parse_statuses statuses
      DataSet.new ({:data_labels => labels, :data_items => items})
    end
  
    def parse_statuses statuses
      return statuses.map{ |s| self.parse_status(s, true) }
    end
  
    def parse_status status, classified=false
      data = []
      self.features.each do |feature|
        data << self.send(feature.to_sym, status).to_s
      end
      data << status.trained_status.send(self.output.to_sym).to_s if classified
      return data
    end
    
    # FEATURES
    
    def has_adjectives? status
      return !status.adjectives.empty?
    end
    
    def has_urls? status
      return !status.urls.empty?
    end
    
    def has_mentions? status
      return !status.mentions.empty?
    end
    
    def no_strong_clues status
      status.strong_subjective_clues.length
    end
    
    def no_weak_clues status
      status.weak_subjective_clues.length
    end
    
    def has_strong_clues? status
      return no_strong_clues(status) > 0
    end
    
    def has_weak_clues? status
      return no_weak_clues(status) > 0
    end
    
    def capitalised_words_frequency status
      pos = status.parts_of_speech
      caps = pos.select{|p| p["word"][0] =~ /[A-Z]/}
      ratio = caps.length.to_f/pos.length.to_f
      grade = case ratio
        when 0...0.3 then 0
        when 0.3...0.5 then 1
        else 2 
      end
    end
    
    # potential features
    # def self.status_words_with_sentiment status
    # def self.status_hashtags_with_sentiment status
    # def self.status_cognition_verbs status
    # w["pos"].include? "pos" => "v", "detailed" => "verb.emotion" or 
    # w["pos"].include? "pos" => "n", "detailed" => "noun.feeling"
    # w["pos"].include? "pos" => "v", "detailed" => "verb.cognition"
    
    
  end
end