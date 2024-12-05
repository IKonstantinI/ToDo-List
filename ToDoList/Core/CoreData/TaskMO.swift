import CoreData

@objc(TaskMO)
public class TaskMO: NSManagedObject {
    @NSManaged public var id: UUID?
    @NSManaged public var title: String?
    @NSManaged public var taskDescription: String?
    @NSManaged public var createdAt: Date?
    @NSManaged public var isCompleted: Bool
}

extension TaskMO {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<TaskMO> {
        return NSFetchRequest<TaskMO>(entityName: "TaskMO")
    }
    
    // Добавим индекс по id для быстрого поиска
    static func addIndexes(to entity: NSEntityDescription) {
        let idProperty = entity.properties.first { $0.name == "id" }
        if let idProperty = idProperty {
            let index = NSFetchIndexDescription(name: "idIndex", elements: [
                NSFetchIndexElementDescription(property: idProperty, collationType: .binary)
            ])
            entity.indexes = [index]
        }
    }
} 