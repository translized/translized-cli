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
    {"name" => 'stringsdict', "format" => 'stringsdict', "desc" => 'iOS Localizable Stringsdict, file extension: stringsdict', "defaultDownload" => './<locale_code>.lproj/Localizable.stringsdict'},
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
print "Upload file path: [default " + downloadDestination + "] "
upload_destination = gets.chomp
upload_destination = upload_destination == '' ? downloadDestination : upload_destination
puts ""

if !(upload_destination.include? "<locale_code>")
    print "Enter the language code of the upload file: [default en] "
    upload_language_code = gets.chomp
    upload_language_code = upload_language_code == '' ? "en" : upload_language_code
    puts ""
end

add_additional_options = "s"
while add_additional_options != "y" && add_additional_options != "n" do
    print "Configure additional download options?: [y/n] "
    add_additional_options = gets.chomp
end
puts ""

download_option = 0
increase_percentage = 20
if add_additional_options == 'y' then 
    print "Download options:\n"
    print "1: Replace empty translations with primary language translations\n"
    print "2: Replace empty translations with pseudolocalized translations of primary language\n"
    print "3: None\n"
    
    while download_option < 1 || download_option > 3 do
        print "Select the download options: (1-3): "
        download_option = gets.chomp.to_i
    end
    puts ""

    if download_option == 2 then
        print "Enter increase percentage for pseudolocalization: [default 20] "
        percentage = gets.chomp.to_i
        unless percentage.nil? || percentage == 0
            increase_percentage = percentage
        end
    end
end

File.open('.translized.yml', 'w') do |file|
    download = {
        'path': downloadDestination,
        'file_format': file_format["format"]
    }
    upload = {
        'path': upload_destination,
    }
    if file_format["name"] == 'nested_json' then 
        download["isNested"] = true
        upload["isNested"] = true
    end
    if upload_language_code then
        upload["language_code"] = upload_language_code
    end

    download_options = {}
    if file_format["name"] == 'strings' || file_format["name"] == 'xml' then 
        download_options["transform_placeholders_iOS_android"] = true
    end
    if download_option == 1 then
        download_options["replace_empty"] = {
            "primary_translations": true
        }
    end
    if download_option == 2 then
        download_options["replace_empty"] = {
            "pseudolocalization": true,
            "increase_percentage": increase_percentage
        }
    end
    unless download_options.empty?
        download["options"] = download_options
    end

    config = {
        'translized': {
            'access_token': token,
            'project_id': projectId,
            'download': [download],
            'upload': [upload]
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
puts "\e[32m#{"Set additional options for upload and download directly in configuration file:"}\e[0m"
puts "- tags (specify which tags to download or how to tag new or updated keys on upload)
- update_translation (specify should upload update existing translations)
"
puts ""
puts "More details and examples can be found on: https://docs.translized.com/docs/cli/basics"
puts ""
puts "\e[32m#{"Project initialization completed!"}\e[0m"
puts ""