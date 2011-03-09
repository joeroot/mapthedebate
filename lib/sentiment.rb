require "mongo_mapper"
MongoMapper.database = "sentiment"  

LIB_DIR = File.dirname(__FILE__)
DB_DIR = "#{LIB_DIR}/../db"

require_relative "#{LIB_DIR}/wordnet.rb"

# Sentiment code
require_relative "#{LIB_DIR}/sentiment/classifiers/classified_status.rb"
require_relative "#{LIB_DIR}/sentiment/classifiers/sentiment_classifier.rb"
require_relative "#{LIB_DIR}/sentiment/classifiers/subjectivity_classifier.rb"

# Tagger code
require_relative "#{LIB_DIR}/sentiment/taggers/part_of_speech.rb"
require_relative "#{LIB_DIR}/sentiment/taggers/name_tagger.rb"
Tagger::NameTagger.load_names


# Twitter API code
require_relative "#{LIB_DIR}/sentiment/twitter/twitter_status.rb"
require_relative "#{LIB_DIR}/sentiment/twitter/twitter_user.rb"
require_relative "#{LIB_DIR}/sentiment/twitter/twitter_search.rb"

