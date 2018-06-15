//
//  AutomaticCollectionViewModel.swift
//  AutomaticModelKit
//
//  Created by Georges Boumis on 13/04/2018.
//
//  Licensed to the Apache Software Foundation (ASF) under one
//  or more contributor license agreements.  See the NOTICE file
//  distributed with this work for additional information
//  regarding copyright ownership.  The ASF licenses this file
//  to you under the Apache License, Version 2.0 (the
//  "License"); you may not use this file except in compliance
//  with the License.  You may obtain a copy of the License at
//
//    http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing,
//  software distributed under the License is distributed on an
//  "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
//  KIND, either express or implied.  See the License for the
//  specific language governing permissions and limitations
//  under the License.
//

import Foundation
import UIKit

open class AutomaticCollectionViewCell<T>: UICollectionViewCell {
    open func configure(withEntry entry: T) {}
}

open class AutomaticCollectionViewModel<T, Cell>: NSObject, Collection, UICollectionViewDataSource where Cell: AutomaticCollectionViewCell<T> {
    final private let decoration: CollectionViewModel<T, Cell>
    
    public init(entries: [T]) {
        self.decoration = CollectionViewModel<T, Cell>(entries: entries,
                                                       configuration: { (entry: T, cell: Cell) in
                                                        cell.configure(withEntry: entry)
        })
    }
    
    public func register(onCollectionView collectionView: UICollectionView) {
        self._register(onCollectionView: collectionView)
        if let delegate = self as? UICollectionViewDelegate {
            collectionView.delegate = delegate
        }
    }
    
    final fileprivate func _register(onCollectionView collectionView: UICollectionView) {
        collectionView.register(self.decoration.cellType,
                                forCellWithReuseIdentifier: self.decoration.cellIdentifier)
        collectionView.dataSource = self
    }
    
    final public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return self.decoration.numberOfSections(in: collectionView)
    }
    
    
    final public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return  self.decoration.collectionView(collectionView,
                                               numberOfItemsInSection: section)
    }
    
    final public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return self.decoration.collectionView(collectionView,
                                              cellForItemAt: indexPath)
    }
    
    // MARK: Collection conformance
    final public var startIndex: Int { return self.decoration.startIndex }
    final public var endIndex: Int { return self.decoration.endIndex }
    final public subscript(i: Int) -> T { return self.decoration[i] }
    final public func index(after i: Int) -> Int { return self.decoration.index(after: i) }
}

//class AutomaticCollectionHeaderFooterView: UICollectionReusableView {
//    func configure(forSection section: Int) {}
//}
//
//class AutomaticCollectionHeaderView: AutomaticCollectionHeaderFooterView {}
//class AutomaticCollectionFooterView: AutomaticCollectionHeaderFooterView {}
//
//
//class FullAutomaticCollectionViewModel<T, Cell, Header, Footer>: AutomaticCollectionViewModel<T, Cell>, UICollectionViewDelegate where Header: AutomaticCollectionHeaderView, Footer: AutomaticCollectionFooterView, Cell: AutomaticCollectionViewCell<T> {
//
//    final private let headerHeight: CGFloat
//    final private let footerHeight: CGFloat
//
//    init(entries: [T],
//         headerHeight: CGFloat = 0,
//         footerHeight: CGFloat = 0) {
//        self.footerHeight = footerHeight
//        self.headerHeight = headerHeight
//        super.init(entries: entries)
//    }
//
//    final override func register(onCollectionView collectionView: UICollectionView) {
//        super.register(onCollectionView: collectionView)
//        (self.headerHeight > 0).map {
//            self.registerHeader(onTableView: collectionView)
//        }
//        (self.footerHeight > 0).map {
//            self.registerHeader(onTableView: collectionView)
//        }
//        collectionView.delegate = self
//    }
//
//    final private var headerType: Header.Type {
//        return Header.self
//    }
//    final private var footerType: Footer.Type {
//        return Footer.self
//    }
//
//    final private var hasHeader: Bool = false
//    final private var hasFooter: Bool = false
//
//    final private var headerIdentifier: String {
//        return String(describing: type(of: self.headerType))
//    }
//
//    final private var footerIdentifier: String {
//        return String(describing: type(of: self.footerType))
//    }
//
//    final func registerHeader(onCollectionView collectionView: UICollectionView) {
//        self.hasHeader = true
//        collectionView.register(self.headerType,
//                                forSupplementaryViewOfKind: "header",
//                                withReuseIdentifier: self.headerIdentifier)
//    }
//
//    final func registerFooter(onCollectionView collectionView: UICollectionView) {
//        self.hasFooter = true
//        collectionView.register(self.footerType,
//                                forSupplementaryViewOfKind: "footer",
//                                withReuseIdentifier: self.footerIdentifier)
//    }
//
//    final override func responds(to aSelector: Selector) -> Bool {
//        if aSelector == #selector(tableView(_:viewForFooterInSection:)) {
//            return self.hasFooter
//        }
//
//        if aSelector == #selector(tableView(_:viewForHeaderInSection:)) {
//            return self.hasHeader
//        }
//        return super.responds(to: aSelector)
//    }
//
//    final func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
//        guard self.hasHeader else { return 0.0 }
//        return self.headerHeight
//    }
//
//    final func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
//        guard self.hasFooter else { return 0.0 }
//        return self.footerHeight
//    }
//
//    final func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//        guard self.hasHeader,
//            let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: self.headerIdentifier) as? Header else { return nil }
//        header.configure(forSection: section)
//        return header
//    }
//
//    final func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
//        guard self.hasFooter,
//            let footer = tableView.dequeueReusableHeaderFooterView(withIdentifier: self.footerIdentifier) as? Footer else { return nil }
//        footer.configure(forSection: section)
//        return footer
//    }
//}
