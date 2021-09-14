require 'net/http'
require 'json'
require 'fileutils'

def http_download_uri(uri, filename, token)
  puts "Starting HTTP download for: " + uri.to_s
  http_object = Net::HTTP.new(uri.host, uri.port)
  http_object.use_ssl = true if uri.scheme == 'https'
  begin
    http_object.start do |http|
      request = Net::HTTP::Get.new uri.request_uri
      http.read_timeout = 500
      http.request request do |response|
        open filename, 'w' do |io|
          response.read_body do |chunk|
            io.write chunk
          end
        end
      end
    end
  rescue Exception => e
    puts "=> Exception: '#{e}'. Skipping download."
    return
  end
  puts "Stored download as " + filename + "."
end

projectId = ARGV[0]
token = ARGV[1]
fileFormat = ARGV[2]
destination = ARGV[3]
if projectId.nil?
  puts "Please input project Id as first argument."
  return
end
if token.nil?
  puts "Please input API token as second argument."
  return
end
if fileFormat.nil?
  puts "Please input export format as third argument."
  return
end
uri = URI("https://translized.eu-4.evennode.com/project/exportAll")
request = Net::HTTP::Post.new(uri)
request.add_field("Content-Type", "application/json")
request.add_field("api-token", token)
request.body = {projectId: projectId, exportFormat: fileFormat}.to_json

http = Net::HTTP.new(uri.host, uri.port)
http.use_ssl = true
response = http.request(request)

jsonResponse = JSON.parse(response.body)
if response.code == "200" then
  puts "Downloading localizations"
  if destination
      create_directory(destination)
      Dir.chdir destination
  end
  
  jsonResponse["result"].each { |language|
      locale, url = language.first
      puts locale
      uriLocale = URI(url["fileURL"])
      http_download_uri(uriLocale, locale + "." + fileFormat, token)
  }
elsif response.code != "200"
  puts jsonResponse["error"]
end
