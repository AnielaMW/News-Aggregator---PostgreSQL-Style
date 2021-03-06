require "sinatra"
require 'sinatra/flash'
require 'pry'
require "pg"
require_relative "./app/models/article"

set :bind, '0.0.0.0'  # bind to all interfaces
set :views, File.join(File.dirname(__FILE__), "app", "views")

enable :sessions

configure :development do
  set :db_config, { dbname: "news_aggregator_development" }
end

configure :test do
  set :db_config, { dbname: "news_aggregator_test" }
end

def db_connection
  begin
    connection = PG.connect(Sinatra::Application.db_config)
    yield(connection)
  ensure
    connection.close
  end
end

get '/' do
  redirect '/articles'
end

get '/articles' do
  @articles = Article.all
  erb :index
end

get '/articles/new' do
  erb :form
end

post '/articles/new' do
  @new_article = Article.new({
    "title" => params[:title],
    "url" => params[:url],
    "description" => params[:description]}
    )

  if @new_article.save
    redirect '/articles'
  else
    flash.now[:error] = @new_article.errors
    erb :form
  end
end
