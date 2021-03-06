require 'fileutils'
require 'yaml'

print "Please enter your API access token: "
token = gets.chomp
print "Please enter your projectId: "
projectId = gets.chomp

# File formats
file_formats_arr = [ 
    {"name" => 'json', "format" => 'json', "desc" => 'Key value JSON, file extension: json', "defaultDownload" => './<locale_code>.json'},
    {"name" => 'nested_json', "format" => 'json', "desc" => 'Nested JSON, file extension: json', "defaultDownload" => './<locale_code>.json'},
    {"name" => 'strings', "format" => 'strings', "desc" => 'iOS Localizable Strings, file extension: strings', "defaultDownload" => './<locale_code>.lproj/Localizable.strings'},
    {"name" => 'xml', "format" => 'xml', "desc" => 'Android Strings, file extension: xml', "defaultDownload" => './values-<locale_code>/strings.xml'},
    {"name" => 'xlsx', "format" => 'xlsx', "desc" => 'Excel XLSX, file extension: xlsx', "defaultDownload" => './<locale_code>.xlsx'},
    {"name" => 'csv', "format" => 'csv', "desc" => 'CSV, file extension: csv', "defaultDownload" => './<locale_code>.csv'},
    {"name" => 'properties', "format" => 'properties', "desc" => 'Java Properties .properties, file extension: properties', "defaultDownload" => './MessagesBundle_<locale_code>.properties'},
    {"name" => 'xlf', "format" => 'xlf', "desc" => 'XLIFF, file extension: xlf', "defaultDownload" => './<locale_code>.xlf'},
    {"name" => 'yml', "format" => 'yml', "desc" => 'Ruby/Rails YAML, file extension: yml', "defaultDownload" => './config/locales/<locale_code>.yml'},
    {"name" => 'yml_symfony', "format" => 'yml', "desc" => 'Symfony YAML, file extension: yml', "defaultDownload" => './app/Resources/translations/<locale_code>.yml'},
    {"name" => 'resx', "format" => 'resx', "desc" => '.NET ResX, file extension: resx', "defaultDownload" => './<locale_code>.resx'},
    {"name" => 'arb', "format" => 'arb', "desc" => 'ARB, file extension: arb', "defaultDownload" => './<locale_code>.arb'},
]

puts "\n"
$i = 1
while $i <= file_formats_arr.length()  do
    format = file_formats_arr[$i-1]
    print("#$i: ")
    print format["name"] + " - "
    puts format["desc"]
    $i +=1
end
file_format_num = 0
while file_format_num < 1 || file_format_num > file_formats_arr.length() do
print "Select the format to use for language files you download from Translized (1-#{file_formats_arr.length()}): "
file_format_num = gets.chomp.to_i
end
file_format = file_formats_arr[file_format_num - 1]
puts "\e[32m#{"Using format " + file_format["name"]}\e[0m"
puts ""
default_destination = file_format["defaultDownload"]
default_upload_destination = default_destination.gsub('<locale_code>', "en")
# android
if file_format["name"] == 'xml' then 
    default_upload_destination = default_upload_destination.gsub('-en', '')
end

puts "Enter the path to which to download language files from Translized."
print "Download file path: [default " + default_destination + "] "
downloadDestination = gets.chomp
downloadDestination = downloadDestination == '' ? default_destination : downloadDestination
puts ""

puts "Enter the path to the upload file to Translized. "
print "Upload file path: [default " + default_upload_destination + "] "
upload_destination = gets.chomp
upload_destination = upload_destination == '' ? default_upload_destination : upload_destination
puts ""
print "Enter the language code of the upload file: [default en] "
upload_language_code = gets.chomp
upload_language_code = upload_language_code == '' ? "en" : upload_language_code
puts ""

File.open('.translized.yml', 'w') do |file|
    download = {
        'path': downloadDestination,
        'file_format': file_format["format"]
    }
    upload = {
        'path': upload_destination,
        'language_code': upload_language_code
    }
    if file_format["name"] == 'nested_json' then 
        download["isNested"] = true
        upload["isNested"] = true
    end
    config = {
        'translized': {
            'access_token': token,
            'project_id': projectId,
            'download': download,
            'upload': upload
        }
    }
    file.write(config.to_yaml)
end

puts "\e[32m#{"We created the following configuration file for you: .translized.yml"}\e[0m"
puts "\e[32m#{"You can now use the download & upload commands in your workflow:"}\e[0m"
puts ""
puts "$ translized download
$ translized upload"
puts ""
puts "\e[32m#{"Project initialization completed!"}\e[0m"
puts ""