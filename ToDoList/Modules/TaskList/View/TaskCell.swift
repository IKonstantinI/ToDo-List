import UIKit

final class TaskCell: UITableViewCell {
    static let reuseIdentifier = "TaskCell"
    
    private let checkBox: UIButton = {
        let button = UIButton()
        let config = UIImage.SymbolConfiguration(pointSize: 28, weight: .regular)
        button.setPreferredSymbolConfiguration(config, forImageIn: .normal)
        button.tintColor = .systemGray3  // Базовый цвет для неактивного состояния
        return button
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16)
        label.textColor = .white
        label.numberOfLines = 0
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = .white
        label.numberOfLines = 2
        return label
    }()
    
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12)
        label.textColor = .systemGray
        return label
    }()
    
    private let contentStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 4
        stackView.alignment = .leading
        return stackView
    }()
    
    private var onToggleCompletion: ((Bool) -> Void)?
    private var isCompleted: Bool = false
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = .black
        selectionStyle = .none
        
        contentView.addSubview(checkBox)
        contentView.addSubview(contentStackView)
        
        contentStackView.addArrangedSubview(titleLabel)
        contentStackView.addArrangedSubview(descriptionLabel)
        contentStackView.addArrangedSubview(dateLabel)
        
        [checkBox, contentStackView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        NSLayoutConstraint.activate([
            checkBox.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            checkBox.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            checkBox.widthAnchor.constraint(equalToConstant: 28),
            checkBox.heightAnchor.constraint(equalToConstant: 28),
            
            contentStackView.leadingAnchor.constraint(equalTo: checkBox.trailingAnchor, constant: 16),
            contentStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            contentStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            contentStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12)
        ])
        
        checkBox.addTarget(self, action: #selector(checkBoxTapped), for: .touchUpInside)
    }
    
    func configure(with task: TaskEntity, onToggleCompletion: @escaping (Bool) -> Void) {
        self.onToggleCompletion = onToggleCompletion
        self.isCompleted = task.isCompleted
        
        updateTitle(task.title, isCompleted: task.isCompleted)
        updateDescription(task.description, isCompleted: task.isCompleted)
        updateDate(task.createdAt)
        updateCheckBox(isCompleted: task.isCompleted)
    }
    
    private func updateTitle(_ title: String, isCompleted: Bool) {
        if isCompleted {
            let attributedString = NSAttributedString(
                string: title,
                attributes: [
                    .strikethroughStyle: NSUnderlineStyle.single.rawValue,
                    .strikethroughColor: UIColor.white,
                    .foregroundColor: UIColor.systemGray
                ]
            )
            titleLabel.attributedText = attributedString
        } else {
            titleLabel.attributedText = nil
            titleLabel.text = title
            titleLabel.textColor = .white
        }
    }
    
    private func updateDescription(_ description: String, isCompleted: Bool) {
        descriptionLabel.text = description
        descriptionLabel.textColor = isCompleted ? .systemGray : .white
    }
    
    private func updateDate(_ date: Date) {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yy"
        dateLabel.text = formatter.string(from: date)
    }
    
    private func updateCheckBox(isCompleted: Bool) {
        let config = UIImage.SymbolConfiguration(pointSize: 28, weight: .regular)
        
        if isCompleted {
            // Активное состояние: желтая галочка в круге
            let image = UIImage(
                systemName: "checkmark.circle",  // Используем .circle вместо .circle.fill
                withConfiguration: config
            )?.withRenderingMode(.alwaysTemplate)
            checkBox.setImage(image, for: .normal)
            checkBox.tintColor = .systemYellow
        } else {
            // Неактивное состояние: серый круг
            let image = UIImage(
                systemName: "circle",
                withConfiguration: config
            )?.withRenderingMode(.alwaysTemplate)
            checkBox.setImage(image, for: .normal)
            checkBox.tintColor = .systemGray3
        }
    }
    
    @objc private func checkBoxTapped() {
        isCompleted.toggle()
        updateTitle(titleLabel.text ?? "", isCompleted: isCompleted)
        updateDescription(descriptionLabel.text ?? "", isCompleted: isCompleted)
        updateCheckBox(isCompleted: isCompleted)
        onToggleCompletion?(isCompleted)
    }
} 