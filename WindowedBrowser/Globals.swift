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
