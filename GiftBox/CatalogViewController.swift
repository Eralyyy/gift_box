import UIKit

/// Catalog tab: gifts grouped by category in a UICollectionView with a flow layout.
final class CatalogViewController: UIViewController {
    private let groups = GiftData.grouped()
    private var animatedItems = Set<IndexPath>()

    private let sectionInset = UIEdgeInsets(top: 8, left: 16, bottom: 20, right: 16)
    private let itemSpacing: CGFloat = 12

    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.sectionHeadersPinToVisibleBounds = true
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = Theme.background
        collectionView.alwaysBounceVertical = true
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(GiftCell.self, forCellWithReuseIdentifier: GiftCell.reuseID)
        collectionView.register(SectionHeaderView.self,
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                withReuseIdentifier: SectionHeaderView.reuseID)
        return collectionView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Каталог"
        view.backgroundColor = Theme.background
        view.addSubview(collectionView)
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    // Column count depends on width, so recompute item sizes on rotation.
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate(alongsideTransition: { _ in
            self.collectionView.collectionViewLayout.invalidateLayout()
        })
    }

    private func gift(at indexPath: IndexPath) -> Gift {
        groups[indexPath.section].gifts[indexPath.item]
    }

    private func columnCount(for width: CGFloat) -> Int {
        width > 600 ? 3 : 2
    }
}

// MARK: - UICollectionViewDataSource

extension CatalogViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        groups.count
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        groups[section].gifts.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: GiftCell.reuseID,
                                                            for: indexPath) as? GiftCell else {
            return UICollectionViewCell()
        }
        let gift = gift(at: indexPath)
        cell.configure(with: gift, isFavorite: CartStore.shared.isFavorite(gift))
        cell.onFavoriteTap = { [weak self, weak cell] in
            // Resolve the index path at tap time: the cell may have been reused or moved.
            guard let self = self, let cell = cell,
                  let currentIndexPath = self.collectionView.indexPath(for: cell) else { return }
            let isFavorite = CartStore.shared.toggleFavorite(self.gift(at: currentIndexPath))
            cell.setFavorite(isFavorite, animated: true)
        }
        return cell
    }

    func collectionView(_ collectionView: UICollectionView,
                        viewForSupplementaryElementOfKind kind: String,
                        at indexPath: IndexPath) -> UICollectionReusableView {
        guard kind == UICollectionView.elementKindSectionHeader,
              let header = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind, withReuseIdentifier: SectionHeaderView.reuseID, for: indexPath) as? SectionHeaderView else {
            return UICollectionReusableView()
        }
        let group = groups[indexPath.section]
        header.configure(title: group.category.title, count: group.gifts.count)
        return header
    }
}

// MARK: - UICollectionViewDelegate

extension CatalogViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let detail = GiftDetailViewController(gift: gift(at: indexPath))
        navigationController?.pushViewController(detail, animated: true)
    }

    // Out-of-stock cards can still be opened, but give no "press" feedback.
    func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        gift(at: indexPath).inStock
    }

    func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) else { return }
        UIView.animate(withDuration: 0.15) {
            cell.transform = CGAffineTransform(scaleX: 0.96, y: 0.96)
        }
    }

    func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) else { return }
        UIView.animate(withDuration: 0.25, delay: 0, usingSpringWithDamping: 0.6,
                       initialSpringVelocity: 4, options: []) {
            cell.transform = .identity
        }
    }

    // Cards fade and slide in the first time they appear.
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell,
                        forItemAt indexPath: IndexPath) {
        guard animatedItems.insert(indexPath).inserted else { return }
        cell.alpha = 0
        cell.transform = CGAffineTransform(translationX: 0, y: 24)
        UIView.animate(withDuration: 0.4, delay: 0.04 * Double(indexPath.item % 4), options: .curveEaseOut) {
            cell.alpha = 1
            cell.transform = .identity
        }
    }

    // Long press: quick actions without opening the detail screen.
    func collectionView(_ collectionView: UICollectionView,
                        contextMenuConfigurationForItemAt indexPath: IndexPath,
                        point: CGPoint) -> UIContextMenuConfiguration? {
        let gift = gift(at: indexPath)
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { [weak self] _ in
            var actions: [UIMenuElement] = []
            if gift.inStock {
                actions.append(UIAction(title: "В корзину", image: UIImage(systemName: "cart.badge.plus")) { _ in
                    CartStore.shared.add(gift)
                })
            }
            let isFavorite = CartStore.shared.isFavorite(gift)
            actions.append(UIAction(title: isFavorite ? "Убрать из избранного" : "В избранное",
                                    image: UIImage(systemName: isFavorite ? "heart.slash" : "heart")) { _ in
                CartStore.shared.toggleFavorite(gift)
                self?.collectionView.reloadItems(at: [indexPath])
            })
            return UIMenu(children: actions)
        }
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension CatalogViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let columns = columnCount(for: collectionView.bounds.width)
        let gaps = itemSpacing * CGFloat(columns - 1)
        let available = collectionView.bounds.width - sectionInset.left - sectionInset.right - gaps
        let width = floor(available / CGFloat(columns))
        return CGSize(width: width, height: width * 1.3)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        sectionInset
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        itemSpacing
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        itemSpacing
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        referenceSizeForHeaderInSection section: Int) -> CGSize {
        CGSize(width: collectionView.bounds.width, height: 44)
    }
}
