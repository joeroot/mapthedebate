require 'mongo_mapper'

class ClassifiedStatus
  include MongoMapper::Document
  
  key :text, String           # textual content of status
  key :source, String         # source of status, e.g. "twitter"
  key :created_at, String     # time/date the status was posted to micro-blog
  key :logged_at, String      # time/date the status was logged to mongo
  key :subjective, String     # takes values "u", "t", "f"
  key :polarity, String       # takes values "u", "+", "-", "0"
  key :sentiment, Array       # takes array of strings
  key :part_of_speech, Array  # an array of the status' part of speech tags
  
  def hashtags
    self.text.scan(/\B#\w*[a-zA-Z]+\w*/)
  end
  
  def urls
    self.text.scan(/(?:http|https):\/\/[a-z0-9]+(?:[\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(?:(?::[0-9]{1,5})?\/[^\s]*)?/ix)
  end
  
  def pos
    if self.part_of_speech.nil? or self.part_of_speech.empty?
      self.part_of_speech = Tagger::PartOfSpeech.tag self.text
      self.save
    end
    return self.part_of_speech
  end
  
  def self.fetch_from_twitter(q, params={})
    ts = TwitterSearch.scrape(q, params)  
    ts.map! do |t|
      t["source_id"] = t["id"]
      t.delete("id")
      t["source"] = "twitter"
      t["subjective"] = nil
      t["polarity"] = nil
      t["sentiment"] = []
      t["created_at"] = Time.parse t["created_at"]
      t["logged_at"] = Time.now
      c = ClassifiedStatus.create t
    end
    return ts
  end
  
end