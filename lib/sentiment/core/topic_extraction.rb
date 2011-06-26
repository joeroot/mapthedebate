class TopicExtraction
  include Singleton
  
  def initialize params={}
    @tagger = TweetTagger.new
    @statuses = params[:statuses] || Status::Status.where(:trained_status.ne => nil)
    @statuses = @statuses.select{|s| s.trained_status and !s.trained_status.subject.empty? }
    @patterns = []
    @statuses.map do |status|
      status.trained_status.subject.split(", ").each do |phrase|
         @patterns << self.extract_pattern(phrase, status.parts_of_speech)
      end
    end
    @patterns = @patterns.sum.uniq
  end
  
  def patterns
    return @patterns
  end
  
  def extract_pattern phrase, parts
    phrase_parts = @tagger.clean_text phrase
    status_parts = parts.each_cons(phrase_parts.length).to_a
    patterns = []
    status_parts.each_index do |i| 
      part = status_parts[i]
      if part.map{|p| p["word"]} == phrase_parts
        pattern = []
        # (i>0) ? pattern << status_parts[i-1][-1]["tag"] : pattern << nil
        pattern += part.map{|p| p["tag"]}
        # (i<(status_parts.length-1)) ? pattern << status_parts[i+1][0]["tag"] : pattern << nil
        patterns << pattern
      end
    end
    return patterns
  end
  
  def self.extract_topics status 
    n = self.instance.patterns.map{|s| s.length}.max 
    parts = status.parts_of_speech #+ [nil]
    grams = (1..n).map{|i| parts.each_cons(i).to_a} 
    grams = grams.sum
    grams = grams.select do |gram|
      # puts "#{gram.map{|pos| pos ? pos["tag"] : pos}}"
      self.instance.patterns.include? gram.map{|pos| pos ? pos["tag"] : pos}
    end
    # grams = status.parts_of_speech.select{|pos| TweetTagger.general(pos["tag"]) == "noun"} if grams.empty?
    # grams[1..-2].map{|pos| pos ? pos["word"] : pos} 
    # puts "#{grams}"
    grams = grams.reject do |gram| 
      gram.map do |pos| 
        pos["meta"]["mention"]
      end.inject(false){|m,n| m or n}
    end
    grams = grams.reject do |gram|
      gram.map{|pos| pos["word"]}.include? "RT"
    end
    grams.uniq.select do |ts|
      !(grams.map do |zs|
        ((ts & zs).length == ts.length) and (ts.length <= zs.length)
      end.select{|s| s}.length > 1) and (ts.length>1 or ts[0].length>1)
    end
  end
end
