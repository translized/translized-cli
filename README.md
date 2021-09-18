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
2. run `translized --type [type] --projectId [projectId] --token [token] --destination [destination] --fileFormat [fileFormat]` where
    - type is type of platform (iOS, android, universal). If universal is selected make sure to specify fileFormat.
    - projectId is id of your project
    - api-token is your API token
    - destination is path to the folder where files will be downloaded. 
        - If type is iOS files will be in {locale}.lproj folders as per iOS preferences. Example: */{destination}/en.lproj/Localized.strings*
        - If type is android files will be in value-{locale} folders as per Android preferences. Examples: 
            - Primary language: */{destination}/values/strings.xml*
            - others: */{destination}/values-de/strings.xml*
        - If type is universal files will be in format {locale}.{fileFormat}. Example: */{destination}/en.json*
    - fileFormat is format of file you want. Specify only if type is universal. Supported files are: .json, .strings, .xml, .xlsx, .csv, .properties, .php.

    Example: `translized --type iOS --projectId SLueUPR7Mg --token 42cf5fec-a74c-4a53-8ebc-86a4e52b --destination Resources/Localization`


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