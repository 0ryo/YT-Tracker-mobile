import SwiftUI

struct HistoryListView : View {
    let stats: [ChannelStats]
    
    // 切り替えモードの定義
    enum HistoryMode: String, CaseIterable {
        case subscribers = "登録者数"
        case views = "再生回数"
    }
    
    // 選択状態の管理
    @State private var selectedMode: HistoryMode = .subscribers
    
    // 新しい順(降順)にソート
    var sortedStats: [ChannelStats] {
        stats.sorted{ $0.recordedAt > $1.recordedAt }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Spacer()
                // セグメントコントロール
                Picker("表示モード", selection: $selectedMode) {
                    ForEach(HistoryMode.allCases, id: \.self) { mode in
                        Text(mode.rawValue).tag(mode)
                    }
                }
                .pickerStyle(.segmented)
                .frame(width: 200)
                Spacer()
            }
            
            HStack {
                Text("日付")
                    .frame(width: 80, alignment: .leading)
                
                Spacer()
                
                Text("変動")
                Text(selectedMode == .subscribers ? "登録者数" : "再生回数")
                    .frame(width: 100, alignment: .trailing)
            }
            .font(.caption)
            .foregroundStyle(.secondary)
            .padding(.horizontal)
            
            // リスト表示
            ForEach(Array(sortedStats.enumerated()), id: \.element.id) { index, stat in
                let prevStat = index + 1 < sortedStats.count ? sortedStats[index + 1] : nil
                
                HistoryRowView(stat: stat, previousStat: prevStat, mode: selectedMode)
                
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
        .animation(.easeInOut, value: selectedMode)
    }
}

struct HistoryRowView : View {
    let stat: ChannelStats
    let previousStat: ChannelStats?
    let mode: HistoryListView.HistoryMode // モードを受け取る
    
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
        HStack {
            Text(stat.recordedAt.formatted(date: .numeric, time: .omitted))
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .frame(width: 80, alignment: .top)
            
            Spacer()
            
            // 登録者数
            HStack(spacing: 4) {
                DiffBadgeView(diff: currentDiff)
                    .frame(width: 100, alignment: .trailing)
                    .lineLimit(1)
                    .padding(.horizontal, 40)
                Text(currentValue.formatted())
                    .fontWeight(.medium)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 4)
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
            views: 380620650,
            subscribers: 964000,
            videoCount: 52,
            recordedAt: today
        ),
        ChannelStats(
            views: 380465318,
            subscribers: 824000,
            videoCount: 51,
            recordedAt: yesterday
        ),
        ChannelStats(
            views: 380465318,
            subscribers: 864000,
            videoCount: 50,
            recordedAt: twoDaysAgo
        )
    ]
    
    return ScrollView {
        HistoryListView(stats: stats)
            .padding()
    }
    .background(Color(.secondarySystemBackground)) // 背景を少しグレーにして見やすく
}
