//
//  WebpageView.swift
//  WindowedBrowser
//
//  Created by leo on 2023-10-18.
//

import SwiftUI
import WebView
import WebKit
import FaviconFinder

struct WebpageView: View {
    let tabID: UUID?
    let navDelegate: SimpleDelegate
    var entryURL: URL {
        webStageShared.openWindows
            .first { $0.id == tabID }?
            .entryURL ?? URL(string: "about:blank")!
    }
    @Environment(\.dismiss) var dismiss
    @Environment(\.supportsMultipleWindows) var supportsMultipleWindows
    @Environment(\.openWindow) var openWindow
    @EnvironmentObject var webStageShared: WebStageShared
    @StateObject private var webViewStore = WebViewStore()
    @State private var loaded = false
    
//    init(tabID: UUID) {
//        self.tabID = tabID
//        self.entryURL = webStageShared.openWindows
//            .first { $0.id == tabID }?
//            .entryURL ?? URL(string: "about:blank")!
//    }
    init(tabID: UUID?) {
        self.tabID = tabID
        navDelegate = SimpleDelegate(
//            newTab: { url in
//                var newItem = TabInfo(entryURL: url, currentURL: nil, title: nil)
//                webStageShared.openWindows.append(newItem)
//                Task { do {
//                    newItem.favicon = try await FaviconFinder(url: url)
//                        .fetchFaviconURLs().first?
//                        .download().image?.image
//                } catch let error {print("Error: \(error)")}}
//                if supportsMultipleWindows {
//                    openWindow(id: "com.wyw.wb.webview", value: newItem.id)
//                } else { // iPhone
//                    withAnimation(.easeInOut(duration: 0.2)) {
//                        webStageShared.compactActiveWindowID = newItem.id
//                    }
//                }
//            },
//            stateUpdate: { newState in
//                switch newState {
//                case .loading:
//                    print("loading")
//                case .loaded:
//                    print("loaded")
//                case .closed:
//                    print("close")
//                }
//            }
        )
    }
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                if #available(iOS 26, *) {
                    Spacer().frame(width: 120)
                }
                if let item = webStageShared.openWindows
                    .first(where: { $0.id == tabID }) {
                    if let fvc = item.favicon {
                        Image(uiImage: fvc).resizable().scaledToFit().frame(width: 20)
                    }
                    Text(item.titleString).lineLimit(1)
                }
                Spacer()
                //control buttons, setting menu
                Menu {
                    Text("not implementerd ...")
                } label: {
                    Image(systemName: "gear.fill")
                }
                if #unavailable(iOS 26) {
                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            webStageShared.openWindows.removeAll { tabID == $0.id }
                            dismiss()
                        }
                    } label: {
                        Image(systemName: "xmark").font(.title3).tint(.gray3)
                    }.buttonStyle(TopbarBtnStyle(tint: .red)).frame(width: 50, height: 48)
                }
            }.background(Color.sysBackground)
            WebView(webView: webViewStore.webView)
        }
        .ignoresSafeArea()
        .onAppear { if !loaded {
            navDelegate.newTab = { url in
                var newItem = TabInfo(entryURL: url, currentURL: nil, title: nil)
                webStageShared.openWindows.append(newItem)
                Task { do {
                    newItem.favicon = try await FaviconFinder(url: url)
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
            navDelegate.stateUpdated = { newState in
                switch newState {
                case .loading:
                    print("loading")
                case .loaded:
                    print("loaded")
                case .closed:
                    print("close")
                }
            }
            let wv = self.webViewStore.webView
            wv.navigationDelegate = navDelegate
            wv.uiDelegate = navDelegate
            wv.scrollView.contentInsetAdjustmentBehavior = .never
            wv.load(URLRequest(url: entryURL))
            loaded = true
        }}
        .onDisappear { webStageShared.openWindows.removeAll { tabID == $0.id }}
    }
}

class SimpleDelegate: NSObject, WKNavigationDelegate, WKUIDelegate {
    
    var newTab: ((URL) -> Void)?
    var stateUpdated: ((WebPageState) -> Void)?
    enum WebPageState: Int { case loading, loaded, closed }
    init(newTab: ((URL) -> Void)? = nil, stateUpdated: ((WebPageState) -> Void)? = nil) {
        self.newTab = newTab
        self.stateUpdated = stateUpdated
    }
    
    func webView(_ webView: WKWebView, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        let credential = URLCredential(trust: challenge.protectionSpace.serverTrust!)
        completionHandler(.useCredential, credential)
    }
    
    func webViewDidClose(_ webView: WKWebView) {
        stateUpdated?(.closed)
    }
    
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        stateUpdated?(.loading)
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        stateUpdated?(.loaded)
    }
    
    func webView(
        _ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration,
        for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures
    ) -> WKWebView? {
        if let newURL = navigationAction.request.url {
            newTab?(newURL)
        }
        return nil
    }
}

#Preview {
    WebpageView(tabID: nil)
        .environmentObject(WebStageShared())
}
