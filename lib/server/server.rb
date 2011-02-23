require 'sinatra'
require 'erb'
require '../sentiment/sentiment.rb'

class App

  get '/' do
    erb :splash
  end

  get '/map' do
    erb :map
  end
  
  get '/admin/classify' do
    @statuses = ClassifiedStatus.all(:subjective => nil, :polarity => nil)
    erb :"admin/classify/classify"
  end
  
  get '/admin/classify/search' do
    if not params[:q].nil?
      ClassifiedStatus.fetch_from_twitter params[:q]
    end
    redirect '/admin/classify'
  end
  
  get '/admin/classify/trained' do
    @statuses = ClassifiedStatus.sort(:logged_at.desc).all(:subjective => "t")
    @statuses += ClassifiedStatus.sort(:logged_at.desc).all(:subjective => "f")
    @statuses += ClassifiedStatus.sort(:logged_at.desc).all(:subjective => "u")
    erb :"admin/classify/trained"
  end
  
  post '/admin/classify/:id' do
    c = ClassifiedStatus.find_by_id params[:id]
    saved = false;
    if not c.nil?
      c.subjective = params["subjective"] if not params["subjective"].nil?
      c.polarity = params["polarity"] if not params["polarity"].nil?
      if not params["sentiment"].nil?
        c.sentiment = params["sentiment"].split(",").map{|s| s.strip}
      end
      saved = c.save
    end
    @json = {"success" => true}
    erb :"admin/json"    
  end
  
  get '/admin/classify/:id/delete' do
    c = ClassifiedStatus.find_by_id id
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