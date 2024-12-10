import Foundation

protocol NetworkServiceProtocol {
    func fetchTasks() async throws -> [TaskDTO]
}

enum NetworkError: LocalizedError {
    case invalidURL
    case invalidResponse
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Неверный URL"
        case .invalidResponse:
            return "Ошибка сервера"
        }
    }
}

final class NetworkService: NetworkServiceProtocol {
    private let baseURL = "https://dummyjson.com"
    
    func fetchTasks() async throws -> [TaskDTO] {
        guard let url = URL(string: "\(baseURL)/todos") else {
            print("❌ Invalid URL")
            throw NetworkError.invalidURL
        }
        
        print("🌐 Fetching tasks from: \(url)")
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            print("❌ Invalid response")
            throw NetworkError.invalidResponse
        }
        
        let decoder = JSONDecoder()
        let result = try decoder.decode(TasksResponse.self, from: data)
        
        print("✅ Fetched \(result.todos.count) tasks")
        return result.todos
    }
} 