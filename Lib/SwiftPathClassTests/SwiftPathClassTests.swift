//
//  SwiftPathClassTests.swift
//  SwiftPathClassTests
//
//  Created by nori0620 on 2015/01/08.
//  Copyright (c) 2015年 nori0620. All rights reserved.
//

import Foundation
import UIKit
import XCTest

import SwiftPathClass

extension String {
    
    func match(pattern: String) -> Bool {
        var error : NSError?
        let matcher = NSRegularExpression(pattern: pattern, options: nil, error: &error)
        return matcher?.numberOfMatchesInString(self, options: nil, range: NSMakeRange(0, self.utf16Count)) != 0
    }
    
}

class SwiftPathClassTests: XCTestCase {
    
    let sandboxDir = Dir.temporaryDir.subdir("sandbox")
    
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
        
        let homeDir = Dir.homeDir
        XCTAssertTrue(
            homeDir.asString.match("/data")
        )
        
        let temporaryDir = Dir.temporaryDir
        XCTAssertTrue(
            temporaryDir.asString.match("/data/tmp/")
        )
        
        let documentsDir = Dir.documentsDir
        println(documentsDir)
        XCTAssertTrue(
            documentsDir.asString.match("/data/Documents")
        )
        
        let cacheDir = Dir.cacheDir
        println(cacheDir)
        XCTAssertTrue(
            cacheDir.asString.match("/data/Library/Caches")
        )
        
    }
    #endif
    
    func testDir(){
        let dir = sandboxDir.subdir("bar")
        XCTAssertEqual( dir.basename, "bar")
    }
    
    func testFile() {
        let file = sandboxDir.file("hoge.txt")
        XCTAssertTrue(
            file.path.match("/data/tmp/sandbox/hoge.txt")
        )
        XCTAssertEqual( file.extention, "txt")
        XCTAssertEqual( file.basename, "hoge.txt")
        XCTAssertTrue(
            file.dir.path.match("/data/tmp/sandbox")
        )
        
    }
    
    func testAttributes() {
        
        let file = sandboxDir.file("foo.txt")
        file.touch()
        let attributes = file.attributes
        var permission:Int? = file.attributes.filePosixPermissions()
        XCTAssertEqual( permission!,420);
        
    }
    
    
    // MARK:
    
    func testTouchAndRemove(){
        let file = sandboxDir.file("file.txt")
        println(file)
        
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
        
        let fruitsDir = sandboxDir.subdir("fruits")
        XCTAssertTrue(
            fruitsDir.path.match("/data/tmp/sandbox/fruits")
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
       
        let booksDir  = sandboxDir.subdir("books")
        let comicsDir = booksDir.subdir("comics")
        let comic = comicsDir.file("DragonBall")
        
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
            
            let relativeComic = self.sandboxDir.file("books/comics/DragonBall")
            println(relativeComic)
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
        let dir = sandboxDir.subdir("foo")
        XCTAssertTrue(
            dir.path.match("/data/tmp/sandbox/foo")
        )
    }
    
    func testParentDir() {
        let dir = sandboxDir.subdir("foo")
        XCTAssertTrue(
            dir.path.match("/data/tmp/sandbox/foo")
        )
        XCTAssertTrue(
            dir.parent.path.match("/data/tmp/sandbox")
        )
        XCTAssertTrue(
            dir.parent.parent.parent.path.match("/data")
        )
        XCTAssertTrue(
            dir.parent.parent.parent.parent.path.match("/")
        )
        XCTAssertTrue(
            dir.parent.parent.parent.parent.parent.parent.path.match("/")
        )
        
    }
    
    // MARK
    
    func testChildren(){
        
    }
    
    // MARK
    
    func testResult(){
        
        locally {
            let result  = Either<String,String>(success:"OK!")
            XCTAssertTrue( result.isSuccess )
            XCTAssertFalse( result.isFailure )
            XCTAssertEqual( result.successValue!,"OK!" )
            XCTAssertNil( result.error? )
        }
        
        locally {
            let result  = Either<String,String>(failure: "NG!")
            XCTAssertFalse( result.isSuccess )
            XCTAssertTrue( result.isFailure )
            XCTAssertNil( result.successValue? )
            XCTAssertEqual( result.error!,"NG!" )
        }
        
    }
    
}
