import UIKit

final class MainTabBarController: UITabBarController {
    private let cartNavigation = UINavigationController(rootViewController: CartViewController())

    override func viewDidLoad() {
        super.viewDidLoad()
        view.tintColor = Theme.rose

        let catalogNavigation = UINavigationController(rootViewController: CatalogViewController())
        catalogNavigation.tabBarItem = UITabBarItem(title: "Каталог",
                                                    image: UIImage(systemName: "square.grid.2x2"),
                                                    selectedImage: UIImage(systemName: "square.grid.2x2.fill"))
        cartNavigation.tabBarItem = UITabBarItem(title: "Корзина",
                                                 image: UIImage(systemName: "cart"),
                                                 selectedImage: UIImage(systemName: "cart.fill"))
        for navigation in [catalogNavigation, cartNavigation] {
            navigation.navigationBar.prefersLargeTitles = true
        }
        viewControllers = [catalogNavigation, cartNavigation]

        NotificationCenter.default.addObserver(self, selector: #selector(refreshBadge),
                                               name: CartStore.didChange, object: nil)
        refreshBadge()
    }

    @objc private func refreshBadge() {
        let count = CartStore.shared.itemCount
        cartNavigation.tabBarItem.badgeValue = count > 0 ? "\(count)" : nil
    }
}
