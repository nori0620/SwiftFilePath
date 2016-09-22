//
//  Path.swift
//  SwiftFilePath
//
//  Created by nori0620 on 2015/01/08.
//  Copyright (c) 2015年 Norihiro Sakamoto. All rights reserved.
//

open class Path {
    
    // MARK: - Class methods
    
    open class func isDir(_ path:NSString) -> Bool {
        var isDirectory: ObjCBool = false
        FileManager.default.fileExists(atPath: path as String, isDirectory:&isDirectory)
        return isDirectory.boolValue ? true : false
    }
    
    // MARK: - Instance properties and initializer
    
    lazy var fileManager = FileManager.default
    open let path_string:String
    
    
    public init(_ p: String) {
        self.path_string = p
    }
    
    // MARK: - Instance val
    
    open var attributes:NSDictionary?{
        get { return self.loadAttributes() }
    }
    
    open var asString: String {
        return path_string
    }
    
    open var exists: Bool {
        return fileManager.fileExists(atPath: path_string)
    }
    
    open var isDir: Bool {
        return Path.isDir(path_string as NSString);
    }
    
    open var basename:NSString {
        return ( path_string as NSString ).lastPathComponent as NSString
    }
    
    open var parent: Path{
        return Path( (path_string as NSString ).deletingLastPathComponent )
    }
    
    // MARK: - Instance methods
    
    open func toString() -> String {
        return path_string
    }
    
    @discardableResult open func remove() -> Result<Path,NSError> {
        assert(self.exists,"To remove file, file MUST be exists")
        var error: NSError?
        let result: Bool
        do {
            try fileManager.removeItem(atPath: path_string)
            result = true
        } catch let error1 as NSError {
            error = error1
            result = false
        }
        return result
            ? Result(success: self)
            : Result(failure: error!);
    }
    
    @discardableResult open func copyTo(_ toPath:Path) -> Result<Path,NSError> {
        assert(self.exists,"To copy file, file MUST be exists")
        var error: NSError?
        let result: Bool
        do {
            try fileManager.copyItem(atPath: path_string,
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
    
    @discardableResult open func moveTo(_ toPath:Path) -> Result<Path,NSError> {
        assert(self.exists,"To move file, file MUST be exists")
        var error: NSError?
        let result: Bool
        do {
            try fileManager.moveItem(atPath: path_string,
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
    
    fileprivate func loadAttributes() -> NSDictionary? {
        assert(self.exists,"File must be exists to load file.< \(path_string) >")
        var loadError: NSError?
        let result: [FileAttributeKey : Any]?
        do {
            result = try self.fileManager.attributesOfItem(atPath: path_string)
        } catch let error as NSError {
            loadError = error
            result = nil
        }
        
        if let error = loadError {
            print("Error< \(error.localizedDescription) >")
        }
        
        return result as NSDictionary?
    }
    
}

// MARK: -

extension Path:  CustomStringConvertible {
    public var description: String {
        return "\(NSStringFromClass(type(of: self)))<path:\(path_string)>"
    }
}


