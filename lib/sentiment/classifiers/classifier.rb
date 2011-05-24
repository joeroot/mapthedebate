module Classifier
  
  def self.repeat_test ratio, repeats, type
    accuracy = {:true => 0, :false => 0}
    (1..repeats).each do |i|
      r = Classifier.subjectvity_test ratio, type
      accuracy[:true] += r[:true]
      accuracy[:false] += r[:false]
    
      puts "#{i} #{r}"
    end
    accuracy[:true] = accuracy[:true]/repeats
    accuracy[:false] = accuracy[:false]/repeats 
    return accuracy
  end

  def self.subjectvity_test ratio, type
    ts = Status::ClassifiedStatus.all(:subjective => "t").shuffle
    fs = Status::ClassifiedStatus.all(:subjective => "f").shuffle
  
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
  
      s = Classifier::SubjectivityClassifier.new (ts[0...index]+fs[0...index]), type

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