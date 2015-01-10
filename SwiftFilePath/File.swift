//
//  File.swift
//  SwiftFilePath
//
//  Created by nori0620 on 2015/01/08.
//  Copyright (c) 2015年 Norihiro Sakamoto. All rights reserved.
//

import UIKit

public class File: Entity {
    
    public var extention:NSString {
        return path.pathExtension
    }
    
    public var dir:Dir {
        return Dir( path.stringByDeletingLastPathComponent )
    }
    
    public func touch() -> Either<File,String> {
        return self.exists
            ? self.updateModificationDate()
            : self.createEmptyFile()
    }
    
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
    
    public func writeString(string:String) -> Either<File,String> {
        var error: NSError?
        let result = string.writeToFile(path,
            atomically:true,
            encoding: NSUTF8StringEncoding,
            error: &error)
        return result
            ? Either(success: self)
            : Either(failure: "Failed to write file.< error:\(error?.localizedDescription) path:\(path) >");
    }
    
    public func updateModificationDate(date: NSDate = NSDate() ) -> Either<File,String>{
        var error: NSError?
        let result = fileManager.setAttributes(
            [NSFileModificationDate :date],
            ofItemAtPath:path,
                error:&error
        )
        return result
            ? Either(success: self)
            : Either(failure: "Failed to modify file.< error:\(error?.localizedDescription) path:\(path) >");
    }
    
    private func createEmptyFile() -> Either<File,String>{
        let result = fileManager.createFileAtPath(path,
            contents:NSData(),
            attributes:nil
        )
        return result
            ? Either(success: self)
            : Either(failure: "Failed to create file:\(path)");
    }
    
}
