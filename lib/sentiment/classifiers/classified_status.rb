require 'mongo_mapper'

class ClassifiedStatus
  include MongoMapper::Document
  
  key :text, String         # textual content of status
  key :source, String       # source of status, e.g. "twitter"
  key :created_at, String   # time/date the status was posted to micro-blog
  key :logged_at, String    # time/date the status was logged to mongo
  key :subjective, String   # takes values "u", "t", "f"
  
  def self.fetch_from_twitter(q, params={})
    ts = TwitterSearch.scrape(q, params)  
    ts.map! do |t|
      t["source_id"] = t["id"]
      t.delete("id")
      t["source"] = "twitter"
      t["subjective"] = nil
      t["created_at"] = Time.parse t["created_at"]
      t["logged_at"] = Time.now
      c = ClassifiedStatus.create t
    end
    return ts
  end
  
end