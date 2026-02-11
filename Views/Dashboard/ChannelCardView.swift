import SwiftUI
import SwiftData

struct ChannelCardView: View {
    let channel: Channel
    
    // プレビューように最新の統計データを受け取る。(nilの可能性あり。)
    let latestStats: ChannelStats?
    
    var body: some View {
        HStack(spacing :12) {
            AsyncImage(url: URL(string: channel.thumbnailURL)) { image in
                image
                    .resizable()
                    .scaledToFill()
            } placeholder: {
                // プレースホルダー。読み込み中に表示。
                Circle()
                    .fill(Color.gray.opacity(0.3))
            }
            .frame(width: 60, height: 60)
            .clipShape(Circle()) //円形に切り抜く
            
            VStack(alignment: .leading, spacing: 4) {
                Text(channel.title)
                    .font(.headline)
                    .lineLimit(1) // 1行に収める
                
                // channel.customURLがあればそれを、なければchannel.channelIdを表示してください。
                Text(channel.customURL ?? channel.channelId)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                // 登録者数の表示(まだフォーマット機能がないので、とりあえずそのまま表示。)
                if let stats = latestStats {
                    Text("\(stats.subscribers) subscribers")
                        .font(.subheadline)
                        .fontWeight(.medium)
                } else {
                    Text("- subscribers")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(.vertical, 8)
    }
}

// Xcode 15以降の新しいプレビューの書き方 (#Preview)
#Preview {
    // 2. ダミーデータを作る
    let dummyChannel = Channel(
        channelId: "UC_DUMMY_ID",
        title: "Swift勉強中チャンネル",
        thumbnailURL: "https://via.placeholder.com/150", // ダミー画像URL
        customURL: "@swift_study"
    )
    
    // 3. ダミーの統計データ
    let dummyStats = ChannelStats(
        views: 12345,
        subscribers: 500,
        videoCount: 10
    )
    
    // 4. コンテナにデータを入れる（保存はしないけど、関係性は作る）
    // 注意: SwiftDataのリレーションシップは自動で管理されることが多いですが、
    // プレビューでは明示的に追加しておくと安全です。
    // dummyChannel.stats.append(dummyStats) // 不要な場合もありますが、念のため
    
    // 5. Viewを表示
    ChannelCardView(channel: dummyChannel, latestStats: dummyStats)
        .padding()
        // プレビュー専用のメモリ内コンテナを使う
        .modelContainer(for: [Channel.self], inMemory: true)
}
