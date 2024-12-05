protocol TaskListInteractorProtocol: AnyObject {
    func fetchTasks() async throws -> [TaskEntity]
    func fetchTasksWithRefresh() async throws -> [TaskEntity]
    func createTask(title: String, description: String) async throws
    func updateTask(_ task: TaskEntity) async throws
    func deleteTask(_ task: TaskEntity) async throws
    func searchTasks(query: String) async throws -> [TaskEntity]
}

final class TaskListInteractor: TaskListInteractorProtocol {
    private let taskService: TaskServiceProtocol
    
    init(taskService: TaskServiceProtocol) {
        self.taskService = taskService
    }
    
    func fetchTasks() async throws -> [TaskEntity] {
        return try await taskService.fetchTasks()
    }
    
    func fetchTasksWithRefresh() async throws -> [TaskEntity] {
        return try await taskService.fetchTasksWithRefresh()
    }
    
    func createTask(title: String, description: String) async throws {
        _ = try await taskService.createTask(title: title, description: description)
    }
    
    func updateTask(_ task: TaskEntity) async throws {
        try await taskService.updateTask(task)
    }
    
    func deleteTask(_ task: TaskEntity) async throws {
        try await taskService.deleteTask(task)
    }
    
    func searchTasks(query: String) async throws -> [TaskEntity] {
        return try await taskService.searchTasks(query: query)
    }
} 