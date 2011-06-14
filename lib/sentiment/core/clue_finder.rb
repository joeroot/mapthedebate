require 'singleton'
require 'stemmer'
require "#{File.dirname(__FILE__)}/tweet_tagger.rb"

module Core
  class ClueFinder
    include Singleton
    
    CLUE_PATH = File.join(File.dirname(__FILE__), '../data/clues/subjclues')
    
    def initialize
      @words = {}
      file = File.new(CLUE_PATH, "r")
      while (line = file.gets)
      	inputs = line.split(" ")
      	if inputs.length == 6
          word = inputs[2][6..-1]
          stemmed = inputs[4][9..-1] == "y"
          word = word.stem if stemmed
          @words[word] = @words[word] || []
          @words[word] << {
            :pos => inputs[3][5..-1],
            :stemmed => stemmed,
            :type => inputs[0][5..-1],
            :polarity => inputs[5][14..-1]
          }
      	end
      end
      file.close
    end
    
    def words
      return @words
    end
    
    def self.clue_data word, pos
      word = word.downcase
      pos = TweetTagger.general pos
      data = nil
      clues = ClueFinder.instance.words[word] || [] 
      clues += (ClueFinder.instance.words[word.stem] || [])
      clues.each do |clue|
        if (clue[:pos] == pos or clue[:pos] == "anypos")
          data = {:type => clue[:type], :polarity => clue[:polarity]}
          break
        end
      end   
      
      return data      
    end
    
    def self.is_clue? word, pos
      return !ClueFinder.clue_data(word, pos).nil?
    end
    
    def self.is_strong_clue? word, pos
      data = ClueFinder.clue_data(word, pos)
      return (!data.nil? and data[:type] == "strongsubj")
    end
    
    def self.is_weak_clue? word, pos
      data = ClueFinder.clue_data(word, pos)
      return (!data.nil? and data[:type] == "weaksubj")
    end
    
    def self.is_positive_clue? word, pos
      data = ClueFinder.clue_data(word, pos)
      return (!data.nil? and data[:polarity] == "positive")
    end
    
    def self.is_negative_clue? word, pos
      data = ClueFinder.clue_data(word, pos)
      return (!data.nil? and data[:polarity] == "negative")
    end
    
    def self.polarity word, pos
      data = ClueFinder.clue_data(word, pos)
      data = data[:polarity] if !data.nil?
      return data
    end
    
  end
end