MediumMenu
====================

Medium 1.8.168 menu in Swift. That is still one of my favorite menus because that is easy to use and looks beautiful.

Inspired by [RBMenu](https://github.com/RoshanNindrai/RBMenu). I made that a reference and customized a fine point.

## Demo

![MediumMenu](https://github.com/pixyzehn/MediumMenu/blob/master/Assets/MediumMenu.gif)

##Installation

###CocoaPods

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

You can set the following property. If you don't set the these property, default value is used.

```Swift
let menu = MediumMenu(items: [item1, item2, item3, item4, item5], forViewController: self)
menu.textColor = UIColor.purpleColor()                        // Default is UIColor(red:0.98, green:0.98, blue:0.98, alpha:1).
menu.highLightTextColor = UIColor.redColor()                  // Default is UIColor(red:0.57, green:0.57, blue:0.57, alpha:1).
menu.backgroundColor = UIColor.yellowColor()                  // Default is UIColor(red:0.05, green:0.05, blue:0.05, alpha:1).
menu.titleFont = UIFont(name: "AvenirNext-Regular", size: 30) // Default is UIFont(name: "HelveticaNeue-Light", size: 28).
menu.titleAlignment = .Center                                 // Default is .Left.
menu.height = 370                                             // Default is 466.
menu.bounceOffset = 10                                        // Default is 0.
menu.velocityTreshold = 700                                   // Default is 1000.
menu.panGestureEnable = false                                 // Default is true.
menu.highLighedIndex = 3                                      // Default is 1.
menu.heightForRowAtIndexPath = 40                             // Default is 57.
menu.heightForHeaderInSection = 0                             // Default is 30.
```

In the rest of the details, refer to MediumMenu-Sample project.

## Description

MediumMenu is really similar to menu of real Medium for iOS.

## Licence

[MIT](https://github.com/pixyzehn/MediumMenu/blob/master/LICENSE)

## Author

[pixyzehn](https://github.com/pixyzehn)🐈
