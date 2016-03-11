# SNSShare
[![Build Status](https://travis-ci.org/sgr-ksmt/SNSShare.svg?branch=master)](https://travis-ci.org/sgr-ksmt/SNSShare)
[![Carthage Compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![Pod Version](https://img.shields.io/cocoapods/v/SNSShare.svg?style=flat)](http://cocoapods.org/pods/SNSShare)
[![](https://img.shields.io/badge/Xcode-7.0%2B-brightgreen.svg?style=flat)]()
[![](https://img.shields.io/badge/iOS-8.0%2B-brightgreen.svg?style=flat)]()

## Warning: iOS9
Over *iOS9.0*,Requires `LSApplicationQueriesSchemes` for `canOpenURL`.
If you want to enable sharing to LINE, add `line` to `LSApplicationQueriesSchemes`

```xml
<key>LSApplicationQueriesSchemes</key>
<array>
  <string>line</string>
</array>
```

# How to use

- Create `SNSData`

```swift
let data = SNSShareData {
    $0.text = "text"
    $0.images = [image]
    $0.urls = [url]
}
```

- share to SNS (e.g. Twitter)
```swift
data.post(.Twitter) { result in
    switch result {
    case .Success(let posted):
      print(posted ? "Posted!!" : "Canceled!!")
    case .Failure(let e):
      print(e)
    }
}
```

If a user posted share data, return result `Success` by completion closure.
else cancelled or other error occurred, return result `Failure`.

### Other methods

- *SNSShare#availableSNSList()*<br>
Return SNS service list that user can use.

### ErrorType
- *NotAvailable(SNSType)* If a user cannot share to SNS service.
- *EmptyData* : If SNSShareData is EmptyData (has no text, image and url).
- *URIEncodingError* : Failed URI encoding When select *LINE* and share text and URL.
- *UnknownError*


#### **Demo is [here](https://github.com/sgr-ksmt/SNSShare/blob/master/Demo/)**

## Requirements
- iOS 8.0+
- Xcode 7.0+(Swift 2+)

## Installation and Setup

### With CocoaPods
**SNSShare** is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'SNSShare'
```

and run `pod install`

### With Carthage
- Add the following to your *Cartfile*:

```ruby
github "sgr-ksmt/SNSShare"
```

- Run `carthage update`
- Add the framework as described.
<br> Details: [Carthage Readme](https://github.com/Carthage/Carthage#adding-frameworks-to-an-application)

### Manual install (for iOS7)
Clone this repository, then add `SNSShare.swift` to your Xcode Project.