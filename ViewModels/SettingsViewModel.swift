import SwiftUI
import SwiftData
import Combine
import UniformTypeIdentifiers

@MainActor
class SettingsViewModel: ObservableObject {
    private let storageKey = "yttracker_api_key"
    
    // APIキーの管理
    @Published var apiKey: String {
        didSet {
            UserDefaults.standard.set(apiKey, forKey: storageKey)
        }
    }
    
    let appVersion: String
    
    // 初期化
    init() {
        self.apiKey = UserDefaults.standard.string(forKey: "yttracker_api_key") ?? ""
        
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
        self.appVersion = "v\(version) (\(build))"
    }
    
    // バリデーション
    var isApiKeyValid: Bool {
        return apiKey.count > 30 && apiKey.starts(with: "AIza")
    }
    
    // MARK: - Export Logic
    func generateBackupData(context: ModelContext) -> Data? {
        do {
            // 全データを取得
            let descriptor = FetchDescriptor<Channel>()
            let channels = try context.fetch(descriptor)
            
            // Channel -> BackupChannel 変換
            let backupChannels = channels.map { ch in
                BackupChannel(
                    id: ch.channelId, // SwiftDataのIDをString化
                    channelId: ch.channelId,
                    title: ch.title,
                    thumbnail: ch.thumbnailURL,
                    customUrl: ch.customURL,
                    lastUpdated: ch.lastUpdated
                )
            }
            
            // Stats -> BackupStat 変換
            var backupStats: [String: [BackupStat]] = [:]
            
            for ch in channels {
                // 各チャンネルの統計データを変換
                // 修正: forループとmapを使って正しく配列を作成
                let stats = ch.stats.map { stat in
                    BackupStat(
                        id: UUID().uuidString, // JSON用に新しいIDを生成してもOK
                        views: stat.views,
                        subscribers: stat.subscribers,
                        videoCount: stat.videoCount,
                        recordedAt: stat.recordedAt
                    )
                }
                // 辞書に登録 (キー: チャンネルID)
                backupStats[ch.channelId] = stats
            }
            
            // 全体をまとめる
            let backupData = BackupData(
                apiKey: self.apiKey,
                channels: backupChannels,
                stats: backupStats
            )
            
            // JSONエンコード設定
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            encoder.outputFormatting = .prettyPrinted
            
            return try encoder.encode(backupData)
            
        } catch {
            print("Backup generation failed: \(error)")
            return nil
        }
    }
    
    // MARK: - Import Logic
    func restoreBackup(from url: URL, context: ModelContext) async throws {
        // セキュリティスコープのリソースアクセス開始
        guard url.startAccessingSecurityScopedResource() else {
            throw NSError(domain: "ImportError", code: 1, userInfo: [NSLocalizedDescriptionKey: "ファイルへのアクセス権限がありません"])
        }
        defer { url.stopAccessingSecurityScopedResource() }
        
        // 1. JSONデータの読み込み
        let data = try Data(contentsOf: url)
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        let backup = try decoder.decode(BackupData.self, from: data)
        
        // 2. 既存データの全削除
        let existingChannels = try context.fetch(FetchDescriptor<Channel>())
        for ch in existingChannels {
            context.delete(ch)
        }
        
        // 3. APIキーの復元
        await MainActor.run {
            self.apiKey = backup.apiKey
        }
        
        // 4. データの復元
        for backupCh in backup.channels {
            // Channel作成
            let newChannel = Channel(
                channelId: backupCh.channelId,
                title: backupCh.title,
                thumbnailURL: backupCh.thumbnail,
                customURL: backupCh.customUrl
            )
            newChannel.lastUpdated = backupCh.lastUpdated
            
            // 統計データの復元
            if let statsList = backup.stats[backupCh.channelId] {
                for statData in statsList {
                    let newStat = ChannelStats(
                        views: statData.views,
                        subscribers: statData.subscribers,
                        videoCount: statData.videoCount,
                        recordedAt: statData.recordedAt
                    )
                    // リレーションシップ設定
                    newStat.channel = newChannel
                }
            }
            
            context.insert(newChannel)
        }
        
        // 5. 保存
        try context.save()
    }
}

// ShareLink用ラッパー (classの外でOK)
struct BackupFile: Transferable {
    let data: Data
    
    static var transferRepresentation: some TransferRepresentation {
        DataRepresentation(exportedContentType: .json) { file in
            file.data
        }
    }
}
