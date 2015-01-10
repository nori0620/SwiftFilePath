//
//  Dir.swift
//  SwiftPathClass
//
//  Created by nori0620 on 2015/01/08.
//  Copyright (c) 2015年 nori0620. All rights reserved.
//

import UIKit


#if os(iOS)
extension Dir {
    
    // Instance Factories for accessing to readable iOS dirs.
    
    public class var homeDir :Dir {
        let pathString = NSHomeDirectory()
        return Dir( pathString )
    }
    
    public class var temporaryDir:Dir {
        let pathString = NSTemporaryDirectory()
        return Dir( pathString )
    }
    
    public class var documentsDir:Dir {
        return Dir.userDomainOf(.DocumentDirectory)
    }
    
    public class var cacheDir:Dir {
        return Dir.userDomainOf(.CachesDirectory)
    }
    
    private class func userDomainOf(pathEnum:NSSearchPathDirectory)->Dir{
        let pathString = NSSearchPathForDirectoriesInDomains(pathEnum, .UserDomainMask, true)[0] as String
        return Dir( pathString )
    }
    
}
#endif

public class Dir: Entity,SequenceType {

    override public var isDir: Bool {
        return true;
    }
    
    public var parent: Dir {
        return Dir( path.stringByDeletingLastPathComponent )
    }
    
    public var children:Array<Entity> {
        assert(self.exists,"Dir must be exists to get children.< \(path) >")
        var loadError: NSError?
        let contents =   self.fileManager.contentsOfDirectoryAtPath(path, error: &loadError)
        if let error = loadError {
            println("Error< \(error.localizedDescription) >")
        }
        
        return contents!.map({ [unowned self] content in
            return self.entityFromFile(content as String)
        })
        
    }
    
    public var contents:Array<Entity> {
        return self.children
    }
    
    public func file(path:NSString) -> File {
        return File( self.path.stringByAppendingPathComponent(path) )
    }
    
    public func subdir(path:NSString) -> Dir {
        return Dir( self.path.stringByAppendingPathComponent(path) )
    }
    
    public func mkdir() -> Either<Dir,String> {
        if( self.exists ){
            return Either(failure: "Already exists.<path:\(path)>")
        }
        var error: NSError?
        let result = fileManager.createDirectoryAtPath(path,
            withIntermediateDirectories:true,
                attributes:nil,
                error: &error
        )
        return result
            ? Either(success: self)
            : Either(failure: "Failed to mkdir.< error:\(error?.localizedDescription) path:\(path) >");
        
    }
    
    public func generate() -> GeneratorOf<Entity> {
        let iterator = fileManager.enumeratorAtPath(path)
        return GeneratorOf<Entity>() {
            let optionalContent = iterator?.nextObject() as String?
            if var content = optionalContent {
                return self.entityFromFile(content)
            } else {
                return .None
            }
        }
    }
    
    private func entityFromFile(file:NSString) -> Entity{
            let fullPath = self.path.stringByAppendingPathComponent(file)
            return Entity.isDir( fullPath )
                ? self.subdir(file)
                : self.file(file);
    }
    
}
