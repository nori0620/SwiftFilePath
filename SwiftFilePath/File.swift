//
//  File.swift
//  SwiftFilePath
//
//  Created by nori0620 on 2015/01/08.
//  Copyright (c) 2015年 Norihiro Sakamoto. All rights reserved.
//

public class File: Path {
    
    public var extention:NSString {
        return path.pathExtension
    }
    
    public var dir:Dir {
        return Dir( path.stringByDeletingLastPathComponent )
    }
    
    public func touch() -> Result<File,String> {
        return self.exists
            ? self.updateModificationDate()
            : self.createEmptyFile()
    }
    
    public func updateModificationDate(date: NSDate = NSDate() ) -> Result<File,String>{
        var error: NSError?
        let result = fileManager.setAttributes(
            [NSFileModificationDate :date],
            ofItemAtPath:path,
                error:&error
        )
        return result
            ? Result(success: self)
            : Result(failure: "Failed to modify file.< error:\(error?.localizedDescription) path:\(path) >");
    }
    
    private func createEmptyFile() -> Result<File,String>{
        let result = fileManager.createFileAtPath(path,
            contents:NSData(),
            attributes:nil
        )
        return result
            ? Result(success: self)
            : Result(failure: "Failed to create file:\(path)");
    }
    
    // MARK: - read/write String
    
    public func readString() -> String? {
        var readError:NSError?
        let read = String(contentsOfFile: path,
                                encoding: NSUTF8StringEncoding,
                                   error: &readError)
        
        if let error = readError {
            println("readError< \(error.localizedDescription) >")
        }
        
        return read
    }
    
    public func writeString(string:String) -> Result<File,String> {
        var error: NSError?
        let result = string.writeToFile(path,
            atomically:true,
            encoding: NSUTF8StringEncoding,
            error: &error)
        return result
            ? Result(success: self)
            : Result(failure: "Failed to write file.< error:\(error?.localizedDescription) path:\(path) >");
    }
    
    // MARK: - read/write NSData
    
    public func readData() -> NSData? {
        return NSData(contentsOfFile: path)
    }
    
    public func writeData(data:NSData) -> Result<File,String> {
        let result = data.writeToFile(path, atomically:true)
        return result
            ? Result(success: self)
            : Result(failure: "Failed to write file.< path:\(path) >");
    }
    
}
