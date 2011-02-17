require 'mongo_mapper'

class TwitterStatus
  include MongoMapper::Document
  
  key :id, String
  key :text, String
  key :created_at, Time
  
  belongs_to :twitter_user
  
  validates_presence_of key :id
  validates_presence_of key :text
  validates_presence_of key :created_at
  
end
