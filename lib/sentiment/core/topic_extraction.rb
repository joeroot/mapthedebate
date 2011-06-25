class TopicExtraction
  include Singleton
  
  def initialize params={}
    @tagger = TweetTagger.new
    @statuses = params[:statuses] || Status::Status.where(:trained_status.ne => nil)
    @statuses = @statuses.select{|s| s.trained_status and !s.trained_status.subject.empty? }
    @statuses.each do |status|
      status.trained_status.subject.split(", ").each do |phrase|
         puts "#{phrase} #{self.extract_pattern phrase, status.parts_of_speech}"
      end
    end
  end
  
  def extract_pattern phrase, parts
    phrase_parts = @tagger.clean_text phrase
    status_parts = parts.each_cons(phrase_parts.length).to_a
    patterns = []
    status_parts.each_index do |i| 
      part = status_parts[i]
      if part.map{|p| p["word"]} == phrase_parts
        pattern = []
        pattern << i>0 ? status_parts[i-1][-1]["tag"] : nil
        pattern += part.map{|p| p["tag"]}
        pattern << i<status_parts.length-1 ? status_parts[i+1][0]["tag"] : nil
        patterns << pattern
      end
    end
    return patterns
  end
  
  def self.extract status
    topics = status.parts_of_speech.select{|pos| TweetTagger.general(pos["tag"]) == "noun"}
    topics = topics.reject{|pos| pos["meta"]["mention"]}
  end
end