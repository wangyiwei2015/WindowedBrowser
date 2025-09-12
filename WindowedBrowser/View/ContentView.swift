//
//  ContentView.swift
//  WindowedBrowser
//
//  Created by leo on 2023-10-18.
//

import SwiftUI
import FaviconFinder

struct ContentView: View {
    @Environment(\.supportsMultipleWindows) private var supportsMultipleWindows
    @Environment(\.openWindow) var openWindow
    @Environment(\.dismissWindow) var dismissWindow
    @Environment(\.dismiss) var dismiss
    
    @EnvironmentObject var webStageShared: WebStageShared
    
    //@AppStorage("_OPEN_TABS") var openTabs: [TabInfo] = []
    
    @State var str: String = "https://"
    //@State var allWindowsURL: [(UIImage, String)] = []
    
    @State var showsQuitAlert = false
    @State var iPhoneShowsConfig = false
    @State var compactActiveWindowURL: URL? = nil
    
    var body: some View {
        ZStack {
            Color.gray6
            VStack(spacing: 0) {
                VStack(spacing: 0) {
                    Color.sysBackground
                    topBar.frame(height: supportsMultipleWindows ? 48 : 60)
                }.frame(height: supportsMultipleWindows ? 48 : 90)
                launchURLView
                bookmarkView
                Spacer()
                bottomTabs
            }
            // overlay
            if !supportsMultipleWindows {
                Color.black.opacity(
                    iPhoneShowsConfig || webStageShared.openWindows
                        .contains { $0.entryURL == compactActiveWindowURL }
                        ? 0.5 : 0.0
                )
                CompactWindow($iPhoneShowsConfig) {
                    PrefsView()
                }
                ForEach(webStageShared.openWindows, id: \.id) { webItem in
                    CompactWebWindow(
                        webItem, activeURL: $compactActiveWindowURL) {
                            webStageShared.openWindows.removeAll { $0.entryURL == webItem.entryURL }
                        } content: {
                            WebpageView(entryURL: webItem.entryURL)
                        }

                }
            }
        }
        .ignoresSafeArea()
        .onOpenURL { url in
            print(url)
            guard url.scheme == "w-browser" else {
                return
            }
            guard url.host() == "new" else {
                return
            }
            let tmp = (url.query() ?? "").components(separatedBy: "=")
            if tmp.first == "url" {
                if let toOpen = tmp.last {
                    openWindow(id: "com.wyw.wb.webview", value: safeURL(toOpen))
                }
            }
        }
        .onAppear {
            if homeWindowOpen {
                dismiss()
            } else {
                homeWindowOpen = true
            }
//            onCloseWindow = { url in
//                print(allWindowsURL.first(where: { safeURL($0.1) == url }))
//                allWindowsURL.removeAll(
//                    where: { safeURL($0.1) == url }
//                )
//            }
        }
        .alert(
            Text("Quit WBrowser"), isPresented: $showsQuitAlert) {
                Button("Cancel", role: .cancel) {
                    //
                }
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
    
    func newTab(_ urlString: String) {
        if !webStageShared.openWindows.contains(where: {$0.entryURL.absoluteString == urlString}) {
            webStageShared.openWindows.append(.init(entryURL: safeURL(urlString), title: "title000"))
            Task {
                do {
                    let favicon = try await FaviconFinder(url: safeURL(urlString))
                        .fetchFaviconURLs().first?
                        .download().image?.image
                    let idx = webStageShared.openWindows.firstIndex(where: {$0.entryURL.absoluteString == urlString})!
                    webStageShared.openWindows[idx].favicon = favicon
                } catch let error {print("Error: \(error)")}
            }
        }
        if supportsMultipleWindows {
            openWindow(id: "com.wyw.wb.webview", value: safeURL(urlString))
        } else { // iPhone
            withAnimation(.easeInOut(duration: 0.2)) {
                compactActiveWindowURL = safeURL(urlString)
            }
        }
    }
    
    @ViewBuilder var topBar: some View {
        ZStack {
            Color.sysBackground
            HStack(spacing: 0) {
                Text(supportsMultipleWindows
                    ? "WBrowser Home (\(webStageShared.openWindows.count) tabs)"
                     : "\(webStageShared.openWindows.count) tabs"
                ).padding(.horizontal, 20)
                Spacer()
                Button {
                    UIApplication.shared.perform(#selector(NSXPCConnection.suspend))
                } label: {
                    Image(systemName: "minus").font(.title3).tint(.gray3)
                }.buttonStyle(TopbarBtnStyle(tint: .gray5)).frame(width: 50)
                //.hoverEffect(.highlight)
                Button {
                    showsQuitAlert = true
                } label: {
                    Image(systemName: "xmark").font(.title3).tint(.gray3)
                }.buttonStyle(TopbarBtnStyle(tint: .red)).frame(width: 50)
            }.padding(.top, 8)
        }
    } // top view
    
    @ViewBuilder var launchURLView: some View {
        HStack(spacing: 0) {
            Text("URL").frame(width: 70)
            TextField("URL", text: $str)
                .keyboardType(.URL)
                .textFieldStyle(.roundedBorder)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)
                .shadow(radius: 1, y: 2)
            Button {
                newTab(str)
                str = "https://"
            } label: {
                Label("Go", systemImage: "swift").foregroundColor(Color("WBColor"))
            }.buttonStyle(HomeBtnStyle())
            .frame(width: 90, height: 35).padding()
        }.font(.title3)
        .padding(.vertical)
    } // launch url
    
    @ViewBuilder var bookmarkView: some View {
        VStack {
            Text("Bookmarks")
            Button("NAS-SMALL") {
                newTab("https://10.19.129.75:5001")
            }
            
            Button("Preferences") {
                if supportsMultipleWindows {
                    openWindow(id: "com.wyw.wb.prefs")
                } else {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        iPhoneShowsConfig = true
                    }
                }
            } // Prefs btn
        }
    } // bookmarks
    
    @ViewBuilder var bottomTabs: some View {
        VStack {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 200))]) {
                ForEach(0..<webStageShared.openWindows.count, id: \.self) {windowIndex in
                    if supportsMultipleWindows {
                        Menu {
                            menuItems(windowIndex)
                        } label: {
                            tabLabel(windowIndex)
                        }.buttonStyle(HomeBtnStyle())
                        .contextMenu { menuItems(windowIndex) }
                    } else { // iPhone
                        Button {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                compactActiveWindowURL = webStageShared.openWindows[windowIndex].entryURL
                            }
                        } label: {
                            tabLabel(windowIndex)
                        }.buttonStyle(HomeBtnStyle())
                        .contextMenu { menuItems(windowIndex) }
                    }
                } // For each
            }.padding(.horizontal)
            Text("\(UIScreen.main.bounds.debugDescription)")
        }
    } // bottom view
    
    @ViewBuilder func tabLabel(_ windowIndex: Int) -> some View {
        ZStack {
            HStack {
                if let favicon = webStageShared.openWindows[windowIndex].favicon {
                    Image(uiImage: favicon).resizable().scaledToFit()
                        .frame(width: 24, height: 24)
                }
                Text(webStageShared.openWindows[windowIndex].title).lineLimit(1)
            }.padding(.vertical, 12).padding(.horizontal, 8)
        }
    }
    
    @ViewBuilder func menuItems(_ windowIndex: Int) -> some View {
        Button(role: .destructive) {
            if supportsMultipleWindows {
                dismissWindow(
                    id: "com.wyw.wb.webview",
                    value: webStageShared.openWindows[windowIndex].entryURL
                    //value: safeURL(allWindowsURL[windowIndex].1)
                )
            } else { // iPhone
                withAnimation(.easeInOut(duration: 0.2)) {
                    compactActiveWindowURL = nil
                }
            }
            webStageShared.openWindows.remove(at: windowIndex)
        } label: {
            Label("Close", systemImage: "xmark")
        }
        Button {
            //
        } label: {
            Label("Add bookmark", systemImage: "bookmark")
        }
        Button {
            //
        } label: {
            Label("Share", systemImage: "square.and.arrow.up")
        }
        Button {
            if supportsMultipleWindows {
                openWindow(
                    id: "com.wyw.wb.webview",
                    value: webStageShared.openWindows[windowIndex].entryURL
                    //value: safeURL(allWindowsURL[windowIndex].1)
                )
            } else { // iPhone
                withAnimation(.easeInOut(duration: 0.2)) {
                    compactActiveWindowURL = webStageShared.openWindows[windowIndex].entryURL
                }
            }
        } label: {
            Label("Show", systemImage: "arrow.down.left.and.arrow.up.right.square")
        }
    }
}

#Preview {
//    ContentView(allWindowsURL: [
//        (UIImage(systemName: "swift")!, "www.bing.com"),
//        (UIImage(systemName: "swift")!, "about:blank"),
//    ], iPhoneShowsConfig: false)
    ContentView().environmentObject(WebStageShared())
}
