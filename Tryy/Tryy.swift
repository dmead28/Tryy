//
//  Tryy.swift
//  Tryy
//
//  Created by Doug Mead on 7/15/17.
//  Copyright © 2017 Doug Mead. All rights reserved.
//

import Foundation


// MARK: - Tuple version

public func tryy<T>(_ block: () throws -> (T)) -> (Error?, T?) {
    var value: T?
    var err: Error?
    do {
        value = try block()
    } catch let error {
        err = error
    }
    return (err, value)
}

public func ___<T>(_ block: () throws -> (T)) -> (Error?, T?) {
    return tryy(block)
}

prefix operator <--
public prefix func <--<T>(block: () throws -> (T)) -> (Error?, T?) {
    return tryy(block)
}

// MARK: - Enum version

public enum TryWrapResult<T> {
    case value(value: T)
    case error(error: Error)
    var value: T? {
        if case .value(let newVal) = self {
            return newVal
        } else {
            return nil
        }
    }
    var error: Error? {
        if case .error(let newError) = self {
            return newError
        } else {
            return nil
        }
    }
}

public func tryyWrap<T>(_ block: () throws -> (T)) -> TryWrapResult<T> {
    do {
        let value = try block()
        return TryWrapResult.value(value: value)
    } catch let error {
        return TryWrapResult.error(error: error)
    }
}

public func __<T>(_ block: () throws -> (T)) -> TryWrapResult<T> {
    return tryyWrap(block)
}

prefix operator <-
public prefix func <-<T>(block: () throws -> T) -> TryWrapResult<T> {
    return tryyWrap(block)
}
