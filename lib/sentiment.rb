require "mongo_mapper" 
MongoMapper.database = "mtd"

SENTIMENT_LIB_DIR = "#{File.dirname(__FILE__)}/sentiment"
SENTIMENT_DB_DIR = "#{File.dirname(__FILE__)}/../db"

require "#{File.dirname(__FILE__)}/wordnet.rb"

# Status code
require "#{SENTIMENT_LIB_DIR}/statuses/status.rb"
require "#{SENTIMENT_LIB_DIR}/statuses/classified_status.rb"
require "#{SENTIMENT_LIB_DIR}/statuses/trained_status.rb"

# Sentiment code
require "#{SENTIMENT_LIB_DIR}/classifiers/classifier.rb"
require "#{SENTIMENT_LIB_DIR}/classifiers/sentiment_classifier.rb"
require "#{SENTIMENT_LIB_DIR}/classifiers/subjectivity_classifier.rb"

# Tagger code
require "#{SENTIMENT_LIB_DIR}/taggers/tagger.rb"
require "#{SENTIMENT_LIB_DIR}/taggers/part_of_speech.rb"
require "#{SENTIMENT_LIB_DIR}/taggers/name_tagger.rb"


# Scraper code
require "#{SENTIMENT_LIB_DIR}/scrapers/twitter_search.rb"