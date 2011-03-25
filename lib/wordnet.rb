require 'active_record'

WORDNET_LIB_DIR = "#{File.dirname(__FILE__)}/wordnet"
WORDNET_DB_DIR = "#{File.dirname(__FILE__)}/../db"

ActiveRecord::Base.establish_connection(
  :adapter => "sqlite3",
  :database => "#{WORDNET_DB_DIR}/wordnet30.sqlite3",
)

require "#{WORDNET_LIB_DIR}/word.rb"
require "#{WORDNET_LIB_DIR}/sense.rb"
require "#{WORDNET_LIB_DIR}/synset.rb"
require "#{WORDNET_LIB_DIR}/category.rb"
require "#{WORDNET_LIB_DIR}/lexicon_link.rb"
require "#{WORDNET_LIB_DIR}/semantic_link.rb"


