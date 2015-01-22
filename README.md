# SwiftFilePath

[![CI Status](http://img.shields.io/travis/nori0620/SwiftFilePath.svg?style=flat)](https://travis-ci.org/nori0620/SwiftFilePath)
[![Carthage Compatibility](https://img.shields.io/badge/carthage-✓-f2a77e.svg?style=flat)](https://github.com/Carthage/Carthage/)
[![Version](https://img.shields.io/cocoapods/v/SwiftFilePath.svg?style=flat)](http://cocoadocs.org/docsets/SwiftFilePath)
[![License](https://img.shields.io/cocoapods/l/SwiftFilePath.svg?style=flat)](http://cocoadocs.org/docsets/SwiftFilePath)
[![Platform](https://img.shields.io/cocoapods/p/SwiftFilePath.svg?style=flat)](http://cocoadocs.org/docsets/SwiftFilePath)

Simple and powerful wrapper for NSFileManager.


# Usage

## Create instance

You can create `Path` object from String.

```swift
let fooDir = Path("/path/to/fooDir")

// You can re obtain String by calling toString.
fooDir.toString() // "/path/to/fooDir"
````

Get accessible `Path`  from App  by  factory methods.

```swift
Path.homeDir.toString()
// "/var/mobile/Containers/Data/Application/<UUID>"

Path.documentsDir.toString()
// "/var/mobile/Containers/Data/Application/<UUID>/Documents"

Path.cacheDir.toString()
// "var/mobile/Containers/Data/Application/<UUID>/Library/Caches"

Path.temporaryDir.toString()
// "var/mobile/Containers/Data/Application/<UUID>/Library/tmp"
````

##  Access to other directories and files

```swift
//  Get Path that indicate foo.txt file in Documents dir
let textFilePath = Path.documentsDir["foo.txt"]
textFilePath.toString() //  "~/Documents/foo.txt"

//  You can access subdir.
let jsonFilePath = Path.documentsDir["subdir"]["bar.json"]
jsonFilePath.toString() //  "~/Documents/subdir/bar.json"

// Access to parent Path.
jsonFilePath.parent.toString() // "~/Documents/subdir"
jsonFilePath.parent.parent.toString() // "~/Documents"
jsonFilePath.parent.parent.parent.toString() // "~/"
````

```swift
let contents = Path.homeDir.contents!
//  Get dir contents as Path object.
// [
//    Path<~/.com.apple.mobile_container_manager.metadata.plist>, 
//    Path<~/Documents>,
//    Path<~/Library>, 
//    Path<~/tmp>,
// ]

// Or you can use dir as iterator
for content:Path in Path.homeDir { 
    println(content) 
 }
````

## Access to file infomation

Check if path is dir or not.

```swift 
Path.homeDir.isDir // true
Path.homeDir["hoge.txt"].isDir //false
````
Check if path is exists  or not.

```swift
// homeDir is exists
Path.homeDir.exists // true

// Is there foo.txt in homeDir ?
Path.homeDir["foo.txt"].exists

// Is there foo.txt in myDir ?
Path.homedir["myDir"]["bar.txt"].exists
````

You can get basename of file.

```swift
Path.homedir["myDir"]["bar.txt"].basename // bar.txt
````

You can get file extension.

```swift
//  Get all *json files in Documents dir.
let allFiles  = Path.documentsDir.contents!
let jsonFiles = allFiles.filter({$0.ext == "json" })
````

You can get more attributes of file.

```swift
let jsonFile = Path.documentsDir["foo.json"]
jsonFile.attributes!.fileCreationDate()! // 2015-01-11 11:30:11 +0000
jsonFile.attributes!.fileModificationDate()! // 2015-01-11 11:30:11 +0000
jsonFile.attributes!.fileSize() // 2341
````

##  File operation

Create ( or delete ) dir and files. 

```swift
// Create "foo" dir in Documents.
let fooDir = Path.documentsDir["foo"]
fooDir.mkdir()

//  Create empty file "hoge.txt" in "foo" dir.
let hogeFile = fooDir["hoge.txt"]
hogeFile.touch()

// Delete foo dir
fooDir.remove()
````

Copy ( or move ) file.

```swift
let fooFile = Path.documentsDir["foo.txt"]
let destination = Path.tmpDir["foo.txt"]
fooFile.copyTo( destination )

````

Write ( or read ) string data.

```swift
// Write string.
let textFile = Path.documentsDir["hello.txt"]
textFile.writeString("HelloSwift")

// Read string.
let text = textFile.readString()! // HelloSwift
````

Write ( or read ) binary  data.

```swift
//  Write binary data.
let binFile = Path.documentsDir["foo.bin"]
binFile.writeData( NSData()  )

// Read  binary data.
let data = binFile.readData()!
````

## Error handling

`touch`/`remove`/`copyTo`/`writeTo`/`mkdir` returns `Result` as Enum.

If operation is success, `Result` has `value` property.
If operation is failure,`Result` has `error` property.


```swift
let result = Path.documentsDir["subdir"].mkdir()
if( result.isSuccess ){ 
    println( result.value! ) 
}
if( result.isFailure ){ 
    println( result.error! ) 
}
````

Or you can write by  closure style. ( You use this style, you don't need to unwrap optional value )

```swift
Path.documentsDir["subdir"].mkdir()
    .onSuccess({ (value:Path) in 
        println( value )
    })
    .onFailure({ (error:NSError) in 
        println( error )
    })
````


# Installation

## CocoaPods

To install it, simply add the following line to your Podfile:

```ruby
pod  'SwiftFilePath',
```

( Currently, to install the framework via CocoaPods you need to use pre-release version.)

## Carthage

To install it, simply add the following line to your Cartfile:

```ruby
github "nori0620/SwiftFilePath"
```


# LICENSE

SwiftPathClass is released under the MIT license. See LICENSE for details.
