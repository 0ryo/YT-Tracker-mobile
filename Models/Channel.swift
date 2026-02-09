import SwiftData
import Foundation

@Model
final class Channel {
    // 一意性を保証する属性をつける
    @Attribute(.unique) var channelId: String
    
    var title: String
    var thumbnailURL: String
    var customURL: String?
    var lastUpdated: Date?
    var createdAt: Date
    
    // 子データ(Stats)への参照
    // Channelが削除されたら、紐づいているChannelStatsも自動的に削除(.cascade)
    @Relationship(deleteRule: .cascade,inverse: \ChannelStats.channel)
    var stats: [ChannelStats] = []
    
    // 初期化メソッド
    init(channelId: String, title: String, thumbnailURL: String, customURL: String? = nil) {
        self.channelId = channelId
        self.title = title
        self.thumbnailURL = thumbnailURL
        self.customURL = customURL
        self.createdAt = Date()
//        self.lastUpdated = nil // 書かなくても、オプショナル型で定義されたプロパティは、初期値にnilが入る。
    }
}
