require 'mongo_mapper'

class TwitterUser
  include MongoMapper::Document
  
  key :id, String
  key :name, String
  key :screen_name, String
  key :location, String
  key :description, String
  key :profile_image_url, String
  
  many :twitter_statuses
  
  validates_presence_of :text
end
