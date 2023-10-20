//
//  Globals.swift
//  WindowedBrowser
//
//  Created by leo on 2023-10-18.
//

import Foundation

extension URL {
    init?(stringLiteral str: String) {
        self.init(string: str)
    }
}

func safeURL(_ str: String) -> URL {
    if let url = URL(string: str) {
        if url.scheme == nil {
            return URL(string: "https://\(url.absoluteString)")!
        }
        return url
    }
    return URL(string: "about:blank")!
}

extension Array: RawRepresentable where Element: Codable {
    public init?(rawValue: String) {
        guard let data = rawValue.data(using: .utf8),
              let result = try? JSONDecoder().decode([Element].self, from: data)
        else {return nil}
        self = result
    }
    public var rawValue: String {
        guard let data = try? JSONEncoder().encode(self),
              let result = String(data: data, encoding: .utf8)
        else {return "[]"}
        return result
    }
}

struct TabInfo: Codable {
    var id = UUID()
    var entryURL: URL
    var title: String
}

//extension UserDefaults {
//    static let shared = UserDefaults(suiteName: "group.com.wyw.")!
//}
