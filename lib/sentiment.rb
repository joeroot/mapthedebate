require 'mongo_mapper'
MongoMapper.database = "sentiment"  

require_relative 'wordnet.rb'

# Sentiment code
require_relative 'sentiment/classifiers/classified_status.rb'
require_relative 'sentiment/classifiers/sentiment_classifier.rb'
require_relative 'sentiment/classifiers/subjectivity_classifier.rb'

# Tagger code
require_relative 'sentiment/taggers/part_of_speech.rb'
require_relative 'sentiment/taggers/name_tagger.rb'
Tagger::NameTagger.load_names


# Twitter API code
require_relative 'sentiment/twitter/twitter_status.rb'
require_relative 'sentiment/twitter/twitter_user.rb'
require_relative 'sentiment/twitter/twitter_search.rb'

