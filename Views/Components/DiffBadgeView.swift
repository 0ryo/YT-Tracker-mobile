import SwiftUI

struct DiffBadgeView: View {
    let diff: Int
    var body: some View {
        if diff == 0 {
            // diff = 0 (前日から変化がない場合)は何も表示しない。
            EmptyView()
        } else {
            // テキスト作成: プラスの場合は"+"を先頭につける。
            Text(diff > 0 ? "+\(diff.formatted())" : "\(diff.formatted())")
                .font(.caption2)
                .fontWeight(.semibold)
                .padding(.horizontal, 5)
                .padding(.vertical, 2)
                .background(
                    diff > 0 ? Color(.green.opacity(0.3)) : Color(.red.opacity(0.3))
                )
                .cornerRadius(4)
        }
    }
}

#Preview {
    VStack {
        DiffBadgeView(diff: 100)  // 緑になるはず
        DiffBadgeView(diff: -50)  // 赤になるはず
        DiffBadgeView(diff: 0)    // 消えるはず
    }
}
