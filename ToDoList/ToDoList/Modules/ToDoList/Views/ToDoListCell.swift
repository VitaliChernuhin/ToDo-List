//
//  ToDoListCell.swift
//  ToDoList
//
//  Created by Vit Chernuhin on 28.07.2026.
//

import UIKit
import SnapKit

final class ToDoListCell: UITableViewCell {
    
    // MARK: - UI Elements
    
    private let checkboxButton: UIButton = {
        let button = UIButton(type: .system)
        button.tintColor = AppColors.goldTint
        return button
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = AppFonts.taskTitle
        label.textColor = AppColors.primaryText
        label.numberOfLines = 1
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = AppFonts.taskDescription
        label.textColor = AppColors.secondaryText
        label.numberOfLines = 2
        return label
    }()
    
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.font = AppFonts.taskDescription
        label.textColor = AppColors.secondaryText
        label.numberOfLines = 1
        return label
    }()
    
    private let textStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 6
        stack.alignment = .fill
        stack.distribution = .fill
        return stack
    }()
    
    // MARK: - Init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCell()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Public Configuration Method
    func configure(with model: ToDoItemViewModel) {
        titleLabel.text = model.title
        descriptionLabel.text = model.description
        dateLabel.text = model.dateString
        
        if model.isCompleted {
            checkboxButton.setImage(AppIcons.ToDoList.completed, for: .normal)
            
            let attributeString = NSMutableAttributedString(string: model.title)
            attributeString.addAttribute(
                .strikethroughStyle,
                value: NSUnderlineStyle.single.rawValue,
                range: NSMakeRange(0, attributeString.length)
            )
            titleLabel.attributedText = attributeString
            titleLabel.textColor = AppColors.secondaryText
        } else {
            checkboxButton.setImage(AppIcons.ToDoList.uncompleted, for: .normal)
            titleLabel.attributedText = nil
            titleLabel.text = model.title
            titleLabel.textColor = AppColors.primaryText
        }
    }
}

// MARK: - Setup methods (private)
private extension ToDoListCell {
    func setupCell() {
        selectionStyle = .none
        backgroundColor = AppColors.appBackground
        
        contentView.addSubview(checkboxButton)
        contentView.addSubview(textStackView)
        
        textStackView.addArrangedSubview(titleLabel)
        textStackView.addArrangedSubview(descriptionLabel)
        textStackView.addArrangedSubview(dateLabel)
    }
    
    func setupConstraints() {
        checkboxButton.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.top.equalToSuperview().offset(12)
            make.width.height.equalTo(24)
        }
        
        textStackView.snp.makeConstraints { make in
            make.leading.equalTo(checkboxButton.snp.trailing).offset(8)
            make.trailing.equalToSuperview()
            make.top.equalToSuperview().offset(12)
            make.bottom.equalToSuperview().offset(-12)
        }
    }
}
