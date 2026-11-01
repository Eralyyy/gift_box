import UIKit

/// Cart tab: items grouped by category in a UITableView. Supports swipe actions,
/// deleting, reordering inside a section, and a checkout bar.
final class CartViewController: UIViewController {
    private let store = CartStore.shared

    private let tableView = UITableView(frame: .zero, style: .insetGrouped)
    private let bottomBar = UIView()
    private let captionLabel = UILabel()
    private let totalLabel = UILabel()
    private let checkoutButton = UIButton(type: .system)

    private let emptyLabel: UILabel = {
        let label = UILabel()
        label.text = "Корзина пуста\nДобавьте подарки из каталога 🎁"
        label.numberOfLines = 0
        label.textAlignment = .center
        label.textColor = .secondaryLabel
        label.font = .preferredFont(forTextStyle: .title3)
        return label
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Корзина"
        view.backgroundColor = Theme.background

        navigationItem.leftBarButtonItem = editButtonItem
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Очистить", style: .plain,
                                                            target: self, action: #selector(clearTapped))
        setUpTableView()
        setUpBottomBar()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Items may have been added from the catalog while this tab was hidden.
        tableView.reloadData()
        refreshSummary()
    }

    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        tableView.setEditing(editing, animated: animated)
    }

    // MARK: - Setup

    private func setUpTableView() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.backgroundColor = Theme.background
        tableView.register(CartCell.self, forCellReuseIdentifier: CartCell.reuseID)
        view.addSubview(tableView)
    }

    private func setUpBottomBar() {
        bottomBar.translatesAutoresizingMaskIntoConstraints = false
        bottomBar.backgroundColor = .secondarySystemGroupedBackground
        view.addSubview(bottomBar)

        let separator = UIView()
        separator.backgroundColor = .separator
        separator.translatesAutoresizingMaskIntoConstraints = false
        bottomBar.addSubview(separator)

        captionLabel.font = .systemFont(ofSize: 13)
        captionLabel.textColor = .secondaryLabel
        totalLabel.font = .systemFont(ofSize: 22, weight: .bold)
        let totals = UIStackView(arrangedSubviews: [captionLabel, totalLabel])
        totals.axis = .vertical
        totals.translatesAutoresizingMaskIntoConstraints = false
        bottomBar.addSubview(totals)

        var configuration = UIButton.Configuration.filled()
        configuration.title = "Оформить"
        configuration.baseBackgroundColor = Theme.rose
        configuration.cornerStyle = .capsule
        configuration.contentInsets = NSDirectionalEdgeInsets(top: 12, leading: 24, bottom: 12, trailing: 24)
        checkoutButton.configuration = configuration
        checkoutButton.addTarget(self, action: #selector(checkoutTapped), for: .touchUpInside)
        checkoutButton.translatesAutoresizingMaskIntoConstraints = false
        bottomBar.addSubview(checkoutButton)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: bottomBar.topAnchor),

            bottomBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bottomBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bottomBar.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            bottomBar.heightAnchor.constraint(equalToConstant: 72),

            separator.topAnchor.constraint(equalTo: bottomBar.topAnchor),
            separator.leadingAnchor.constraint(equalTo: bottomBar.leadingAnchor),
            separator.trailingAnchor.constraint(equalTo: bottomBar.trailingAnchor),
            separator.heightAnchor.constraint(equalToConstant: 1 / UIScreen.main.scale),

            totals.leadingAnchor.constraint(equalTo: bottomBar.leadingAnchor, constant: 20),
            totals.centerYAnchor.constraint(equalTo: bottomBar.centerYAnchor),

            checkoutButton.trailingAnchor.constraint(equalTo: bottomBar.trailingAnchor, constant: -20),
            checkoutButton.centerYAnchor.constraint(equalTo: bottomBar.centerYAnchor)
        ])
    }

    // MARK: - State

    private func refreshSummary() {
        let isEmpty = store.sections.isEmpty
        captionLabel.text = "Итого · \(store.itemCount) шт."
        totalLabel.text = Money.format(store.total)
        checkoutButton.isEnabled = !isEmpty
        editButtonItem.isEnabled = !isEmpty
        navigationItem.rightBarButtonItem?.isEnabled = !isEmpty
        tableView.backgroundView = isEmpty ? emptyLabel : nil
        if isEmpty && isEditing {
            setEditing(false, animated: true)
        }
    }

    /// Footers show per-section subtotals, so they must be rebuilt after any change.
    private func reloadAllSections() {
        tableView.reloadSections(IndexSet(integersIn: 0..<store.sections.count), with: .none)
    }

    private func deleteItem(at indexPath: IndexPath) {
        let removedSection = store.remove(at: indexPath)
        tableView.performBatchUpdates({
            if removedSection {
                tableView.deleteSections(IndexSet(integer: indexPath.section), with: .fade)
            } else {
                tableView.deleteRows(at: [indexPath], with: .automatic)
            }
        }, completion: { _ in
            self.reloadAllSections()
        })
        refreshSummary()
    }

    // MARK: - Actions

    @objc private func clearTapped() {
        let alert = UIAlertController(title: "Очистить корзину?",
                                      message: "Все позиции будут удалены.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Отмена", style: .cancel))
        alert.addAction(UIAlertAction(title: "Очистить", style: .destructive) { _ in
            self.store.clear()
            self.tableView.reloadData()
            self.refreshSummary()
        })
        present(alert, animated: true)
    }

    @objc private func checkoutTapped() {
        let message = "Позиций: \(store.itemCount)\nСумма: \(Money.format(store.total))\n\nМы свяжемся с вами для оплаты."
        let alert = UIAlertController(title: "Заказ оформлен 🎉", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Отлично", style: .default) { _ in
            self.store.clear()
            self.tableView.reloadData()
            self.refreshSummary()
        })
        present(alert, animated: true)
    }
}

