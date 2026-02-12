import SwiftUI
import SwiftData

struct DashboardView: View {
    // 1. ViewModelの準備
    // StateObject: Viewが作られる時に、ViewModelも一緒に作って所有する。
    // modelContextはEnvironmentから自動でもらえるので、それをinitで渡す。
    @Environment(\.modelContext) private var modelContext
    @StateObject private var viewModel: ChannelListViewModel
    
    // 2. 状態管理
    @State private var showAddSheet = false
    
    // APIキー。とりあえずUserDefaultsから取得。なければ空文字。
    private let apiKey = "AIzaSyBJCiCL74G48uuX389coli61wxPf2VO7wg"
    
    // 外部から受け取ったmodelContextを使って店長(ViewModel)を雇うための定型文
    init(modelContext: ModelContext) {
        _viewModel = StateObject(wrappedValue: ChannelListViewModel(modelContext: modelContext))
    }
    
    var body: some View {
        NavigationStack {
            Group {
                if viewModel.channels.isEmpty {
                    // データがない時の表示
                    if #available(iOS 17.0, *) {
                        ContentUnavailableView(
                            "チャンネルがありません。",
                            systemImage: "play.rectangle.on.rectangle",
                            description: Text("右上のボタンからチャンネルを追加してください。")
                        )
                    } else {
                        Text("チャンネルがありません。")
                    }
                } else {
                    // データがあるときのリスト表示
                    List {
                        // ViewModel.channels(全体)から、1つずつchannelを取り出す。
                        ForEach(viewModel.channels) { channel in
                            // NavigationLink(行き先) { 見た目 }
                            NavigationLink{
                                // 行き先（まだ作っていないので仮置き）
                                Text("詳細画面: \(channel.title)")
                            } label: {
                                ChannelCardView(
                                    channel: channel,
                                    latestStats: channel.stats.last // 最新の統計
                                )
                            }
                        }
                        // スワイプ削除機能
                        .onDelete { indexSet in
                            for index in indexSet {
                                viewModel.deleteChannel(viewModel.channels[index])
                            }
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("YT Tracker")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showAddSheet = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showAddSheet) {
                // ViewModelとAPIキーを渡す
               AddChannelSheet(viewModel: viewModel, apiKey: apiKey)
                    .presentationDetents([.medium])
            }
        }
    }
}

#Preview {
    // 1. メモリ内だけの使い捨てデータベースを作る
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Channel.self, configurations: config)
    
    // 2. ダミーデータを入れておく（これがないと「データなし」画面になる）
    let dummy = Channel(
        channelId: "UC_TEST",
        title: "テストチャンネル",
        thumbnailURL: "https://via.placeholder.com/150",
        customURL: "@test_channel"
    )
    container.mainContext.insert(dummy)
    
    // 3. Viewを表示
    // initにコンテキスト（container.mainContext）を渡すのがポイント！
    return DashboardView(modelContext: container.mainContext)
        .modelContainer(container)
}
