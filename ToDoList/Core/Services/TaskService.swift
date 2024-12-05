import CoreData
import Foundation

final class TaskService: TaskServiceProtocol {
    private let context: NSManagedObjectContext
    private let networkService: NetworkServiceProtocol
    private var userDefaultsService: UserDefaultsServiceProtocol
    
    init(
        context: NSManagedObjectContext,
        networkService: NetworkServiceProtocol = NetworkService(),
        userDefaultsService: UserDefaultsServiceProtocol = UserDefaultsService()
    ) {
        self.context = context
        self.networkService = networkService
        self.userDefaultsService = userDefaultsService
    }
    
    // MARK: - Initial Setup
    
    func performInitialSetupIfNeeded() async throws {
        guard userDefaultsService.isFirstLaunch else { return }
        
        // Загружаем данные с API
        let remoteTasks = try await networkService.fetchTasks()
        
        // Сохраняем в CoreData
        try await saveTasks(remoteTasks)
        
        // Отмечаем, что первый запуск выполнен
        userDefaultsService.isFirstLaunch = false
    }
    
    // MARK: - Create
    
    func createTask(_ task: TaskEntity) async throws -> TaskEntity {
        return try await Task {
            let taskMO = TaskMO(context: self.context)
            taskMO.id = task.id
            taskMO.title = task.title
            taskMO.taskDescription = task.description
            taskMO.createdAt = task.createdAt
            taskMO.isCompleted = task.isCompleted
            
            try context.save()
            
            return TaskEntity(
                id: taskMO.id ?? UUID(),
                title: taskMO.title ?? "",
                description: taskMO.taskDescription ?? "",
                createdAt: taskMO.createdAt ?? Date(),
                isCompleted: taskMO.isCompleted
            )
        }.value
    }
    
    // MARK: - Read
    
    func fetchTasks() async throws -> [TaskEntity] {
        return try await Task {
            let fetchRequest = TaskMO.fetchRequest()
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]
            
            let taskMOs = try self.context.fetch(fetchRequest)
            return taskMOs.map { self.convertToEntity($0) }
        }.value
    }
    
    func searchTasks(query: String) async throws -> [TaskEntity] {
        return try await Task {
            let fetchRequest = TaskMO.fetchRequest()
            if !query.isEmpty {
                fetchRequest.predicate = NSPredicate(
                    format: "title CONTAINS[cd] %@ OR taskDescription CONTAINS[cd] %@",
                    query, query
                )
            }
            
            let taskMOs = try self.context.fetch(fetchRequest)
            return taskMOs.map { self.convertToEntity($0) }
        }.value
    }
    
    // MARK: - Update
    
    func updateTask(_ task: TaskEntity) async throws {
        try await Task {
            let fetchRequest = TaskMO.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "id == %@", task.id as CVarArg)
            
            let taskMOs = try self.context.fetch(fetchRequest)
            guard let taskMO = taskMOs.first else {
                throw TaskServiceError.taskNotFound
            }
            
            taskMO.title = task.title
            taskMO.taskDescription = task.description
            taskMO.isCompleted = task.isCompleted
            
            try self.context.save()
        }.value
    }
    
    // MARK: - Delete
    
    func deleteTask(_ task: TaskEntity) async throws {
        try await Task {
            let fetchRequest = TaskMO.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "id == %@", task.id as CVarArg)
            
            let taskMOs = try self.context.fetch(fetchRequest)
            guard let taskMO = taskMOs.first else {
                throw TaskServiceError.taskNotFound
            }
            
            self.context.delete(taskMO)
            try self.context.save()
        }.value
    }
    
    // MARK: - Private Helpers
    
    private func saveTasks(_ tasks: [TaskDTO]) async throws {
        try await Task {
            for task in tasks {
                let taskMO = TaskMO(context: context)
                taskMO.id = UUID()
                taskMO.title = task.todo
                taskMO.taskDescription = ""
                taskMO.createdAt = Date()
                taskMO.isCompleted = task.completed
            }
            try context.save()
        }.value
    }
    
    private func convertToEntity(_ taskMO: TaskMO) -> TaskEntity {
        TaskEntity(
            id: taskMO.id ?? UUID(),
            title: taskMO.title ?? "",
            description: taskMO.taskDescription ?? "",
            createdAt: taskMO.createdAt ?? Date(),
            isCompleted: taskMO.isCompleted
        )
    }
} 