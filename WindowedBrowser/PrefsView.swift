//
//  PrefsView.swift
//  WindowedBrowser
//
//  Created by leo on 2024-07-06.
//

import SwiftUI

struct PrefsView: View {
    @Environment(\.dismissWindow) var dismissWindow
    
    @State var prefsDetailShowing: SidebarMenuItem = .init(group: 0, order: 0, name: "None")
    @State var sidebarMinimal = false
    
    var body: some View {
        GeometryReader { geo in
            if geo.size.width < 700 {
                prefsCompact
            } else { // Wide window
                prefsRegular
            }
        } // Geo
    } // body
    
    @ViewBuilder var prefsRegular: some View {
        VStack(spacing: 0) {
            ZStack {
                Color.sysBackground
                HStack(spacing: 0) {
                    Text("All Preferences")
                        .font(.title2).bold()
                        .padding(.horizontal, 20)
                    Spacer()
                    Button {
                        dismissWindow(id: "com.wyw.wb.prefs")
                    } label: {
                        Image(systemName: "xmark").font(.title3).tint(.gray3)
                    }.buttonStyle(TopbarBtnStyle(tint: .red)).frame(width: 50)
                }.padding(.top, 8)
            }.frame(height: 48)
            Color.gray5.frame(height: 1)
            HStack {
                //Sidebar
                ZStack {
                    Color.gray6
                    VStack(spacing: 0) {
                        Button {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                sidebarMinimal.toggle()
                            }
                        } label: {
                            sideLabel("Minimize", fullImg: "chevron.left", miniImg: "line.3.horizontal")
                        }.frame(height: 40)
                        .buttonStyle(HomeBtnStyle())
                        .padding(.vertical, 12).padding(.horizontal, 10)
                        
                        Capsule(style: .circular)
                            .fill(Color.gray5)
                            .frame(height: 4)
                            .padding(.horizontal, 10)
                        
                        ScrollView(.vertical) {
                            VStack(spacing: 12) {
                                ForEach(sidebarMenuItems.sorted(
                                    by: { $0.order < $1.order }
                                )) { item in
                                    Button {
                                        prefsDetailShowing = item
                                    } label: {
                                        sideLabel(
                                            item.name,
                                            fullImg: sysImg[item.order].fullImg,
                                            miniImg: sysImg[item.order].miniImg
                                        )
                                    }.frame(height: 40)
                                    .buttonStyle(HomeBtnStyle())
                                } // ForEach
                            }.padding(.top, 12).padding(.horizontal, 10)
                        }
                    }
                }.frame(
                    width: sidebarMinimal ? 70 : 300
                )
                //Details
                GeometryReader { geo in
                    VStack {
                        Text("\(geo.size)")
                        Text(prefsDetailShowing.name)
                    }
                }
            }
        }.ignoresSafeArea()
    }
    
    @ViewBuilder func sideLabel(_ title: String, fullImg: String, miniImg: String) -> some View {
        HStack(spacing: 0) {
            Image(systemName: miniImg)
                .font(.system(size: 20))
                .frame(width: 50)
            if !sidebarMinimal {
                Text(title).font(.system(size: 20))
                Spacer()
            }
        }.foregroundColor(Color("WBColor"))
    }
    
    @ViewBuilder var prefsCompact: some View {
        NavigationView {
            ScrollView(.vertical) {
                VStack(spacing: 16) {
                    ForEach(sidebarMenuItems.sorted(
                        by: { $0.order < $1.order }
                    )) { item in
                        NavigationLink {
                            Text(item.name + "\(item.group)")
                        } label: {
                            sideLabel(
                                item.name,
                                fullImg: sysImg[item.order].fullImg,
                                miniImg: sysImg[item.order].miniImg
                            )
                        }
                        .buttonStyle(HomeBtnStyle())
                        .frame(height: 50)
                        .padding(.horizontal)
                    }
                }.padding(.vertical)
            }.navigationTitle("All Preferences")
        }.tint(Color("WBColor")) // Nav View
    }
}

struct SidebarMenuItem: Hashable, Identifiable {
    var id = UUID()
    var group: Int
    var order: Int
    var name: String
}

let sidebarMenuItems: [SidebarMenuItem] = [
    .init(group: 0, order: 1, name: "About"),
    .init(group: 0, order: 2, name: "General"),
]

fileprivate let sysImg: [(fullImg: String, miniImg: String)] = [
    ("", ""),
    ("info.circle.fill", "info.circle.fill"), // about
    ("gearshape.fill", "gearshape.fill"), // general
]

#Preview {
    PrefsView()
}
