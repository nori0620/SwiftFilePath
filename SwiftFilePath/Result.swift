//
//  Result.swift
//  SwiftFilePath
//
//  Created by nori0620 on 2015/01/11.
//  Copyright (c) 2015年 Norihiro Sakamoto. All rights reserved.
//

public enum Result<S,F> {
    
    case Success(S)
    case Failure(F)
    
    public init(success:S){
        self = .Success(success)
    }
    
    public init(failure:F){
        self = .Failure(failure)
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
        case .Success(let success):
            return success
        case .Failure(_):
            return .None
        }
    }
    
    public var error:F? {
        switch self {
        case .Success(_):
            return .None
        case .Failure(let error):
            return error
        }
    }
    
    public func onFailure(handler:(F) -> Void ) -> Result<S,F> {
        switch self {
        case .Success(_):
            return self
        case .Failure(let error):
            handler( error )
            return self
        }
    }
    
    public func onSuccess(handler:(S) -> Void ) -> Result<S,F> {
        switch self {
        case .Success(let success):
            handler(success )
            return self
        case .Failure(_):
            return self
        }
    }
   
}