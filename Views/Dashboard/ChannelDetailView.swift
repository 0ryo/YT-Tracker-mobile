import SwiftUI
import SwiftData

struct ChannelDetailView: View {
    // 画面を閉じる機能
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    // 前の画面から渡されるチャンネルデータ
    let channel: Channel
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
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
                    .frame(width: 60, height: 60)
                    .clipShape(Circle())
                }
            }
        }
    }
}
