//
//  ContentView+Actions.swift
//  WindowedBrowser
//
//  Created by leo on 2025.09.18.
//

import SwiftUI
import FaviconFinder

extension ContentView {
    func newTab(_ urlString: String) {
        var newItem = TabInfo(entryURL: safeURL(urlString), currentURL: nil, title: nil)
        webStageShared.openWindows.append(newItem)
        Task { do {
            newItem.favicon = try await FaviconFinder(url: safeURL(urlString))
                .fetchFaviconURLs().first?
                .download().image?.image
        } catch let error {print("Error: \(error)")}}
        if supportsMultipleWindows {
            openWindow(id: "com.wyw.wb.webview", value: newItem.id)
        } else { // iPhone
            withAnimation(.easeInOut(duration: 0.2)) {
                webStageShared.compactActiveWindowID = newItem.id
            }
        }
    }
    
    func showTab(_ id: UUID) {
        if supportsMultipleWindows {
            openWindow(
                id: "com.wyw.wb.webview", value: id
            )
        } else { // iPhone
            withAnimation(.easeInOut(duration: 0.2)) {
                webStageShared.compactActiveWindowID = id
            }
        }
    }
    
    func closeTab(_ index: Int) {
        if supportsMultipleWindows {
            dismissWindow(
                id: "com.wyw.wb.webview",
                value: webStageShared.openWindows[index].id
            )
        } else { // iPhone
            withAnimation(.easeInOut(duration: 0.2)) {
                webStageShared.compactActiveWindowID = nil
            }
        }
        webStageShared.openWindows.remove(at: index)
    }
}
