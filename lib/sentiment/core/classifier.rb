require 'SVM'
require "ai4r"
require "#{File.dirname(__FILE__)}/clue_finder.rb"
require "#{File.dirname(__FILE__)}/tweet_tagger.rb"

# include SVM
include Ai4r::Classifiers
include Ai4r::Data

class Classifier

  attr_accessor :classifier, :classifier_type, :statuses, :unigrams, :output, :features
  
  def classify status
    data = self.parse_status status
    
    if self.classifier_type == "NB"
      result = self.classifier.eval(data).to_i
    else
      result = self.classifier.predict(data)
    end  
    return self.statuses.keys[result]
  end
  
  def initialize output, features, params = {}   
    self.output = output
    self.features = features
    
    ss = params[:statuses] || Status::Status.where(:trained_status.ne => nil)
    ss = ss.select{|s| ["t", "f"].include? s.trained_status.subjective}
    ss = ss.select{|s| ["pos", "neg"].include? s.trained_status.polarity} if output == :polarity
    statuses = {}
    ss.each{|s|
      l = s.trained_status.send(self.output.to_sym)
      statuses[l] = (statuses[l] || []) + [s]
    }
    
    # max = statuses.values.map{|v| v.length}.min
    # statuses.values.map!{|v| v.shuffle.sample(max)}
    statuses.values.map!{|v| v.shuffle}
    
    self.statuses = statuses
    self.unigrams = self.build_unigrams(self.statuses.values.sum) if self.features.include?(:unigrams)
    self.classifier_type = params[:classifier_type] || "SVM"
    self.classifier = self.build_classifier self.statuses.values.sum
  end
  
  def build_classifier statuses
    if self.classifier_type == "NB"
      return self.build_naive_bayes_classifier statuses
    else 
      return self.build_svm_classifier statuses
    end
  end
  
  def build_naive_bayes_classifier statuses
    training_set = self.build_training_set statuses
    training_set = DataSet.new ({
      :data_labels => training_set[:labels],
      :data_items => training_set[:items]
    })
    NaiveBayes.new.set_parameters({:m=>3}).build training_set
  end
  
  def build_svm_classifier statuses
    kernels = [ LINEAR, POLY, RBF, SIGMOID ]
    kernel_names = [ 'Linear', 'Polynomial', 'Radial basis function', 'Sigmoid' ]
    
    pa = Parameter.new
    pa.C = 100
    pa.svm_type = NU_SVC
    pa.degree = 1
    pa.coef0 = 0
    pa.eps= 0.001
    pa.kernel_type = kernels[3]
    
    ls = self.build_labels statuses
    fs = self.build_feature_sets statuses
    # (fs.zip ls).each{|j| puts "#{j}" if j[0][0] > 0}
    sp = Problem.new ls, fs
    
    return Model.new(sp, pa)
  end

  def build_feature_sets statuses
    return statuses.map{ |s| self.parse_status(s) }
  end
  
  def build_labels statuses
    return statuses.map{ |s| self.parse_status_label(s) }
  end

  def build_training_set statuses
    labels = []
    self.features.each do |f|
      (f != :unigrams) ? (labels << f) : (labels += self.unigrams)
    end
    labels = (labels + [self.output]).map{|f| f.to_s}
    items = self.parse_statuses(statuses)
    {:labels => labels, :items => items}
  end

  def parse_statuses statuses
    return statuses.map{ |s| self.parse_status(s, true) }
  end

  def parse_status status, classified=false
    data = []
    self.features.each do |f|
      (f != :unigrams) ? (data << self.send(f.to_sym, status)) : (data += self.parse_unigrams(status))
    end
    data << self.parse_status_label(status) if classified
    data.map!{|d| d.to_s} if self.classifier_type == "NB"
    return data
  end
  
  def parse_status_label status
    lbl = status.trained_status.send(self.output.to_sym) 
    return self.statuses.keys.index(lbl)
  end
  
  def build_unigrams statuses
    statuses.map{|s| s.parts_of_speech}.sum.map{|p| p["word"].downcase}.uniq
  end
  
  def parse_unigrams status
    words = status.parts_of_speech.map{|p| p["word"].downcase}
    self.unigrams.map{|u| words.include?(u) ? 1 : 0}
  end
  
  
  # TESTING METHODS
  
  def self.repeat_test k, r, cls, output, params={}
    results = {
      :accuracy => 0,
      :min_accuracy => 100,
      :max_accuracy => 0,
      :partition => 0
    }
  
    (0...r).each do |i|
      test = self.test k, cls, output, params
      labels = test.keys - [:accuracy, :partition]        
      labels.each {|l| results[l] = {
        :precision => 0,
        :max_precision => 0,
        :min_precision => 100,
        :recall => 0, 
        :max_recall => 0,
        :min_recall => 100,
        :fmeasure => 0,
        :max_fmeasure => 0,
        :min_fmeasure => 100
      }} if i==0
    
      labels.each do |l|
        results[l][:precision] += test[l][:precision].to_f/r.to_f * 100
        results[l][:min_precision] = test[l][:precision] * 100 if test[l][:precision] * 100 < results[l][:min_precision]
        results[l][:max_precision] = test[l][:precision] * 100 if test[l][:precision] * 100 > results[l][:max_precision]
        results[l][:recall] += test[l][:recall].to_f/r.to_f * 100
        results[l][:min_recall] = test[l][:recall] * 100 if test[l][:recall] * 100 < results[l][:min_recall]
        results[l][:max_recall] = test[l][:recall] * 100 if test[l][:recall] * 100 > results[l][:max_recall]
        results[l][:fmeasure] += test[l][:fmeasure].to_f/r.to_f * 100
        results[l][:min_fmeasure] = test[l][:fmeasure] * 100 if test[l][:fmeasure] * 100 < results[l][:min_fmeasure]
        results[l][:max_fmeasure] = test[l][:fmeasure] * 100 if test[l][:fmeasure] * 100 > results[l][:max_fmeasure]
      end
    
      results[:min_accuracy] = test[:accuracy] * 100 if test[:accuracy] * 100 < results[:min_accuracy]
      results[:max_accuracy] = test[:accuracy] * 100 if test[:accuracy] * 100 > results[:max_accuracy]
      results[:accuracy] += test[:accuracy].to_f/r.to_f * 100
      results[:partition] = test[:partition]
    end
  
    return results
  end
    
  def self.test k, cls, output, params={}
    ss = Status::Status.where(:trained_status.ne => nil)
    statuses = {}
    ss.select{|s| s.trained_status.polarity != "neu"}.each{|s|
      l = s.trained_status.send(output.to_sym)
      statuses[l] = (statuses[l] || []) + [s] if l != "both" and l != "u"
    }      
    labels = statuses.keys
  
    ratio = 1.to_f / k.to_f
    
    max = statuses.values.map{|v| v.length}.min
    partition = ratio * max
  
    statuses.each{|l,v| statuses[l] = v.shuffle.sample(max)}
  
    results = {
      :accuracy => 0,
      :partition => partition
    }
  
    labels.each do |l|
      results[l] = {}
      results[l][:precision] = 0
      results[l][:recall] = 0
      results[l][:fmeasure] = 0
    end
  
    (0...k).each do |i|
      statuses.values.each{|v| v.rotate! partition}
    
      training = {}
      statuses.each{|l,v| training[l] = v[0...(k-1)*partition]}
    
      testing = {}
      statuses.each{|l,v| testing[l] = v[(k-1)*partition...max]}

      c = cls.new (params.merge({:statuses => training.values.sum}))
    
      classified = {}
      testing.each{|l,v| classified[l] = v.map{|s| c.classify s}}
    
      correct = {}
      classified.each{|l,v| correct[l] = v.select{|c| c == l}.length}
    
      classified.each do |l,v|
        precision = correct[l].to_f / (classified.values.sum.length - (correct.values.sum - correct[l])).to_f
        recall = correct[l].to_f / classified[l].length.to_f
        fmeasure = 2 * (precision * recall)/(precision + recall)
        results[l][:precision] += precision/k.to_f
        results[l][:recall] += recall/k.to_f
        results[l][:fmeasure] += fmeasure/k.to_f
      end
      # puts "#{correct}"
      results[:accuracy] += (correct.values.sum.to_f/classified.values.sum.length.to_f)/k.to_f 
    end
    
    # puts "-----"
  
    return results
  end
  
  
end