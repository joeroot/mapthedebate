module Tagger
  
  class PartOfSpeech
    
    def self.grammar? text
      text.length == 1 && text.match(/\.|\?|\!|\:/)
    end

    def self.number? text
      text.match(/^[\d]+(\,[\d]+)*+(\.[\d]+){0,1}$/)
    end
    
    def self.url? text
      text.match(/(?:http|https):\/\/[a-z0-9]+(?:[\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(?:(?::[0-9]{1,5})?\/[^\s]*)?/ix)
    end

    def self.tokenize text
      ts = text.split(/(\.|\?|\!|\:)?\ /).reject{|s| s == ""}
      ts.map!{|s| {"original" => s.strip, "word" => PartOfSpeech.parse(s.strip)}}
    end

    def self.parse text
      text = text[1..-1] if text[0] == "#"
      text = text[0..-2] if text[-1] == ","
      return text
    end

    def self.tag text
      tokens = PartOfSpeech.tokenize text
      return tokens.each do |token|
        pos = []
        word = token["word"].downcase
        lemma = WordNet::Word.find_by_lemma(word)
        if not lemma.nil?
          pos += lemma.senses.map{|s| {"pos" => s.pos, "detailed" => s.pos_detailed}}.uniq 
        elsif Tagger::NameTagger.name? word
          pos += [{"pos" => "n", "detailed" => "noun.person"}]
        elsif PartOfSpeech.url? word
          pos += [{"pos" => "n", "detailed" => "noun.url"}]
        elsif PartOfSpeech.grammar? word
          pos += [{"pos" => "g", "detailed" => "grammar.all"}]
        elsif PartOfSpeech.number? word
          pos += [{"pos" => "#", "detailed" => "number.all"}]
        end
        token["pos"] = pos.uniq
      end
      tokens
    end
    
  end
  
end