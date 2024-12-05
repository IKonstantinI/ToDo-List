import UIKit

final class TaskCell: UITableViewCell {
    static let reuseIdentifier = "TaskCell"
    
    private let checkboxButton: UIButton = {
        let button = UIButton()
        let config = UIImage.SymbolConfiguration(pointSize: 28, weight: .regular)
        let emptyCircle = UIImage(systemName: "circle", withConfiguration: config)?.withRenderingMode(.alwaysTemplate)
        let filledCircle = UIImage(systemName: "checkmark.circle.fill", withConfiguration: config)?.withRenderingMode(.alwaysTemplate)
        button.setImage(emptyCircle, for: .normal)
        button.setImage(filledCircle, for: .selected)
        button.tintColor = .systemYellow
        return button
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17)
        label.textColor = .white
        label.numberOfLines = 0
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = .systemGray
        label.numberOfLines = 0
        return label
    }()
    
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12)
        label.textColor = .systemGray
        return label
    }()
    
    private let stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 4
        stack.alignment = .leading
        return stack
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = .black
        contentView.backgroundColor = .black
        selectionStyle = .none
        
        [checkboxButton, stackView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview($0)
        }
        
        [titleLabel, descriptionLabel, dateLabel].forEach {
            stackView.addArrangedSubview($0)
        }
        
        NSLayoutConstraint.activate([
            checkboxButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            checkboxButton.topAnchor.constraint(equalTo: titleLabel.topAnchor),
            checkboxButton.widthAnchor.constraint(equalToConstant: 32),
            checkboxButton.heightAnchor.constraint(equalToConstant: 32),
            
            stackView.leadingAnchor.constraint(equalTo: checkboxButton.trailingAnchor, constant: 12),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12)
        ])
        
        checkboxButton.addTarget(self, action: #selector(checkboxTapped), for: .touchUpInside)
    }
    
    @objc private func checkboxTapped() {
        checkboxButton.isSelected.toggle()
        updateTaskAppearance()
        onTaskStatusChanged?(checkboxButton.isSelected)
    }
    
    private func updateTaskAppearance() {
        if checkboxButton.isSelected {
            titleLabel.attributedText = NSAttributedString(
                string: titleLabel.text ?? "",
                attributes: [
                    .strikethroughStyle: NSUnderlineStyle.single.rawValue,
                    .strikethroughColor: UIColor.white,
                    .foregroundColor: UIColor.systemGray
                ]
            )
            descriptionLabel.textColor = .systemGray2
        } else {
            titleLabel.attributedText = nil
            titleLabel.text = task?.title
            titleLabel.textColor = .white
            descriptionLabel.textColor = .systemGray
        }
    }
    
    private var task: TaskEntity?
    var onTaskStatusChanged: ((Bool) -> Void)?
    
    func configure(with task: TaskEntity, onStatusChanged: @escaping (Bool) -> Void) {
        self.task = task
        titleLabel.text = task.title
        descriptionLabel.text = task.description
        checkboxButton.isSelected = task.isCompleted
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yy"
        dateLabel.text = dateFormatter.string(from: task.createdAt)
        
        self.onTaskStatusChanged = onStatusChanged
        updateTaskAppearance()
    }
} 