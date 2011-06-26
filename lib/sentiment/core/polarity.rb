require "ai4r"
require "#{File.dirname(__FILE__)}/classifier.rb"
require "#{File.dirname(__FILE__)}/clue_finder.rb"
require "#{File.dirname(__FILE__)}/tweet_tagger.rb"

include Ai4r::Classifiers
include Ai4r::Data

class PolarityClassifier < Classifier

  DEFAULT_OUTPUT = :polarity
  DEFAULT_FEATURES = [
    :unigrams,
    :has_positive_clues?,
    :has_negative_clues?,
    # :has_weak_positive_clues?,
    # :has_weak_negative_clues?,
    :has_strong_positive_clues?,
    :has_strong_negative_clues?,
    # :no_positive_clues,
    # :no_negative_clues,
    # :no_weak_positive_clues,
    # :no_weak_negative_clues,
    :no_strong_positive_clues,
    :no_strong_negative_clues,
    :has_positive_patterns?,
    :has_negative_patterns?
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
  
  def has_positive_clues? status
    !status.positive_clues.empty? ? 1 : 0
  end
  
  def has_negative_clues? status
    !status.negative_clues.empty? ? 1 : 0
  end
  
  def has_weak_positive_clues? status
    !status.weak_positive_clues.empty? ? 1 : 0
  end
  
  def has_weak_negative_clues? status
    !status.weak_negative_clues.empty? ? 1 : 0
  end
  
  def has_strong_positive_clues? status
    !status.strong_positive_clues.empty? ? 1 : 0
  end
  
  def has_strong_negative_clues? status
    !status.strong_negative_clues.empty? ? 1 : 0
  end
  
  def no_positive_clues status
    status.positive_clues.length
  end
  
  def no_negative_clues status
    status.negative_clues.length
  end
  
  def no_weak_positive_clues status
    status.weak_positive_clues.length
  end
  
  def no_weak_negative_clues status
    status.weak_negative_clues.length
  end
  
  def no_strong_positive_clues status
    status.strong_positive_clues.length
  end
  
  def no_strong_negative_clues status
    status.strong_negative_clues.length
  end

  def has_positive_patterns? status
    !status.patterns_with_positive_clues.empty? ? 1 : 0
  end
  
  def has_negative_patterns? status
    !status.patterns_with_negative_clues.empty? ? 1 : 0
  end
  
end
