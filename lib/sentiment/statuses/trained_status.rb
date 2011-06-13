require 'mongo_mapper'

module Status
  class TrainedStatus
    include MongoMapper::EmbeddedDocument

    # Keys
    key :subjective, String             # u="unclassified", t="true", f="false", b="both", s="spam"
    key :polarity, String               # takes values "u", "pos", "neg", "neu", "both"
    key :sentiment, Array               # takes array of strings
    key :subject, String
    key :positive_phrases, Array
    key :negative_phrases, Array
    key :sentiment_phrases, Array
  end
end