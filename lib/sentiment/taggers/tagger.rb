require "#{File.dirname(__FILE__)}/name_tagger.rb"
require "#{File.dirname(__FILE__)}/part_of_speech.rb"

module Tagger
  Tagger::NameTagger.load_names
end