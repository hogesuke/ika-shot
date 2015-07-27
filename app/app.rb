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

get '/' do

  @items = Result.all
  @counts = Result.group('result').count()

  if @counts['win'].nil?
    @win_rate  = 0
  elsif @counts['lose'].nil?
    @win_rate  = 100
  else
    @win_rate = (@counts['win'] / (@counts['win'] + @counts['lose'])) * 100
  end

  haml :index
end

get '/image/:id' do

  unless Result.exists?(params[:id])
    status(400)
    return { :result => false, :msg => '対象のレコードは存在しません' }.to_json
  end

  result = Result.find(params[:id])

  content_type('application/octet-stream')
  result.image
end

post '/upload' do

  if settings.secret != params['secret']
    status(403)
    return { :result => false, :msg => '認証に失敗しました' }.to_json
  end

  result = Result.new
  result.result = params['result']
  result.date   = params['datetime']
  result.image  = params['image'][:tempfile].read

  unless result.save
    status(400)
    { :result => false }.to_json
  end

  { :result => true }.to_json
end
