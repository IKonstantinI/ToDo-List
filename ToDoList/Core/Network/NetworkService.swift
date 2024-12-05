import Foundation

protocol NetworkServiceProtocol {
    func fetchTasks() async throws -> [TaskDTO]
}

enum NetworkError: LocalizedError {
    case invalidURL
    case invalidResponse
    case networkError(Error)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Неверный URL"
        case .invalidResponse:
            return "Некорректный ответ от сервера"
        case .networkError(let error):
            return error.localizedDescription
        }
    }
}

final class NetworkService: NetworkServiceProtocol {
    private let baseURL = "https://dummyjson.com"
    
    func fetchTasks() async throws -> [TaskDTO] {
        guard let url = URL(string: "\(baseURL)/todos") else {
            throw NetworkError.invalidURL
        }
        
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                throw NetworkError.invalidResponse
            }
            
            let decoder = JSONDecoder()
            let tasksResponse = try decoder.decode(TasksResponse.self, from: data)
            return tasksResponse.todos
        } catch let error as NetworkError {
            throw error
        } catch {
            throw NetworkError.networkError(error)
        }
    }
} 