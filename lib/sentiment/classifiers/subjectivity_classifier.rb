require 'ai4r'

include Ai4r::Classifiers
include Ai4r::Data

class SubjectivityClassifier
  
  attr_accessor :classifier
  
  def initialize
    data = SubjectivityClassifier.build_training_set
    self.classifier = NaiveBayes.new.set_parameters({:m=>3}).build data
  end
  
  def classify status
    data = SubjectivityClassifier.parse_status status
    return [self.classifier.eval(data), self.classifier.get_probability_map(data)]
  end
  
  def self.build_training_set
    ts = ClassifiedStatus.all(:subjective => "t")[0..20]
    fs = ClassifiedStatus.all(:subjective => "f")[0..20]
    labels = ["hashtags", "verbs", "urls", "adjectives", "subjective?"]
    items = SubjectivityClassifier.parse_training_data (ts + fs)
    data = DataSet.new ({:data_labels => labels, :data_items => items})
  end
  
  def self.parse_training_data statuses
    data = statuses.map{ |s| SubjectivityClassifier.parse_status s, true }
  end
  
  def self.parse_status status, classified=false
    data = [
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
      puts w
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
      when 1 then 1
      else 2 
    end
    
    feature.to_s
  end
  
  
  
end