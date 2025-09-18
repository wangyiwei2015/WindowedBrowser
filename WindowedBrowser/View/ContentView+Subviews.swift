//
//  ContentView+Subviews.swift
//  WindowedBrowser
//
//  Created by leo on 2025.09.18.
//

import SwiftUI

extension ContentView {
    @ViewBuilder var topBar: some View {
        ZStack {
            Color.sysBackground
            HStack(spacing: 0) {
                if #available(iOS 26, *) {
                    Spacer().frame(width: 100)
                }
                Text(supportsMultipleWindows
                    ? "WebStage Manager (\(webStageShared.openWindows.count) tabs)"
                     : "\(webStageShared.openWindows.count) tabs"
                ).padding(.horizontal, 20)
                Spacer()
                if #unavailable(iOS 26) { // shows below 26
                    topTrailingButtons
                } else if !supportsMultipleWindows { // shows on iPhone
                    topTrailingButtons
                }
            }.padding(.top, 8)
        }
    } // top view
    
    @ViewBuilder var topTrailingButtons: some View {
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
    }
    
    @ViewBuilder var launchURLView: some View {
        HStack(spacing: 0) {
            Text("URL").frame(width: 70)
            TextField("URL", text: $str)
                .keyboardType(.URL)
                .textFieldStyle(.plain)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)
                .padding(6).background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.sysBackground)
                        .shadow(radius: 2, y: 1)
                        .frame(height: 48)
                )
            Button {
                newTab(str)
                str = "https://"
            } label: {
                Label("Go", systemImage: "plus").foregroundColor(Color("WBColor"))
            }.buttonStyle(HomeBtnStyle())
            .frame(width: 90, height: 48).padding()
        }.font(.title3)
    } // launch url
    
    @ViewBuilder var bookmarkView: some View {
        HStack(spacing: 16) {
            Button {
                if supportsMultipleWindows {
                    openWindow(id: "com.wyw.wb.prefs")
                } else {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        iPhoneShowsConfig = true
                    }
                }
            } label: { Image(systemName: "gear") }
                .buttonStyle(HomeBtnStyle())
                .frame(width: 56, height: 48)
            
            Button { newTab("https://10.19.129.75:5001") }
            label: { Image(systemName: "swift") }
                .buttonStyle(HomeBtnStyle())
                .frame(width: 56, height: 48)
                .contextMenu {
                    Button(role: .destructive) {
                        //
                    } label: {
                        Label("Remove", systemImage: "bookmark.slash")
                    }
                    Button {
                        //
                    } label: {
                        Label("Open", systemImage: "arrow.down.left.and.arrow.up.right.square")
                    }
                }
            
        }.font(.system(size: 20))
    } // bookmarks
    
    @ViewBuilder var bottomTabs: some View {
        VStack {
            LazyVGrid(columns: Array(
                repeating: GridItem(.adaptive(minimum: 120, maximum: 250)),
                count: supportsMultipleWindows ? 6 : 3
            )) {
                ForEach(0..<webStageShared.openWindows.count, id: \.self) {windowIndex in
                    Button {
                        showTab(webStageShared.openWindows[windowIndex].id)
                    } label: { tabLabel(windowIndex)
                    }.buttonStyle(HomeBtnStyle())
                    .contextMenu {
                        Button(role: .destructive) {
                            closeTab(windowIndex)
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
                            showTab(webStageShared.openWindows[windowIndex].id)
                        } label: {
                            Label("Show", systemImage: "arrow.down.left.and.arrow.up.right.square")
                        }
                    }
                } // For each
            }
            //Text("\(UIScreen.main.bounds.debugDescription)")
        }
    } // bottom view
    
    @ViewBuilder func tabLabel(_ windowIndex: Int) -> some View {
        ZStack {
            VStack(spacing: 4) {
                HStack(spacing: 2) {
                    if let favicon = webStageShared.openWindows[windowIndex].favicon {
                        Image(uiImage: favicon).resizable().scaledToFit()
                            .frame(width: 18, height: 18)
                    } else {
                        Image(systemName: "circle.dotted").resizable().scaledToFit()
                            .frame(width: 18, height: 18).foregroundStyle(.gray)
                    }
                    Text(webStageShared.openWindows[windowIndex].titleString
                    ).lineLimit(1)
                }
                RoundedRectangle(cornerRadius: 8).fill(Color.gray5)
                    .aspectRatio(1.8, contentMode: .fit)
                    .overlay {
                        if let scr = webStageShared.openWindows[windowIndex].screenshot {
                            Image(uiImage: scr).resizable().scaledToFill()
                        } else {
                            Image(systemName: "globe").resizable().scaledToFit()
                                .foregroundStyle(Color.gray3).padding()
                        }
                    }.clipped()
            }.padding(4)
            //webStageShared.openWindows[windowIndex].currentURL?.urlWithoutSubdomains?.absoluteString
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
