import Foundation

//actor: 複数の場所から同時に呼ばれてもデータが壊れない安全なクラス
actor YouTubeAPIService {
    private let baseURL = "https//:www.googleapis.com/youtube/v3/channels"
    
    // エラーの種類を定義
    enum APIError: Error {
        case invalidURL
        case networkError(Error)
        case decodingError(Error)
        case channelNotFound
    }
    
    //チャンネル情報を取得するメソッド
    //input: ユーザーが入力した文字列
    //apiKey: YouTube Data API v3のキー
    func fetchChannel(input: String, apiKey: String)async throws -> YouTubeChannelItem {
        // 1. URLの組み立て
        var components = URLComponents(string: baseURL)!
        
        //共通のクエリパラメータ
        var queryItems = [
            URLQueryItem(name: "part", value: "snippet,statistics"),
            URLQueryItem(name: "key", value: apiKey)
        ]
        
        //TODO: inputの中身によってパラメータを変える
        // Web版のロジック:
        // "UC"で始まるなら -> name: "id"
        // "@"で始まるなら -> name: "forHandle"
        // それ以外なら -> name: "forUsername"
        if input.hasPrefix("UC") {
            // ID検索の場合
            queryItems.append(URLQueryItem(name: "id", value: input))
        } else if input.hasPrefix("@") {
            // ハンドル検索の場合
            queryItems.append(URLQueryItem(name: "forHandle", value: input))
        } else {
            // ユーザー名検索の場合
            queryItems.append(URLQueryItem(name: "forUsername", value: input))
        }
        
        //　配列をセット
        components.queryItems = queryItems
        
        guard let url = components.url else {
            throw APIError.invalidURL
        }
        
        // 2. 通信の実行
        // URLSessionw使ってデータを取りに行く
        // responseは今回は使わないので、＿で捨てる。
        let(data, _) = try await URLSession.shared.data(from: url)
        
        // 3. デコード(解析）
        do {
            let decodedResponse = try JSONDecoder().decode(YouTubeChannelResponse.self, from: data)
            
            // アイテムが空だった場合
            guard let item = decodedResponse.items?.first else {
                throw APIError.channelNotFound
            }
            
            return item
        } catch {
            print("Decoding Error: \(error)")
            throw APIError.decodingError(error)
        }
    }
}
