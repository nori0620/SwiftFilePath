//
//  Either.swift
//  SwiftEither
//
//  Created by Fuji Goro on 2014/12/31.
//  Copyright (c) 2014年 FUJI Goro. All rights reserved.
//

/// Represent either Success or Failure, implementiong the Either pattern
public enum Either<S, F> {
    typealias Left = S
    typealias Right = F

    case Success(EitherContainer<S>)
    case Failure(EitherContainer<F>)

    public init(success: S) {
        self = .Success(EitherContainer(success))
    }
    public init(failure: F) {
        self = .Failure(EitherContainer(failure))
    }

    /// Evaluates the argument block with the receiver's success value if the receiver is in "success" state.
    /// Returns the failure value of the receiver otherwise.
    public func chain<S0>(f: (S) -> Either<S0, F>) -> Either<S0, F> {
        switch self {
        case .Success(let s):
            return f(s.value)
        case .Failure(let e):
            return Either<S0, F>.Failure(e)
        }
    }

    /// Returns the receiver itself if the receiver is in "success" state.
    /// Evaluates the argument block otherwise.
    public func fallback(f: () -> Either<S, F>) -> Either<S, F> {
        switch self {
        case .Success:
            return self
        case .Failure:
            return f()
        }
    }

    public var successValue: S? {
        switch self {
        case .Success(let s):
            return s.value
        case .Failure(let f):
            return nil
        }
    }

    public var failureValue: F? {
        switch self {
        case .Success(let s):
            return nil
        case .Failure(let f):
            return f.value
        }
    }
}

extension Either: Printable {
    public var description: String {
        switch self {
        case .Success(let s):
            return "Either<S,F>(success: \(s.value))"
        case .Failure(let f):
            return "Either<S,F>(failure: \(f.value))"
        }
    }
}

/// A reference type that has a value type
public class EitherContainer<T> {
    public let value: T

    internal init(_ value: T) {
        self.value = value
    }
}

/// The fallback operator, alike to null coalescing operator, executes right-hand side expression
/// if left-hand side is in failure state.
/// This is the same as left.fallback(right).
public func ??<S, E>(left: Either<S, E>, right: @autoclosure () -> Either<S, E>) -> Either<S, E> {
    return left.fallback(right)
}

public func ??<S, E>(left: Either<S, E>, right: @autoclosure () -> S) -> Either<S, E> {
    return left.fallback({
        return Either(success: right())
    })
}

//
//  EitherExtention For SwiftFilePath
//  SwiftFilePath
//
//  Created by nori0620 on 2015/01/10.
//  Copyright (c) 2015年 nori0620. All rights reserved.
//

extension Either {
    
    public var isSuccess : Bool {
        switch self {
            case .Success(let success):
                return true
            case .Failure(let failure):
                return false
        }
    }
    
    public var isFailure: Bool {
        switch self {
            case .Success(let success):
                return false
            case .Failure(let failure):
                return true
        }
    }
   
    // methods alias for SwiftFilePath
    public var value: S? { return self.successValue }
    public var error: F? { return self.failureValue }
    
}


