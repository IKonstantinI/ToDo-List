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
} 