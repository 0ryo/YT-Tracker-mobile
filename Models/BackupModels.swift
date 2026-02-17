import Foundation

struct BackupData: Codable {
    let apiKey: String
    let channels: [BackupChannel]
    let stats: [String: [BackupStat]] // チャンネルID
}
