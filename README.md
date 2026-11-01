# Gift Box

UIKit app (programmatic UI, Swift, iOS 15+) with a **UICollectionView** catalog and a **UITableView** cart.

Open `GiftBox.xcodeproj` in Xcode 15+, pick any iPhone simulator, press Run.

## Screens
- **Каталог** (`CatalogViewController`): 16 gifts in 4 category sections. Tap a card for details, tap the heart
  to favourite, long-press for a context menu.
- **Корзина** (`CartViewController`): 10 seeded cart rows in 4 sections. Swipe, Edit mode, checkout bar.
- **Детали** (`GiftDetailViewController`): description, quantity stepper, add to cart, favourite.

## UITableView methods (16)
DataSource: `numberOfSections`, `numberOfRowsInSection`, `cellForRowAt`, `titleForHeaderInSection`,
`titleForFooterInSection`, `canEditRowAt`, `commit editingStyle`, `canMoveRowAt`, `moveRowAt`.
Delegate: `heightForRowAt`, `didSelectRowAt`, `trailingSwipeActionsConfigurationForRowAt` (delete, +1),
`leadingSwipeActionsConfigurationForRowAt` (gift wrap), `willDisplay cell` (wrapped rows tinted),
`willDisplayHeaderView` (header style), `targetIndexPathForMoveFromRowAt` (reorder only inside a section).

## UICollectionView methods (15)
DataSource: `numberOfSections`, `numberOfItemsInSection`, `cellForItemAt`, `viewForSupplementaryElementOfKind`.
Delegate: `didSelectItemAt`, `shouldHighlightItemAt` (no press feedback when out of stock), `didHighlightItemAt`,
`didUnhighlightItemAt` (press animation), `willDisplay cell` (appear animation),
`contextMenuConfigurationForItemAt`.
FlowLayout: `sizeForItemAt` (2 or 3 columns by width), `insetForSectionAt`, `minimumLineSpacingForSectionAt`,
`minimumInteritemSpacingForSectionAt`, `referenceSizeForHeaderInSection`.
