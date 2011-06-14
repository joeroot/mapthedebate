module Classifier
  module Tests
    def repeat_test k, r
      results = {
        :accuracy => 0
      }
    
      (0...r).each do |i|
        test = self.test k
        labels = test.keys - [:accuracy]        
        labels.each {|l| results[l] = {:precision => 0, :recall => 0, :fmeasure => 0}} if i==0
      
        labels.each do |l|
          results[l][:precision] += test[l][:precision].to_f/r.to_f
          results[l][:recall] += test[l][:recall].to_f/r.to_f
          results[l][:fmeasure] += test[l][:fmeasure].to_f/r.to_f
        end
      
        results[:accuracy] += test[:accuracy].to_f/r.to_f
      end
    
      return results
    end
  
    def test k
      ss = Status::Status.where(:trained_status.ne => nil)
      statuses = {}
      ss.select{|s| s.trained_status.polarity != "neu"}.each{|s|
        l = s.trained_status.send(self.default_output.to_sym)
        statuses[l] = (statuses[l] || []) + [s] if l != "both" and l != "u"
      }      
      labels = statuses.keys
    
      ratio = 1.to_f / k.to_f
      max = statuses.values.map{|v| v.length}.min
      partition = ratio * max
    
      statuses.each{|l,v| statuses[l] = v.shuffle.sample(max)}
    
      results = {
        :accuracy => 0
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
      
        c = self.new ({:statuses => training.values.sum})
      
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
      
        results[:accuracy] += (correct.values.sum.to_f/classified.values.sum.length.to_f)/k.to_f 
      end
    
      return results
    end
  end
end