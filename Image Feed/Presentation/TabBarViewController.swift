import UIKit

final class TabBarController: UITabBarController {

    private enum TabBarItem {
        case list
        case profile
        
        var image: UIImage? {
            switch self {
            case .list:
                return UIImage(named: "tab_editorial_active")
            case .profile:
                return UIImage(named: "tab_profile_active")
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabBar()
    }
    
    func setupTabBar() {
        tabBar.backgroundColor = .ypBlack
        tabBar.barTintColor = .clear
        tabBar.tintColor = .white
        
        let items: [TabBarItem] = [.list, .profile]
        
        viewControllers = items.compactMap({ item in
            switch item {
            case .list:
                return ImagesListViewController()
            case .profile:
                return ProfileViewController()
            }
        })
        
        viewControllers?.enumerated().forEach({ (index, vc) in
            vc.tabBarItem.image = items[index].image
        })
    }
}
