//
//  GridView.swift
//  blendr
//
//  Created by Andrew Nielson on 6/23/24.
//

import SwiftUI

struct GridView<Item, ItemView>: View where Item: Identifiable & Equatable, ItemView: View {
    private var items: [Item]
    private var viewForItem: (Item) -> ItemView

    init(_ items: [Item], viewForItem: @escaping (Item) -> ItemView) {
        self.items = items
        self.viewForItem = viewForItem
    }

    var body: some View {
        GeometryReader { geometry in
            let layout = GridLayout(itemCount: items.count, in: geometry.size, rowCount: 4, columnCount: 4)
            ForEach(items) { item in
                viewForItem(item)
                    .frame(width: layout.itemSize.width, height: layout.itemSize.height)
                    .position(layout.location(ofItemAt: items.firstIndex(of: item)!))
            }
        }
    }
}

struct GridLayout {
    var size: CGSize
    var rowCount: Int
    var columnCount: Int

    init(itemCount: Int, in size: CGSize, rowCount: Int = 4, columnCount: Int = 4) {
        self.size = size
        self.rowCount = rowCount
        self.columnCount = columnCount
    }

    var itemSize: CGSize {
        CGSize(
            width: size.width / CGFloat(columnCount),
            height: size.height / CGFloat(rowCount)
        )
    }

    func location(ofItemAt index: Int) -> CGPoint {
        let row = index / columnCount
        let column = index % columnCount
        return CGPoint(
            x: (CGFloat(column) + 0.5) * itemSize.width,
            y: (CGFloat(row) + 0.5) * itemSize.height
        )
    }
}
