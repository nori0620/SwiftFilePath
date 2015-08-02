//
//  SwiftFilePathTests.swift
//  SwiftFilePathTests
//
//  Created by nori0620 on 2015/01/10.
//  Copyright (c) 2015年 Norihiro Sakamoto. All rights reserved.
//

import XCTest
import SwiftFilePath

// MARK: Extensions as Test utils

extension String {
    
    func match(pattern: String) -> Bool {
        let matcher: NSRegularExpression?
        do {
            matcher = try NSRegularExpression(pattern: pattern, options: [])
        } catch _ as NSError {
            matcher = nil
        }
        return matcher?.numberOfMatchesInString(self, options: [], range: NSMakeRange(0, self.utf16.count)) != 0
    }
    
}

// MARK: Test cases

class SwiftFilePathTests: XCTestCase {
    
    let sandboxDir = Path.temporaryDir.content("sandbox")
    
    override func setUp() {
        super.setUp()
        self.sandboxDir.mkdir()
    }
    
    override func tearDown() {
        super.tearDown()
        self.sandboxDir.remove()
    }
    
    func locally(x: () -> ()) {
        x()
    }
    
    
    // MARK:
    
    #if os(iOS)
    func testDirFactories() {
        
        let homeDir = Path.homeDir
        XCTAssertTrue(
            homeDir.toString().match("/data")
        )
        
        let temporaryDir = Path.temporaryDir
        XCTAssertTrue(
            temporaryDir.toString().match("/data/tmp/")
        )                        
        
        let documentsDir = Path.documentsDir
        XCTAssertTrue(
            documentsDir.toString().match("/data/Documents")
        )                        
        
        let cacheDir = Path.cacheDir
        XCTAssertTrue(
            cacheDir.toString().match("/data/Library/Caches")
        )                    
        
    }
    #endif
    
    func testDir(){
        let dir = sandboxDir.content("bar")
        let dir2 = sandboxDir["bar"]
        let dir3 = sandboxDir.child("bar")
        XCTAssertEqual( dir.basename, "bar")
        XCTAssertEqual( dir.toString(), dir2.toString() )
        XCTAssertEqual( dir.toString(), dir3.toString() )
    }
    
    func testFile() {
        let file = sandboxDir.content("hoge.txt")
        XCTAssertTrue(
            file.toString().match("/data/tmp/sandbox/hoge.txt")
        )
        XCTAssertEqual( file.ext , "txt")
        XCTAssertEqual( file.basename, "hoge.txt")
        XCTAssertTrue(
            file.parent.toString().match("/data/tmp/sandbox")
        )
        
    }
    
    func testAttributes() {
        
        let file = sandboxDir.content("foo.txt")
        file.touch()
        let permission:Int? = file.attributes!.filePosixPermissions()
        XCTAssertEqual( permission!,420);
        
    }
    
    
    // MARK:
    
    func testTouchAndRemove(){
        let file = sandboxDir.content("file.txt")
        
        XCTAssertFalse( file.exists )
       
        locally { // touch
            let result = file.touch()
            XCTAssertTrue( result.isSuccess )
            XCTAssertTrue( file.exists )
        }
        
        locally { // remove
            let result = file.remove()
            XCTAssertTrue( result.isSuccess )
            XCTAssertFalse( file.exists )
        }
        
        
    }
    
    func testMkdirAndRemove(){
        
        let fruitsDir = sandboxDir.content("fruits")
        XCTAssertTrue(
            fruitsDir.toString().match("/data/tmp/sandbox/fruits")
        )
        XCTAssertFalse( fruitsDir.exists )
        
        locally { // mkdir
            let result = fruitsDir.mkdir()
            XCTAssertTrue( result.isSuccess )
            XCTAssertTrue( fruitsDir.exists )
        }
        
        locally { // remove
            let result = fruitsDir.remove()
            XCTAssertTrue( result.isSuccess )
            XCTAssertFalse( fruitsDir.exists )
        }
    }
    
    // MARK:
    
