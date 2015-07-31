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
  set :per_page, 30
  set :haml, :format => :html5
end

configure :development do
  set :server, 'webrick'
end

after do
  ActiveRecord::Base.connection.close
end

get '/' do

  @items = Result.order('date DESC').limit(settings.per_page)
  @counts = Result.group('result').count()

  if @counts['win'].nil?
    @win_rate  = 0
    @lose_rate  = 100
  elsif @counts['lose'].nil?
    @win_rate  = 100
    @lose_rate  = 0
  else
    @win_rate = (@counts['win'] / (@counts['win'] + @counts['lose']).to_f) * 100
    @win_rate = @win_rate.round(1)
    @lose_rate = (100 - @win_rate).round(1)
  end

  haml :index
end

get '/page/:page' do
  page = params[:page]

  unless valid_page?(page)
    status(400)
    return { :result => false, :msg => '無効なページ指定です' }.to_json
  end

  page = params[:page].to_i
  items = Result.order('date DESC').offset(settings.per_page * page).limit(settings.per_page)

  rendered_items = []
  items.each do |item|
    rendered_items.push(haml(:result, :locals => { :item => item }))
  end

  { :result => true, :items => rendered_items }.to_json
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

def valid_page?(page)
  return false if page.nil?
  return false unless page =~ /^[0-9]+$/
  return false if page.to_i <= 0
  true
end