// MARK: - UITableViewDataSource

extension CartViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        store.sections.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        store.sections[section].items.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CartCell.reuseID,
                                                       for: indexPath) as? CartCell else {
            return UITableViewCell()
        }
        cell.configure(with: store.item(at: indexPath))
        return cell
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        store.sections[section].category.title
    }

    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        "Сумма по разделу: \(Money.format(store.sections[section].subtotal))"
    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        true
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle,
                   forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete else { return }
        deleteItem(at: indexPath)
    }

    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        true
    }

    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        store.move(from: sourceIndexPath, to: destinationIndexPath)
    }
}

// MARK: - UITableViewDelegate

extension CartViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        76
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let detail = GiftDetailViewController(gift: store.item(at: indexPath).gift)
        navigationController?.pushViewController(detail, animated: true)
    }

    // Swipe right-to-left: delete or add one more.
    func tableView(_ tableView: UITableView,
                   trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let delete = UIContextualAction(style: .destructive, title: "Удалить") { [weak self] _, _, done in
            self?.deleteItem(at: indexPath)
            done(true)
        }
        delete.image = UIImage(systemName: "trash")

        let plusOne = UIContextualAction(style: .normal, title: "+1") { [weak self] _, _, done in
            guard let self = self else { return done(false) }
            self.store.incrementQuantity(at: indexPath)
            self.reloadAllSections()
            self.refreshSummary()
            done(true)
        }
        plusOne.backgroundColor = .systemBlue

        return UISwipeActionsConfiguration(actions: [delete, plusOne])
    }

    // Swipe left-to-right: toggle gift wrapping (+500 ₸ per item).
    func tableView(_ tableView: UITableView,
                   leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let isWrapped = store.item(at: indexPath).isWrapped
        let wrap = UIContextualAction(style: .normal, title: isWrapped ? "Без упаковки" : "Упаковать") { [weak self] _, _, done in
            guard let self = self else { return done(false) }
            self.store.toggleWrapped(at: indexPath)
            self.reloadAllSections()
            self.refreshSummary()
            done(true)
        }
        wrap.image = UIImage(systemName: "gift")
        wrap.backgroundColor = isWrapped ? .systemGray : Theme.rose
        return UISwipeActionsConfiguration(actions: [wrap])
    }

    // Wrapped items get a pale pink background (cell colours must be set in willDisplay).
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.backgroundColor = store.item(at: indexPath).isWrapped
            ? Theme.rose.withAlphaComponent(0.08)
            : .secondarySystemGroupedBackground
    }

    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        guard let header = view as? UITableViewHeaderFooterView else { return }
        header.textLabel?.textColor = Theme.rose
        header.textLabel?.font = .systemFont(ofSize: 15, weight: .bold)
    }

    // Rows can be reordered only inside their own category section.
    func tableView(_ tableView: UITableView,
                   targetIndexPathForMoveFromRowAt sourceIndexPath: IndexPath,
                   toProposedIndexPath proposedDestinationIndexPath: IndexPath) -> IndexPath {
        guard sourceIndexPath.section != proposedDestinationIndexPath.section else {
            return proposedDestinationIndexPath
        }
        let lastRow = store.sections[sourceIndexPath.section].items.count - 1
        let row = proposedDestinationIndexPath.section < sourceIndexPath.section ? 0 : lastRow
        return IndexPath(row: row, section: sourceIndexPath.section)
    }
}
