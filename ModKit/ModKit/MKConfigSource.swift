//
//  MKConfigSource.swift
//  ModKit
//
//  Created by wuweixin on 2020/1/8.
//  Copyright © 2020 wuweixin. All rights reserved.
//

import Foundation

public enum MKConfigSource {
    case none
    case fileName(String)
    case fileURL(URL)
}

public extension MKConfigSource {
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
