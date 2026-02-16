import SwiftUI

struct HistoryListView : View {
    let stats: [ChannelStats]
    
    // 新しい順(降順)にソート
    var sortedStats: [ChannelStats] {
        stats.sorted{ $0.recordedAt > $1.recordedAt }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text ("履歴")
                .font(.headline)
                .padding(.horizontal)
            
            // リスト表示
            ForEach(Array(sortedStats.enumerated()), id: \.element.id) { index, stat in
                let prevStat = index + 1 < sortedStats.count ? sortedStats[index + 1] : nil
                
                HistoryRowView(stat: stat, previousStat: prevStat)
                
                // 区切り線
                if index < sortedStats.count - 1 {
                    Divider()
                        .padding(.leading)
                }
            }
        }
        .padding(.vertical)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 5)
    }
}

struct HistoryRowView : View {
    let stat: ChannelStats
    let previousStat: ChannelStats?
    
    // 登録者数の差分計算
    var subscriberDiff: Int {
        guard let prev = previousStat else { return 0 }
        return stat.subscribers - prev.subscribers
    }
    // 再生回数の差分計算
    var viewDiff: Int {
        guard let prev = previousStat else { return 0 }
        return stat.views - prev.views
    }
    
    var body: some View {
        HStack {
            Text(stat.recordedAt.formatted(date: .numeric, time: .omitted))
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .frame(width: 80, alignment: .top)
            
            Spacer()
            
            // 登録者数
            VStack(alignment: .trailing, spacing: 2) {
                HStack(spacing: 4) {
                    Text(stat.subscribers.formatted())
                        .fontWeight(.medium)
                    DiffBadgeView(diff: subscriberDiff)
                }
                
                HStack(spacing: 4) {
                    Text(stat.views.formatted())
                        .fontWeight(.medium)
                    DiffBadgeView(diff: viewDiff)
                }
            }
        }
        .padding(.horizontal)
    }
}
