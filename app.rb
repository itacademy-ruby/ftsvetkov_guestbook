# encoding: utf-8

#Sinatra Guestbook night-Beta

require 'sinatra'

get '/' do
	erb:index
end

post '/' do
	author = params[:author]
	message = params[:message]

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
			html_posts << "<br />#{post[:date]}<br />#{post[:name]}<br />#{post[:message]}<br />"		
		end
	else
		html_posts = "<br />Guestbook is empty... =("
	end

	html_posts
end

def get_posts
	file_content = File.open('posts.txt'){ |file| file.read }
	unparsed_posts = file_content.split("=====")

	pattern = /^date:\s(.+)\nname:\s(.+)\nmessage:\s(.+)$/

	posts ||= []

	unparsed_posts.each do |post|
		pattern =~ post

		parse_data = Regexp.last_match

		parsed_post = Hash.new
		parsed_post[:date] = parse_data[1].chomp
		parsed_post[:name] = parse_data[2].chomp
		parsed_post[:message] = parse_data[3].chomp

		posts << parsed_post
	end

	posts
end

def save_post (author, message)	
	File.open('posts.txt', 'a') do |file| 
		file.puts "date: #{Time.new}"
		file.puts "name: #{author}"
		file.puts "message: #{message}"
		file.print "====="
	end
end