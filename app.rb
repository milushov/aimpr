%w{ rubygems sinatra haml coffee-script sass sinatra/assetpack }.each(&method(:require))

class App < Sinatra::Base
  set :root, File.dirname(__FILE__)

  register Sinatra::AssetPack

  assets do
    js :app, ['/js/app.coffee', '/vendor/js/*.js']
    css :app_css, ['/css/app.scss', '/vendor/css/*.css']

    js_compression :jsmin
    css_compression :scss
  end
end

configure { set :debug, development? ? true : false }

before { content_type :html, charset: 'utf-8' }

get('/') { haml :index }

