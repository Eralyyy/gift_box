import UIKit

/// Detail screen pushed from both tabs: description, quantity, add to cart, favourite.
final class GiftDetailViewController: UIViewController {
    private let gift: Gift
    private var quantity = 1 {
        didSet { updateQuantityUI() }
    }

    private let quantityLabel = UILabel()
    private let stepper = UIStepper()
    private let addButton = UIButton(type: .system)

    init(gift: Gift) {
        self.gift = gift
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = gift.category.title
        navigationItem.largeTitleDisplayMode = .never
        view.backgroundColor = Theme.background
        updateFavoriteButton()
        setUpLayout()
        updateQuantityUI()
    }

    private func setUpLayout() {
        let hero = UIView()
        hero.backgroundColor = gift.category.tint
        hero.layer.cornerRadius = 28
        let emoji = UILabel()
        emoji.text = gift.emoji
        emoji.font = .systemFont(ofSize: 110)
        emoji.translatesAutoresizingMaskIntoConstraints = false
        hero.addSubview(emoji)

        let nameLabel = UILabel()
        nameLabel.text = gift.name
        nameLabel.font = .systemFont(ofSize: 26, weight: .bold)
        nameLabel.numberOfLines = 0

        let priceLabel = UILabel()
        priceLabel.text = Money.format(gift.price)
        priceLabel.font = .systemFont(ofSize: 22, weight: .semibold)
        priceLabel.textColor = Theme.rose

        let detailsLabel = UILabel()
        detailsLabel.text = gift.details
        detailsLabel.font = .preferredFont(forTextStyle: .body)
        detailsLabel.textColor = .secondaryLabel
        detailsLabel.numberOfLines = 0

        let quantityTitle = UILabel()
        quantityTitle.text = "Количество"
        quantityTitle.font = .systemFont(ofSize: 17, weight: .medium)
        quantityTitle.setContentHuggingPriority(.defaultLow, for: .horizontal)
        quantityLabel.font = .monospacedDigitSystemFont(ofSize: 17, weight: .semibold)
        stepper.minimumValue = 1
        stepper.maximumValue = 20
        stepper.value = 1
        stepper.addTarget(self, action: #selector(stepperChanged), for: .valueChanged)
        let quantityRow = UIStackView(arrangedSubviews: [quantityTitle, quantityLabel, stepper])
        quantityRow.spacing = 12
        quantityRow.alignment = .center

        var configuration = UIButton.Configuration.filled()
        configuration.baseBackgroundColor = Theme.rose
        configuration.cornerStyle = .large
        configuration.contentInsets = NSDirectionalEdgeInsets(top: 16, leading: 20, bottom: 16, trailing: 20)
        addButton.configuration = configuration
        addButton.addTarget(self, action: #selector(addTapped), for: .touchUpInside)

        let stack = UIStackView(arrangedSubviews: [hero, nameLabel, priceLabel, detailsLabel, quantityRow, addButton])
        stack.axis = .vertical
        stack.spacing = 14
        stack.setCustomSpacing(24, after: detailsLabel)
        stack.translatesAutoresizingMaskIntoConstraints = false

        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(stack)
        view.addSubview(scrollView)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),

            stack.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: 16),
            stack.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor, constant: 20),
            stack.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor, constant: -20),
            stack.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -24),
            stack.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor, constant: -40),

            hero.heightAnchor.constraint(equalToConstant: 220),
            emoji.centerXAnchor.constraint(equalTo: hero.centerXAnchor),
            emoji.centerYAnchor.constraint(equalTo: hero.centerYAnchor)
        ])
    }

    private func updateQuantityUI() {
        quantityLabel.text = "\(quantity)"
        if gift.inStock {
            addButton.configuration?.title = "В корзину · \(Money.format(gift.price * quantity))"
        } else {
            addButton.configuration?.title = "Нет в наличии"
            addButton.isEnabled = false
            stepper.isEnabled = false
        }
    }

    private func updateFavoriteButton() {
        let symbol = CartStore.shared.isFavorite(gift) ? "heart.fill" : "heart"
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: symbol), style: .plain,
                                                            target: self, action: #selector(favoriteTapped))
    }

    @objc private func stepperChanged() {
        quantity = Int(stepper.value)
    }

    @objc private func favoriteTapped() {
        CartStore.shared.toggleFavorite(gift)
        updateFavoriteButton()
    }

    @objc private func addTapped() {
        CartStore.shared.add(gift, quantity: quantity)
        UINotificationFeedbackGenerator().notificationOccurred(.success)
        addButton.isEnabled = false
        addButton.configuration?.title = "Добавлено ✓"
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        }
    }
}
