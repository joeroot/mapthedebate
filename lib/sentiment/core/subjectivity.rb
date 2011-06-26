require "ai4r"
require "#{File.dirname(__FILE__)}/classifier.rb"
require "#{File.dirname(__FILE__)}/clue_finder.rb"
require "#{File.dirname(__FILE__)}/tweet_tagger.rb"

include Ai4r::Classifiers
include Ai4r::Data

class SubjectivityClassifier < Classifier

  DEFAULT_OUTPUT = :subjective
  DEFAULT_FEATURES = [
    :has_adjectives?, 
    :has_urls?, 
    :has_strong_clues?, 
    :has_weak_clues?, 
    :matches_subjective_patterns?,
    :capitalised_words_frequency
  ]
  
  def initialize params = {}  
    features = params[:features] || DEFAULT_FEATURES
    super DEFAULT_OUTPUT, features, params
  end
  
  # TESTS
  
  def self.test k, params={}
    Classifier.test k, self, DEFAULT_OUTPUT, params
  end
  
  def self.repeat_test k, r, params={}
    Classifier.repeat_test k, r, self, DEFAULT_OUTPUT, params
  end
  
  # FEATURES
  
  def has_adjectives? status
    return !status.adjectives.empty? ? 1 : 0
  end
  
  def no_adjectives status
    no = status.adjectives.length
    return 0 if no == 0
    return 1 if no < 3
    return 2
  end
  
  def has_urls? status
    return !status.urls.empty? ? 1 : 0
  end
  
  def no_urls status
    no = status.urls.length
    return 0 if no == 0
    return 1 if no < 3
    return 2
  end
  
  def has_mentions? status
    return !status.mentions.empty? ? 1 : 0
  end
  
  def no_mentions status
    no = status.mentions.length
    return 0 if no == 0
    return 1 if no < 3
    return 2
  end
  
  def no_clues status
    no = status.clues.length
    return 0 if no == 0
    return 1 if no < 3
    return 2
  end
  
  def no_strong_clues status
    no = status.strong_subjective_clues.length
    return 0 if no == 0
    return 1 if no < 3
    return 2
  end
  
  def no_weak_clues status
    no = status.weak_subjective_clues.length
    return 0 if no == 0
    return 1 if no < 3
    return 2
  end
  
  def has_clues? status
    return no_clues(status) > 0 ? 1 : 0
  end
  
  def has_strong_clues? status
    return no_strong_clues(status) > 0 ? 1 : 0
  end
  
  def has_weak_clues? status
    return no_weak_clues(status) > 0 ? 1 : 0
  end
  
  def matches_subjective_patterns? status
    return !status.patterns.empty? ? 1 : 0
  end
  
  def capitalised_words_frequency status
    pos = status.parts_of_speech
    caps = pos.select{|p| p["word"][0] =~ /[A-Z]/}
    ratio = caps.length.to_f/pos.length.to_f
    grade = case ratio
      when 0...0.4 then 0
      when 0.4...0.6 then 1
      else 2 
    end
  end
  
  def capitalised_letters_frequency status
    letters = status.parts_of_speech.map{|p| p["word"].split("")}.sum
    caps = letters.select{|l| l =~ /[A-Z]/}
    ratio = caps.length.to_f/letters.length.to_f
    grade = case ratio
      when 0...0.3 then 0
      when 0.3...0.6 then 1
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