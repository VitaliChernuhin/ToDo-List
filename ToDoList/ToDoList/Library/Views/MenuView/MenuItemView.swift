//
//  MenuItemView.swift
//  ToDoList
//
//  Created by Vit Chernuhin on 09.08.2026.
//


import UIKit
import SnapKit

// MARK: MenuItemType
enum MenuItemType {
    case edit
    case share
    case delete
}

final class MenuItemView: UIView {
    
    var onTap: ((MenuItemType) -> Void)?
    
    // MARK: - UI Elements
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = AppColors.menuText
        label.font = AppFonts.menuBody
        return label
    }()
    
    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = AppColors.menuText
        return imageView
    }()
    
    private let type: MenuItemType
    
    // MARK: - Init
    init(type: MenuItemType) {
        self.type = type
        super.init(frame: .zero)
        setupView()
        setupConstraints()
        configure(itemType: type)
        setupGesture()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Configuration (private)
private extension MenuItemView {
    func configure(itemType: MenuItemType) {
        switch itemType {
        case .edit:
            iconImageView.image = AppIcons.Menu.edit
            titleLabel.textColor = AppColors.menuText
            iconImageView.tintColor = AppColors.menuText
            titleLabel.text = "Редактировать"
        case .share:
            iconImageView.image = AppIcons.Menu.share
            titleLabel.textColor = AppColors.menuText
            iconImageView.tintColor = AppColors.menuText
            titleLabel.text = "Поделиться"
        case .delete:
            iconImageView.image = AppIcons.Menu.delete
            titleLabel.textColor = AppColors.deleteMenuText
            iconImageView.tintColor = AppColors.deleteMenuText
            titleLabel.text = "Удалить"
        }
    }
}

// MARK: - Setup Methods (private)
private extension MenuItemView {
    
    func setupView() {
        backgroundColor = AppColors.menuBackground
        
        addSubview(titleLabel)
        addSubview(iconImageView)
    }
    
    func setupConstraints() {
        titleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
        }
        
        iconImageView.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-16)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(16)
        }
    }
    
    func setupGesture() {
        let tapGesture = AgencyTapGestureRecognizer(target: self, action: #selector(handleTap))
        addGestureRecognizer(tapGesture)
    }
    
    @objc func handleTap() {
        onTap?(type)
    }
}

// MARK: - Custom Gesture Helper (Чтобы ячейка приятно подсвечивалась при тапе)
private final class AgencyTapGestureRecognizer: UITapGestureRecognizer {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesBegan(touches, with: event)
        view?.alpha = 0.6 // Эффект нативного нажатия
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesEnded(touches, with: event)
        view?.alpha = 1.0
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesCancelled(touches, with: event)
        view?.alpha = 1.0
    }
}
