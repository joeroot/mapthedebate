module Tagger
  
  class NameTagger
    
    @@names = {}
    
    def self.name? name
      self.load_names if @@names.empty? 
      @@names[name.downcase] || false
    end
    
    def self.load_names
      file = File.new('../db/names.csv', 'r')
      file.each_line { |line|
        name = line.split(',')[0].downcase
        @@names[name] = true
      }
      file.close
      file = File.new('../db/surnames.csv', 'r')
      file.each_line { |line|
        name = line.split(',')[0].downcase
        @@names[name] = true
      }
      file.close
    end
    
  end
  
end