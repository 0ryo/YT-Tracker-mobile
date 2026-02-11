//
//  YTTrackerApp.swift
//  YTTracker
//
//  Created by 伊藤瞭汰 on 2026/02/08.
//

import SwiftUI
import SwiftData // フレームワークを導入

@main
struct YTTrackerApp: App {
    // アプリ全域で使用するためのモデルコンテナを作成する
    // Channelモデルを保存するよ、と宣言する。
    var sharedModelContainer: ModelContainer = {
        // スキーマとモデルコンフィグを作成する
        let schema = Schema([
            Channel.self
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        // モデルコンテナを作成できなければ、致命的なエラーでアプリを終了
        do {
            // スキーマとモデルコンフィグを指定し、モデルコンテナを初期化して返す。
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
//        .modelContainer(sharedModelContainer) // アプリのビュー階層トップで、作成したモデルコンテナを接続。
    }
}
