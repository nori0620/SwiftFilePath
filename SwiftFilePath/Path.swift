//
//  Path.swift
//  SwiftFilePath
//
//  Created by nori0620 on 2015/01/08.
//  Copyright (c) 2015年 Norihiro Sakamoto. All rights reserved.
//

public class Path {
    
    lazy var fileManager = NSFileManager.defaultManager()
    
    public class func isDir(path:NSString) -> Bool {
        var isDirectory: ObjCBool = false
        let isFileExists = NSFileManager.defaultManager().fileExistsAtPath(path, isDirectory:&isDirectory)
        
        return isDirectory ? true : false
    }
    
    public class func isExists(path:NSString) -> Bool {
        
        return true
    }
    
    public let path:String
    public var attributes:NSDictionary{
        get { return self.loadAttributes() }
    }
    
    public init(_ p: String) {
        self.path = p
    }
    
    public var toString : String{
        return self.path
    }
    
    public var exists: Bool {
        return fileManager.fileExistsAtPath(path)
    }
    
    public var isDir: Bool {
        return false;
    }
    
    public var basename:NSString {
        return path.lastPathComponent
    }
    
    public func remove() -> Result<Path,String> {
        assert(self.exists,"To remove file, file MUST be exists")
        var error: NSError?
        let result = fileManager.removeItemAtPath(path, error:&error)
        return result
            ? Result(success: self)
            : Result(failure: "Failed to remove file.<error:\(error?.localizedDescription) path:\(path)>");
    }
    
    public func copyTo(toPath:Path) -> Result<Path,String> {
        assert(self.exists,"To copy file, file MUST be exists")
        var error: NSError?
        let result = fileManager.copyItemAtPath(path,
            toPath: toPath.toString,
             error: &error)
        return result
            ? Result(success: self)
            : Result(failure: "Failed to copy file.<error:\(error?.localizedDescription) from-path:\(path) to-path:\(toPath)>");
    }
    
    public func moveTo(toPath:Path) -> Result<Path,String> {
        assert(self.exists,"To move file, file MUST be exists")
        var error: NSError?
        let result = fileManager.moveItemAtPath(path,
            toPath: toPath.toString,
             error: &error)
        return result
            ? Result(success: self)
            : Result(failure: "Failed to move file.<error:\(error?.localizedDescription) from-path:\(path) to-path:\(toPath)>");
    }
    
    private func loadAttributes() -> NSDictionary {
        assert(self.exists,"File must be exists to load file.< \(path) >")
        var loadError: NSError?
        let result =   self.fileManager.attributesOfItemAtPath(path, error: &loadError)
        
        if let error = loadError {
            println("Error< \(error.localizedDescription) >")
        }
        
        return result!
    }
    
}

extension Path:  Printable {
    public var description: String {
        return "\(NSStringFromClass(self.dynamicType))<path:\(path)>"
    }
}


