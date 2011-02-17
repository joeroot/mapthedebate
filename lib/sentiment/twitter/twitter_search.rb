require 'open-uri'

class TwitterSearch
  
  TWITTER_SEARCH_URL = "http://search.twitter.com/search.json" 
  
  def self.scrape(q, params={})
    params["rpp"] = params["rpp"] || 20
    params["rpp"] = (params["rpp"] > 100) ? 100 : params["rpp"]
    url = "#{TWITTER_SEARCH_URL}?q=#{q.gsub(' ','+')}&result_type=mixed"
    params.each {|k,v| url = url + "&#{k}=#{v}"}
    rs = self.retrieve(url)
    keep = ["id", "text", "created_at"]
    rs["results"].each{|r| r.reject! {|k,v| not keep.include? k}}
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