require 'mongo_mapper'

module Status
  class TrainedStatus
    include MongoMapper::EmbeddedDocument

    # Keys
    key :subjective, String             # takes values "u", "t", "f", "b"
    key :polarity, String               # takes values "u", "+", "-", "0"
    key :sentiment, Array               # takes array of strings

    # Validations
    validates_presence_of :subjective, :polarity, :sentiment

  end
end