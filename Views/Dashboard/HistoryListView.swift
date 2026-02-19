import SwiftUI

struct HistoryListView : View {
    let stats: [ChannelStats]
    
    // 親(ChannelDetailView)からDisplayModeを受け取る。
    let mode: ChannelDetailView.DisplayMode
    
    @State private var isExpanded = true

    // 新しい順(降順)にソート
    var sortedStats: [ChannelStats] {
        stats.sorted{ $0.recordedAt > $1.recordedAt }
    }
    
    private let  dateWidth: CGFloat = 90
    private let  badgeWidth: CGFloat = 100
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // 折りたたみスイッチ
            Button {
                withAnimation(.easeInOut(duration: 0.3)) {
                    isExpanded.toggle()
                }
            } label: {
                HStack {
                    Text("履歴")
                        .font(.headline)
                        .foregroundStyle(.primary)
                    Spacer()
                    
                    // 開閉に合わせて回転する矢印
                    Image(systemName: "chevron.right")
                        .foregroundStyle(.secondary)
                        .rotationEffect(.degrees(isExpanded ? 90 : -90))
                }
                .padding()
                .background(Color(.secondarySystemBackground))
            }
            .buttonStyle(.plain)
            
            if isExpanded {
                Divider()
                
                // ヘッダー行
                HStack(spacing: 8) {
                    Text("日付")
                        .frame(width: dateWidth, alignment: .leading)
                    
                    Text("変動")
                        .frame(width: badgeWidth, alignment: .trailing)
                    
                    Text(mode == .subscribers ? "登録者数" : "再生回数")
                        .frame(maxWidth: .infinity, alignment: .trailing)
                }
                .font(.caption)
                .foregroundStyle(.secondary)
                .padding(.horizontal)
                .padding(.vertical, 8)
                .background(Color(.secondarySystemBackground))
                
                Divider()
                
                // リスト表示
                LazyVStack(spacing: 0) {
                    ForEach(Array(sortedStats.enumerated()), id: \.element.id) { index, stat in
                        let prevStat = index + 1 < sortedStats.count ? sortedStats[index + 1] : nil
                        
                        HistoryRowView(
                            stat: stat,
                            previousStat: prevStat,
                            mode: mode,
                            dateWidth: dateWidth,
                            badgeWidth: badgeWidth
                        )
                        
                        // 区切り線
                        if index < sortedStats.count - 1 {
                            Divider()
                                .padding(.leading, 16)
                        }
                    }
                }
                .transition(.opacity)
            }
        }
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 5)
        .clipped()
    }
}

struct HistoryRowView : View {
    let stat: ChannelStats
    let previousStat: ChannelStats?
    let mode: ChannelDetailView.DisplayMode // モードを受け取る
    
    let dateWidth: CGFloat
    let badgeWidth: CGFloat
    
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
    
    var currentValue: Int {
        mode == .subscribers ? stat.subscribers : stat.views
    }
    
    var currentDiff: Int {
        mode == .subscribers ? subscriberDiff : viewDiff
    }
    
    var body: some View {
        HStack(spacing: 8) {
            // 日付
            Text(stat.recordedAt.formatted(date: .numeric, time: .omitted))
                .font(.callout)
                .foregroundStyle(.secondary)
                .frame(width: dateWidth, alignment: .leading)
                .lineLimit(1)
            
                DiffBadgeView(diff: currentDiff)
                    .frame(width: badgeWidth, alignment: .trailing)
            
            // 登録者数or再生回数
            Text(currentValue.formatted())
                .font(.callout)
                .fontWeight(.medium)
                .frame(maxWidth: .infinity, alignment: .trailing)
                .lineLimit(1)
        }
        .padding(.horizontal)
        .padding(.vertical, 10)
    }
}

#Preview {
    // 日付計算用のカレンダー
    let calendar = Calendar.current
    let today = Date()
    let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!
    let twoDaysAgo = calendar.date(byAdding: .day, value: -2, to: today)!
    
    // ダミーデータ（3日分）
    // 一番上が最新（今日）になるようにリスト側でソートされます
    let stats = [
        ChannelStats(
            views: 38062062250,
            subscribers: 964000,
            videoCount: 52,
            recordedAt: today
        ),
        ChannelStats(
            views: 38046353185,
            subscribers: 824000,
            videoCount: 51,
            recordedAt: yesterday
        ),
        ChannelStats(
            views: 38046533418,
            subscribers: 864000,
            videoCount: 50,
            recordedAt: twoDaysAgo
        )
    ]
    
    return ScrollView {
        HistoryListView(stats: stats, mode: .views)
            .padding()
    }
    .background(Color(.secondarySystemBackground)) // 背景を少しグレーにして見やすく
}
