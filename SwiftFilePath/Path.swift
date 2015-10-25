//
//  Path.swift
//  SwiftFilePath
//
//  Created by nori0620 on 2015/01/08.
//  Copyright (c) 2015年 Norihiro Sakamoto. All rights reserved.
//

public class Path {
    
    // MARK: - Class methods
    
    public class func isDir(path:NSString) -> Bool {
        var isDirectory: ObjCBool = false
        NSFileManager.defaultManager().fileExistsAtPath(path as String, isDirectory:&isDirectory)
        return isDirectory ? true : false
    }
    
    // MARK: - Instance properties and initializer
    
    lazy var fileManager = NSFileManager.defaultManager()
    public let path_string:String
    
    
    public init(_ p: String) {
        self.path_string = p
    }
    
    // MARK: - Instance val
    
    public var attributes:NSDictionary?{
        get { return self.loadAttributes() }
    }
    
    public var asString: String {
        return path_string
    }
    
    public var exists: Bool {
        return fileManager.fileExistsAtPath(path_string)
    }
    
    public var isDir: Bool {
        return Path.isDir(path_string);
    }
    
    public var basename:NSString {
        return ( path_string as NSString ).lastPathComponent
    }
    
    public var parent: Path{
        return Path( (path_string as NSString ).stringByDeletingLastPathComponent )
    }
    
    // MARK: - Instance methods
    
    public func toString() -> String {
        return path_string
    }
    
    public func remove() -> Result<Path,NSError> {
        assert(self.exists,"To remove file, file MUST be exists")
        var error: NSError?
        let result: Bool
        do {
            try fileManager.removeItemAtPath(path_string)
            result = true
        } catch let error1 as NSError {
            error = error1
            result = false
        }
        return result
            ? Result(success: self)
            : Result(failure: error!);
    }
    
    public func copyTo(toPath:Path) -> Result<Path,NSError> {
        assert(self.exists,"To copy file, file MUST be exists")
        var error: NSError?
        let result: Bool
        do {
            try fileManager.copyItemAtPath(path_string,
                        toPath: toPath.toString())
            result = true
        } catch let error1 as NSError {
            error = error1
            result = false
        }
        return result
            ? Result(success: self)
            : Result(failure: error!)
    }
    
    public func moveTo(toPath:Path) -> Result<Path,NSError> {
        assert(self.exists,"To move file, file MUST be exists")
        var error: NSError?
        let result: Bool
        do {
            try fileManager.moveItemAtPath(path_string,
                        toPath: toPath.toString())
            result = true
        } catch let error1 as NSError {
            error = error1
            result = false
        }
        return result
            ? Result(success: self)
            : Result(failure: error!)
    }
    
    private func loadAttributes() -> NSDictionary? {
        assert(self.exists,"File must be exists to load file.< \(path_string) >")
        var loadError: NSError?
        let result: [NSObject: AnyObject]?
        do {
            result = try self.fileManager.attributesOfItemAtPath(path_string)
        } catch let error as NSError {
            loadError = error
            result = nil
        }
        
        if let error = loadError {
            print("Error< \(error.localizedDescription) >")
        }
        
        return result
    }
    
}

// MARK: -

extension Path:  CustomStringConvertible {
    public var description: String {
        return "\(NSStringFromClass(self.dynamicType))<path:\(path_string)>"
    }
}


