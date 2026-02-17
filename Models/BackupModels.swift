// Web版のYTTrackerからエクスポートされたJSONを読み込むために、JSONの形に合わせた構造体を作る。
// JSONの構造が異なるため、変換用の中間モデル(DTO)としてここで定義する。

import Foundation

// JSON全体の構造
struct BackupData: Codable {
    let apiKey: String
    let channels: [BackupChannel]
    let stats: [String: [BackupStat]] // チャンネルID
}

// チャンネル情報の構造
struct BackupChannel: Codable {
    let id: String
    let channelId: String
    let title: String
    let thumbnail: String // SwiftDataではthumbnailURLだが、JSONではthumbnail
    let customUrl: String?
    let lastUpdated: Date?
}

// 統計情報の構造
struct BackupStat: Codable {
    let id: String
    let views: Int
    let subscribers: Int
    let videoCount: Int
    let recordeAt: Date
}
