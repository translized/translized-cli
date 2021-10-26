# translized-cli

Follow next steps to download and import localization files to your project.
Before start make sure you have **projectId** and **api-token**, which you can find in Project Statistics and Account/API Access.

# Homebrew (system-wide installation)

To install translized-cli via Brew, simply use:
```
brew tap translized/translized
brew install translized-cli
```

Usage:
1. Open Terminal and navigate to root folder of your project.
    ```
    cd /path/to/project
    ```
2. Initialize your project by executing the `init` command. This lets you define your preferred locale file format, download, upload files and more.
    ```
    translized init
    ```
3. Use the upload command to `upload` your locale file from your defined sources:
    ```
    translized upload
    ```
4. Use the download command to `download` the most recent locale files back into your project:
    ```
    translized download
    ```



# Manual installation
## iOS

1. Download translate.rb for iOS and put it to root folder of you project.
2. Open Terminal and navigate to root folder of your project.
3. run `ruby translate.rb [projectId] [api-token] [destination]` where
    - projectId is id of your project
    - api-token is your API token
    - destination is path to the folder where files will be downloaded. Files will be in {locale}.lproj folders as per iOS preferences. Example: 
        - */{destination}/en.lproj/Localized.strings*

## Android

1. Download translate.rb for Android and put it to root folder of you project.
2. Open Terminal and navigate to root folder of your project.
3. run `ruby translate.rb [projectId] [api-token] [destination]` where
    - projectId is id of your project
    - api-token is your API token
    - destination is path to the folder where files will be downloaded. Files will be in value-{locale} folders as per Android preferences. Examples: 
        - Primary language: */{destination}/values/strings.xml*
        - others: */{destination}/values-de/strings.xml*

## Universal

1. Download translate.rb from universal folder and put it to root folder of you project.
2. Open Terminal and navigate to root folder of your project.
3. run `ruby translate.rb [projectId] [api-token] [fileFormat] [destination]` where
    - projectId is id of your project
    - api-token is your API token
    - fileFormat is format of file you want. Supported files are: .json, .strings, .xml, .xlsx, .csv, .properties, .php.
    - destination is path to the folder where files will be downloaded. Files will be in format {locale}.{fileFormat}. Make sure that destination folder exists. Example: 
        - */{destination}/en.json*