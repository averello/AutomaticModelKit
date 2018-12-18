//
//  TableViewModel.swift
//  AutomaticModelKit
//
//  Created by Georges Boumis on 22/03/2018.
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

/// A one-dimension generic table view model of homogenous entries that is
/// specialized by the type `T` for each entry and the cell `Cell` type.
/// A `TableViewModel` acts as a `Collection` of `T` elements.
///
/// `T` can by of any type.
///
/// `Cell` can be any subtype of `UITableViewCell`.
///
/// Example a table view is to be filled with entries of type `Book` using
/// `UITableViewCell`s:
///
/// ```swift
/// let books = [Book]()
/// let model = TableViewModel<Book, UITableViewCell>(entries: books) { book, cell in
/// /* configure cell with book */
/// }
/// ```
/// Should you require an index then just pass an `.enumerated()` books.
///
/// ```swift
/// let books = [Book]()
/// let model = TableViewModel<Book, UITableViewCell>(entries: books.enumerated()) { enumeratedEntry, cell in
/// /* configure cell with book with enumeratedEntry.offset & enumeratedIndex.element */
/// }
/// ```
open class TableViewModel<T, Cell>: NSObject, Collection, UITableViewDataSource where Cell: UITableViewCell {
    
    final private var entries: [T]
    public typealias Configuration = (T, Cell) -> Void
    final private let configuration: Configuration

    /// Create a model with the specified entries and cell configuration.
    /// - parameter entries: The entries of the model.
    /// - parameter configuration: The configuration closure that gets called
    /// for every cell each time the table view askes for a cell.
    public init(entries: [T],
         configuration: @escaping Configuration) {
        self.entries = entries
        self.configuration = configuration
    }

    /// The cell type to register to the table view.
    final public var cellType: Cell.Type {
        return Cell.self
    }
    /// The cell identifiern to use for registering the table view.
    final public var cellIdentifier: String {
        return String(describing: type(of: Cell.self))
    }

    /// Registers the model with the given table view.
    ///
    /// Registering to a table view means the model register the `cellType`
    /// with `cellIdentifier` to the table view and sets the receiver as the
    /// the data source of the table view. If the receiver conforms to
    /// `UITableViewDelegate` it sets the receiver as the delegate of the
    /// table view.
    /// - parameter tableView: the table view to register with.
    final public func register(onTableView tableView: UITableView) {
        self._register(onTableView: tableView)
        if let delegate = self as? UITableViewDelegate {
            tableView.delegate = delegate
        }
    }

    final fileprivate func _register(onTableView tableView: UITableView) {
        tableView.register(self.cellType,
                           forCellReuseIdentifier: self.cellIdentifier)
        tableView.dataSource = self
    }
    
    
    final public func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    final public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.entries.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: self.cellIdentifier,
                                                 for: indexPath) as! Cell
        self.configuration(self[indexPath.row], cell)
        return cell
    }
    
    // MARK: Collection conformance
    final public var startIndex: Int { return self.entries.startIndex }
    final public var endIndex: Int { return self.entries.endIndex }
    final public func index(after i: Int) -> Int { return self.entries.index(after: i) }
    final public subscript(i: Int) -> T {
        get { return self.entries[i] }
//        set { self.entries[i] = newValue }
    }
    
//    // MARK: RangeReplaceableCollection
//    required convenience override init() {
//        self.init(entries: []) { _,_ in }
//    }
//
//    final func replaceSubrange(_ subrange: Range<Int>, with newElements: [T]) {
//        self.entries.replaceSubrange(subrange, with: newElements)
//    }
}

/// A two-dimension generic table view model of homogenous entries that is
/// specialized by the type `T` for each entry and the cell `Cell` type.
/// A `TableViewModel` acts as a `Collection` of `T` elements.
///
/// `T` can by of any type.
///
/// `Cell` can be any subtype of `UITableViewCell`.
///
/// Example a table view is to be filled with entries of type `Book` using
/// `UITableViewCell`s:
///
/// ```swift
/// let books = [[Book]]()
/// let model = MultidimensionTableViewModel<Book, UITableViewCell>(entries: books) { book, cell in
/// /* configure cell with book */
/// }
/// model.register(onTableView: tableView)
/// ```
/// Should you require an index then just pass an `.enumerated()` books.
///
/// ```swift
/// let books = [[Book]]()
/// let model = MultidimensionTableViewModel<(Int,Book), UITableViewCell>(entries: books.enumerated()) { enumeratedEntry, cell in
/// /* configure cell with book with enumeratedEntry.offset & enumeratedIndex.element */
/// }
/// model.register(onTableView: tableView)
/// ```
open class MultidimensionTableViewModel<T, Cell>: NSObject, UITableViewDataSource where Cell: UITableViewCell {
    final private let options: [[T]]
    public typealias Configuration = (T, Cell) -> Void
    final private let configuration: Configuration
    
    public init(options: [[T]],
         configuration: @escaping Configuration) {
        self.options = options
        self.configuration = configuration
    }
    
    final public var cellType: Cell.Type {
        return Cell.self
    }
    final public var cellIdentifier: String {
        return String(describing: type(of: Cell.self))
    }
    
    final public func numberOfSections(in tableView: UITableView) -> Int {
        return self.options.count
    }
    
    final public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.options[section].count
    }
    
    final public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: self.cellIdentifier,
                                                 for: indexPath) as! Cell
        self.configuration(self.options[indexPath.section][indexPath.row], cell)
        return cell
    }
    //
    //    // MARK: Collection conformance
    //    final var startIndex: Int { return self.options.startIndex }
    //    final var endIndex: Int { return self.options.endIndex }
    //    final subscript(i: Int) -> T { return self.options[i] }
    //    final func index(after i: Int) -> Int { return self.options.index(after: i) }
}
