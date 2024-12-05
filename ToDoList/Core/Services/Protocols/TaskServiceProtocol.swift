import Foundation

protocol TaskServiceProtocol {
    func performInitialSetupIfNeeded() async throws
    func createTask(_ task: TaskEntity) async throws -> TaskEntity
    func fetchTasks() async throws -> [TaskEntity]
    func searchTasks(query: String) async throws -> [TaskEntity]
    func updateTask(_ task: TaskEntity) async throws
    func deleteTask(_ task: TaskEntity) async throws
}

enum TaskServiceError: LocalizedError {
    case taskNotFound
    case saveFailed
    
    var errorDescription: String? {
        switch self {
        case .taskNotFound:
            return "Задача не найдена"
        case .saveFailed:
            return "Ошибка сохранения"
        }
    }
} 