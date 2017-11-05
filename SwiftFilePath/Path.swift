//
//  Path.swift
//  SwiftFilePath
//
//  Created by nori0620 on 2015/01/08.
//  Copyright (c) 2015年 Norihiro Sakamoto. All rights reserved.
//

public class Path {
    
    // MARK: - Class methods
    
    public class func isDir(_ path: String) -> Bool {
        var isDirectory: ObjCBool = false
        FileManager.default.fileExists(atPath: path, isDirectory: &isDirectory)
        return isDirectory.boolValue
    }
    
    // MARK: - Instance properties and initializer
    
    var fileManager: FileManager {
        return FileManager.default
    }
    
    public let url: URL
    
    public init(_ url: URL) {
        assert(url.isFileURL, "Must be file URL")
        self.url = url
    }
    
    public convenience init(_ path: String) {
        self.init(URL(fileURLWithPath: path))
    }
    
    // MARK: - Instance val
    
    public var attributes: [FileAttributeKey: Any]?{
        get { return self.loadAttributes() }
    }
    
    public var asString: String {
        return url.path
    }
    
    public var exists: Bool {
        return fileManager.fileExists(atPath: url.path)
    }
    
    public var isDir: Bool {
        return Path.isDir(url.path)
    }
    
    public var basename: String {
        return url.lastPathComponent
    }
    
    public var parent: Path {
        return Path(url.deletingLastPathComponent())
    }
    
    // MARK: - Instance methods
    
    public func toString() -> String {
        return url.path
    }
    
    @discardableResult
    public func remove() -> Result<Path, Error> {
        assert(self.exists,"To remove file, file MUST be exists")
        do {
            try fileManager.removeItem(at: url)
            return Result(success: self)
        } catch let error {
            return Result(failure: error)
        }
    }
    
    @discardableResult
    public func copyTo(_ toPath: Path) -> Result<Path,Error> {
        assert(self.exists,"To copy file, file MUST be exists")
        do {
            try fileManager.copyItem(at: url, to: toPath.url)
            return Result(success: self)
        } catch let error {
            return Result(failure: error)
        }
    }
    
    @discardableResult
    public func moveTo(_ toPath: Path) -> Result<Path,Error> {
        assert(self.exists,"To move file, file MUST be exists")
        do {
            try fileManager.moveItem(at: url, to: toPath.url)
            return Result(success: self)
        } catch let error {
            return Result(failure: error)
        }
    }
    
    private func loadAttributes() -> [FileAttributeKey: Any]? {
        assert(self.exists,"File must be exists to load file.< \(url.path) >")
        do {
            return try fileManager.attributesOfItem(atPath: url.path)
        } catch let error {
            print("Error< \(error.localizedDescription) >")
        }
        return nil
    }
    
}

// MARK: -

extension Path:  CustomStringConvertible {
    public var description: String {
        return "\(String(describing: Path.self))<path:\(url.path)>"
    }
}


