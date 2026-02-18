import SwiftUI
import SwiftData
import UniformTypeIdentifiers

struct SettingsView : View {
    @Environment(\.modelContext) private var modelContext
    @StateObject private var viewModel = SettingsViewModel()
    
    
    // ファイルインポート用の状態
    @State private var showFileImporter = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        NavigationStack {
            List {
                // APIキー設定セクション
                Section {
                    VStack(alignment: .leading) {
                        Text("YouTube Data API Key")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        
                        // パスワード入力フィールド
                        HStack {
                            Image(systemName: "key.fill")
                                .foregroundStyle(.gray)
                            SecureField("", text: $viewModel.apiKey)
                        }
                    }
                    if !viewModel.apiKey.isEmpty {
                        if viewModel.isApiKeyValid {
                            Label("有効な形式です", systemImage: "checkmark.circle.fill")
                                .foregroundStyle(.green)
                                .font(.caption)
                        } else {
                            Label("無効な形式です", systemImage: "xmark.circle.fill")
                                .foregroundStyle(.red)
                                .font(.caption)
                        }
                    }
                    
                    Link("APIキーの取得方法(Google Cloud Console)", destination: URL(string: "https://console.cloud.google.com/apis/credentials")!)
                        .font(.caption)
                } header: {
                    Text("基本設定")
                } footer: {
                    Text("APIキーは端末内にのみ保存され、外部に送信されることはありません。")
                        .padding(.bottom, 20)
                }
                
                // バックアップ・復元セクション
                Section {
                    if let backupData = viewModel.generateBackupData(context: modelContext) {
                        let fileName = "yt-tracker-backup-\(Date().formatted(date: .numeric, time: .omitted)).json"
                        
                        ShareLink(
                            item: BackupFile(data:backupData),
                            preview: SharePreview(fileName, image: Image(systemName: "arrow.down.doc.fill"))
                        ) {
                            Label("データをエクスポート", systemImage: "square.and.arrow.up")
                        }
                    }
                    
                    // インポートボタン
                    Button {
                        showFileImporter = true
                    } label: {
                        Label("データをインポート", systemImage: "square.and.arrow.down")
                            .foregroundStyle(.red)
                    }
                } header: {
                    Text("データ管理")
                } footer: {
                    Text("インポートを行うと、現在のデータは全て上書きされます。")
                        .padding(.bottom, 20)
                }
                
                // アプリ情報セクション
                Section("アプリについて") {
                    HStack {
                        Text("バージョン")
                        Spacer()
                        Text(viewModel.appVersion)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .navigationTitle("設定")
            .fileImporter(
                isPresented: $showFileImporter,
                allowedContentTypes: [.json],
                allowsMultipleSelection: false
            ) { result in
                switch result {
                case .success(let urls):
                    guard let url = urls.first else { return }
                    Task {
                        do {
                            try await viewModel.restoreBackup(from: url, context: modelContext)
                            alertMessage = "インポートが完了しました。"
                        } catch {
                            alertMessage = "インポート失敗: \(error.localizedDescription)"
                        }
                        showAlert = true
                    }
                case.failure(let error):
                    alertMessage = "ファイル選択エラー: \(error.localizedDescription)"
                    showAlert = true
                }
            }
            // 結果表示アラート
            .alert("通知", isPresented: $showAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(alertMessage)
            }
//             // 閉じるボタン
//            .toolbar {
//                ToolbarItem(placement: .primaryAction) {
//                    Button {
//                        EmptyView()
//                    } label: {
//                        Image(systemName: "gearshape")
//                    }
//                }
//            }
            
        }
    }
}

#Preview {
    SettingsView()
}
