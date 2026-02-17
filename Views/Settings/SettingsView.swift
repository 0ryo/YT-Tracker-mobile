import SwiftUI

struct SettingsView : View {
    @StateObject private var viewModel = SettingsViewModel()
    
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
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        
                    } label: {
                        Image(systemName: "gearshape")
                    }
                }
            }
        }
    }
}

#Preview {
    SettingsView()
}
