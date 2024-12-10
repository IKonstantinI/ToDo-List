import UIKit
import CoreData

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        let window = UIWindow(windowScene: windowScene)
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let context = appDelegate.persistentContainer.viewContext
        
        context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        context.automaticallyMergesChangesFromParent = true
        
        let userDefaultsService = UserDefaultsService()
        let networkService = NetworkService()
        let taskService = TaskService(
            context: context,
            networkService: networkService,
            userDefaultsService: userDefaultsService
        )
        
        Task {
            do {
                try await taskService.performInitialSetupIfNeeded()
            } catch {
                print("Initial setup failed:", error)
            }
        }
        
        let rootViewController = TaskListAssembly.createModule(
            context: context,
            taskService: taskService
        )
        let navigationController = UINavigationController(rootViewController: rootViewController)
        
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
        
        self.window = window
    }
    
    func sceneDidEnterBackground(_ scene: UIScene) {
        (UIApplication.shared.delegate as? AppDelegate)?.saveContext()
    }
}