    func testDirHierarchy() {
       
        let booksDir  = sandboxDir.content("books")
        let comicsDir = booksDir.content("comics")
        let comic = comicsDir.content("DragonBall")
        
        XCTAssertFalse( booksDir.exists )
        XCTAssertFalse( comicsDir.exists )
        XCTAssertFalse( comic.exists )
        
        locally { // mkdir
            let result = comicsDir.mkdir()
            XCTAssertTrue( result.isSuccess )
            XCTAssertTrue( booksDir.exists )
            XCTAssertTrue( comicsDir.exists )
        }
        
        locally { // touch
            let result = comic.touch()
            XCTAssertTrue( result.isSuccess )
            XCTAssertTrue( comic.exists )
            
            let relativeComic = self.sandboxDir.content("books/comics/DragonBall")
            XCTAssertTrue( relativeComic.exists )
        }
        
        locally { // remove rootDir
            let result = booksDir.remove()
            XCTAssertTrue( result.isSuccess )
            XCTAssertFalse( booksDir.exists )
            XCTAssertFalse( comicsDir.exists )
            XCTAssertFalse( comic.exists )
        }
        
    }
    
    func testSubDir() {
        let dir = sandboxDir.content("foo")
        XCTAssertTrue(
            dir.toString().match("/data/tmp/sandbox/foo")
        )
    }
    
    func testParentDir() {
        let dir = sandboxDir.content("foo")
        XCTAssertTrue(
            dir.toString().match("/data/tmp/sandbox/foo")
        )
        XCTAssertTrue(
            dir.parent.toString().match("/data/tmp/sandbox")
        )
        XCTAssertTrue(
            dir.parent.parent.parent.toString().match("/data")
        )
        XCTAssertTrue(
            dir.parent.parent.parent.parent.toString().match("/")
        )
        XCTAssertTrue(
            dir.parent.parent.parent.parent.parent.parent.toString().match("/")
        )
        
    }
    
    // MARK:
    
    func testChildren(){
        
        sandboxDir.content("foo.txt").touch()
        sandboxDir.content("bar.txt").touch()
        
        let subdir = sandboxDir.content("mydir")
        subdir.mkdir()
       
        let boxContents = sandboxDir.contents
        XCTAssertEqual( boxContents!.count, 3)
        XCTAssertEqual( subdir.contents!.count, 0)
        
        for content in boxContents! {
            XCTAssertTrue(content.exists)
        }
        
        let dirsInContents = boxContents!.filter({content in
            return content.isDir
        })
        XCTAssertEqual( dirsInContents.count, 1)
        XCTAssertEqual( dirsInContents.first!.toString(), subdir.toString())
        
    }
    
    func testIterator(){
        
        sandboxDir.content("foo.txt").touch()
        sandboxDir.content("bar.txt").touch()
        
        let subdir = sandboxDir.content("mydir")
        subdir.mkdir()
       
        var contentCount = 0
        var dirCount     = 0
        
        for content in sandboxDir {
            XCTAssertTrue(content.exists)
            contentCount++
            if( content.isDir ){ dirCount++ }
        }
        XCTAssertEqual( contentCount, 3)
        XCTAssertEqual( dirCount, 1)
       
        
    }
    
    // MARK:
    
    func testReadWriteString(){
        
        let textFile = sandboxDir.content("test.txt")
        
        locally {
            let result = textFile.writeString("foo")
            XCTAssertTrue( result.isSuccess )
            let readString = textFile.readString()!
            XCTAssertEqual( readString, "foo")
        }
        
        locally {
            let result = textFile.writeString("bar")
            XCTAssertTrue( result.isSuccess )
            let readString = textFile.readString()!
            XCTAssertEqual( readString, "bar")
        }
        
        locally {
            textFile.remove()
            let readString = textFile.readString() ?? "failed to read"
            XCTAssertEqual( readString, "failed to read")
        }
        
    }
    
