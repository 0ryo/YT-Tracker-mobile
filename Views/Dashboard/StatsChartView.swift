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
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)
            
            // グラフ本体
            Chart {
                ForEach(stats) { stat in
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
                AxisMarks(values: .stride(by: .day)) { value in
                    AxisValueLabel(format: .dateTime.month().day())
                    AxisGridLine()
                }
            }
            .chartYAxis {
                AxisMarks{ value in
                    AxisValueLabel()
                    AxisGridLine()
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 5)
    }
}

#Preview {
    // ダミーデータ作成
    let stats = [
        ChannelStats(views: 100, subscribers: 10, videoCount: 1, recordedAt: Date().addingTimeInterval(-86400 * 2)), // 2日前
        ChannelStats(views: 150, subscribers: 12, videoCount: 1, recordedAt: Date().addingTimeInterval(-86400)),     // 1日前
        ChannelStats(views: 200, subscribers: 15, videoCount: 2, recordedAt: Date())                                 // 今日
    ]
    
    return VStack {
        // 登録者数のグラフ（赤）
        StatsChartView(
            stats: stats,
            keyPath: \.subscribers,
            title: "登録者数",
            color: .red
        )
        
        // 再生回数のグラフ（青）
        StatsChartView(
            stats: stats,
            keyPath: \.views,
            title: "再生回数",
            color: .blue
        )
    }
    .padding()
    .background(Color(.secondarySystemBackground))
}
