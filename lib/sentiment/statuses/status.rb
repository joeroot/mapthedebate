require 'mongo_mapper'
require "#{File.dirname(__FILE__)}/classified_status.rb"
require "#{File.dirname(__FILE__)}/trained_status.rb"

module Status
  class Status
    include MongoMapper::Document

    # Keys
    key :text, String           # textual content of status
    key :source, String         # source of status, e.g. "twitter"
    key :posted_at, String      # time/date the status was posted to micro-blog
    key :part_of_speech, Array  # an array of the status' part of speech tags
    timestamps!
  
    # Relationships
    key :classified_status, ClassifiedStatus    # class containing classification data
    key :trained_status, TrainedStatus          # class containing training data
  
    # Validations
    validates_presence_of :text

    def hashtags
      self.text.scan(/\B#\w*[a-zA-Z]+\w*/)
    end

    def urls
      self.text.scan(/(?:http|https):\/\/[a-z0-9]+(?:[\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(?:(?::[0-9]{1,5})?\/[^\s]*)?/ix)
    end
  
    def is_classified?
      not self.classified_status.nil?
    end
  
    def is_trained?
      not self.trained_status.nil?
    end

    def pos
      if self.part_of_speech.nil? or self.part_of_speech.empty?
        self.part_of_speech = Tagger::PartOfSpeech.tag self.text
        self.save
      end
      return self.part_of_speech
    end

  end
end