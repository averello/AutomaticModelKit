//
//  AutomaticTableViewModel.swift
//  AutomaticModelKit
//
//  Created by Georges Boumis on 26/03/2018.
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

/// An `AutomaticTableViewCell` is an abstract class intended to be subclassed.
/// It is specialized to be configured by an entry type `T`, thus, creating a
/// strong typed `UITableViewCell`.
open class AutomaticTableViewCell<T>: UITableViewCell {

    /// Configures the receiver with the specialized entry of type `T`.
    /// - parameter entry: A specialized entry `T` to configure the receiver.
    open func configure(withEntry entry: T) {}
}

/// A one-dimension generic table view model of homogenous entries that is
/// specialized by the type `T` for each entry and the cell `Cell` type.
/// A `AutomaticTableViewModel` acts as a `Collection` of `T` elements.
///
/// `T` can by of any type.
///
/// `Cell` must be a subtype of `AutomaticTableViewCell<T>`.
///
/// Example a table view is to be filled with entries of type `Book` using
/// `CustomAutomaticTableViewCel` which is a subclass of
/// `AutomaticTableViewCell<Book>`:
///
/// ```swift
/// class CustomAutomaticTableViewCel: AutomaticTableViewCell<Book> {
///   override func configure(withEntry entry: Book) {
///     /* use entry to configure self */
///   }
/// }
///
/// let books = [Book]()
/// let model = AutomaticTableViewModel<Book, AutomaticTableViewCell<Book>>(entries: books)
/// model.register(onTableView: tableView)
/// ```
/// Should you require an index then just pass an `.enumerated()` books.
///
/// ```swift
/// class CustomAutomaticTableViewCel: AutomaticTableViewCell<Book> {
///   override func configure(withEntry entry: (index: Int, book: Book)) {
///     /* use entry.index & entry.book to configure self */
///   }
/// }
/// let books = [Book]()
/// let model = AutomaticTableViewModel<(Int, Book), AutomaticTableViewCell<(Int, Book)>>(entries: books.enumerated)
/// model.register(onTableView: tableView)
/// ```
open class AutomaticTableViewModel<T, Cell>: NSObject, Collection, UITableViewDataSource where Cell: AutomaticTableViewCell<T> {
    
    final fileprivate let decoration: TableViewModel<T, Cell>

    /// Creates an `AutomaticTableViewModel<T, Cell` with the given entries.
    /// - parameter entries: The entries of the model.
    public init(entries: [T]) {
        self.decoration = TableViewModel<T, Cell>(entries: entries,
                                                  configuration: { (entry: T, cell: Cell) in
                                                    cell.configure(withEntry: entry)
        })
    }

    /// Registers the model with the given table view.
    ///
    /// Registering to a table view means the model register the `cellType`
    /// with `cellIdentifier` to the table view and sets the receiver as the
    /// the data source of the table view. If the receiver conforms to
    /// `UITableViewDelegate` it sets the receiver as the delegate of the
    /// table view.
    /// - parameter tableView: the table view to register with.
    open func register(onTableView tableView: UITableView) {
        self._register(onTableView: tableView)
        if let delegate = self as? UITableViewDelegate {
            tableView.delegate = delegate
        }
        tableView.reloadData()
    }
    
    final fileprivate func _register(onTableView tableView: UITableView) {
        tableView.register(self.decoration.cellType,
                           forCellReuseIdentifier: self.decoration.cellIdentifier)
        tableView.dataSource = self
    }
    
    final public func numberOfSections(in tableView: UITableView) -> Int {
        return self.decoration.numberOfSections(in: tableView)
    }
    
    final public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.decoration.tableView(tableView,
                                         numberOfRowsInSection: section)
    }
    
    final public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return self.decoration.tableView(tableView, cellForRowAt: indexPath)
    }
    
    // MARK: Collection conformance
    final public var startIndex: Int { return self.decoration.startIndex }
    final public var endIndex: Int { return self.decoration.endIndex }
    final public func index(after i: Int) -> Int { return self.decoration.index(after: i) }
    final public subscript(i: Int) -> T {
        get { return self.decoration[i] }
//        set { self.decoration[i] = newValue }
    }
    
