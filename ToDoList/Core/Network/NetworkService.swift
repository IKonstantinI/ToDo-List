import Foundation

protocol NetworkServiceProtocol {
    func fetchTasks() async throws -> [TaskDTO]
}

enum NetworkError: LocalizedError {
    case invalidURL
    case invalidResponse
    case networkError(Error)
    case noInternetConnection
    case timeout
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Неверный URL"
        case .invalidResponse:
            return "Некорректный ответ от сервера"
        case .networkError(let error):
            return error.localizedDescription
        case .noInternetConnection:
            return "Отсутствует подключение к интернету"
        case .timeout:
            return "Превышено время ожидания запроса"
        }
    }
}

final class NetworkService: NetworkServiceProtocol {
    private let baseURL = "https://dummyjson.com"
    private let session: URLSession
    private let timeout: TimeInterval = 30
    
    init(session: URLSession = .shared) {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = timeout
        config.timeoutIntervalForResource = timeout
        self.session = URLSession(configuration: config)
    }
    
    func fetchTasks() async throws -> [TaskDTO] {
        guard let url = URL(string: "\(baseURL)/todos") else {
            throw NetworkError.invalidURL
        }
        
        do {
            let (data, response) = try await session.data(from: url)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw NetworkError.invalidResponse
            }
            
            switch httpResponse.statusCode {
            case 200...299:
                let decoder = JSONDecoder()
                let tasksResponse = try decoder.decode(TasksResponse.self, from: data)
                return tasksResponse.todos
            case 408:
                throw NetworkError.timeout
            case 500...599:
                throw NetworkError.invalidResponse
            default:
                throw NetworkError.invalidResponse
            }
            
        } catch let error as NetworkError {
            throw error
        } catch let error as URLError {
            switch error.code {
            case .notConnectedToInternet:
                throw NetworkError.noInternetConnection
            case .timedOut:
                throw NetworkError.timeout
            default:
                throw NetworkError.networkError(error)
            }
        } catch {
            throw NetworkError.networkError(error)
        }
    }
} 