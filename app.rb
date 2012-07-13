%w{ rubygems sinatra haml coffee-script sass sinatra/assetpack }.each(&method(:require))

class App < Sinatra::Base
  set :root, File.dirname(__FILE__)

  register Sinatra::AssetPack

  assets do
    serve '/js',     from: 'assets/js'
    serve '/css',    from: 'assets/css'
    serve '/images', from: 'assets/images'

    js :app, '/js/app.js', %w{ /assets/js/*.coffee /vendor/js/*.js }
    css :app, '/css/app.css', %w{ /assets/css/*.scss /vendor/css/*.css }

    js_compression :jsmin
    css_compression :scss
  end
end

configure do
  if development?
    set :debug, true
  else
    set :debug, false
  end
end

before { content_type :html, charset: 'utf-8' }

get('/'){ haml :index }

