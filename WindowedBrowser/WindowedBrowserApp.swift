//
//  WindowedBrowserApp.swift
//  WindowedBrowser
//
//  Created by leo on 2023-10-18.
//

import SwiftUI

@main
struct WindowedBrowserApp: App {
    
    @ObservedObject var webStageShared = WebStageShared(restore: true)
    
    var body: some Scene {
        WindowGroup("Home", id: "com.wyw.wb.main") {
            ContentView().environmentObject(webStageShared)
        }.defaultSize(width: 20, height: 16)
        #if os(macOS)
        .windowStyle(.hiddenTitleBar)
        #endif
        
        WindowGroup("Web Page",id: "com.wyw.wb.webview", for: UUID.self) { id in
            WebpageView(tabID: id.wrappedValue)
                .environmentObject(webStageShared)
        }//.defaultSize(width: .infinity, height: .infinity)
        
        WindowGroup("Preferences", id: "com.wyw.wb.prefs") {
            PrefsView().environmentObject(webStageShared)
        } //.defaultSize(width: .infinity, height: .infinity)
    }
}

var homeWindowOpen = false
