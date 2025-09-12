//
//  WebpageData.swift
//  WindowedBrowser
//
//  Created by leo on 2023-10-18.
//

import SwiftUI

final class WebpageData: NSObject {
    let entryURL: URL
    var setTitle: (String) -> Void
    var onDismiss: () -> Void
    
    init(entryURL: URL, setTitle: @escaping (String) -> Void, onDismiss: @escaping () -> Void) {
        self.entryURL = entryURL
        self.setTitle = setTitle
        self.onDismiss = onDismiss
    }
}

//extension WebpageData: Codable {
//}
