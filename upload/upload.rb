require 'net/http'
require 'json'
require 'fileutils'
require 'yaml'

config = YAML.load(File.read(".translized.yml"))
projectId = config[:translized][:project_id]
token = config[:translized][:access_token]
filePath = config[:translized][:upload][:path]
languageCode = config[:translized][:upload][:language_code]

if projectId.nil?
  puts "\e[31m#{"Please input project_id in .translized.yml file"}\e[0m"
  return
end
if token.nil?
  puts "\e[31m#{"Please input access_token in .translized.yml file"}\e[0m"
  return
end
if filePath.nil?
  puts "\e[31m#{"Please input upload file path in .translized.yml file"}\e[0m"
  return
end
if languageCode.nil?
    puts "\e[31m#{"Please input language code of upload file in .translized.yml file"}\e[0m"
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
  puts ""

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
    puts "\e[32m#{"Total parsed: " + jsonResponseImport["result"]["totalParsed"].to_s}\e[0m"
    puts "\e[32m#{"Total added: " + jsonResponseImport["result"]["totalAdded"].to_s}\e[0m"
    puts ""
  elsif responseImport.code != "200"
    puts puts "\e[31m#{jsonResponseImport["error"]}\e[0m"
  end

elsif response.code != "201"
  puts puts "\e[31m#{jsonResponse["error"]}\e[0m"
end
