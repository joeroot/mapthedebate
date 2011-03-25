require 'rubygems'

require "mongo_mapper" 
MongoMapper.database = "sentiment"

SENTIMENT_LIB_DIR = "#{File.dirname(__FILE__)}/sentiment"
SENTIMENT_DB_DIR = "#{File.dirname(__FILE__)}/../db"

require "#{File.dirname(__FILE__)}/wordnet.rb"

# Sentiment code
require "#{SENTIMENT_LIB_DIR}/classifiers/classified_status.rb"
require "#{SENTIMENT_LIB_DIR}/classifiers/sentiment_classifier.rb"
require "#{SENTIMENT_LIB_DIR}/classifiers/subjectivity_classifier.rb"

# Tagger code
require "#{SENTIMENT_LIB_DIR}/taggers/part_of_speech.rb"
require "#{SENTIMENT_LIB_DIR}/taggers/name_tagger.rb"


# Twitter API code
require "#{SENTIMENT_LIB_DIR}/twitter/twitter_status.rb"
require "#{SENTIMENT_LIB_DIR}/twitter/twitter_user.rb"
require "#{SENTIMENT_LIB_DIR}/twitter/twitter_search.rb"


