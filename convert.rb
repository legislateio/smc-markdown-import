require 'github/markup'
require 'redcarpet'
require 'faraday'
require 'json'

files = Dir['./*.md']

conn = Faraday.new(:url => 'http://localhost:8080') do |faraday|
  faraday.response :logger
  faraday.adapter  Faraday.default_adapter
end

files.each do |file|
  output_filename = + File.basename(file, '.*')
  contents = File.read(file, encoding: 'UTF-8')

  split = contents.split("\n")
  title = split.first.slice(2, split.first.length)
  rest = split.slice(1, split.length).join("\n").strip

  output = GitHub::Markup.render(file, rest)

  body = {
    title: title,
    body: output,
    locale: 'seattle'
  }.to_json

  conn.post do |req|
    req.url '/api/documents'
    req.headers['Content-Type'] = 'application/json'
    req.headers['Authorization'] = 'YOUR JWT TOKEN'
    req.body = body
  end

  puts "POSTed #{output_filename}"
end
