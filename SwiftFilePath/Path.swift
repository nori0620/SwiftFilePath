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
        let isFileExists = NSFileManager.defaultManager().fileExistsAtPath(path, isDirectory:&isDirectory)
        
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
        return path_string.lastPathComponent
    }
    
    public var parent: Path{
        return Path( path_string.stringByDeletingLastPathComponent )
    }
    
    // MARK: - Instance methods
    
    public func toString() -> String {
        return path_string
    }
    
    public func remove() -> Result<Path,NSError> {
        assert(self.exists,"To remove file, file MUST be exists")
        var error: NSError?
        let result = fileManager.removeItemAtPath(path_string, error:&error)
        return result
            ? Result(success: self)
            : Result(failure: error!);
    }
    
    public func copyTo(toPath:Path) -> Result<Path,NSError> {
        assert(self.exists,"To copy file, file MUST be exists")
        var error: NSError?
        let result = fileManager.copyItemAtPath(path_string,
            toPath: toPath.toString(),
             error: &error)
        return result
            ? Result(success: self)
            : Result(failure: error!)
    }
    
    public func moveTo(toPath:Path) -> Result<Path,NSError> {
        assert(self.exists,"To move file, file MUST be exists")
        var error: NSError?
        let result = fileManager.moveItemAtPath(path_string,
            toPath: toPath.toString(),
             error: &error)
        return result
            ? Result(success: self)
            : Result(failure: error!)
    }
    
    private func loadAttributes() -> NSDictionary? {
        assert(self.exists,"File must be exists to load file.< \(path_string) >")
        var loadError: NSError?
        let result =   self.fileManager.attributesOfItemAtPath(path_string, error: &loadError)
        
        if let error = loadError {
            println("Error< \(error.localizedDescription) >")
        }
        
        return result
    }
    
}

// MARK: -

extension Path:  Printable {
    public var description: String {
        return "\(NSStringFromClass(self.dynamicType))<path:\(path_string)>"
    }
}