//    // MARK: RangeReplaceableCollection
//    required convenience override init() {
//        self.init(entries: [])
//    }
//    
//    final func replaceSubrange(_ subrange: Range<Int>, with newElements: [T]) {
//        self.decoration.replaceSubrange(subrange, with: newElements)
//    }
}

/// An `AutomaticTableHeaderFooterView` is an abstract class intended to be
/// subclassed.
open class AutomaticTableHeaderFooterView: UITableViewHeaderFooterView {
    open func configure(forSection section: Int) {}
}

/// An `AutomaticTableHeaderView` is an abstract class intended to be
/// subclassed and be used as a table view header.
open class AutomaticTableHeaderView: AutomaticTableHeaderFooterView {}
/// An `AutomaticTableFooterView` is an abstract class intended to be
/// subclassed and be used as a table view footer.
open class AutomaticTableFooterView: AutomaticTableHeaderFooterView {}


/// A `FullAutomaticTableViewModel` is an `AutomaticTableViewModel` that handles
/// headers and footers of the registered table view.
open class FullAutomaticTableViewModel<T, Cell, Header, Footer>: AutomaticTableViewModel<T, Cell>, UITableViewDelegate where Header: AutomaticTableHeaderView, Footer: AutomaticTableFooterView, Cell: AutomaticTableViewCell<T> {
    
    final private let headerHeight: CGFloat
    final private let footerHeight: CGFloat
    
    public init(entries: [T],
                headerHeight: CGFloat = 0,
                footerHeight: CGFloat = 0) {
        self.footerHeight = footerHeight
        self.headerHeight = headerHeight
        super.init(entries: entries)
    }
    
    // MARK: RangeReplaceableCollection
    required convenience public init() {
        self.init(entries: [])
    }
    
    final public override func register(onTableView tableView: UITableView) {
        super.register(onTableView: tableView)
        if self.headerHeight > 0 {
            self.registerHeader(onTableView: tableView)
        }
        if self.footerHeight > 0 {
            self.registerHeader(onTableView: tableView)
        }
        tableView.delegate = self
    }
    
    final private var headerType: Header.Type {
        return Header.self
    }
    final private var footerType: Footer.Type {
        return Footer.self
    }
    
    final private var hasHeader: Bool = false
    final private var hasFooter: Bool = false
    
    final private var headerIdentifier: String {
        return String(describing: type(of: self.headerType))
    }
    
    final private var footerIdentifier: String {
        return String(describing: type(of: self.footerType))
    }

    final public func registerHeader(onTableView tableView: UITableView) {
        self.hasHeader = true
        tableView.register(self.headerType,
                           forHeaderFooterViewReuseIdentifier: self.headerIdentifier)
    }
    
    final public func registerFooter(onTableView tableView: UITableView) {
        self.hasFooter = true
        tableView.register(self.footerType,
                           forHeaderFooterViewReuseIdentifier: self.footerIdentifier)
    }
    
    final public override func responds(to aSelector: Selector) -> Bool {
        if aSelector == #selector(tableView(_:viewForFooterInSection:)) {
            return self.hasFooter
        }
        
        if aSelector == #selector(tableView(_:viewForHeaderInSection:)) {
            return self.hasHeader
        }
        return super.responds(to: aSelector)
    }
    
    final public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        guard self.hasHeader else { return 0.0 }
        return self.headerHeight
    }
    
    final public func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        guard self.hasFooter else { return 0.0 }
        return self.footerHeight
    }

    final public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard self.hasHeader,
            let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: self.headerIdentifier) as? Header else { return nil }
        header.configure(forSection: section)
        return header
    }
    
    final public func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        guard self.hasFooter,
            let footer = tableView.dequeueReusableHeaderFooterView(withIdentifier: self.footerIdentifier) as? Footer else { return nil }
        footer.configure(forSection: section)
        return footer
    }
}
