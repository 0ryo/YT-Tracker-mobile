import Foundation

enum ChartRange: String, CaseIterable {
    case week = "今週"
    case month = "先月"
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
