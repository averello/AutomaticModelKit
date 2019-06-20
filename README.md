# AutomaticModelKit

A reusable strong typed data source for `UITableView` and `UICollectionView`. 

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

```
import UIKit
import AutomaticModelKit

final class View: UIView {
    final private let model = Model(entries: [View.Entry(content: "First")])
    final private var tableView = UITableView(frame: CGRect.zero, style: UITableView.Style.plain)
    
    func someMethod() {
        // add table view as a subview
        self.addSubview(tableView)
        // and register to the model
        self.model.register(onTableView: tableView)
    }
}

fileprivate extension View {

    /// the content of each cell
    struct Entry {
        let content: String
    }

    /// The strongly typed model that indicates that for each Cell there is 
    /// associated an Entry.
    final class Model: AutomaticTableViewModel<Entry, Cell> {}

    final class Cell: AutomaticTableViewCell<Entry> {
    
        // if you want to create a custom cell override `init(style:reuseIdentifier:)`
        
        // populate the cell with data
        final override func configure(withEntry entry: Entry) {
            self.textLabel?.text = entry.content
        }
    }
}
```

## Requirements

## Installation

## Author

Georges Boumis, developer.george.boumis@gmail.com

## License

AutomaticModelKit is available under the Apache 2.0 license. See the LICENSE file for more info.
