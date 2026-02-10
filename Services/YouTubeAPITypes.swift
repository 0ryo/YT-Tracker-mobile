import Foundation

// 1. 一番外側のレスポンス
struct YouTubeChannelResponse: Codable {
    let items: [YouTubeChannelItem]?
}

// 2. 個々のチャンネル情報
struct YouTubeChannelItem: Codable {
    let id: String
    let snippet: YouTubeSnippet
    let statistics: YouTubeStatistics
}

// 3. チャンネルの基本情報(snippet)
struct YouTubeSnippet: Codable {
    let title: String
    let customUrl: String?
    let thumbnails: YouTubeThumbnails
}

// プロパティ名がSwiftの予約語なので、バッククォートで囲む。
struct YouTubeThumbnails: Codable {
    let `default`: YouTubeThumbnail
}

struct YouTubeThumbnail: Codable {
    let url: String
}

// 4. 統計情報
struct YouTubeStatistics: Codable {
    let viewCount: String
    let subscriberCount: String
    let videoCount: String
}
