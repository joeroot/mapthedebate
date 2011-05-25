require 'sinatra'
require 'erb'
require "#{File.dirname(__FILE__)}/../sentiment.rb"

class App

  get '/' do
    erb :splash
  end

  get '/map' do
    erb :map
  end
  
  get '/admin/train' do
    @statuses = Status::Status.where(:trained_status => nil).sort(:created_at.desc)
    erb :"admin/train/index"
  end
  
  get '/admin/train/search' do
    if not params[:q].nil?
      Scraper::TwitterSearch.scrape params[:q]
    end
    redirect '/admin/train'
  end
  
  get '/admin/train/trained' do
    @statuses = Status::Status.where(:trained_status.ne => nil).sort(:created_at.desc)
    erb :"admin/train/trained"
  end
  
  post '/admin/train/:id' do
    s = Status::Status.find_by_id params[:id]
    saved = false;
    if not s.nil?
      if s.trained_status.nil?
        s.trained_status = Status::TrainedStatus.new
        s.save
      end
      t = s.trained_status
      t.subjective = params["subjective"] if not params["subjective"].nil?
      t.polarity = params["polarity"] if not params["polarity"].nil?
      if not params["sentiment"].nil?
        t.sentiment = params["sentiment"].split(",").map{|s| s.strip}
      end
      saved = s.save and t.save
    end
    @json = {"success" => saved}
    erb :"admin/json"    
  end
  
  get '/admin/train/:id/delete' do
    s = Status::Status.find_by_id id
    destroyed = c.destroy
    @json = {"success" => destroyed}
    erb :"admin/json"
  end
  
  helpers do
    def wrap_text(txt, col = 80)
      txt.gsub(/(.{1,#{col}})( +|$\n?)|(.{1,#{col}})/,
        "\\1\\3\n") 
    end
  end

end