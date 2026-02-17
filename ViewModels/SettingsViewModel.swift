import SwiftUI
import SwiftData
import Combine

@MainActor
class SettingsViewModel: ObservableObject {
    private let storageKey = "yttracker_api_key"
    // APIキーの管理
    @Published var apiKey: String {
        didSet {
            // 値が変わったらUserDefaultsに保存する処理
            UserDefaults.standard.set(apiKey, forKey: storageKey)
        }
    }
    
    let appVersion: String
    
    // 初期化
    init() {
        self.apiKey = UserDefaults.standard.string(forKey: "yttracker_api_key") ?? ""
        
        //アプリのバージョンを取得(info.plistから)
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
        self.appVersion = "v\(version) (\(build))"
    }
    
    // バリデーション(入力チェック)
    var isApiKeyValid: Bool {
        return apiKey.count > 30 && apiKey.starts(with: "AIza")
    }
}
