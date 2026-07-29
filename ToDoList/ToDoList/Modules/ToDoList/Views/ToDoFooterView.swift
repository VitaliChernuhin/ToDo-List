//
//  ToDoFooterView.swift
//  ToDoList
//
//  Created by Vit Chernuhin on 29.07.2026.
//

import UIKit
import SnapKit

final class ToDoFooterView: UIView {
    
    var onCreateTaskTap: (() -> Void)?
    
    // MARK: - UI Elements
    
    private let topSeparatorView: UIView = {
        let view = UIView()
        view.backgroundColor = AppColors.separatorTint
        return view
    }()
    
    private let countLabel: UILabel = {
        let label = UILabel()
        label.textColor = AppColors.primaryText
        label.font = AppFonts.caption
        label.textAlignment = .center
        return label
    }()
    
    private let createButton: UIButton = {
        let button = UIButton(type: .custom)
        button.imageView?.contentMode = .scaleAspectFill
        button.setImage(AppIcons.ToDoList.addNote, for: .normal)
        return button
    }()
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Public  method
    func updateTaskCount(_ count: Int) {
        if count == 0 {
            countLabel.text = "Нет задач"
        } else {
            countLabel.text = "\(count) задач"
        }
    }
}

// MARK: - Setup Methods (private)
private extension ToDoFooterView {
    
    func setupView() {
        backgroundColor = AppColors.footerBackground
        
        addSubview(topSeparatorView)
        addSubview(countLabel)
        addSubview(createButton)
        
        createButton.addTarget(self, action: #selector(createButtonTapped), for: .touchUpInside)
    }
    
    func setupConstraints() {
        topSeparatorView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(0.5)
        }
        
        countLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(topSeparatorView.snp.bottom).offset(20.5)
            make.bottom.equalTo(safeAreaLayoutGuide.snp.bottom).offset(-15)
        }
        
        createButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview()
            make.centerY.equalTo(countLabel.snp.centerY)
            make.height.equalTo(44)
            make.width.equalTo(68)
        }
    }
    
    @objc func createButtonTapped() {
        onCreateTaskTap?()
    }
}
