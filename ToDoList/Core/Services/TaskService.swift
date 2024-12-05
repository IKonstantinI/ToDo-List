import CoreData
import Foundation

final class TaskService: TaskServiceProtocol {
    private let context: NSManagedObjectContext
    private let networkService: NetworkServiceProtocol
    private var userDefaultsService: UserDefaultsServiceProtocol
    private let backgroundContext: NSManagedObjectContext
    
    init(
        context: NSManagedObjectContext,
        networkService: NetworkServiceProtocol = NetworkService(),
        userDefaultsService: UserDefaultsServiceProtocol = UserDefaultsService()
    ) {
        self.context = context
        self.networkService = networkService
        self.userDefaultsService = userDefaultsService
        
        self.backgroundContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        self.backgroundContext.parent = context
    }
    
    // MARK: - Initial Setup
    
    func performInitialSetupIfNeeded() async throws {
        guard userDefaultsService.isFirstLaunch else { return }
        
        let remoteTasks = try await networkService.fetchTasks()
        
        try await backgroundContext.perform {
            for task in remoteTasks {
                let taskMO = TaskMO(context: self.backgroundContext)
                taskMO.id = UUID()
                taskMO.title = task.todo
                taskMO.taskDescription = ""
                taskMO.createdAt = Date()
                taskMO.isCompleted = task.completed
            }
            
            try self.backgroundContext.save()
            try self.context.save()
        }
        
        userDefaultsService.isFirstLaunch = false
    }
    
    // MARK: - Create
    
    func createTask(_ task: TaskEntity) async throws -> TaskEntity {
        return try await backgroundContext.perform {
            let taskMO = TaskMO(context: self.backgroundContext)
            taskMO.id = task.id
            taskMO.title = task.title
            taskMO.taskDescription = task.description
            taskMO.createdAt = task.createdAt
            taskMO.isCompleted = task.isCompleted
            
            try self.backgroundContext.save()
            try self.context.save()
            
            return self.convertToEntity(taskMO)
        }
    }
    
    // MARK: - Read
    
    func fetchTasks() async throws -> [TaskEntity] {
        return try await backgroundContext.perform {
            let request = TaskMO.fetchRequest()
            request.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]
            
            let taskMOs = try self.backgroundContext.fetch(request)
            return taskMOs.map { self.convertToEntity($0) }
        }
    }
    
    func searchTasks(query: String) async throws -> [TaskEntity] {
        return try await backgroundContext.perform {
            let request = TaskMO.fetchRequest()
            request.predicate = NSPredicate(
                format: "title CONTAINS[cd] %@ OR taskDescription CONTAINS[cd] %@",
                query, query
            )
            request.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]
            
            let taskMOs = try self.backgroundContext.fetch(request)
            return taskMOs.map { self.convertToEntity($0) }
        }
    }
    
    // MARK: - Update
    
    func updateTask(_ task: TaskEntity) async throws {
        try await backgroundContext.perform {
            let request = TaskMO.fetchRequest()
            request.predicate = NSPredicate(format: "id == %@", task.id as CVarArg)
            
            guard let taskMO = try self.backgroundContext.fetch(request).first else {
                throw TaskServiceError.taskNotFound
            }
            
            taskMO.title = task.title
            taskMO.taskDescription = task.description
            taskMO.isCompleted = task.isCompleted
            
            try self.backgroundContext.save()
            try self.context.save()
        }
    }
    
    // MARK: - Delete
    
    func deleteTask(_ task: TaskEntity) async throws {
        try await backgroundContext.perform {
            let request = TaskMO.fetchRequest()
            request.predicate = NSPredicate(format: "id == %@", task.id as CVarArg)
            
            guard let taskMO = try self.backgroundContext.fetch(request).first else {
                throw TaskServiceError.taskNotFound
            }
            
            self.backgroundContext.delete(taskMO)
            try self.backgroundContext.save()
            try self.context.save()
        }
    }
    
    // MARK: - Private
    
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