//
//  File.swift
//  SwiftPathClass
//
//  Created by nori0620 on 2015/01/08.
//  Copyright (c) 2015年 nori0620. All rights reserved.
//

import UIKit

public class File: Entity {
    
    public func touch() -> Either<File,String> {
        return self.exists
            ? self.updateModificationDate()
            : self.createEmptyFile()
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
    
    public var extention:NSString {
        return path.pathExtension
    }
    
    public var dir:Dir {
        return Dir( path.stringByDeletingLastPathComponent )
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
