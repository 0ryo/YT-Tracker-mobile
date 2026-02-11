import SwiftUI
import SwiftData
import Combine

// @MainActor: UIに関わる更新をメインスレッドで行うことを保証する属性
@MainActor
class ChannelListViewModel: ObservableObject {
    // 画面の状態を管理する変数
    @Published var channels: [Channel] = []
    @Published var isLoading =  false
    @Published var errorMessage: String?
    @Published var showError = false
    
    // Dependencies(依存する機能)
    private let apiService = YouTubeAPIService()
    private var modelContext: ModelContext
    
    // 初期化時にデータベースの操作権限(ModelContext)をもらう
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        fetchChannels()
    }
    
    // データベースから保存済みのチャンネルを読み込む
    func fetchChannels() {
        do {
            //　作成日順にソートして取得
            let descriptor = FetchDescriptor<Channel>(sortBy: [SortDescriptor(\.createdAt)])
            //実際にデータベースから取ってくる
            channels = try modelContext.fetch(descriptor)
        } catch {
            print("Fetch failed: \(error)")
        }
    }
    
    // チャンネル追加処理
    func addChannel(input: String, apiKey: String) async {
        // guard文: 入力が空なら何もしない。
        guard !input.isEmpty, !apiKey.isEmpty else { return }
        
        isLoading = true
        defer { isLoading = false } // 処理が終わったら必ず(エラーでも成功でも)falseにする。
        
        do {
            // 1. APIからデータを取得(/Services/を使う。)
            // ここで`item`にはYouTubeChannelItem型のデータが入る。
            let item = try await apiService.fetchChannel(input: input, apiKey: apiKey)
            
            // 2. 重複チェック(すでに同じChannelIdのチャンネルがないか確認)
            // $0.channelIdは保存済みのデータのID、item.idは今撮ってきたAPIのID
            if channels.contains(where: {$0.channelId == item.id}) {
                return
            }
            
            // 3. データモデルへの変換(/Models/を使う。)
            // APIのデータ構造(item.snippet)を辿って、Channelモデルの形に詰め替える
            // APIから来るデータ(item)は、入れ子構造になっているため、平らなChannelモデルに移し替える必要がある。
            // 深い階層にあるデータは、ドットで繋いで取り出すことができる。
            let newChannel = Channel(
                channelId: item.id,
                title: item.snippet.title,
                thumbnailURL: item.snippet.thumbnails.default.url,
                customURL: item.snippet.customUrl
            )
            
            // 4. 初回の統計データを作成して紐付ける
            let initialStats = ChannelStats(
                views: Int(item.statistics.viewCount) ?? 0, // YouTubeAPITypesのitemの中のstatisticsの中のviewCountをここに紐付ける
                subscribers: Int(item.statistics.subscriberCount) ?? 0,
                videoCount: Int(item.statistics.videoCount) ?? 0,
                recordedAt: Date() // 現在時刻
            )
            // 親(Channel)と子(Stats)を紐付け。
            // newChannel.stats.append(initialStats)でも可だが、
            // 関係性を明示するために子の親を設定するのが一般的。
            initialStats.channel = newChannel
            
            // 5. データベースに保存
            modelContext.insert(newChannel) // メモリ上の変更リストに書き込む（まだ保存されていない）
            try modelContext.save() // 実際にデータベースファイルに書き込んで確定させる。
            
            // 6. リストを再読み込み
            fetchChannels()
            
        } catch {
            self.errorMessage = error.localizedDescription
            self.showError = true
        }
    }
    
    // チャンネル削除機能
    func deleteChannel(_ channel: Channel) {
        modelContext.delete(channel)
        try? modelContext.save()
        fetchChannels()
    }
}
