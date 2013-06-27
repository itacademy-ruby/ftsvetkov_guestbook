# encoding: utf-8

#Sinatra Guestbook

require 'sinatra'
require 'sinatra/assetpack'

set :root, File.dirname(__FILE__)

configure do
  assets do
    serve '/js',     from: 'public/bootstrap/js'
    serve '/css',    from: 'public/bootstrap/css'
    serve '/img',    from: 'public/bootstrap/img'

    js :bootstrap, [
      '/js/bootstrap.js'
    ]

    css :bootstrap, [
      '/css/bootstrap.css',
      '/css/bootstrap-responsive.css'
    ]

    js_compression  :jsmin
    css_compression :simple
  end
end

get '/' do
  erb:index
end

get '/clear' do
  clear_file

  redirect to('/')
end

post '/' do
  author = params[:author].strip.chomp
  message = params[:message].strip.chomp

  if author != nil && author.empty? != true && 
    message != nil && message.empty? != true
    save_post(author, message)
  end

  erb:index
end

def render_posts
  posts = get_posts

  html_posts = ""

  if posts.length > 0
    posts.each do |post|
      html_posts << "<div><small><strong>#{post[:name]}</strong> on #{post[:date]} wrote</small><blockquote>#{render_message(post[:message])}</blockquote></div>"
    end
  else
    html_posts = "<div>Guestbook is empty... =(</div>"
  end

  html_posts
end

def render_message(message)
  paragraphs = ""

  message.each_line('\n') do |line|
    if line.empty? != true
      paragraphs << "#{line.chomp('\n')}<br />"
    end
  end

  paragraphs.chomp('<br />')
end

def get_posts
  file_content = File.open('posts.txt'){ |file| file.read }
  unparsed_posts = file_content.split("=====\n")

  pattern = /^date:\s(.+)\nname:\s(.+)\nmessage:\s(.+)$/

  posts ||= []

  unparsed_posts.each do |post|
    pattern =~ post.gsub(/\r\n/, '\n')

    parse_data = Regexp.last_match

    parsed_post = Hash.new
    parsed_post[:date] = parse_data[1].strip.chomp
    parsed_post[:name] = parse_data[2].strip.chomp
    parsed_post[:message] = parse_data[3].strip.chomp

    posts << parsed_post
  end

  posts
end

def save_post (author, message) 
  File.open('posts.txt', 'a') do |file| 
    file.puts "date: #{Time.new}"
    file.puts "name: #{author}"
    file.puts "message: #{message}"
    file.puts "====="
  end
end

def clear_file
  File.open('posts.txt', 'w') do |file| 
    file.print ''
  end
end