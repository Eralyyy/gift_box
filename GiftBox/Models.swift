import UIKit

enum Theme {
    static let rose = UIColor(red: 0.84, green: 0.20, blue: 0.42, alpha: 1)
    static let background = UIColor.systemGroupedBackground
}

enum Money {
    private static let formatter: NumberFormatter = {
        let f = NumberFormatter()
        f.numberStyle = .decimal
        f.usesGroupingSeparator = true
        f.groupingSeparator = " "
        return f
    }()

    static func format(_ value: Int) -> String {
        let number = formatter.string(from: NSNumber(value: value)) ?? "\(value)"
        return "\(number) ₸"
    }
}

enum GiftCategory: Int, CaseIterable {
    case boxes, sweets, personal, decor

    var title: String {
        switch self {
        case .boxes: return "Боксы"
        case .sweets: return "Сладости"
        case .personal: return "Именные"
        case .decor: return "Декор"
        }
    }

    var tint: UIColor {
        switch self {
        case .boxes: return UIColor(red: 1.00, green: 0.88, blue: 0.92, alpha: 1)
        case .sweets: return UIColor(red: 1.00, green: 0.93, blue: 0.82, alpha: 1)
        case .personal: return UIColor(red: 0.89, green: 0.90, blue: 1.00, alpha: 1)
        case .decor: return UIColor(red: 0.87, green: 0.96, blue: 0.89, alpha: 1)
        }
    }
}

struct Gift: Hashable {
    let id: Int
    let name: String
    let emoji: String
    let price: Int
    let category: GiftCategory
    let details: String
    var inStock: Bool = true
}

enum GiftData {
    static let all: [Gift] = [
        Gift(id: 1, name: "Бокс «Нежность»", emoji: "🎀", price: 18_500, category: .boxes,
             details: "Клубника в шоколаде, макароны и открытка с вашим текстом в подарочной коробке."),
        Gift(id: 2, name: "Бокс «Для неё»", emoji: "💐", price: 24_000, category: .boxes,
             details: "Мини-букет, сладости и именная шоколадка. Подойдёт на 8 марта и день рождения."),
        Gift(id: 3, name: "Мини-бокс «Сюрприз»", emoji: "🎁", price: 9_500, category: .boxes,
             details: "Небольшой набор для знака внимания: конфеты, открытка и ленточка."),
        Gift(id: 4, name: "Бокс «Шоколадный рай»", emoji: "🍫", price: 21_000, category: .boxes,
             details: "Шоколад трёх видов, конфеты ручной работы и горячий шоколад в чашке."),
        Gift(id: 5, name: "Клубника в шоколаде", emoji: "🍓", price: 8_500, category: .sweets,
             details: "Свежая клубника в бельгийском шоколаде. Делаем в день заказа."),
        Gift(id: 6, name: "Капкейки, 6 шт.", emoji: "🧁", price: 7_200, category: .sweets,
             details: "Нежные капкейки с кремом. Можно выбрать вкусы и цвет декора."),
        Gift(id: 7, name: "Торт-бенто", emoji: "🎂", price: 6_500, category: .sweets,
             details: "Маленький тортик на двоих с надписью на заказ."),
        Gift(id: 8, name: "Конфеты ручной работы", emoji: "🍬", price: 5_400, category: .sweets,
             details: "Набор из 12 конфет с разными начинками в красивой коробочке."),
        Gift(id: 9, name: "Брелок с фото", emoji: "🔑", price: 3_500, category: .personal,
             details: "Ваше любимое фото на брелке. Всегда с вами на ключах или сумке."),
        Gift(id: 10, name: "Кружка с фото", emoji: "☕", price: 4_800, category: .personal,
             details: "Кружка с вашим снимком или надписью. Печать не стирается."),
        Gift(id: 11, name: "Золотой билет", emoji: "🎫", price: 2_500, category: .personal,
             details: "Именное приглашение в стиле Вилли Вонки с именем гостя и деталями праздника."),
        Gift(id: 12, name: "Открытка с фото", emoji: "🖼️", price: 2_900, category: .personal,
             details: "Плотная открытка с вашей фотографией и тёплыми словами."),
        Gift(id: 13, name: "Большой мишка", emoji: "🧸", price: 15_000, category: .decor,
             details: "Гигантская мягкая игрушка. Привозим в подарочной упаковке."),
        Gift(id: 14, name: "Букет из шаров", emoji: "🎈", price: 6_000, category: .decor,
             details: "Воздушные шары с гелием: цвета выбираете сами."),
        Gift(id: 15, name: "Лампа-ночник с фото", emoji: "💡", price: 11_000, category: .decor,
             details: "Светильник с вашей фотографией: тёплый свет и мягкий уют."),
        Gift(id: 16, name: "Букет из игрушек", emoji: "🐻", price: 13_500, category: .decor,
             details: "Букет из мягких игрушек вместо цветов. Сейчас временно нет в наличии.",
             inStock: false)
    ]

    static func grouped() -> [(category: GiftCategory, gifts: [Gift])] {
        GiftCategory.allCases.map { category in
            (category: category, gifts: all.filter { $0.category == category })
        }
    }
}

struct CartItem {
    static let wrapPrice = 500

    let gift: Gift
    var quantity: Int
    var isWrapped: Bool

    var unitPrice: Int { gift.price + (isWrapped ? CartItem.wrapPrice : 0) }
    var total: Int { unitPrice * quantity }
}

struct CartSection {
    let category: GiftCategory
    var items: [CartItem]

    var subtotal: Int { items.reduce(0) { $0 + $1.total } }
}
