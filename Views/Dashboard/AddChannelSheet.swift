import SwiftUI
import SwiftData

struct AddChannelSheet: View {
    // 画面を閉じるための機能
    @Environment(\.dismiss) private var dismiss
    
    // 親(DashboardView)から渡されたViewModeLを監視する。
    // 親が作ったViewModelをそのまま使うため、新しく作るわけではない。→ @StateObjectではなく、＠ObservedObjectを使用。
    @ObservedObject var viewModel: ChannelListViewModel
    
    // 親から渡されるAPIキー
    let apiKey: String
    
    @State private var input = ""
    
    var body: some View {
        NavigationStack {
            VStack (alignment: .leading, spacing: 8) {
                Text("チャンネルを追加")
                    .font(.title2.bold())
                Text("チャンネルID（UC...）またはハンドル（＠...）を入力してください。")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            //　入力フィールド
            TextField("UC... または ＠handle", text: $input)
                .textFieldStyle(.roundedBorder)
                .textInputAutocapitalization(.never) // 勝手に大文字にしない
                .autocorrectionDisabled() // 勝手に修正しない
                .disabled(viewModel.isLoading) // 通信中は入力不可
            
            // エラー表示
            if viewModel.showError, let message = viewModel.errorMessage {
                Text(message)
                    .foregroundStyle(.red)
                    .font(.caption)
            }
            
            // 追加ボタン
            Button {
                // 非同期処理(await)をするため、Taskを使う。
                Task {
                    await viewModel.addChannel(input: input, apiKey: apiKey) // viewModel.addChannelを呼ぶ
                    // エラーがなければ画面を閉じる
                    if !viewModel.showError {
                        dismiss()
                    }
                }
            } label: {
                HStack {
                    if viewModel.isLoading {
                        ProgressView()
                            .tint(.white)
                    } else {
                        Text("追加")
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(input.isEmpty || viewModel.isLoading ? Color.gray : Color.red)
                .foregroundStyle(.white)
                .cornerRadius(10)
            }
            .disabled(input.isEmpty || viewModel.isLoading)
        }
        .padding()
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("キャンセル") {
                    dismiss()
                }
            }
        }
    }
}

#Preview {
    // 1. メモリ内データベース作成
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Channel.self, configurations: config)
    
    // 2. ViewModel作成（コンテキストを渡す）
    // @MainActorなのでTask.detached等は不要ですが、プレビュー内では通常通り初期化できます
    let viewModel = ChannelListViewModel(modelContext: container.mainContext)
    
    // 3. View表示
    AddChannelSheet(
        viewModel: viewModel,
        apiKey: "DUMMY_API_KEY"
    )
}
