import UIKit
import SnapKit

final class ToDoMicControl: UIControl {
    
    private let imageView: UIImageView = {
        let icon = UIImageView(image: AppIcons.ToDoList.microphone)
        icon.tintColor = AppColors.searchTint
        icon.contentMode = .scaleAspectFill
        return icon
    }()
    
    override var isHighlighted: Bool {
        didSet {
            UIView.animate(withDuration: 0.1, delay: 0, options: [.allowUserInteraction], animations: {
                self.imageView.alpha = self.isHighlighted ? 0.4 : 1.0
            })
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        backgroundColor = .clear
        addSubview(imageView)
        
        imageView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.equalTo(12)
            make.height.equalTo(17)
        }
    }
}
