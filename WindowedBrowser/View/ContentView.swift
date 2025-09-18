//
//  ContentView.swift
//  WindowedBrowser
//
//  Created by leo on 2023-10-18.
//

import SwiftUI
import FaviconFinder

struct ContentView: View {
    @Environment(\.supportsMultipleWindows) var supportsMultipleWindows
    @Environment(\.openWindow) var openWindow
    @Environment(\.dismissWindow) var dismissWindow
    @Environment(\.dismiss) var dismiss
    
    @EnvironmentObject var webStageShared: WebStageShared
    
    @State var str: String = "https://"
    @State var showsQuitAlert = false
    @State var iPhoneShowsConfig = false
    @State var compactActiveWindowID: UUID? = nil
    
    var body: some View {
        ZStack {
            Color.gray6
            VStack(spacing: 0) {
                VStack(spacing: 0) {
                    Color.sysBackground
                    topBar.frame(height: supportsMultipleWindows ? 48 : 60)
                }.frame(height: supportsMultipleWindows ? 48 : 90)
                launchURLView
                bookmarkView.padding(.bottom)
                ScrollView(.vertical) {
                    bottomTabs.padding(8)
                }
                .background(
                    RoundedRectangle(cornerRadius: 16).fill(Color.sysBackground)
                ).padding()
                Text("Version test").padding(.bottom)
            }
            // overlay
            if !supportsMultipleWindows {
                Color.black.opacity(
                    iPhoneShowsConfig || webStageShared.openWindows
                        .contains { $0.id == compactActiveWindowID }
                        ? 0.5 : 0.0
                )
                CompactWindow($iPhoneShowsConfig) {
                    PrefsView()
                }
                ForEach(webStageShared.openWindows, id: \.id) { webItem in
                    CompactWebWindow(
                        webItem, activeTabID: $compactActiveWindowID) {
                            webStageShared.openWindows.removeAll { $0.id == webItem.id }
                        } content: {
                            WebpageView(tabID: webItem.id)
                        }

                }
            }
        }
        .ignoresSafeArea(.all)
        .onOpenURL { url in
            print(url)
            guard url.scheme == "w-browser" else { return }
            guard url.host() == "new" else { return }
            let tmp = (url.query() ?? "").components(separatedBy: "=")
            if tmp.first == "url" {
                if let toOpen = tmp.last {
                    openWindow(id: "com.wyw.wb.webview", value: safeURL(toOpen))
                }
            }
        }
        .onAppear {
            if homeWindowOpen { dismiss() }
            else { homeWindowOpen = true }
        }
        .alert(
            Text("Quit WebStage"), isPresented: $showsQuitAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Quit?", role: .destructive) {
                    UIApplication.shared.perform(#selector(NSXPCConnection.suspend))
                    Task {
                        try? await Task.sleep(nanoseconds: 1_000_000_000)
                        exit(0)
                    }
                }
            } message: {
                Text("You have \(webStageShared.openWindows.count) open windows")
            }
    }
}

#if targetEnvironment(simulator)
#Preview {
    ContentView().environmentObject({
        let d = WebStageShared()
        d.openWindows = [
            .init(entryURL: URL(string: "about:blank")!),
            .init(entryURL: URL(string: "about:blank")!),
            .init(entryURL: URL(string: "about:blank")!),
            .init(entryURL: URL(string: "about:blank")!),
            .init(entryURL: URL(string: "about:blank")!),
            .init(entryURL: URL(string: "about:blank")!),
            .init(entryURL: URL(string: "about:blank")!),
        ]
        return d
    }())
}
#endif
