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


open class AutomaticTableViewCell<T>: UITableViewCell {
    open func configure(withEntry entry: T) {}
}

open class AutomaticTableViewModel<T, Cell>: NSObject, Collection, UITableViewDataSource where Cell: AutomaticTableViewCell<T> {
    
    final fileprivate let decoration: TableViewModel<T, Cell>
    
    public init(entries: [T]) {
        self.decoration = TableViewModel<T, Cell>(entries: entries,
                                                  configuration: { (entry: T, cell: Cell) in
                                                    cell.configure(withEntry: entry)
        })
    }
    
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

open class AutomaticTableHeaderFooterView: UITableViewHeaderFooterView {
    open func configure(forSection section: Int) {}
}

open class AutomaticTableHeaderView: AutomaticTableHeaderFooterView {}
open class AutomaticTableFooterView: AutomaticTableHeaderFooterView {}


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
