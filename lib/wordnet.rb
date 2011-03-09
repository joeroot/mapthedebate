require 'active_record'

LIB_DIR = File.dirname(__FILE__)
DB_DIR = "#{LIB_DIR}/../db"

ActiveRecord::Base.establish_connection(
  :adapter => "sqlite3",
  :database => "#{DB_DIR}/wordnet30.sqlite3",
)

require "#{LIB_DIR}/wordnet/word.rb"
require "#{LIB_DIR}/wordnet/sense.rb"
require "#{LIB_DIR}/wordnet/synset.rb"
require "#{LIB_DIR}/wordnet/category.rb"
require "#{LIB_DIR}/wordnet/lexicon_link.rb"
require "#{LIB_DIR}/wordnet/semantic_link.rb"


