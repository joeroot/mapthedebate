require 'ai4r'

include Ai4r::Classifiers
include Ai4r::Data

class SubjectivityClassifier
  
  # FEATURES:
  #  status_hashtags_with_sentiment: 
  #  status_cognition_verbs: 
  #  status_urls: 
  #  status_adjectives: 
  
  attr_accessor :classifier
  
  def initialize statuses
    data = SubjectivityClassifier.build_training_set statuses
    self.classifier = NaiveBayes.new.set_parameters({:m=>3}).build data
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
  
  def self.repeat_test r1, n, repeats
    accuracy = {:true => 0, :false => 0}
    (1..repeats).each do |i|
      r = SubjectivityClassifier.test r1, n
      accuracy[:true] += r[:true]
      accuracy[:false] += r[:false]
    end
    accuracy[:true] = accuracy[:true]/repeats
    accuracy[:false] = accuracy[:false]/repeats 
    return accuracy
  end
  
  
  def self.test r1, n=10
    ts = ClassifiedStatus.all(:subjective => "t")
    fs = ClassifiedStatus.all(:subjective => "f")
    
    max = ts.length > fs.length ? fs.length : ts.length
    
    ts = ts.sample(max)
    fs = fs.sample(max)
    
    ts_acc = 0
    fs_acc = 0
    (1..n).each do |i|
        
      ts_index = (ts.length * r1).ceil
      fs_index = (fs.length * r1).ceil
      
      ts.rotate! ((ts.length.to_f/i.to_f).ceil)
      fs.rotate! ((ts.length.to_f/i.to_f).ceil)
    
      s = SubjectivityClassifier.new (ts[0...ts_index] + fs[0..fs_index])
    
      # puts "TESTING SUBJECTIVE CASES"
      ts_classified = ts[ts_index..-1].map{ |t| s.classify t } 
      ts_classified.each do |t|
        correct = t[0] == "t" ? "pass" : "fail"
        # puts "#{correct}: #{t[1]}"
      end
      accuracy = ts_classified.select{|t| t[0] == "t"}.length.to_f/ts_classified.length.to_f
      # puts "ACCURACY: #{accuracy}\n"
      ts_acc += accuracy
    
      # puts "TESTING OBJECTIVE CASES"
      fs_classified = fs[fs_index..-1].map{ |t| s.classify t } 
      fs_classified.each do |t|
        correct = t[0] == "f" ? "pass" : "fail"
        # puts "#{correct}: #{t[1]}"
      end
      accuracy = fs_classified.select{|t| t[0] == "f"}.length.to_f/fs_classified.length.to_f
      # puts "ACCURACY: #{accuracy}\n"
      fs_acc += accuracy
      
    end
    
    return {:true => ts_acc.to_f/n.to_f, :false => fs_acc.to_f/n.to_f}
  end
  
  
end