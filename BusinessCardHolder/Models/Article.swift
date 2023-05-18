//
//  Article.swift
//  BusinessCardHolder
//

import Foundation

let urlString = "https://newsapi.org/v2/top-headlines?country=jp&apiKey=a2a7dbffbe8249c29a51d7235a52b715"

class Article: Codable {
    var title: String
    var url: String
        
    init(title: String, url: String) {
        self.title = title
        self.url = url
    }

    enum CodingKeys: String, CodingKey {
        case title, url
    }
}

struct ArticleList: Codable {
    let articles: [Article]
}

extension Article {
    func getArticles(completion: @escaping ([Article]) -> Void){
        let session = URLSession(configuration: .default)
        
        guard let url = URL(string: urlString) else {
            completion([])
            return
        }

        let task = session.dataTask(with: url) { data, response, error in
            if error != nil {
                completion([])
            }

            if let safeData = data {
                let decoder = JSONDecoder()
                do {
                    let decodedData = try decoder.decode(ArticleList.self, from: safeData)
                    completion(decodedData.articles)
                } catch  {
                    print(String(describing: error))
                    completion([])
                }
            }
        }

        task.resume()
    }
}
