//
//  CompactWindow.swift
//  WindowedBrowser
//
//  Created by leo on 2024-07-07.
//

import SwiftUI

struct CompactWindow<Content: View>: View {
    @Binding var isPresented: Bool
    var minimize: (() -> Void)?
    var content: () -> Content
    
    init(
        _ isPresented: Binding<Bool>,
        minimize: (() -> Void)? = nil,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self._isPresented = isPresented
        self.minimize = minimize
        self.content = content
    }
    
    var body: some View {
        Group {
            ZStack {
                RoundedRectangle(cornerRadius: 6, style: .continuous)
                    .fill(Color.sysBackground)
                    .stroke(.black.opacity(0.5), lineWidth: 0.2)
                    .shadow(radius: 3,y: 4)
                    .zIndex(1)
                content().padding(6)
                    .zIndex(2)
                VStack {
                    HStack {
                        Spacer()
                        if let minimizeAction = minimize {
                            Button {
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    minimizeAction()
                                }
                            } label: {
                                Image(systemName: "minus").font(.title3).tint(.gray3)
                            }.buttonStyle(TopbarBtnStyle(tint: .gray5)).frame(width: 50, height: 48)
                                .padding(.trailing, 6)
                        }
                        Button {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                isPresented = false
                            }
                        } label: {
                            Image(systemName: "xmark").font(.title3).tint(.gray3)
                        }.buttonStyle(TopbarBtnStyle(tint: .red)).frame(width: 50, height: 48)
                            .padding(.trailing, 6)
                    }
                    Spacer()
                }.zIndex(3)
            }
            .padding(.vertical, 75).padding(.horizontal, 16)
        }.opacity(isPresented ? 1.0 : 0.0).scaleEffect(isPresented ? 1.0 : 0.96)
    }
}

struct CompactWebWindow<Content: View>: View {
    var entry: (UIImage, String)
    @Binding var activeStr: String
    var dismissAction: (() -> Void)
    var content: () -> Content
    
    init(
        _ entry: (UIImage, String), activeStr: Binding<String>,
        dismissAction: @escaping (() -> Void),
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.entry = entry
        self._activeStr = activeStr
        self.dismissAction = dismissAction
        self.content = content
    }
    
    var body: some View {
        Group {
            ZStack {
                RoundedRectangle(cornerRadius: 6, style: .continuous)
                    .fill(Color.sysBackground)
                    .stroke(.black.opacity(0.5), lineWidth: 0.2)
                    .shadow(radius: 3,y: 4)
                    .zIndex(1)
                
                VStack(spacing: 0) {
                    HStack {
                        HStack {
                            Image(uiImage: entry.0)
                                .resizable().scaledToFit().frame(width: 24, height: 24)
                            Text(entry.1).lineLimit(1)
                        }.padding(.horizontal, 8)
                        Spacer()
                        Button {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                activeStr = ""
                            }
                        } label: {
                            Image(systemName: "minus").font(.title3).tint(.gray3)
                        }
                        .buttonStyle(TopbarBtnStyle(tint: .gray5))
                        .frame(width: 50, height: 48)
                        .padding(.trailing, 6)
                            
                        Button {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                dismissAction()
                            }
                        } label: {
                            Image(systemName: "xmark").font(.title3).tint(.gray3)
                        }
                        .buttonStyle(TopbarBtnStyle(tint: .red))
                        .frame(width: 50, height: 48)
                        .padding(.trailing, 6)
                    }
                    content().padding(6)
                }.zIndex(3)
            }
            .padding(.vertical, 75).padding(.horizontal, 16)
        }
        .opacity(activeStr == entry.1 ? 1.0 : 0.0)
        .scaleEffect(
            x: activeStr == entry.1 ? 1.0 : 0.5,
            y: activeStr == entry.1 ? 1.0 : 0.3
        )
        .offset(y: activeStr == entry.1 ? 0 : 400)
        .transition(.opacity.combined(with: .scale(0.96)))
    }
}
