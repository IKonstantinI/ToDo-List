import UIKit

final class EmptyStateView: UIView {
    private let stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = UIConstants.Padding.standard
        stack.alignment = .center
        return stack
    }()
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "list.bullet.clipboard")
        imageView.tintColor = .systemGray
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Нет задач"
        label.textColor = .systemGray
        label.textAlignment = .center
        label.font = UIConstants.Font.title
        return label
    }()
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Нажмите + чтобы добавить новую задачу"
        label.textColor = .systemGray
        label.textAlignment = .center
        label.font = UIConstants.Font.subtitle
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        [imageView, titleLabel, subtitleLabel].forEach {
            stackView.addArrangedSubview($0)
        }
        
        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: centerYAnchor),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: UIConstants.Padding.standard),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -UIConstants.Padding.standard),
            
            imageView.heightAnchor.constraint(equalToConstant: UIConstants.Size.iconSize),
            imageView.widthAnchor.constraint(equalToConstant: UIConstants.Size.iconSize)
        ])
    }
}