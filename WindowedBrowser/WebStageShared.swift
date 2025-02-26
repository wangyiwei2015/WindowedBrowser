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
