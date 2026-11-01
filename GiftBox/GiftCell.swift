import UIKit

/// Card in the catalog grid: emoji "photo", name, price, favourite button.
final class GiftCell: UICollectionViewCell {
    static let reuseID = "GiftCell"

    var onFavoriteTap: (() -> Void)?

    private let artView = UIView()
    private let emojiLabel = UILabel()
    private let nameLabel = UILabel()
    private let priceLabel = UILabel()
    private let stockLabel = UILabel()
    private let favoriteButton = UIButton(type: .system)

    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: 18).cgPath
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        onFavoriteTap = nil
        transform = .identity
        alpha = 1
    }

    func configure(with gift: Gift, isFavorite: Bool) {
        artView.backgroundColor = gift.category.tint
        emojiLabel.text = gift.emoji
        nameLabel.text = gift.name
        priceLabel.text = Money.format(gift.price)
        stockLabel.isHidden = gift.inStock
        contentView.alpha = gift.inStock ? 1 : 0.6
        setFavorite(isFavorite, animated: false)
    }

    func setFavorite(_ isFavorite: Bool, animated: Bool) {
        let symbol = isFavorite ? "heart.fill" : "heart"
        favoriteButton.setImage(UIImage(systemName: symbol), for: .normal)
        favoriteButton.tintColor = isFavorite ? Theme.rose : .systemGray
        guard animated else { return }
        favoriteButton.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
        UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 0.45,
                       initialSpringVelocity: 8, options: []) {
            self.favoriteButton.transform = .identity
        }
    }

    @objc private func favoriteTapped() {
        onFavoriteTap?()
    }

    private func setUpViews() {
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.08
        layer.shadowRadius = 8
        layer.shadowOffset = CGSize(width: 0, height: 3)

        contentView.backgroundColor = .secondarySystemGroupedBackground
        contentView.layer.cornerRadius = 18
        contentView.clipsToBounds = true

        emojiLabel.font = .systemFont(ofSize: 60)

        nameLabel.font = .systemFont(ofSize: 15, weight: .semibold)
        nameLabel.numberOfLines = 2

        priceLabel.font = .systemFont(ofSize: 15, weight: .bold)
        priceLabel.textColor = Theme.rose

        stockLabel.text = "  Нет в наличии  "
        stockLabel.font = .systemFont(ofSize: 11, weight: .semibold)
        stockLabel.textColor = .white
        stockLabel.backgroundColor = UIColor.black.withAlphaComponent(0.55)
        stockLabel.layer.cornerRadius = 10
        stockLabel.clipsToBounds = true

        favoriteButton.backgroundColor = UIColor.white.withAlphaComponent(0.85)
        favoriteButton.layer.cornerRadius = 17
        favoriteButton.addTarget(self, action: #selector(favoriteTapped), for: .touchUpInside)

        [artView, nameLabel, priceLabel].forEach { contentView.addSubview($0) }
        [emojiLabel, stockLabel, favoriteButton].forEach { artView.addSubview($0) }
        [artView, emojiLabel, nameLabel, priceLabel, stockLabel, favoriteButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        NSLayoutConstraint.activate([
            artView.topAnchor.constraint(equalTo: contentView.topAnchor),
            artView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            artView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            artView.heightAnchor.constraint(equalTo: contentView.heightAnchor, multiplier: 0.6),

            emojiLabel.centerXAnchor.constraint(equalTo: artView.centerXAnchor),
            emojiLabel.centerYAnchor.constraint(equalTo: artView.centerYAnchor),

            favoriteButton.topAnchor.constraint(equalTo: artView.topAnchor, constant: 8),
            favoriteButton.trailingAnchor.constraint(equalTo: artView.trailingAnchor, constant: -8),
            favoriteButton.widthAnchor.constraint(equalToConstant: 34),
            favoriteButton.heightAnchor.constraint(equalToConstant: 34),

            stockLabel.leadingAnchor.constraint(equalTo: artView.leadingAnchor, constant: 8),
            stockLabel.bottomAnchor.constraint(equalTo: artView.bottomAnchor, constant: -8),
            stockLabel.heightAnchor.constraint(equalToConstant: 20),

            nameLabel.topAnchor.constraint(equalTo: artView.bottomAnchor, constant: 10),
            nameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            nameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),

            priceLabel.topAnchor.constraint(greaterThanOrEqualTo: nameLabel.bottomAnchor, constant: 4),
            priceLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            priceLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            priceLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12)
        ])
    }
}

/// Pinned category title above each group of cards.
final class SectionHeaderView: UICollectionReusableView {
    static let reuseID = "SectionHeaderView"

    private let titleLabel = UILabel()
    private let countLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = Theme.background

        titleLabel.font = .systemFont(ofSize: 22, weight: .bold)
        countLabel.font = .systemFont(ofSize: 14)
        countLabel.textColor = .secondaryLabel
        countLabel.setContentHuggingPriority(.required, for: .horizontal)

        [titleLabel, countLabel].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            addSubview($0)
        }
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            countLabel.leadingAnchor.constraint(greaterThanOrEqualTo: titleLabel.trailingAnchor, constant: 8),
            countLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            countLabel.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(title: String, count: Int) {
        titleLabel.text = title
        countLabel.text = "\(count) шт."
    }
}
