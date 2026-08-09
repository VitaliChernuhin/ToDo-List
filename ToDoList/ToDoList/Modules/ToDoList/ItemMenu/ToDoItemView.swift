//
//  ToDoItemView.swift
//  ToDoList
//
//  Created by Vit Chernuhin on 09.08.2026.
//

import UIKit
import SnapKit

final class ToDoItemView: UIView {
    
    // MARK: - UI Elements
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
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Configure (public)
extension ToDoItemView {
    func configure(with item: ToDoItem) {
        descriptionLabel.text = item.description
        
        let dateFormatter = DateFormatterProvider.formatter(for: .shortUIDate)
        dateLabel.text = dateFormatter.string(from: item.date)
        
        if item.isCompleted {
            let attributeString = NSMutableAttributedString(string: item.title)
            attributeString.addAttribute(
                .strikethroughStyle,
                value: NSUnderlineStyle.single.rawValue,
                range: NSMakeRange(0, attributeString.length)
            )
            titleLabel.attributedText = attributeString
            titleLabel.textColor = AppColors.secondaryText
        } else {
            titleLabel.attributedText = nil
            titleLabel.text = nil
            
            titleLabel.text = item.title
            titleLabel.textColor = AppColors.primaryText
        }
    }
}

// MARK: - Setup Methods (private)
private extension ToDoItemView {
    
    func setupView() {
        backgroundColor = AppColors.menuTaskBackground
        
        let contentStackView = UIStackView(arrangedSubviews: [titleLabel, descriptionLabel, dateLabel])
        contentStackView.axis = .vertical
        contentStackView.spacing = 6
        contentStackView.alignment = .fill
        contentStackView.distribution = .fill
        contentStackView.layer.cornerRadius = 12
        
        addSubview(contentStackView)
        
        contentStackView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(12)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.bottom.equalToSuperview().offset(-12)
        }
    }
}

