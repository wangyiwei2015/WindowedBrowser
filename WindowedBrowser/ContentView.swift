//
//  ContentView.swift
//  WindowedBrowser
//
//  Created by leo on 2023-10-18.
//

import SwiftUI
import FaviconFinder

struct ContentView: View {
    @Environment(\.openWindow) var openWindow
    @Environment(\.dismissWindow) var dismissWindow
    
    @State var str: String = ""
    @State var allWindowsURL: [(UIImage, String)] = []
    
    var body: some View {
        VStack {
            Button("minimize") {
                UIApplication.shared.perform(#selector(NSXPCConnection.suspend))
            }
            Text("URL scheme: w-browser://new?url={URL}")
            Text("Bookmarks")
            Button("NAS-SMALL") {
                openWindow(id: "com.wyw.wb.webview", value: safeURL("https://10.19.129.75:5001"))
            }
            Text("Launch")
            TextField("URL", text: $str)
                .keyboardType(.URL)
            Button("open") {
                if !allWindowsURL.contains(where: {$0.1 == str}) {
                    allWindowsURL.append((UIImage(), str))
                    Task {
                        do {
                            let favicon = try await FaviconFinder(url: safeURL(str))
                                .downloadFavicon()
                            //print("URL of Favicon: \(favicon.url)")
                            let idx = allWindowsURL.firstIndex(where: {$0.1 == str})!
                            allWindowsURL[idx].0 = favicon.image
                        } catch let error {print("Error: \(error)")}
                    }
                }
                openWindow(id: "com.wyw.wb.webview", value: safeURL(str))
                str = ""
            }
            ForEach(0..<allWindowsURL.count, id: \.self) {windowIndex in
                HStack {
                    Image(uiImage: allWindowsURL[windowIndex].0)
                        .resizable().scaledToFit().frame(width: 24, height: 24)
                    Text(allWindowsURL[windowIndex].1)
                }
                .contextMenu {
                    Button("close") {
                        dismissWindow(id: "com.wyw.wb.webview", value: safeURL(allWindowsURL[windowIndex].1))
                        allWindowsURL.remove(at: windowIndex)
                    }
                }
            }
        }
        .padding()
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
    }
}

#Preview {
    ContentView()
}
