require "#{File.dirname(__FILE__)}/polarity.rb"
require "#{File.dirname(__FILE__)}/subjectivity.rb"

module Classifier
  class Core
    
    include Singleton
    
    attr_reader :subjectivity, :polarity
    
    def initialize
      @subjectivity = Classifier::Subjectivity.new
      @polarity = Classifier::Polarity.new
    end
  
    def self.classify status
      subjective = self.instance.subjectivity.classify(status) == "t"
      polarity = "neu"
      polarity = self.instance.polarity.classify(status) if subjective
      return {:subjective => subjective, :polarity => polarity}
    end  
  end
end