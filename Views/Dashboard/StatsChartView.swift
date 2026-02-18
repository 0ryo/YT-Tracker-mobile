import SwiftUI
import Charts

struct StatsChartView: View {
    // グラフに表示するデータ群
    let stats: [ChannelStats]
    
    // どのデータをY軸にするかを決めるパス
    let keyPath: KeyPath<ChannelStats, Int>
    
    // グラフのタイトルと色
    let title: String
    let color: Color
    
    @State private var selection: ChartRange = .all
    
    // フィルタリング済みデータ
    var filteredStats: [ChannelStats] {
        guard let days = selection.days else { return stats } // 全期間ならそのまま
        
        let cutoffDate = Calendar.current.date(byAdding: .day, value: -days, to:Date())!
        
        return stats.filter { $0.recordedAt >= cutoffDate }
    }
    
    // x軸のラベル計算
    var xAxisValues: [Date] {
        guard let first = filteredStats.first?.recordedAt,
              let last = filteredStats.last?.recordedAt,
              filteredStats.count > 1 else {
            return filteredStats.map { $0.recordedAt }
        }
        
        let duration = last.timeIntervalSince(first)
        
        let step = duration / 6
        
        return (0...6).map { i in
            first.addingTimeInterval(step * Double(i))
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(title)
                    .font(.headline)
                Spacer()
                Picker("期間", selection: $selection) {
                    ForEach(ChartRange.allCases, id: \.self) { range in
                        Text(range.rawValue).tag(range)
                    }
                }
                .pickerStyle(.menu)
                .labelsHidden()
                .frame(width: 200, alignment: .trailing)
                .border(Color.red)
            }
            
            // グラフ本体
            Chart {
                ForEach(filteredStats) { stat in
                    LineMark(
                        x: .value("日付", stat.recordedAt),
                        y: .value("数値", stat[keyPath: keyPath])
                    )
                    .foregroundStyle(color)
                    .interpolationMethod(.catmullRom) // 線を滑らかに
                    
                    PointMark(
                        x: .value("日付", stat.recordedAt),
                        y: .value("数値", stat[keyPath: keyPath])
                    )
                    .foregroundStyle(color)
                }
            }
            .frame(height: 200)
            
            // X軸の表示設定
            .chartXAxis {
                AxisMarks(values: xAxisValues) { value in
                    AxisValueLabel(format: .dateTime.month(.defaultDigits).day())
                    AxisGridLine()
                }
            }
            .chartYAxis {
                AxisMarks{ value in
                    AxisGridLine()
                    AxisValueLabel(format: Decimal.FormatStyle.number.notation(.compactName))
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 5)
    }
}

enum ChartRange: String, CaseIterable {
    case week = "1週間"
    case month = "1ヶ月"
    case threeMonths = "3ヶ月"
    case all = "全期間"
    
    var days: Int? {
        switch self {
        case .week: return 7
        case .month: return 30
        case .threeMonths: return 90
        case .all: return nil
        }
    }
}

#Preview {
    // 3ヶ月分くらいのダミーデータを作成してテストすると分かりやすいです
    let stats = (0..<100).map { i in
        ChannelStats(
            views: 10000 + i * 100,
            subscribers: 100 + i,
            videoCount: 10,
            recordedAt: Date().addingTimeInterval(-86400 * Double(99 - i))
        )
    }
    
    return StatsChartView(
        stats: stats,
        keyPath: \.views,
        title: "テストグラフ",
        color: .blue
    )
    .padding()
    .background(Color(.secondarySystemBackground))
}
