import Foundation

enum UserDefaultsKey {
    static let isFirstLaunch = "isFirstLaunch"
}

protocol UserDefaultsServiceProtocol {
    var isFirstLaunch: Bool { get set }
}

final class UserDefaultsService: UserDefaultsServiceProtocol {
    private let defaults = UserDefaults.standard
    
    var isFirstLaunch: Bool {
        get {
            !defaults.bool(forKey: UserDefaultsKey.isFirstLaunch)
        }
        set {
            defaults.set(!newValue, forKey: UserDefaultsKey.isFirstLaunch)
        }
    }
} 
