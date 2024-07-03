//
//  GlobalMsgHelper.swift
//  WindowedBrowser
//
//  Created by leo on 2024-07-03.
//

import SwiftUI

class GlobalMsgHelper {
    var onDestruction: (() -> Void)? = nil
    deinit {
        onDestruction?()
    }
}

var onCloseWindow: ((URL) -> Void)? = nil
