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
        return Path.userDomainOf(.documentDirectory)
    }
    
    public class var cacheDir:Path {
        return Path.userDomainOf(.cachesDirectory)
    }
    
    private class func userDomainOf(_ pathEnum: FileManager.SearchPathDirectory) -> Path {
        let pathString = NSSearchPathForDirectoriesInDomains(pathEnum, .userDomainMask, true)[0]
        return Path(pathString)
    }
    
}
#endif

// Add Dir Behavior to Path by extension
extension Path: Sequence {
    
    public subscript(filename: String) -> Path {
        return content(filename)
    }

    public var children: [Path]? {
        assert(self.isDir,"To get children, path must be dir< \(url.path) >")
        assert(self.exists,"Dir must be exists to get children.< \(url.path) >")
        do {
            let contents = try fileManager.contentsOfDirectory(atPath: url.path)
            return contents.map({
                content($0)
            })
        } catch let error {
            print("Error< \(error.localizedDescription) >")
        }
        return nil
    }
    
    public var contents: [Path]? {
        return children
    }
    
    public func content(_ path: String) -> Path {
        return Path(url.appendingPathComponent(path))
    }
    
    public func child(_ path: String) -> Path {
        return content(path)
    }
    
    @discardableResult
    public func mkdir() -> Result<Path,Error> {
        do {
            try fileManager.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
            return Result(success: self)
        } catch let error {
            return Result(failure: error)
        }
    }
    
    public func makeIterator() -> AnyIterator<Path> {
        assert(self.isDir,"To get iterator, path must be dir< \(url.path) >")
        let iterator = fileManager.enumerator(atPath: url.path)
        return AnyIterator() {
            if let content = iterator?.nextObject() as? String {
                return self.content(content)
            }
            return .none
        }
    }
}
