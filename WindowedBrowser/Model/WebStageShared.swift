//
//  WebStageShared.swift
//  WindowedBrowser
//
//  Created by leo on 2024-12-28.
//

import SwiftUI
import Combine

class WebStageShared: ObservableObject {
    @Published var openWindows: [TabInfo] = []
}

struct TabInfo {
    let id = UUID()
    var entryURL: URL
    var title: String
    var favicon: UIImage? = nil
}
