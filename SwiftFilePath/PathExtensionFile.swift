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
        return path_string.pathExtension
    }
    
    public func touch() -> Result<Path,String> {
        assert(!self.isDir,"Can NOT touch to dir")
        return self.exists
            ? self.updateModificationDate()
            : self.createEmptyFile()
    }
    
    public func updateModificationDate(date: NSDate = NSDate() ) -> Result<Path,String>{
        var error: NSError?
        let result = fileManager.setAttributes(
            [NSFileModificationDate :date],
            ofItemAtPath:path_string,
                error:&error
        )
        return result
            ? Result(success: self)
            : Result(failure: "Failed to modify file.< error:\(error?.localizedDescription) path:\(path_string) >");
    }
    
    private func createEmptyFile() -> Result<Path,String>{
        let result = fileManager.createFileAtPath(path_string,
            contents:NSData(),
            attributes:nil
        )
        return result
            ? Result(success: self)
            : Result(failure: "Failed to create file:\(path_string)");
    }
    
    // MARK: - read/write String
    
    public func readString() -> String? {
        assert(!self.isDir,"Can NOT read data from  dir")
        var readError:NSError?
        let read = String(contentsOfFile: path_string,
                                encoding: NSUTF8StringEncoding,
                                   error: &readError)
        
        if let error = readError {
            println("readError< \(error.localizedDescription) >")
        }
        
        return read
    }
    
    public func writeString(string:String) -> Result<Path,String> {
        assert(!self.isDir,"Can NOT write data from  dir")
        var error: NSError?
        let result = string.writeToFile(path_string,
            atomically:true,
            encoding: NSUTF8StringEncoding,
            error: &error)
        return result
            ? Result(success: self)
            : Result(failure: "Failed to write file.< error:\(error?.localizedDescription) path:\(path_string) >");
    }
    
    // MARK: - read/write NSData
    
    public func readData() -> NSData? {
        assert(!self.isDir,"Can NOT read data from  dir")
        return NSData(contentsOfFile: path_string)
    }
    
    public func writeData(data:NSData) -> Result<Path,String> {
        assert(!self.isDir,"Can NOT write data from  dir")
        let result = data.writeToFile(path_string, atomically:true)
        return result
            ? Result(success: self)
            : Result(failure: "Failed to write file.< path:\(path_string) >");
    }
    
}
