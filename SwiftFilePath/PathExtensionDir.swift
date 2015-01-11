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
        let pathString = NSSearchPathForDirectoriesInDomains(pathEnum, .UserDomainMask, true)[0] as String
        return Path( pathString )
    }
    
}
#endif

// Add Dir Behavior to Path by extension
extension Path: SequenceType {

    public var children:Array<Path>? {
        assert(self.isDir,"To get children, path must be dir< \(path_string) >")
        assert(self.exists,"Dir must be exists to get children.< \(path_string) >")
        var loadError: NSError?
        let contents =   self.fileManager.contentsOfDirectoryAtPath(path_string
            , error: &loadError)
        if let error = loadError {
            println("Error< \(error.localizedDescription) >")
        }
        
        return contents!.map({ [unowned self] content in
            return self.content(content as String)
        })
        
    }
    
    public var contents:Array<Path>? {
        return self.children
    }
    
    public func content(path_string:NSString) -> Path {
        return Path( self.path_string.stringByAppendingPathComponent(path_string) )
    }
    
    public func child(path:NSString) -> Path {
        return self.child(path)
    }
    
    public func mkdir() -> Result<Path,String> {
        if( self.exists ){
            return Result(failure: "Already exists.<path:\(path_string)>")
        }
        var error: NSError?
        let result = fileManager.createDirectoryAtPath(path_string,
            withIntermediateDirectories:true,
                attributes:nil,
                error: &error
        )
        return result
            ? Result(success: self)
            : Result(failure: "Failed to mkdir.< error:\(error?.localizedDescription) path:\(path_string) >");
        
    }
    
    public func generate() -> GeneratorOf<Path> {
        assert(self.isDir,"To get iterator, path must be dir< \(path_string) >")
        let iterator = fileManager.enumeratorAtPath(path_string)
        return GeneratorOf<Path>() {
            let optionalContent = iterator?.nextObject() as String?
            if var content = optionalContent {
                return self.content(content)
            } else {
                return .None
            }
        }
    }
    
}
