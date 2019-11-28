//
//  Header.swift
//  Mesh Audio Controller
//
//  Created by jeremy Wu on 11/5/19.
//  Copyright © 2019 jeremy Wu. All rights reserved.
//

import Foundation
import UIKit

class Header: UITableViewHeaderFooterView {
    let title = UILabel()
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        configureContents()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureContents() {
        title.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(title)
        
        // Center the image vertically and place it near the leading
        // edge of the view. Constrain its width and height to 50 points.
        NSLayoutConstraint.activate([
            // Center the label vertically, and use it to fill the remaining
            // space in the header view.
            title.heightAnchor.constraint(equalToConstant: 30),
            title.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor,
                                           constant: 8),
            title.trailingAnchor.constraint(equalTo:
                contentView.layoutMarginsGuide.trailingAnchor),
            title.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
}
