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

/// An `AutomaticCollectionViewCell` is an abstract class intended to be subclassed.
/// It is specialized to be configured by an entry type `T`, thus, creating a
/// strong typed `UICollectionViewCell`.
open class AutomaticCollectionViewCell<T>: UICollectionViewCell {

    /// Configures the receiver with the specialized entry of type `T`.
    /// - parameter entry: A specialized entry `T` to configure the receiver.
    open func configure(withEntry entry: T) {}
}

/// A one-dimension generic collection view model of homogenous entries that is
/// specialized by the type `T` for each entry and the cell `Cell` type.
/// A `AutomaticCollectionViewModel` acts as a `Collection` of `T` elements.
///
/// `T` can by of any type.
///
/// `Cell` must be a subtype of `AutomaticCollectionViewCell<T>`.
///
/// Example a collection view is to be filled with entries of type `Book` using
/// `CustomAutomaticCollectionViewCel` which is a subclass of
/// `AutomaticCollectionViewCell<Book>`:
///
/// ```swift
/// class CustomAutomaticCollectionViewCel: AutomaticCollectionViewCell<Book> {
///   override func configure(withEntry entry: Book) {
///     /* use entry to configure self */
///   }
/// }
///
/// let books = [Book]()
/// let model = AutomaticCollectionViewModel<Book, AutomaticCollectionViewCell<Book>>(entries: books)
/// model.register(onCollectionView: collectionView)
/// ```
/// Should you require an index then just pass an `.enumerated()` books.
///
/// ```swift
/// class CustomAutomaticCollectionViewCel: AutomaticCollectionViewCell<Book> {
///   override func configure(withEntry entry: (index: Int, book: Book)) {
///     /* use entry.index & entry.book to configure self */
///   }
/// }
/// let books = [Book]()
/// let model = AutomaticCollectionViewModel<(Int, Book), AutomaticCollectionViewCell<(Int, Book)>>(entries: books.enumerated)
/// model.register(onCollectionView: collectionView)
/// ```
open class AutomaticCollectionViewModel<T, Cell>: NSObject, Collection, UICollectionViewDataSource where Cell: AutomaticCollectionViewCell<T> {
    final private let decoration: CollectionViewModel<T, Cell>

    /// Creates an `AutomaticCollectionViewModel<T, Cell` with the given entries.
    /// - parameter entries: The entries of the model.
    public init(entries: [T]) {
        self.decoration = CollectionViewModel<T, Cell>(entries: entries,
                                                       configuration: { (entry: T, cell: Cell) in
                                                        cell.configure(withEntry: entry)
        })
    }

    /// Registers the model with the given collection view.
    ///
    /// Registering to a collection view means the model register the `cellType`
    /// with `cellIdentifier` to the collection view and sets the receiver as the
    /// the data source of the collection view. If the receiver conforms to
    /// `UICollectionViewDelegate` it sets the receiver as the delegate of the
    /// collection view.
    /// - parameter collectionView: the collection view to register with.
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
