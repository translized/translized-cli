require 'net/http'
require 'json'
require 'fileutils'
require 'yaml'

config = YAML.load(File.read(".translized.yml"))
projectId = config[:translized][:project_id]
token = config[:translized][:access_token]
filePath = config[:translized][:upload][:path]
fileFormat = config[:translized][:download][:file_format]
languageCode = config[:translized][:upload][:language_code]
isNested = config[:translized][:upload]["isNested"] || false

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

overrideTranslations = ARGV[0] == 'true'
newKeysTag = ARGV[1] == "-" ? nil : ARGV[1]
updatedKeysTag = ARGV[2] == "-" ? nil : ARGV[2]
unless updatedKeysTag.nil?
  if !overrideTranslations then
    puts "\e[31m#{"Override translations flag (-o) must be set to true so that updated keys can be tagged"}\e[0m"
    return
  end
end

uri = URI("https://api.translized.com/upload/" + File.basename(filePath))
request = Net::HTTP::Post.new(uri)
request["Content-Type"] = "text/" + fileFormat
request.body = ""
request.body << File.read(filePath)

http = Net::HTTP.new(uri.host, uri.port)
http.use_ssl = true
response = http.request(request)

jsonResponse = JSON.parse(response.body)
if response.code == "201" then
  puts "Uploaded file. Importing translations..."
  puts ""

  uriImport = URI("https://api.translized.com/import")
  requestImport = Net::HTTP::Post.new(uriImport)
  requestImport.add_field("Content-Type", "application/json")
  requestImport.add_field("api-token", token)
  body = {projectId: projectId, languageCode: languageCode, fileURL: jsonResponse["url"], isNested: isNested}
  body["overrideTranslations"] = overrideTranslations
  unless (newKeysTag.nil? || newKeysTag.empty?) && (updatedKeysTag.nil? || updatedKeysTag.empty?)
    processingRules = {
      "overrideImportAutomations": true,
      "newKeys": newKeysTag ? {"tags": [newKeysTag]} : {},
      "updatedKeys": updatedKeysTag ? {"tags": [updatedKeysTag]} : {}
    } 
    body["processingRules"] = processingRules
  end
  requestImport.body = body.to_json

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
