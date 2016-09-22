//
//  File.swift
//  SwiftFilePath
//
//  Created by nori0620 on 2015/01/08.
//  Copyright (c) 2015年 Norihiro Sakamoto. All rights reserved.
//

// Add File Behavior to Path by extension
extension  Path {
    
    public var ext:NSString {
        return URL(fileURLWithPath:path_string).pathExtension as NSString
    }
    
    @discardableResult public func touch() -> Result<Path,NSError> {
        assert(!self.isDir,"Can NOT touch to dir")
        return self.exists
            ? self.updateModificationDate()
            : self.createEmptyFile()
    }
    
    @discardableResult public func updateModificationDate(_ date: Date = Date() ) -> Result<Path,NSError>{
        var error: NSError?
        let result: Bool
        do {
            try fileManager.setAttributes(
                        [FileAttributeKey.modificationDate :date],
                        ofItemAtPath:path_string)
            result = true
        } catch let error1 as NSError {
            error = error1
            result = false
        }
        return result
            ? Result(success: self)
            : Result(failure: error!)
    }
    
    @discardableResult fileprivate func createEmptyFile() -> Result<Path,NSError>{
        return self.writeString("")
    }
    
    // MARK: - read/write String
    
    public func readString() -> String? {
        assert(!self.isDir,"Can NOT read data from  dir")
        var readError:NSError?
        let read: String?
        do {
            read = try String(contentsOfFile: path_string,
                                            encoding: String.Encoding.utf8)
        } catch let error as NSError {
            readError = error
            read = nil
        }
        
        if let error = readError {
            print("readError< \(error.localizedDescription) >")
        }
        
        return read
    }
    
    public func writeString(_ string:String) -> Result<Path,NSError> {
        assert(!self.isDir,"Can NOT write data from  dir")
        var error: NSError?
        let result: Bool
        do {
            try string.write(toFile: path_string,
                        atomically:true,
                        encoding: String.Encoding.utf8)
            result = true
        } catch let error1 as NSError {
            error = error1
            result = false
        }
        return result
            ? Result(success: self)
            : Result(failure: error!)
    }
    
    // MARK: - read/write NSData
    
    public func readData() -> Data? {
        assert(!self.isDir,"Can NOT read data from  dir")
        return (try? Data(contentsOf: URL(fileURLWithPath: path_string)))
    }
    
    public func writeData(_ data:Data) -> Result<Path,NSError> {
        assert(!self.isDir,"Can NOT write data from  dir")
        var error: NSError?
        let result: Bool
        do {
            try data.write(to: URL(fileURLWithPath: path_string), options:.atomic)
            result = true
        } catch let error1 as NSError {
            error = error1
            result = false
        }
        return result
            ? Result(success: self)
            : Result(failure: error!)
    }
    
}
