//
//  ContentView.swift
//  YTTracker
//
//  Created by 伊藤瞭汰 on 2026/02/08.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    
    var body: some View {
        VStack {
            Text("Hello, YT-Tracker!!")
        }
    }
}

#Preview {
    ContentView()
}
