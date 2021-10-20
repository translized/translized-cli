require 'net/http'
require 'json'
require 'fileutils'

projectId = ARGV[0]
token = ARGV[1]
filePath = ARGV[2]
languageCode = ARGV[3]
if projectId.nil?
  puts "Please input project Id as first argument."
  return
end
if token.nil?
  puts "Please input API token as second argument."
  return
end
if filePath.nil?
  puts "Please input file path as third argument."
  return
end
if languageCode.nil?
    puts "Please input language code as fourth argument."
    return
  end

uri = URI("https://translized.eu-4.evennode.com/upload/" + File.basename(filePath))
request = Net::HTTP::Post.new(uri)
request.body = ""
request.body << File.read(filePath)

http = Net::HTTP.new(uri.host, uri.port)
http.use_ssl = true
response = http.request(request)

jsonResponse = JSON.parse(response.body)
if response.code == "201" then
  puts "Uploaded file. Importing translations..."

  uriImport = URI("https://translized.eu-4.evennode.com/import")
  requestImport = Net::HTTP::Post.new(uriImport)
  requestImport.add_field("Content-Type", "application/json")
  requestImport.add_field("api-token", token)
  requestImport.body = {projectId: projectId, languageCode: languageCode, fileURL: jsonResponse["url"]}.to_json

  httpImport = Net::HTTP.new(uriImport.host, uriImport.port)
  httpImport.use_ssl = true
  responseImport = httpImport.request(requestImport)
  jsonResponseImport = JSON.parse(responseImport.body)
  if responseImport.code == "200" then
    puts "Total parsed: " + jsonResponseImport["result"]["totalParsed"].to_s
    puts "Total added: " + jsonResponseImport["result"]["totalAdded"].to_s
  elsif responseImport.code != "200"
    puts jsonResponseImport["error"]
  end

elsif response.code != "201"
  puts jsonResponse["error"]
end