    func testReadWriteData(){
        
        let binFile = sandboxDir.content("test.bin")
        
        locally {
            let string  = "HelloData"
            let data    = string.dataUsingEncoding(NSUTF8StringEncoding)
            let result = binFile.writeData( data! )
            XCTAssertTrue( result.isSuccess )
            
            let readData = binFile.readData()
            let readString = NSString(data: readData!, encoding: NSUTF8StringEncoding)!
            XCTAssertEqual( readString, "HelloData")
        }
        
        locally {
            let string  = "HelloData Again"
            let data    = string.dataUsingEncoding(NSUTF8StringEncoding)
            let result = binFile.writeData( data! )
            XCTAssertTrue( result.isSuccess )
            
            let readData = binFile.readData()
            let readString = NSString(data: readData!, encoding: NSUTF8StringEncoding)!
            XCTAssertEqual( readString, "HelloData Again")
        }
        
        locally {
            binFile.remove()
            let empty = NSData()
            let readData = binFile.readData() ?? empty
            XCTAssertEqual( readData, empty )
        }
    }
    
    // MARK:
    
    func testCopyDir() {
        
        let srcDir  = sandboxDir.content("src")
        let destDir = sandboxDir.content("dest")
        srcDir.mkdir()
        
        let result = srcDir.copyTo( destDir )
        XCTAssertTrue( result.isSuccess )
        XCTAssertTrue( srcDir.exists )
        XCTAssertTrue( destDir.exists )
        
    }
    
    func testCopyFile() {
        
        let srcFile = sandboxDir.content("foo.txt")
        let destFile = sandboxDir.content("bar.txt")
        srcFile.touch()
        
        let result = srcFile.copyTo( destFile )
        XCTAssertTrue( result.isSuccess )
        XCTAssertTrue( srcFile.exists )
        XCTAssertTrue( destFile.exists )
        
    }
    
    // MARK:
    
    func testMoveDir() {
        
        let srcDir  = sandboxDir.content("src")
        let destDir = sandboxDir.content("dest")
        srcDir.mkdir()
        
        let result = srcDir.moveTo(destDir)
        XCTAssertTrue( result.isSuccess )
        XCTAssertFalse( srcDir.exists )
        XCTAssertTrue( destDir.exists )
        
    }
    
    func testMoveFile() {
        let srcFile = sandboxDir.content("foo.txt")
        let destFile = sandboxDir.content("bar.txt")
        srcFile.touch()
        
        let result = srcFile.moveTo( destFile )
        XCTAssertTrue( result.isSuccess )
        XCTAssertFalse( srcFile.exists )
        XCTAssertTrue( destFile.exists )
        
    }
    
    // MARK:
    
    func testSuccessResult() {
        var callOnFailure = false
        var callOnSuccess = false
        let result = Result<Int,String>(success:200)
            .onSuccess({ (value:Int) in
                callOnSuccess = true
                XCTAssertEqual(value,200)
            })
            .onFailure({ (error:String) in
                callOnFailure = true
            })
        
        XCTAssertTrue( result.isSuccess )
        XCTAssertEqual( result.value!, 200 )
        XCTAssertFalse( callOnFailure )
        XCTAssertTrue( callOnSuccess )
    }
    
    
    func testFailureResult() {
        var callOnFailure = false
        var callOnSuccess = false
        let result = Result<Int,String>(failure:"NG!")
            .onSuccess({ (value:Int) in
                callOnSuccess = true
            })
            .onFailure({ (error:String) in
                callOnFailure = true
                XCTAssertEqual(error,"NG!")
            })
        
        
        XCTAssertTrue( result.isFailure )
        XCTAssertEqual( result.error!, "NG!" )
        XCTAssertTrue( callOnFailure )
        XCTAssertFalse( callOnSuccess )
    }
    
    func testSuccessResultWithSwitch() {
        
        locally { // On success.
            var callOnFailure = false
            var callOnSuccess = false
            let result = Result<Int,String>(success:200);
            
            switch result {
                case .Success(let value):
                    callOnSuccess = true
                    print(value)
                case .Failure(let error):
                    callOnFailure = true
                    print(error)
            }
            XCTAssertFalse( callOnFailure )
            XCTAssertTrue( callOnSuccess )
        }
        
        locally { // On Error.
            var callOnFailure = false
            var callOnSuccess = false
            let result = Result<Int,String>(failure: "ERROR!!!");
            
            switch result {
                case .Success(let value):
                    callOnSuccess = true
                    print(value)
                case .Failure(let error):
                    callOnFailure = true
                    print(error)
            }
            XCTAssertTrue( callOnFailure )
            XCTAssertFalse( callOnSuccess )
        }
    }
    
}