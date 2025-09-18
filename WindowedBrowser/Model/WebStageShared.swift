//
//  WebStageShared.swift
//  WindowedBrowser
//
//  Created by leo on 2024-12-28.
//

import SwiftUI
import Combine

class WebStageShared: ObservableObject {
    @Published var openWindows: [TabInfo] = []
    
    func saveSession() {
        var savedTabs: [UUID: URL] = [:]
        openWindows.forEach {
            savedTabs[$0.id] = $0.currentURL ?? $0.entryURL
        }
        UserDefaults.standard.set(savedTabs, forKey: "_SAVED_TABS")
    }
    
    convenience init(restore: Bool = false) {
        self.init()
        if restore {
            if let savedTabs = UserDefaults.standard
                .object(forKey: "_SAVED_TABS") as? [UUID: URL] {
                savedTabs.forEach { (_, url) in
                    openWindows.append(TabInfo(
                        entryURL: url, currentURL: url,
                        title: nil, favicon: nil, screenshot: nil
                    ))
                }
            }
        }
    }
}

struct TabInfo {
    let id = UUID()
    let entryURL: URL
    var currentURL: URL? = nil
    var title: String? = nil
    var favicon: UIImage? = nil
    var screenshot: UIImage? = nil
    
    var titleString: String {
        title ?? currentURL?.absoluteString ?? entryURL.absoluteString
    }
}
