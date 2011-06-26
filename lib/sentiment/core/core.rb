require "#{File.dirname(__FILE__)}/../statuses/classified_status.rb"

class CoreClassifier
  include Singleton
  
  def initialize
    @subjectivity = SubjectivityClassifier.new 
    @polarity = PolarityClassifier.new
    @emotion = EmotionClassifier.new
  end 
  
  def classify status
    return {
      :subjectivity => @subjectivity.classify(status),
      :polarity => @polarity.classify(status),
      :emotion => @emotion.classify(status),
      :topics => TopicExtraction.extract_topics(status)
    }      
  end
  
  def self.classify status
    c = self.instance.classify status
    c = Status::ClassifiedStatus.new c
    status.classified_status = c
    status.save!
    return status
  end
  
   
end