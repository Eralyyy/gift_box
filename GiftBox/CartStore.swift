import UIKit

/// In-memory cart and favourites shared by both tabs.
final class CartStore {
    static let shared = CartStore()
    static let didChange = Notification.Name("CartStoreDidChange")

    private(set) var sections: [CartSection] = []
    private var favoriteIDs: Set<Int> = [1, 9]

    private init() {
        seed()
    }

    var itemCount: Int {
        sections.reduce(0) { total, section in
            total + section.items.reduce(0) { $0 + $1.quantity }
        }
    }

    var total: Int { sections.reduce(0) { $0 + $1.subtotal } }

    func item(at indexPath: IndexPath) -> CartItem {
        sections[indexPath.section].items[indexPath.row]
    }

    func add(_ gift: Gift, quantity: Int = 1) {
        guard gift.inStock else { return }
        let newItem = CartItem(gift: gift, quantity: quantity, isWrapped: false)

        if let s = sections.firstIndex(where: { $0.category == gift.category }) {
            if let r = sections[s].items.firstIndex(where: { $0.gift == gift }) {
                sections[s].items[r].quantity += quantity
            } else {
                sections[s].items.append(newItem)
            }
        } else {
            // Keep sections in the same order as the catalog categories.
            let position = sections.firstIndex { $0.category.rawValue > gift.category.rawValue } ?? sections.count
            sections.insert(CartSection(category: gift.category, items: [newItem]), at: position)
        }
        notify()
    }

    /// Removes a row; returns true when that was the last row and the whole section went away.
    @discardableResult
    func remove(at indexPath: IndexPath) -> Bool {
        sections[indexPath.section].items.remove(at: indexPath.row)
        let sectionIsEmpty = sections[indexPath.section].items.isEmpty
        if sectionIsEmpty {
            sections.remove(at: indexPath.section)
        }
        notify()
        return sectionIsEmpty
    }

    func move(from source: IndexPath, to destination: IndexPath) {
        guard source.section == destination.section else { return }
        let item = sections[source.section].items.remove(at: source.row)
        sections[source.section].items.insert(item, at: destination.row)
        notify()
    }

    func toggleWrapped(at indexPath: IndexPath) {
        sections[indexPath.section].items[indexPath.row].isWrapped.toggle()
        notify()
    }

    func incrementQuantity(at indexPath: IndexPath) {
        sections[indexPath.section].items[indexPath.row].quantity += 1
        notify()
    }

    func clear() {
        sections.removeAll()
        notify()
    }

    func isFavorite(_ gift: Gift) -> Bool {
        favoriteIDs.contains(gift.id)
    }

    @discardableResult
    func toggleFavorite(_ gift: Gift) -> Bool {
        if favoriteIDs.remove(gift.id) == nil {
            favoriteIDs.insert(gift.id)
            return true
        }
        return false
    }

    private func notify() {
        NotificationCenter.default.post(name: CartStore.didChange, object: nil)
    }

    private func seed() {
        let ids = [1, 3, 5, 6, 9, 10, 11, 13, 14, 15]
        for gift in GiftData.all where ids.contains(gift.id) {
            add(gift, quantity: gift.id == 5 ? 2 : 1)
        }
    }
}
