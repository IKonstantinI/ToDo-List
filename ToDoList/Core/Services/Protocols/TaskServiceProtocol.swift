import Foundation

protocol TaskServiceProtocol {
    // Create
    func createTask(_ task: TaskEntity) async throws -> TaskEntity
    
    // Read
    func fetchTasks() async throws -> [TaskEntity]
    func searchTasks(query: String) async throws -> [TaskEntity]
    
    // Update
    func updateTask(_ task: TaskEntity) async throws
    
    // Delete
    func deleteTask(_ task: TaskEntity) async throws
    
    // Initial Setup
    func performInitialSetupIfNeeded() async throws
}

enum TaskServiceError: LocalizedError {
    case saveFailed
    case fetchFailed
    case taskNotFound
    
    var errorDescription: String? {
        switch self {
        case .saveFailed:
            return "Не удалось сохранить задачу"
        case .fetchFailed:
            return "Не удалось загрузить задачи"
        case .taskNotFound:
            return "Задача не найдена"
        }
    }
} 