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
  
  get '/classify' do
    @statuses = ClassifiedStatus.sort(:logged_at.desc).limit(5).all(:subjective => nil)
    redirect "/classify/search" if @statuses.empty?
    erb :"classify/list"
  end
  
  post '/classify' do
    if not params["subjective"].nil?
      params["subjective"].each do |k,v|
        c = ClassifiedStatus.find_by_id k
        c.subjective = v
        c.save
      end      
    end
    redirect "/classify"
  end
  
  get '/classify/trained' do
    @statuses = ClassifiedStatus.sort(:logged_at.desc).all(:subjective => "t")
    @statuses += ClassifiedStatus.sort(:logged_at.desc).all(:subjective => "f")
    @statuses += ClassifiedStatus.sort(:logged_at.desc).all(:subjective => "u")
    erb :"classify/list"
  end
  
  get '/classify/search'do
    if not params[:q].nil?
      ClassifiedStatus.fetch_from_twitter params[:q]
      redirect "/classify"
    end 
    erb :"classify/search"
  end
  
  get '/status/:id/classify' do
    c = ClassifiedStatus.find_by_id(params[:id])
    c.subjective = params[:subjective] if not params[:subjective].nil?
    c.sentiment = params[:sentiment] if not params[:sentiment].nil?
    c.save
  end

end