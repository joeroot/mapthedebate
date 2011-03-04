require 'active_record'

ActiveRecord::Base.establish_connection(
  :adapter => 'sqlite3',
  :database => '../db/wordnet30.sqlite3',
)

require_relative 'wordnet/word.rb'
require_relative 'wordnet/sense.rb'
require_relative 'wordnet/synset.rb'
require_relative 'wordnet/category.rb'
require_relative 'wordnet/lexicon_link.rb'
require_relative 'wordnet/semantic_link.rb'


