import CoreData
import Foundation

final class TaskService: TaskServiceProtocol {
    private let context: NSManagedObjectContext
    private let networkService: NetworkServiceProtocol
    
    init(
        context: NSManagedObjectContext,
        networkService: NetworkServiceProtocol = NetworkService()
    ) {
        self.context = context
        self.networkService = networkService
    }
    
    func fetchTasks() async throws -> [TaskEntity] {
        return try await fetchTasks(forceRefresh: false)
    }
    
    private func fetchTasks(forceRefresh: Bool) async throws -> [TaskEntity] {
        if forceRefresh {
            let remoteTasks = try await networkService.fetchTasks()
            try await saveRemoteTasks(remoteTasks)
            return try await fetchLocalTasks()
        }
        
        let localTasks = try await fetchLocalTasks()
        if localTasks.isEmpty {
            let remoteTasks = try await networkService.fetchTasks()
            try await saveRemoteTasks(remoteTasks)
            return try await fetchLocalTasks()
        }
        
        return localTasks
    }
    
    private func fetchLocalTasks() async throws -> [TaskEntity] {
        try await withCheckedThrowingContinuation { continuation in
            let fetchRequest = NSFetchRequest<TaskMO>(entityName: "TaskMO")
            
            do {
                let taskMOs = try context.fetch(fetchRequest)
                let tasks = taskMOs.map { TaskEntity(
                    id: $0.id ?? UUID(),
                    title: $0.title ?? "",
                    description: $0.taskDescription ?? "",
                    createdAt: $0.createdAt ?? Date(),
                    isCompleted: $0.isCompleted
                ) }
                continuation.resume(returning: tasks)
            } catch {
                continuation.resume(throwing: TaskServiceError.fetchFailed)
            }
        }
    }
    
    private func saveRemoteTasks(_ remoteTasks: [TaskDTO]) async throws {
        try await withCheckedThrowingContinuation { continuation in
            remoteTasks.forEach { remoteTask in
                let taskMO = TaskMO(context: context)
                taskMO.id = UUID()
                taskMO.title = remoteTask.todo
                taskMO.taskDescription = ""
                taskMO.createdAt = Date()
                taskMO.isCompleted = remoteTask.completed
            }
            
            do {
                try context.save()
                continuation.resume()
            } catch {
                continuation.resume(throwing: TaskServiceError.saveFailed)
            }
        }
    }
    
    func createTask(title: String, description: String) async throws -> TaskEntity {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<TaskEntity, Error>) in
            let taskMO = TaskMO(context: context)
            taskMO.id = UUID()
            taskMO.title = title
            taskMO.taskDescription = description
            taskMO.createdAt = Date()
            taskMO.isCompleted = false
            
            do {
                try context.save()
                let task = TaskEntity(
                    id: taskMO.id ?? UUID(),
                    title: taskMO.title ?? "",
                    description: taskMO.taskDescription ?? "",
                    createdAt: taskMO.createdAt ?? Date(),
                    isCompleted: taskMO.isCompleted
                )
                continuation.resume(returning: task)
            } catch {
                continuation.resume(throwing: TaskServiceError.saveFailed)
            }
        }
    }
    
    func updateTask(_ task: TaskEntity) async throws {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            let fetchRequest = NSFetchRequest<TaskMO>(entityName: "TaskMO")
            fetchRequest.predicate = NSPredicate(format: "id == %@", task.id as CVarArg)
            
            do {
                let tasks = try context.fetch(fetchRequest)
                guard let taskMO = tasks.first else {
                    continuation.resume(throwing: TaskServiceError.taskNotFound)
                    return
                }
                
                taskMO.title = task.title
                taskMO.taskDescription = task.description
                taskMO.isCompleted = task.isCompleted
                
                try context.save()
                continuation.resume()
            } catch {
                continuation.resume(throwing: TaskServiceError.saveFailed)
            }
        }
    }
    
    func deleteTask(_ task: TaskEntity) async throws {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            let fetchRequest = NSFetchRequest<TaskMO>(entityName: "TaskMO")
            fetchRequest.predicate = NSPredicate(format: "id == %@", task.id as CVarArg)
            
            do {
                let tasks = try context.fetch(fetchRequest)
                guard let taskMO = tasks.first else {
                    continuation.resume(throwing: TaskServiceError.taskNotFound)
                    return
                }
                
                context.delete(taskMO)
                try context.save()
                continuation.resume()
            } catch {
                continuation.resume(throwing: TaskServiceError.saveFailed)
            }
        }
    }
    
    func searchTasks(query: String) async throws -> [TaskEntity] {
        try await withCheckedThrowingContinuation { continuation in
            let fetchRequest = NSFetchRequest<TaskMO>(entityName: "TaskMO")
            
            if !query.isEmpty {
                let predicate = NSPredicate(
                    format: "title CONTAINS[cd] %@ OR taskDescription CONTAINS[cd] %@",
                    query, query
                )
                fetchRequest.predicate = predicate
            }
            
            do {
                let taskMOs = try context.fetch(fetchRequest)
                let tasks = taskMOs.map { TaskEntity(
                    id: $0.id ?? UUID(),
                    title: $0.title ?? "",
                    description: $0.taskDescription ?? "",
                    createdAt: $0.createdAt ?? Date(),
                    isCompleted: $0.isCompleted
                ) }
                continuation.resume(returning: tasks)
            } catch {
                continuation.resume(throwing: TaskServiceError.fetchFailed)
            }
        }
    }
    
    func fetchTasksWithRefresh() async throws -> [TaskEntity] {
        return try await fetchTasks(forceRefresh: true)
    }
    
    private func clearOldTasks() async throws {
        try await withCheckedThrowingContinuation { continuation in
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "TaskMO")
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
            deleteRequest.resultType = .resultTypeObjectIDs
            
            do {
                let result = try context.execute(deleteRequest) as? NSBatchDeleteResult
                let changes: [AnyHashable: Any] = [
                    NSDeletedObjectsKey: result?.result as? [NSManagedObjectID] ?? []
                ]
                NSManagedObjectContext.mergeChanges(fromRemoteContextSave: changes, into: [context])
                continuation.resume()
            } catch {
                continuation.resume(throwing: TaskServiceError.saveFailed)
            }
        }
    }
    
    private func saveContext() throws {
        if context.hasChanges {
            try context.save()
        }
    }
    
    private func performInBackground<T>(_ block: @escaping (NSManagedObjectContext) throws -> T) async throws -> T {
        try await withCheckedThrowingContinuation { continuation in
            context.perform {
                do {
                    let result = try block(self.context)
                    continuation.resume(returning: result)
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }
} 