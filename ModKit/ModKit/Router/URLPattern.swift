//
//  URLSlicePattern.swift
//  ModKit
//
//  Created by wuweixin on 2020/1/10.
//  Copyright © 2020 wuweixin. All rights reserved.
//

import Foundation


public struct URLVar {
    public struct Declare: Equatable, Hashable {
        public let name: String
        public let type: String
        
        public init(name: String, type: String) {
            self.name = name
            self.type = type.lowercased()
        }
    }
    
    public let declare: Declare
    public var value: Any?
    
    public init(declare: Declare, value: Any?) {
        self.declare = declare
        self.value = value
    }
}

public enum URLSlicePattern {
    case const(String)
    case ivar(URLVar.Declare)
}

enum URLPatternNodeKey: Int {
    case node = 0
    case leaf = 1
}

enum URLPatternNodeValue {
    case node(URLPattern)
    case leaf
}

struct URLPatternNode: Hashable {
    let value: URLPattern
}

// pathVarSymbolTable path变量符号表
// [symbolIdentifier: URLVar]
//



public enum URLPattern: Equatable, Hashable {
    case schema(String?)
    case host(String?)
    case port(Int?)
    case sign(String?) // user:password
    case path(String)
    
    case end //结束
}

extension Optional: CustomStringConvertible where Wrapped: CustomStringConvertible {
    public var description: String {
        switch self {
        case .none:
            return ""
        case let .some(value):
            return value.description
        }
    }
}


extension URLComponents {
    var otherURLPatterns: [URLPattern] {
        return [.schema(scheme),
                .host(host),
                .port(port),
                .sign("\(user.description):\(password.description)")]
    }
    
    var pathURLPatterns: [URLPattern] {
        return self.path
            .split(separator: "/")
            .filter { !$0.isEmpty }
            .map { .path(String($0)) }
    }
}
