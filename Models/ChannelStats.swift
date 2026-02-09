import SwiftData
import Foundation

@Model
final class ChannelStats {
    var views: Int
    var subscribers: Int
    var videoCount: Int
    var recordedAt: Date
    
    //親データ(Channel)への参照を持つ
    var channel: Channel?
    
    init(views: Int, subscribers: Int, videoCount: Int, recordedAt: Date = Date()) {
        self.views = views
        self.subscribers = subscribers
        self.videoCount = videoCount
        self.recordedAt = recordedAt
    }
}

