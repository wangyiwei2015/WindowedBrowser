//
//  WindowedBrowserApp.swift
//  WindowedBrowser
//
//  Created by leo on 2023-10-18.
//

import SwiftUI

@main
struct WindowedBrowserApp: App {
    var body: some Scene {
        WindowGroup("Home", id: "com.wyw.wb.main") {
            ContentView()
        }.defaultSize(width: 20, height: 16)
        #if os(macOS)
        .windowStyle(.hiddenTitleBar)
        #endif
        
        WindowGroup("Web Page",id: "com.wyw.wb.webview", for: URL.self) { url in
            WebpageView(entryURL: url.wrappedValue ?? URL(string: "about:blank")!)
        }.defaultSize(width: .infinity, height: .infinity)
        
        WindowGroup("Preferences", id: "com.wyw.wb.prefs") {
            PrefsView()
        } //.defaultSize(width: .infinity, height: .infinity)
    }
}

var homeWindowOpen = false
