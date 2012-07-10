require 'rubygems'
require 'sinatra'
require 'haml'
require 'coffee-script'
require 'sass'
# require 'sinatra-activerecord'

configure do
  if development?
    set :debug, true
  else
    set :debug, false
  end
end

before  do
  content_type :html, charset: 'utf-8'
end

get '/' do
  haml :index
end

get '/js/*.js' do
  content_type 'text/javascript'
  filename = params[:splat].first
  coffee filename.to_sym, views: "#{settings.root}/assets/js"
end

get '/css/*.css' do
  content_type 'text/css', charset: 'utf-8'
  filename = params[:splat].first
  scss filename.to_sym, views: "#{settings.root}/assets/css"
end

get '/:name' do
  "hello, #{params[:name]}"
end

get '/?*' do
  params[:splat].size
end