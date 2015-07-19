# coding: utf-8

require 'sinatra'
require 'sinatra/reloader'
require 'net/http'
require 'json'
require 'active_record'
require 'yaml'
require 'haml'
require 'pp'
require_relative 'models/result'

ActiveRecord::Base.configurations = YAML.load_file(File.join(__dir__, '../config/database.yml'))
ActiveRecord::Base.establish_connection(settings.environment)

configure :production, :development do
  set :secret, ENV['SECRET']
  set :haml, :format => :html5
end

configure :development do
  set :server, 'webrick'
end

after do
  ActiveRecord::Base.connection.close
end

# todo エラー処理
error do
end

get '/' do

  @results = Result.all

  haml :index
end

get '/image/:id' do

  unless Result.exists?(params[:id])
    status(400)
    raise("対象のレコードは存在しません")
  end

  result = Result.find(params[:id])
  # send_data(result.image, :disposition => 'inline', :type => 'image/jpeg')

  content_type('application/octet-stream')
  result.image
end

post '/upload' do

  if settings.secret != params['secret']
    status(403)
    raise("認証に失敗しました")
  end

  result = Result.new
  result.result = params['result']
  result.date   = params['datetime']
  result.image  = params['image'][:tempfile].read

  if result.save
    status(400)
    { :result => false }.to_json
  end

  { :result => true }.to_json
end
