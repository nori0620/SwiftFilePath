//
//  Dir.swift
//  SwiftFilePath
//
//  Created by nori0620 on 2015/01/08.
//  Copyright (c) 2015年 Norihiro Sakamoto. All rights reserved.
//

// Instance Factories for accessing to readable iOS dirs.
#if os(iOS)
extension Path {
    
    public class var homeDir :Path{
        let pathString = NSHomeDirectory()
        return Path( pathString )
    }
    
    public class var temporaryDir:Path {
        let pathString = NSTemporaryDirectory()
        return Path( pathString )
    }
    
    public class var documentsDir:Path {
        return Path.userDomainOf(.DocumentDirectory)
    }
    
    public class var cacheDir:Path {
        return Path.userDomainOf(.CachesDirectory)
    }
    
    private class func userDomainOf(pathEnum:NSSearchPathDirectory)->Path{
        let pathString = NSSearchPathForDirectoriesInDomains(pathEnum, .UserDomainMask, true)[0] 
        return Path( pathString )
    }
    
}
#endif

// Add Dir Behavior to Path by extension
extension Path: SequenceType {
    
    public subscript(filename: String) -> Path{
        get { return self.content(filename) }
    }

    public var children:Array<Path>? {
        assert(self.isDir,"To get children, path must be dir< \(path_string) >")
        assert(self.exists,"Dir must be exists to get children.< \(path_string) >")
        var loadError: NSError?
        let contents: [AnyObject]?
        do {
            contents = try self.fileManager.contentsOfDirectoryAtPath(path_string
                        )
        } catch let error as NSError {
            loadError = error
            contents = nil
        }
        if let error = loadError {
            print("Error< \(error.localizedDescription) >")
        }
        
        return contents!.map({ [unowned self] content in
            return self.content(content as! String)
        })
        
    }
    
    public var contents:Array<Path>? {
        return self.children
    }
    
    public func content(path_string:NSString) -> Path {
        return Path(
            NSURL(fileURLWithPath: self.path_string)
                .URLByAppendingPathComponent( path_string as String )
                .path!
        )
    }
    
    public func child(path:NSString) -> Path {
        return self.content(path)
    }
    
    public func mkdir() -> Result<Path,NSError> {
        var error: NSError?
        let result: Bool
        do {
            try fileManager.createDirectoryAtPath(path_string,
                        withIntermediateDirectories:true,
                            attributes:nil)
            result = true
        } catch let error1 as NSError {
            error = error1
            result = false
        }
        return result
            ? Result(success: self)
            : Result(failure: error!)
        
    }
    
    public func generate() -> AnyGenerator<Path> {
        assert(self.isDir,"To get iterator, path must be dir< \(path_string) >")
        let iterator = fileManager.enumeratorAtPath(path_string)
        return anyGenerator() {
            let optionalContent = iterator?.nextObject() as! String?
            if let content = optionalContent {
                return self.content(content)
            } else {
                return .None
            }
        }
    }
    
}
