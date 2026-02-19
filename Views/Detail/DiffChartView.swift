import SwiftUI
import Charts

struct DiffChartView: View {
    let stats: [ChannelStats]
    let mode: ChannelDetailView.DisplayMode // 親のモードを受け取る
    
    // 期間選択の状態
    @State private var selection: ChartRange = .week // 期間のデフォルト値。
    
    // 差分データの構造体
    struct DailyDiff: Identifiable {
        var id = UUID()
        let date: Date
        let value: Int
    }
    
    // 差分データの計算プロパティ
    var diffData: [DailyDiff] {
        // 日付順に並べる
        let sorted = stats.sorted { $0.recordedAt < $1.recordedAt }
        
        // フィルタリング
        let filtered: [ChannelStats]
        if let days = selection.days {
            let cutoff = Calendar.current.date(byAdding: .day, value: -days, to: Date())!
            filtered = sorted.filter { $0.recordedAt >= cutoff }
        } else {
            filtered = sorted
        }
        
        // 差分計算
        var diffs: [DailyDiff] = []
        
        // データが2つ以上ないと差分は出せない
        if filtered.count < 2 { return [] }
        
        for i in 1..<filtered.count {
            let current = filtered[i]
            let prev = filtered[i-1]
            
            let diffValue: Int
            if mode == .subscribers {
                diffValue = current.subscribers - prev.subscribers
            } else {
                diffValue = current.views - prev.views
            }
            
            diffs.append(DailyDiff(date: current.recordedAt, value: diffValue))
        }
        
        return diffs
    }
    
    // x軸のラベル計算
    var xAxisValues: [Date] {
        guard let first = diffData.first?.date,
              let last = diffData.last?.date,
              diffData.count > 1 else {
            return diffData.map { $0.date }
        }
        let duration = last.timeIntervalSince(first)
        let step = duration / 6
        return (0...6).map { i in
            first.addingTimeInterval(step * Double(i))
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // ヘッダー
            HStack {
                Text(mode == .subscribers ? "登録者増加数" : "再生回数増加数")
                    .font(.headline)
                
                Spacer()
                
                Picker("期間", selection: $selection) {
                    ForEach(ChartRange.allCases, id: \.self){ range in
                        Text(range.rawValue).tag(range)
                    }
                }
                .pickerStyle(.segmented)
                .labelsHidden()
                .frame(width: 200)
            }
            
            if diffData.isEmpty {
                ContentUnavailableView("データ不足", systemImage: "chart.bar", description: Text("差分を計算するためのデータが足りません。"))
                    .frame(height: 200)
            } else {
                Chart {
                    ForEach(diffData){ data in
                        BarMark(
                            x: .value("日付", data.date),
                            y: .value("増分", data.value)
                        )
                        .foregroundStyle(mode == .subscribers ? Color.red : Color.blue)
                    }
                }
                .frame(height: 200)
                .chartXAxis {
                    AxisMarks(values: xAxisValues) { value in
                        AxisValueLabel(format: .dateTime.month(.defaultDigits).day())
                        AxisGridLine()
                    }
                }
                .chartYAxis {
                    AxisMarks { value in
                        AxisGridLine()
                        AxisValueLabel(format: Decimal.FormatStyle.number.notation(.compactName))
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 5)
        .animation(.easeInOut, value: selection)
    }
}

// プレビュー
#Preview {
    let stats = (0..<30).map { i in
        ChannelStats(
            views: 10000 + i * 500, // 毎日500増える
            subscribers: 100 + i * 10, // 毎日10増える
            videoCount: 10,
            recordedAt: Date().addingTimeInterval(-86400 * Double(29 - i))
        )
    }
    
    return DiffChartView(stats: stats, mode: .subscribers)
        .padding()
        .background(Color(.secondarySystemBackground))
}
