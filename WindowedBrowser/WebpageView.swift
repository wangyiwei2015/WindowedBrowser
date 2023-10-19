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
    var entryURL: URL
    fileprivate let navDelegate = SimpleDelegate()
    
    @StateObject var webViewStore = WebViewStore()
    @State var loaded = false
    
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
        .onDisappear {print("disap")}
    }
}

fileprivate
class SimpleDelegate: NSObject, WKNavigationDelegate {
    func webView(_ webView: WKWebView, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        let credential = URLCredential(trust: challenge.protectionSpace.serverTrust!)
        completionHandler(.useCredential, credential)
    }
}

#Preview {
    WebpageView(entryURL: URL(string: "about:blank")!)
}
