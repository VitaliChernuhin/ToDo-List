//
//  UIView+Reusable.swift
//  ToDoList
//
//  Created by Vit Chernuhin on 28.07.2026.
//

import UIKit

protocol ReusableView: AnyObject {
    static var reuseIdentifier: String { get }
}

extension ReusableView where Self: UIView {
    static var reuseIdentifier: String {
        return String(describing: self)
    }
}

extension UICollectionReusableView: ReusableView {}
extension UITableViewCell: ReusableView {}
