require 'net/http'
require 'json'
require 'fileutils'
require 'yaml'

def create_directory(dirname)
  unless Dir.exists?(dirname)
    FileUtils.mkdir_p(dirname)
  end
end

def http_download_uri(uri, filename, token, locale, downloadPath)
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
    puts "\e[31m#{"=> Exception: '#{e}'. Skipping download."}\e[0m"
    return
  end
  puts "\e[32m#{"Downloaded " + locale + " to " + downloadPath}\e[0m"
end

config = YAML.load(File.read(".translized.yml"))
projectId = config[:translized][:project_id]
token = config[:translized][:access_token]
fileFormat = config[:translized][:download][:file_format]
downloadPath = config[:translized][:download][:path]
isNested = config[:translized][:download]["isNested"] || false
if projectId.nil?
  puts "\e[31m#{"Please input project_id in .translized.yml file"}\e[0m"
  return
end
if token.nil?
  puts "\e[31m#{"Please input access_token in .translized.yml file"}\e[0m"
  return
end
if fileFormat.nil?
  puts "\e[31m#{"Please input file_format in .translized.yml file"}\e[0m"
  return
end
if downloadPath.nil?
  puts "\e[31m#{"Please input download path in .translized.yml file"}\e[0m"
  return
end
uri = URI("https://translized.eu-4.evennode.com/project/exportAll")
request = Net::HTTP::Post.new(uri)
request.add_field("Content-Type", "application/json")
request.add_field("api-token", token)
request.body = {projectId: projectId, exportFormat: fileFormat, isNested: isNested}.to_json

http = Net::HTTP.new(uri.host, uri.port)
http.use_ssl = true
response = http.request(request)

jsonResponse = JSON.parse(response.body)
if response.code == "200" then
  script_dir = Dir.pwd
  jsonResponse["result"].each { |language|
      locale, url = language.first
      uriLocale = URI(url["fileURL"])
      dirname = File.dirname(downloadPath).gsub('<locale_code>', locale)
      filename = File.basename(downloadPath).gsub('<locale_code>', locale)
      # android
      if fileFormat == 'xml' && locale == "en" then 
        dirname = dirname.gsub('-' + locale, '')
      end
      Dir.chdir script_dir
      if dirname
        create_directory(dirname)
        Dir.chdir dirname
      end
      http_download_uri(uriLocale, filename, token, locale, dirname + "/" + filename)
  }
elsif response.code != "200"
  puts "\e[31m#{jsonResponse["error"]}\e[0m"
end
