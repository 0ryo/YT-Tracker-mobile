import SwiftUI
import SwiftData

struct ChannelDetailView: View {
    // 画面を閉じる機能
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    // 前の画面から渡されるチャンネルデータ
    let channel: Channel
    
    // モード定義
    enum DisplayMode: String, CaseIterable {
        case subscribers = "登録者数"
        case views = "再生回数"
    }
    
    @State private var selection: DisplayMode = .subscribers
    
    // 日付順にソートした統計データ
    var sortedStats: [ChannelStats] {
        channel.stats.sorted { $0.recordedAt < $1.recordedAt }
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // 1. ヘッダー部分
                HStack(spacing: 16) {
                    // アイコン画像
                    AsyncImage(url: URL(string: channel.thumbnailURL)) { image in
                        image
                            .resizable()
                            .scaledToFill()
                    } placeholder: {
                        // プレースホルダー。読み込み中に表示。
                        Circle()
                            .fill(Color.gray.opacity(0.3))
                    }
                    .frame(width: 80, height: 80)
                    .clipShape(Circle())
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(channel.title)
                            .font(.title2.bold())
                        
                        Text(channel.customURL ?? channel.channelId)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        
                        Text("記録数: \(channel.stats.count)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .padding(.top, 4)
                    }
                    Spacer()
                }
                .padding()
                
                // Picker
                Picker("表示モード", selection: $selection) {
                    ForEach(DisplayMode.allCases, id: \.self) { mode in
                        Text(mode.rawValue).tag(mode)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                
                // 2. グラフ表示エリア
                if sortedStats.isEmpty {
                    Text("データがありません。")
                        .foregroundStyle(.secondary)
                        .padding()
                } else {
                    if selection == .subscribers {
                        StatsChartView(
                            stats: sortedStats,
                            keyPath: \.subscribers,
                            title: "チャンネル登録者数",
                            color: .red
                        )
                        .padding(.horizontal)
                        .transition(.opacity)
                    } else {
                        StatsChartView(
                            stats: sortedStats,
                            keyPath: \.views,
                            title: "総再生回数",
                            color: .blue
                        )
                        .padding(.horizontal)
                        .transition(.opacity)
                    }
                }
                
                HistoryListView(stats: channel.stats, mode: selection)
                    .padding(.horizontal)
                    .padding(.bottom, 40)
            }
        }
        .navigationTitle("詳細情報")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Channel.self, configurations: config)
    
    let dummy = Channel(
        channelId: "UC_TEST",
        title: "HikakinTV",
        thumbnailURL: "https://yt3.googleusercontent.com/ytc/AIdro_k2L0Zg...", // 適当なURL
        customURL: "@hikakin"
    )
    
    return NavigationStack {
        ChannelDetailView(channel: dummy)
            .modelContainer(container)
    }
}
