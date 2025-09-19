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
    @Environment(\.dismiss) var dismiss
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
            Color.red
            WebView(webView: webViewStore.webView)
        }
        .ignoresSafeArea()
        .onAppear { if !loaded {
            let wv = self.webViewStore.webView
            wv.navigationDelegate = navDelegate
            wv.scrollView.contentInsetAdjustmentBehavior = .never
            wv.load(URLRequest(url: entryURL))
            loaded = true
        }}
        .onDisappear { webStageShared.openWindows.removeAll { tabID == $0.id }}
    }
}

fileprivate
class SimpleDelegate: NSObject, WKNavigationDelegate {
    func webView(_ webView: WKWebView, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        let credential = URLCredential(trust: challenge.protectionSpace.serverTrust!)
        completionHandler(.useCredential, credential)
    }
    
    //func w
}

#Preview {
    WebpageView(tabID: nil)
        .environmentObject(WebStageShared())
}
