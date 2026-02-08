//
//  Item.swift
//  YTTracker
//
//  Created by 伊藤瞭汰 on 2026/02/08.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
