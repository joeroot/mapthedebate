require 'ai4r'

include Ai4r::Classifiers
include Ai4r::Data

class SubjectivityClassifier

  # Current accuracy on 1000 runs: 
  #  {:true=>0.7028299999999995, :false=>0.7452800000000012}
  
  # FEATURES:
  #  status_hashtags_with_sentiment: 
  #  status_cognition_verbs: 
  #  status_urls: 
  #  status_adjectives: 
  
  attr_accessor :classifier, :type
  
  def initialize statuses, type
    self.type = type
    data = SubjectivityClassifier.build_training_set statuses 
    if type == "NB"
      self.classifier = NaiveBayes.new.set_parameters({:m=>3}).build data
    elsif type == "SVM"
      
    end
  end
  
  def classify status
    data = SubjectivityClassifier.parse_status status
    return [self.classifier.eval(data), self.classifier.get_probability_map(data)]
  end
  
  def self.build_training_set statuses
    labels = ["sentiment", "hashtags", "verbs", "urls", "adjectives", "subjective?"]
    items = SubjectivityClassifier.parse_training_data statuses
    data = DataSet.new ({:data_labels => labels, :data_items => items})
  end
  
  def self.parse_training_data statuses
    data = statuses.map{ |s| SubjectivityClassifier.parse_status s, true }
  end
  
  def self.parse_status status, classified=false
    data = [
      SubjectivityClassifier.status_words_with_sentiment(status),
      SubjectivityClassifier.status_hashtags_with_sentiment(status),
      SubjectivityClassifier.status_cognition_verbs(status),
      SubjectivityClassifier.status_urls(status),
      SubjectivityClassifier.status_adjectives(status)
    ]
    
    data << status.subjective if classified
        
    data
  end
  
  def self.status_hashtags_with_sentiment status
    hs = status.pos.select do |w| 
      w["original"][0] == "#" and 
      (
        w["pos"].include? "pos" => "v", "detailed" => "verb.emotion" or 
        w["pos"].include? "pos" => "n", "detailed" => "noun.feeling"
      )
    end
    
    feature = case hs.length
      when 0 then 0
      when 1 then 1
      else 2 
    end
    
    feature.to_s
  end
  
  def self.status_words_with_sentiment status
    ws = status.pos.select do |w| 
      w["pos"].include? "pos" => "v", "detailed" => "verb.emotion" or 
      w["pos"].include? "pos" => "n", "detailed" => "noun.feeling"
    end
    
    feature = case ws.length
      when 0 then 0
      when 1 then 1
      else 2 
    end
    
    feature.to_s  
  end
  
  def self.status_cognition_verbs status
    vs = status.pos.select{|w| w["pos"].include? "pos" => "v", "detailed" => "verb.cognition" }
    
    feature = case vs.length
      when 0 then 0
      when 1 then 1
      else 2 
    end
    
    feature.to_s
  end
  
  def self.status_urls status
    urls = status.pos.select{|w| w["pos"].include? "pos" => "n", "detailed" => "noun.url" }
    
    feature = case urls.length
      when 0 then 0
      when 1 then 1
      else 2 
    end
    
    feature.to_s
  end
  
  def self.status_adjectives status
    as = status.pos.select{|w| w["pos"].any? {|pos| pos["pos"] == "a"} }
    
    feature = case as.length
      when 0 then 0
      when 1..2 then 1
      else 2 
    end
    
    feature.to_s
  end
  
  def self.status_subjectivity_patterns
    # 1       2         3
    # JJ      NN/NNS
    # RB      JJ        not NN/NNS
    # JJ      JJ        not NN/NNS
    # NN/NNS  JJ        not NN/NNS
    # RB      VB        
    
    patterns = [
      
      
    ]
    
  end
  
  def self.repeat_test ratio, repeats, type
    accuracy = {:true => 0, :false => 0}
    (1..repeats).each do |i|
      r = SubjectivityClassifier.test ratio, type
      accuracy[:true] += r[:true]
      accuracy[:false] += r[:false]
      
      puts "#{i} #{r}"
    end
    accuracy[:true] = accuracy[:true]/repeats
    accuracy[:false] = accuracy[:false]/repeats 
    return accuracy
  end
  
  def self.test ratio, type
    ts = ClassifiedStatus.all(:subjective => "t").shuffle
    fs = ClassifiedStatus.all(:subjective => "f").shuffle
    
    max = ts.length > fs.length ? fs.length : ts.length
    
    ts = ts.sample(max)
    fs = fs.sample(max)
        
    index = (max * ratio).ceil
    
    results = {:true => 0, :false => 0}
    
    n = 10
    offset = max/n
    
    (0...n).each do |i|
    
      ts = ts.rotate offset
      fs = fs.rotate offset
    
      s = SubjectivityClassifier.new (ts[0...index]+fs[0...index]), type
  
      cs = ts[index..-1].map{ |t| s.classify t } 
      results[:true] += cs.select{|t| t[0] == "t"}.length.to_f/cs.length.to_f
    
      cs = fs[index..-1].map{ |f| s.classify f } 
      results[:false] += cs.select{|f| f[0] == "f"}.length.to_f/cs.length.to_f
      
    end
    
    results[:true] /= n
    results[:false] /= n
    
    results
  end
  
  
end