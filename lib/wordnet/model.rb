require 'sequel'

module WordNet
  
  class Model
    
    @@table = self.class.to_s
    @@primary_key = :id
    @@attributes = []
    
    def initialize(id)
      self.id = id
    end
    
    @@attributes.each do |attribute|
      puts "define"
      define_method attribute do
        WordNet::DB[@@table].where(@@primary_key => self.id).first[attribute]
      end
    end
    
  end

end