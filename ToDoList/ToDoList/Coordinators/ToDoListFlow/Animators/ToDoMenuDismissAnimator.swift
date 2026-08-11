//
//  ToDoMenuDismissAnimator.swift
//  ToDoList
//
//  Created by Vit Chernuhin on 11.08.2026.
//

import UIKit
import SnapKit

final class ToDoMenuDismissAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    
    private let sourceCellRect: CGRect
    
    init(sourceCellRect: CGRect) {
        self.sourceCellRect = sourceCellRect
        super.init()
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.2
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        // 1. Извлекаем контроллер меню, который мы сейчас гасим
        guard let fromVC = transitionContext.viewController(forKey: .from) as? ToDoItemMenuViewController else {
            transitionContext.completeTransition(false)
            return
        }
        
        let duration = transitionDuration(using: transitionContext)
        
        UIView.animate(withDuration: duration, delay: 0, options: .curveEaseInOut, animations: {
            
            fromVC.blurEffectView.effect = nil
            fromVC.dimmingView.alpha = 0
            fromVC.menuView.alpha = 0
            
            // Схлопываем карточку задачи точь-в-точь в координаты исходной ячейки таблицы!
            fromVC.toDoItemContainerView.snp.remakeConstraints { make in
                make.top.equalTo(fromVC.view.snp.top).offset(self.sourceCellRect.origin.y)
                make.leading.equalTo(fromVC.view.snp.leading).offset(self.sourceCellRect.origin.x)
                make.width.equalTo(self.sourceCellRect.width)
                make.height.equalTo(self.sourceCellRect.height)
            }
            
            fromVC.view.layoutIfNeeded()
            
        }, completion: { finished in
            fromVC.view.removeFromSuperview()
            transitionContext.completeTransition(finished)
        })
    }
}
