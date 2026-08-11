//
//  ToDoMenuPresentAnimator.swift
//  ToDoList
//
//  Created by Vit Chernuhin on 10.08.2026.
//

import UIKit
import SnapKit

final class ToDoMenuPresentAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    
    private let sourceCellRect: CGRect
    
    // MARK: - Init
    init(sourceCellRect: CGRect) {
        self.sourceCellRect = sourceCellRect
        super.init()
    }
    
    // MARK: - UIViewControllerAnimatedTransitioning
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.25
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        // 1. Извлекаем контейнер анимации и наш целевой контроллер меню
        let containerView = transitionContext.containerView
        guard let toVC = transitionContext.viewController(forKey: .to) as? ToDoItemMenuViewController else {
            transitionContext.completeTransition(false)
            return
        }
        
        // 2. Монтируем вьюху меню в общий системный контейнер транзишена
        containerView.addSubview(toVC.view)
        toVC.view.frame = containerView.bounds
        toVC.toDoItemContainerView.translatesAutoresizingMaskIntoConstraints = false
        toVC.view.layoutIfNeeded()
        
        // 3. УСТАНАВЛИВАЕМ СТАРТОВУЮ ГЕОМЕТРИЮ (Карточка сидит точь-в-точь на месте ячейки таблицы!)
        toVC.toDoItemContainerView.snp.remakeConstraints { make in
            make.top.equalTo(toVC.view.snp.top).offset(sourceCellRect.origin.y)
            make.leading.equalTo(toVC.view.snp.leading).offset(sourceCellRect.origin.x)
            make.width.equalTo(sourceCellRect.width)
            make.height.equalTo(sourceCellRect.height)
        }
        
        // 4. Плашка меню кнопок изначально полностью прозрачна и сжата за карточкой
        toVC.menuView.alpha = 0
        toVC.menuView.snp.remakeConstraints { make in
            make.top.equalTo(toVC.toDoItemContainerView.snp.bottom)
            make.centerX.equalTo(toVC.toDoItemContainerView)
            make.width.equalTo(toVC.toDoItemContainerView).multipliedBy(0.7) // Чуть уже карточки по макету
        }
        
        toVC.view.layoutIfNeeded()
        
        // Высчитываем, влезет ли меню СНИЗУ или ротируем НАВЕРХ! 🚀
        let requiredMenuHeight: CGFloat = 150 // 3 строки по 44pt + 2 разделителя по 1pt + отступ 16pt
        let availableSpaceBelow = containerView.bounds.height - sourceCellRect.maxY - containerView.safeAreaInsets.bottom
        let isMenuFittingBelow = availableSpaceBelow >= requiredMenuHeight
        
        // 5. ЗАПУСКАЕМ СИСТЕМНЫЙ АНИМАТОР
        let duration = transitionDuration(using: transitionContext)
        
        UIView.animate(withDuration: duration, delay: 0, options: .curveEaseInOut, animations: {
            toVC.blurEffectView.effect = UIBlurEffect(style: .systemUltraThinMaterialDark)
            
            toVC.dimmingView.alpha = 0.52
            toVC.menuView.alpha = 1
            
            // В: Перестраиваем констреинты в финальную позицию на основе математики пространства
            if isMenuFittingBelow {
                // Если места внизу полно — меню выкатывается СНИЗУ карточки задач
                toVC.menuView.snp.remakeConstraints { make in
                    make.top.equalTo(toVC.toDoItemContainerView.snp.bottom).offset(16)
                    make.centerX.equalTo(toVC.toDoItemContainerView)
                    make.width.equalTo(toVC.toDoItemContainerView).multipliedBy(0.7)
                }
            } else {
                // Если ячейка в самом низу экрана у футера — нагло перекидываем меню НАВЕРХ карточки! 🎯
                toVC.menuView.snp.remakeConstraints { make in
                    make.bottom.equalTo(toVC.toDoItemContainerView.snp.top).offset(-16)
                    make.centerX.equalTo(toVC.toDoItemContainerView)
                    make.width.equalTo(toVC.toDoItemContainerView).multipliedBy(0.7)
                }
            }
            
            toVC.view.layoutIfNeeded()
            
        }, completion: { finished in
            transitionContext.completeTransition(finished)
        })
    }
}
