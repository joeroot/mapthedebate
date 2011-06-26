require 'mongo_mapper'

module Status
  class ClassifiedStatus
    include MongoMapper::EmbeddedDocument

    # Keys
    key :subjectivity, String, :default => 'u'  # takes values "u", "t", "f", "b"
    key :polarity, String, :default => 'u'    # takes values "u", "+", "-", "0"
    key :emotion, Array, :default => []     # takes array of strings

  end
end