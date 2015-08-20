//
//  Result.swift
//  SwiftFilePath
//
//  Created by nori0620 on 2015/01/11.
//  Copyright (c) 2015年 Norihiro Sakamoto. All rights reserved.
//

public enum Result<S,F> {
    
    case Success(ResultContainer<S>)
    case Failure(ResultContainer<F>)
    
    public init(success:S){
        self = .Success( ResultContainer(success) )
    }
    
    public init(failure:F){
        self = .Failure( ResultContainer(failure) )
    }
    
    public var isSuccess:Bool {
        switch self {
            case .Success: return true
            case .Failure: return false
        }
        
    }
    
    public var isFailure:Bool {
        switch self {
            case .Success: return false
            case .Failure: return true
        }
    }
    
    public var value:S? {
        switch self {
        case .Success(let container):
            return container.content
        case .Failure( _):
            return .None
        }
    }
    
    public var error:F? {
        switch self {
        case .Success( _):
            return .None
        case .Failure(let container):
            return container.content
        }
    }
    
    public func onFailure(handler:(F) -> Void ) -> Result<S,F> {
        switch self {
        case .Success( _):
            return self
        case .Failure(let container):
            handler( container.content )
            return self
        }
    }
    
    public func onSuccess(handler:(S) -> Void ) -> Result<S,F> {
        switch self {
        case .Success(let container):
            handler( container.content )
            return self
        case .Failure( _):
            return self
        }
    }
   
}

public class ResultContainer<T> {
    let content:T
    init(_ content:T){
        self.content = content
    }
}
