//
//  Result.swift
//  SwiftFilePath
//
//  Created by nori0620 on 2015/01/11.
//  Copyright (c) 2015年 Norihiro Sakamoto. All rights reserved.
//

public enum Result<S,F> {
    
    case success(S)
    case failure(F)
    
    public init(success:S){
        self = .success(success)
    }
    
    public init(failure:F){
        self = .failure(failure)
    }
    
    public var isSuccess:Bool {
        switch self {
            case .success: return true
            case .failure: return false
        }
        
    }
    
    public var isFailure:Bool {
        switch self {
            case .success: return false
            case .failure: return true
        }
    }
    
    public var value:S? {
        switch self {
        case .success(let success):
            return success
        case .failure(_):
            return .none
        }
    }
    
    public var error:F? {
        switch self {
        case .success(_):
            return .none
        case .failure(let error):
            return error
        }
    }
    
    public func onFailure(_ handler:(F) -> Void ) -> Result<S,F> {
        switch self {
        case .success(_):
            return self
        case .failure(let error):
            handler( error )
            return self
        }
    }
    
    public func onSuccess(_ handler:(S) -> Void ) -> Result<S,F> {
        switch self {
        case .success(let success):
            handler(success )
            return self
        case .failure(_):
            return self
        }
    }
   
}
