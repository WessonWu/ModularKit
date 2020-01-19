//
//  ConfigSource.swift
//  ModKit
//
//  Created by wuweixin on 2020/1/8.
//  Copyright © 2020 wuweixin. All rights reserved.
//

import Foundation

public enum ConfigSource {
    case none
    case fileName(String)
    case fileURL(URL)
}

public extension ConfigSource {
    var fileURL: URL? {
        switch self {
        case .none:
            return nil
        case let .fileName(fileName):
            return Bundle.main.url(forResource: fileName, withExtension: "plist")
        case let .fileURL(fileURL):
            return fileURL
        }
    }
}

public enum ServiceConfigKey {
    public static let moduleName = "moduleName"
    public static let serviceClass = "serviceClass"
    public static let serviceImpl = "serviceImpl"
}

public enum ModuleConfigKey {
    public static let moduleList = "moduleList"
    public static let moduleName = "moduleName"
    public static let moduleClass = "moduleClass"
    public static let moduleLevel = "moduleLevel"
    public static let modulePriority = "modulePriority"
}
