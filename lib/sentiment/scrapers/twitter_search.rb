require 'open-uri'
require 'time'

module Scraper
  class TwitterSearch
  
    TWITTER_SEARCH_URL = "http://search.twitter.com/search.json" 
  
    def self.scrape(q, params={})
      results = self.search(q, params)
      results.map! do |t|
        t["source"] = "twitter_stream"
        t["source_id"] = t["id"]
        t.delete("id")
        t["posted_at"] = Time.parse t["created_at"]
        t.delete("created_at")
        s = Status::Status.create t
      end
    end
  
    def self.search(q, params={})
      params["rpp"] = params["rpp"] || 40
      params["rpp"] = (params["rpp"] > 100) ? 100 : params["rpp"]
      url = "#{TWITTER_SEARCH_URL}?q=#{q.gsub(' ','+')}&result_type=mixed&lang=en"
      params.each {|k,v| url = url + "&#{k}=#{v}"}
      rs = self.retrieve(url)
      puts "#{url} #{rs["results"]}"
      rs["results"].reject!{|r| r["text"].include? "RT"}[0..10]
      # keep = ["id", "text", "created_at"]
      # rs["results"].each{|r| r.reject! {|k,v| not keep.include? k}}
      return rs["results"]
    end

    def self.retrieve(url)
      begin 
        resp = open(url).read
      rescue OpenURI::HTTPError => error
        puts error
        return {}
      end
      return JSON.parse(resp)
    end
  
  end
end