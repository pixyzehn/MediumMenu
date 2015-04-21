MediumMenu
====================

Medium 1.8.168 menu in Swift. That is still one of my favorite menus because that is easy to use and looks beautiful.

Inspired by [RBMenu](https://github.com/RoshanNindrai/RBMenu). I made that a reference and customized a fine point.

## Demo

![MediumMenu](https://github.com/pixyzehn/MediumMenu/blob/master/Assets/MediumMenu.gif)

##Installation

###Cocoapods

The easiest way to get started is to use [CocoaPods](http://cocoapods.org/). Add the following line to your Podfile:

```ruby
platform :ios, '8.0'
use_frameworks!
# The following is a Library of Swift.
pod 'MediumMenu'
```

Then, run the following command:

```ruby
pod install
```

###Carthage

[Carthage](https://github.com/Carthage/Carthage) is a decentralized dependency manager that automates the process of adding frameworks to your Cocoa application.

You can install Carthage with [Homebrew](http://brew.sh/) using the following command:

```bash
$ brew update
$ brew install carthage
```

To integrate MediumMenu into your Xcode project using Carthage, specify it in your `Cartfile`:

```ogdl
github "pixyzehn/MediumMenu"
```
Run `carthage update`.

```bash
$ carthage update
```

###Other

Add the MediumMenu (including MediumMenu.swift) folder into your project.

---

Due to the lack of choice whether status bar is hidden or not,  Edit info.plist in your project.

Add "Status bar is initially hidden" and "View controller-based status bar appearance" in info.plist as key. Eash value is "YES" and "NO".

In the rest of the details, refer to MediumMenu-Sample project.

## Description

MediumMenu is really similar to menu of real Medium for iOS.

## Licence

[MIT](https://github.com/pixyzehn/MediumMenu/blob/master/LICENSE)

## Author

[pixyzehn](https://github.com/pixyzehn)
