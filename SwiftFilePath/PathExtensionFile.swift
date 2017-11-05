//
//  File.swift
//  SwiftFilePath
//
//  Created by nori0620 on 2015/01/08.
//  Copyright (c) 2015年 Norihiro Sakamoto. All rights reserved.
//

// Add File Behavior to Path by extension
extension  Path {
    
    public var ext: String {
        return url.pathExtension
    }
    
    @discardableResult
    public func touch() -> Result<Path,Error> {
        assert(!self.isDir,"Can NOT touch to dir")
        return self.exists
            ? self.updateModificationDate()
            : self.createEmptyFile()
    }
    
    public func updateModificationDate(_ date: Date = Date() ) -> Result<Path,Error> {
        do {
            try fileManager.setAttributes([.modificationDate: date], ofItemAtPath: url.path)
            return Result(success: self)
        } catch let error {
            return Result(failure: error)
        }
    }
    
    @discardableResult
    private func createEmptyFile() -> Result<Path,Error> {
        return self.writeString("")
    }
    
    // MARK: - read/write String
    public func readString() -> String? {
        assert(!self.isDir,"Can NOT read data from  dir")
        
        do {
            return try String(contentsOf: url, encoding: .utf8)
        } catch let error {
            print("readError< \(error.localizedDescription) >")
        }
        return nil
    }
    
    @discardableResult
    public func writeString(_ string: String) -> Result<Path,Error> {
        assert(!self.isDir,"Can NOT write data from  dir")
        do {
            try string.write(to: url, atomically: true, encoding: .utf8)
            return Result(success: self)
        } catch let error {
            return Result(failure: error)
        }
    }
    
    // MARK: - read/write NSData
    
    public func readData() -> Data? {
        assert(!self.isDir,"Can NOT read data from  dir")
        return try? Data(contentsOf: url)
    }
    
    @discardableResult
    public func writeData(_ data: Data) -> Result<Path,Error> {
        assert(!self.isDir,"Can NOT write data from  dir")
        do {
            try data.write(to: url)
            return Result(success: self)
        } catch let error {
            return Result(failure: error)
        }
    }
    
}
