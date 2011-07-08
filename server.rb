require 'rubygems'
require 'sinatra'
require 'haml'
require 'sass'
require 'active_record'

class Server
  configure do
    ActiveRecord::Base.establish_connection(YAML::load(File.open('config.yml'))["development"])
  end

  get '/' do
    @contacts = Contact.all
    haml :index
  end

  get '/new' do
    haml :new
  end

  post '/new' do
    c                = Contact.new
    c.first_name     = params[:first_name]
    c.last_name      = params[:last_name]
    c.phone_number   = params[:phone_number]
    c.street_address = params[:street_address]
    c.zip_code       = params[:zip_code]
    c.save!

    redirect "/#{c.to_param}"
  end

  get '/:id/edit' do
    @contact = Contact.find(params[:id])
    haml :edit
  end

  post '/:id' do
    c                = Contact.find(params[:id])
    c.first_name     = params[:first_name]
    c.last_name      = params[:last_name]
    c.phone_number   = params[:phone_number]
    c.street_address = params[:street_address]
    c.zip_code       = params[:zip_code]
    c.save!

    redirect "/#{c.to_param}"
  end

  get '/stylesheet.css' do
    sass :stylesheet
  end  

  get %r{/(\d+)} do |id|
    @contact = Contact.find(id)
    haml :contact
  end

  get %r{/(\w+)} do |letter|
    @contacts = Contact.all(:conditions => "LOWER(last_name) like '#{letter}%'")
    haml :letter
  end

end

class Contact < ActiveRecord::Base

  def to_s
    string = ""
    string += first_name
    string += last_name
    string += phone_number.to_s
    string
  end

  def to_param
    "#{id}-#{full_name.gsub(' ', '_')}"
  end

  def full_name
    "#{first_name} #{last_name}"
  end

  def last_name_first
    "#{last_name}, #{first_name}"
  end

  def initials_only
    "#{first_name[0]}. #{last_name[0]}.".upcase
  end

end
