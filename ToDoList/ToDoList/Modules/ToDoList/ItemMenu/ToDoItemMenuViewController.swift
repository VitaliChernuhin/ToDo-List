//
//  ToDoItemMenuViewController.swift
//  ToDoList
//
//  Created by Vit Chernuhin on 07.08.2026.
//

import UIKit
import SnapKit

final class ToDoItemMenuViewController: UIViewController {
    
    // MARK: - Callback Link
    var onActionSelected: ((ToDoListItemMenuAction) -> Void)?
    
    // MARK: - UI Elements
    let blurEffectView = UIVisualEffectView(effect: nil)
    
    let toDoItemContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = AppColors.menuTaskBackground
        view.layer.cornerRadius = 12
        view.clipsToBounds = true
        return view
    }()
    
    let toDoItemView = ToDoItemView()
    
    private lazy var menuView: MenuView = {
        let menu = MenuView(types: [.edit, .share, .delete])
        return menu
    }()
    
    var toDoItem: ToDoItem? = nil
    
    // MARK: - Init
    init() {
        super.init(nibName: nil, bundle: nil)
        // Заставляем контроллер открываться как кастомный оверлей поверх таблицы
        self.modalPresentationStyle = .custom
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        setupMenuActions()
        setupTapGesture()
        
        if let item = toDoItem {
            toDoItemView.configure(with: item)
        }
    }
}

// MARK: - Setup Methods (private)
private extension ToDoItemMenuViewController {
    
    func setupUI() {
        view.backgroundColor = .clear
        
        view.addSubview(blurEffectView)
        view.addSubview(toDoItemContainerView)
        toDoItemContainerView.addSubview(toDoItemView)
        view.addSubview(menuView)
    }
    
    func setupConstraints() {
        blurEffectView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        toDoItemView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        
        // КРИТИЧЕСКИ ВАЖНО ДЛЯ ГЕОМЕТРИИ АНИМАТОРОВ:
        // Констреинты для taskCardContainerView и menuView мы тут НЕ СТАВИМ! 🛑
        // Наш ToDoMenuPresentAnimator сам нагло привяжет их к координатам ячейки на экране!
    }
    
    func setupMenuActions() {
        menuView.onActionTap = { [weak self] type in
            guard let self = self, let item = self.toDoItem else { return }
            
            switch type {
            case .edit:
                self.onActionSelected?(.edit(item: item))
            case .share:
                self.onActionSelected?(.share(item: item))
            case .delete:
                self.onActionSelected?(.delete(item: item))
            }
        }
    }
    
    func setupTapGesture() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleDismiss))
        blurEffectView.addGestureRecognizer(tap)
    }
    
    @objc func handleDismiss() {
        onActionSelected?(.dismiss)
    }
}
