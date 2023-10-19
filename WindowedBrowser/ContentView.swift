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
            Text("Bookmarks")
            Button("NAS-SMALL") {
                openWindow(id: "com.wyw.wb.webview", value: "https://10.19.129.75:5001")
            }
            Text("Launch")
            TextField("URL", text: $str)
                .keyboardType(.URL)
            Button("open") {
                if !allWindowsURL.contains(where: {$0.1 == str}) {
                    allWindowsURL.append((UIImage(), str))
                    Task {
                        do {
                            let favicon = try await FaviconFinder(url: URL(string: str)!)
                                .downloadFavicon()
                            //print("URL of Favicon: \(favicon.url)")
                            let idx = allWindowsURL.firstIndex(where: {$0.1 == str})!
                            allWindowsURL[idx].0 = favicon.image
                        } catch let error {print("Error: \(error)")}
                    }
                }
                openWindow(id: "com.wyw.wb.webview", value: str)
            }
            ForEach(0..<allWindowsURL.count, id: \.self) {windowIndex in
                HStack {
                    Image(uiImage: allWindowsURL[windowIndex].0)
                        .resizable().scaledToFit().frame(width: 24, height: 24)
                    Text(allWindowsURL[windowIndex].1)
                }
                .contextMenu {
                    Button("close") {
                        dismissWindow(id: "com.wyw.wb.webview", value: allWindowsURL[windowIndex].1)
                        allWindowsURL.remove(at: windowIndex)
                    }
                }
            }
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
