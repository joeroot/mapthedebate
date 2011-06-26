class EmotionClassifier
  
  LEXICON_PATH = File.join(File.dirname(__FILE__), '../data/clues/emotion.csv')
  
  def initialize
    @lexicon = self.load_lexicon
  end
  
  def lexicon
    return @lexicon
  end
  
  def classify status
    emotions = []
    parts = status.parts_of_speech
    parts.each do |pos|
      word = WordNet::Word.find_by_lemma pos["word"].downcase
      if !word.nil?
        synsets = word.synsets.map{|s| s.id}
        @lexicon.each do |emotion, ids|
          emotions += [emotion] if !synsets.select{|s| ids.include? s}.empty?
        end
      end
    end
    return emotions.uniq
  end
  
  # def classify status
  #   emotion = []
  #   pos = wordnet_pos status
  #   pos.each do |pos|
  #     emotion += [:surprise] if pos["word"] == "!"
  #     wordnet_emotion = self.classify_wordnet pos
  #     emotion += [wordnet_emotion] if !wordnet_emotion.nil?
  #   end
  #   return emotion.uniq
  # end
  # 
  # def wordnet_pos status
  #   words = status.parts_of_speech.each do |pos| 
  #     pos["wordnet"] = WordNet::Word.find_by_lemma pos["word"].downcase
  #   end
  # end
  # 
  # def classify_wordnet pos
  #   return nil if pos["wordnet"].nil?
  #   tag = TweetTagger.general pos["tag"]
  #   tag = tag[0] if tag != "adj"
  #   synsets = pos["wordnet"].synsets.reject{|synset| synset.pos == tag}
  #   synsets.each do |synset|
  #     emotion = self.find_emotion synset
  #     return emotion if !emotion.nil?
  #   end
  #   return nil
  # end
  # 
  # def find_emotion synset, level=0
  #   if level < 3
  #     pos = synset.pos
  #     synset.words.each do |word|
  #       @lexicon.each do |emotion,values|
  #         # puts "#{{:word => word.lemma, :pos => pos}}"
  #         return emotion if values.include?({:word => word.lemma, :pos => pos})
  #       end
  #     end
  #     synset.hypernyms.each do |hypernym|
  #       emotion = self.find_emotion hypernym, (level+1)
  #       return emotion if !emotion.nil?
  #     end
  #   end
  #   return nil
  # end
  
  def load_lexicon
    lexicon = {}
    file = File.new(LEXICON_PATH, "r")
    while (line = file.gets)
    	inputs = line.split(",").split("\n")[0].map{|i| i.strip}
      emotion = inputs[0]
      ids = []
      inputs[1..-1].each do |lemma|
        word = WordNet::Word.find_by_lemma(lemma)
        if !word.nil?
          word.synsets.each do |synset|
            ids += [synset.id] + self.load_hyponyms(synset)
          end
        end
      end
      lexicon[emotion] = ((lexicon[emotion] || []) + ids).uniq
    end
    return lexicon
  end
  
  def load_hyponyms synset
    ids = []
    synset.hyponyms.each do |hyponym|
      ids += [hyponym.id] + load_hyponyms(hyponym)
    end
    return ids
  end
  
end