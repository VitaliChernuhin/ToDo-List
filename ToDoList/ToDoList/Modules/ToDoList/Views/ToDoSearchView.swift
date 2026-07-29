//
//  ToDoSearchView.swift
//  ToDoList
//
//  Created by Vit Chernuhin on 29.07.2026.
//

import UIKit
import SnapKit

final class ToDoSearchView: UIView {
    
    // MARK: - UI Elements
    
    private let textField: UITextField = {
        let field = UITextField()

        field.attributedPlaceholder = NSAttributedString(
            string: "Поиск",
            attributes: [.foregroundColor: AppColors.searchTint]
        )
        
        field.textColor = AppColors.primaryText
        field.font = AppFonts.searchBody
        field.backgroundColor = AppColors.searchBackground
     
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 29, height: 0))
        field.leftView = paddingView
        field.leftViewMode = .always
        return field
    }()

    private let searchIconView: UIImageView = {
        let icon = UIImageView(image: AppIcons.ToDoList.search)
        icon.tintColor = AppColors.searchTint
        icon.contentMode = .scaleAspectFit
        return icon
    }()
    
    private let micButton = ToDoMicControl()

    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    private func setupView() {
        self.backgroundColor = AppColors.searchBackground
        self.layer.cornerRadius = 10
        self.clipsToBounds = true
        
        addSubview(textField)
        textField.addSubview(searchIconView)
        addSubview(micButton)
    }
    
    private func setupConstraints() {
        textField.snp.makeConstraints { make in
            make.leading.top.bottom.equalToSuperview()
            make.trailing.equalToSuperview().offset(-30) // Офсет под кнопку микрофона
        }
        
        searchIconView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(8)
            make.centerY.equalToSuperview()
            make.height.equalTo(18)
            make.width.equalTo(16)
        }

        micButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(2)
            make.centerY.equalTo(searchIconView.snp.centerY)
            make.width.height.equalTo(36)
        }
    }
}
