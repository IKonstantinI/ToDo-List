import Foundation

protocol TaskServiceProtocol {
    func fetchTasks() async throws -> [TaskEntity]
    func fetchTasksWithRefresh() async throws -> [TaskEntity]
    func createTask(title: String, description: String) async throws -> TaskEntity
    func updateTask(_ task: TaskEntity) async throws
    func deleteTask(_ task: TaskEntity) async throws
    func searchTasks(query: String) async throws -> [TaskEntity]
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