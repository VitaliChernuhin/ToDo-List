//
//  MenuView.swift
//  ToDoList
//
//  Created by Vit Chernuhin on 09.08.2026.
//

import UIKit
import SnapKit

final class MenuView: UIView {
    
    var onActionTap: ((MenuItemType) -> Void)?
    
    // MARK: - UI Elements
    private let stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.backgroundColor = AppColors.separatorTint // Цвет тонкого разделителя между ячейками!
        stack.spacing = 1 // Создает ту самую пиксель-перфект линию из макета
        return stack
    }()
    
    // MARK: - Init
    init(types: [MenuItemType]) {
        super.init(frame: .zero)
        setupUI()
        setupConstraints()
        buildMenu(with: types)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Build & Setup Methods (private)
private extension MenuView {
    
    func setupUI() {
        backgroundColor = .clear
        layer.cornerRadius = 12
        clipsToBounds = true

        addSubview(stackView)
    }
    
    func setupConstraints() {
        stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    func buildMenu(with types: [MenuItemType]) {
        types.forEach { type in
            let itemView = MenuItemView(type: type)
            itemView.onTap = { [weak self] selectedType in
                self?.onActionTap?(selectedType)
            }
    
            itemView.snp.makeConstraints { make in
                make.height.equalTo(44)
            }
            
            stackView.addArrangedSubview(itemView)
        }
    }
}
