class FeatureAnalysis
  
  @@subjectivity = [
    :has_adjectives?,
    :no_adjectives,
    :has_urls?,
    :no_urls,
    :has_mentions?, 
    :no_mentions,
    :has_clues?,
    :no_clues,
    :has_strong_clues?,
    :no_strong_clues, 
    :has_weak_clues?,
    :no_weak_clues,
    :capitalised_words_frequency,
    :capitalised_letters_frequency
  ]
  
  @@subjectivity_tests = [
    [
      :has_urls?,
      :has_strong_clues?,
    ],
    [
      :has_urls?,
      :has_strong_clues?,
      :no_clues
    ],
    [
      :has_urls?,
      :has_strong_clues?,
      :capitalised_words_frequency
    ],
    [
      :has_urls?,
      :has_strong_clues?,
      :no_clues,
      :capitalised_words_frequency
    ],
    [
      :has_adjectives?,
      :has_urls?,
      :has_strong_clues?,
      :no_clues,
      :capitalised_words_frequency
    ]
  ]
  
  @@polarity = [
    :has_positive_clues?,
    :has_negative_clues?,
    :has_weak_positive_clues?,
    :has_weak_negative_clues?,
    :has_strong_positive_clues?,
    :has_strong_negative_clues?,
    :no_positive_clues,
    :no_negative_clues,
    :no_weak_positive_clues,
    :no_weak_negative_clues,
    :no_strong_positive_clues,
    :no_strong_negative_clues,
    :has_positive_patterns?,
    :has_negative_patterns?,
    :unigrams
  ]
  
  @@polarity_tests = [
    # [
    #   :has_positive_clues?,
    #   :has_negative_clues?,
    #   :has_strong_positive_clues?,
    #   :has_strong_negative_clues?
    # ],
    # [
    #   :has_positive_clues?,
    #   :has_negative_clues?,
    #   :no_strong_positive_clues,
    #   :no_strong_negative_clues
    # ],
    [
      :has_positive_clues?,
      :has_negative_clues?,
      :has_strong_positive_clues?,
      :has_strong_negative_clues?,
      :has_positive_patterns?,
      :has_negative_patterns?
    ]#,
    # [
    #   :has_positive_clues?,
    #   :has_negative_clues?,
    #   :has_strong_positive_clues?,
    #   :has_strong_negative_clues?,
    #   :has_positive_patterns?,
    #   :has_negative_patterns?,
    #   :unigrams
    # ]
  ]
  
  def self.individual cls, k, n, params={}  
    features = self.load_features cls
    self.test cls, k, n, features, params
  end
  
  def self.print_individual cls, k, n, params={} 
    features = self.load_features cls
    self.print_test cls, k, n, features, params
  end
  
  def self.features cls, k, n, params={}  
    features = self.load_features_tests cls
    self.test cls, k, n, features, params
  end
  
  def self.print_features cls, k, n, params={} 
    features = self.load_features_tests cls
    self.print_test cls, k, n, features, params
  end
  
  def self.test cls, k, n, features, params={}    
    features.map do |f|
      f = [f] if f.class != Array
      {
        :feature => f.to_s,
        :results => cls.repeat_test(k, n, params.merge({:features => f}))
      }
    end
  end
  
  def self.print_test cls, k, n, features, params={} 
    results = self.test cls, k, n, features, params
    puts "accuracy"
    results.each_index do |i|
      rs = results[i][:results]
      puts "#{i+1}, #{rs[:min_accuracy]}, #{rs[:accuracy]}, #{rs[:max_accuracy]}"
    end
    
    labels = results[0][:results].keys - [:accuracy, :max_accuracy, :min_accuracy, :partition]

    puts
    puts "precision"
    labels.each do |l|
      puts "#{l}"
      results.each_index do |i|
        rs = results[i][:results][l]
        puts "#{i+1}, #{rs[:min_precision]}, #{rs[:precision]}, #{rs[:max_precision]}"    
      end
    end
    
    puts
    puts "recall"
    labels.each do |l|
      puts "#{l}"
      results.each_index do |i|
        rs = results[i][:results][l]
        puts "#{i+1}, #{rs[:min_recall]}, #{rs[:recall]}, #{rs[:max_recall]}"    
      end
    end
    
    puts
    puts "fmeasure"
    labels.each do |l|
      puts "#{l}"
      results.each_index do |i|
        rs = results[i][:results][l]
        puts "#{i+1}, #{rs[:min_fmeasure]}, #{rs[:fmeasure]}, #{rs[:fmeasure]}"    
      end
    end
    
  end
  
  def self.load_features cls
    return @@subjectivity if cls == SubjectivityClassifier
    return @@polarity if cls == PolarityClassifier
  end
  
  def self.load_features_tests cls
    return @@subjectivity_tests if cls == SubjectivityClassifier
    return @@polarity_tests if cls == PolarityClassifier
  end
  
  
end