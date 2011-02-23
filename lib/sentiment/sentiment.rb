require 'mongo_mapper'

MongoMapper.database = "sentiment"  

# Sentiment code
require_relative 'classifiers/classified_status.rb'
require_relative 'classifiers/sentiment_classifier.rb'
require_relative 'classifiers/subjectivity_classifier.rb'

# Twitter API code
require_relative 'twitter/twitter_status.rb'
require_relative 'twitter/twitter_user.rb'
require_relative 'twitter/twitter_search.rb'