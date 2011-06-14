require "mongo_mapper" 
MongoMapper.database = "mtd"

SENTIMENT_LIB_DIR = "#{File.dirname(__FILE__)}/sentiment"
SENTIMENT_DB_DIR = "#{File.dirname(__FILE__)}/../db"

require "#{File.dirname(__FILE__)}/wordnet.rb"

# Tagger code
require "#{SENTIMENT_LIB_DIR}/core/tweet_tagger.rb"
require "#{SENTIMENT_LIB_DIR}/core/clue_finder.rb"

# Status code
require "#{SENTIMENT_LIB_DIR}/statuses/status.rb"
require "#{SENTIMENT_LIB_DIR}/statuses/classified_status.rb"
require "#{SENTIMENT_LIB_DIR}/statuses/trained_status.rb"

# Sentiment code
require "#{SENTIMENT_LIB_DIR}/core/subjectivity.rb"
require "#{SENTIMENT_LIB_DIR}/core/polarity.rb"
require "#{SENTIMENT_LIB_DIR}/core/tests.rb"
require "#{SENTIMENT_LIB_DIR}/core/classifier.rb"

# Search code
require "#{SENTIMENT_LIB_DIR}/scrapers/twitter_search.rb"