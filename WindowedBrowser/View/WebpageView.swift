//
//  WebpageView.swift
//  WindowedBrowser
//
//  Created by leo on 2023-10-18.
//

import SwiftUI
import WebView
import WebKit

struct WebpageView: View {
    let tabID: UUID?
    fileprivate let navDelegate = SimpleDelegate()
    var entryURL: URL {
        webStageShared.openWindows
            .first { $0.id == tabID }?
            .entryURL ?? URL(string: "about:blank")!
    }
    @EnvironmentObject var webStageShared: WebStageShared
    @StateObject private var webViewStore = WebViewStore()
    @State private var loaded = false
    
//    init(tabID: UUID) {
//        self.tabID = tabID
//        self.entryURL = webStageShared.openWindows
//            .first { $0.id == tabID }?
//            .entryURL ?? URL(string: "about:blank")!
//    }
    
    var body: some View {
        WebView(webView: webViewStore.webView)
        .ignoresSafeArea()
        .onAppear {
            if !loaded {
                let wv = self.webViewStore.webView
                wv.navigationDelegate = navDelegate
                wv.scrollView.contentInsetAdjustmentBehavior = .never
                wv.load(URLRequest(url: entryURL))
                loaded = true
            }
        }
        .onDisappear { webStageShared.openWindows.removeAll { tabID == $0.id }}
    }
}

fileprivate
class SimpleDelegate: NSObject, WKNavigationDelegate {
    func webView(_ webView: WKWebView, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        let credential = URLCredential(trust: challenge.protectionSpace.serverTrust!)
        completionHandler(.useCredential, credential)
    }
}

//#Preview {
//    WebpageView(entryURL: URL(string: "about:blank")!)
//}
