import UIKit

/// Row in the cart: emoji tile, name, "qty × price" line, line total.
final class CartCell: UITableViewCell {
    static let reuseID = "CartCell"

    private let artView = UIView()
    private let emojiLabel = UILabel()
    private let nameLabel = UILabel()
    private let detailLabel = UILabel()
    private let totalLabel = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setUpViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(with item: CartItem) {
        artView.backgroundColor = item.gift.category.tint
        emojiLabel.text = item.gift.emoji
        nameLabel.text = item.gift.name
        var detail = "\(item.quantity) × \(Money.format(item.unitPrice))"
        if item.isWrapped {
            detail += " · 🎀 упаковка"
        }
        detailLabel.text = detail
        totalLabel.text = Money.format(item.total)
    }

    private func setUpViews() {
        selectionStyle = .default

        artView.layer.cornerRadius = 14
        emojiLabel.font = .systemFont(ofSize: 28)

        nameLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        nameLabel.numberOfLines = 2

        detailLabel.font = .systemFont(ofSize: 13)
        detailLabel.textColor = .secondaryLabel

        totalLabel.font = .systemFont(ofSize: 16, weight: .bold)
        totalLabel.textColor = Theme.rose
        totalLabel.textAlignment = .right
        totalLabel.setContentHuggingPriority(.required, for: .horizontal)
        totalLabel.setContentCompressionResistancePriority(.required, for: .horizontal)

        let textStack = UIStackView(arrangedSubviews: [nameLabel, detailLabel])
        textStack.axis = .vertical
        textStack.spacing = 3

        contentView.addSubview(artView)
        artView.addSubview(emojiLabel)
        contentView.addSubview(textStack)
        contentView.addSubview(totalLabel)
        [artView, emojiLabel, textStack, totalLabel].forEach { $0.translatesAutoresizingMaskIntoConstraints = false }

        NSLayoutConstraint.activate([
            artView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            artView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            artView.widthAnchor.constraint(equalToConstant: 52),
            artView.heightAnchor.constraint(equalToConstant: 52),

            emojiLabel.centerXAnchor.constraint(equalTo: artView.centerXAnchor),
            emojiLabel.centerYAnchor.constraint(equalTo: artView.centerYAnchor),

            textStack.leadingAnchor.constraint(equalTo: artView.trailingAnchor, constant: 12),
            textStack.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            textStack.trailingAnchor.constraint(lessThanOrEqualTo: totalLabel.leadingAnchor, constant: -8),

            totalLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            totalLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
}
