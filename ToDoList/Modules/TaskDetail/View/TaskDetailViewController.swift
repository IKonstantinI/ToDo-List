import UIKit

protocol TaskDetailViewProtocol: AnyObject {
    func updateView(with task: TaskEntity?)
    func showError(_ error: Error)
    func showLoading()
    func hideLoading()
    func close()
}

final class TaskDetailViewController: UIViewController {
    private var presenter: TaskDetailPresenterProtocol!
    
    private let titleTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Название задачи"
        textField.borderStyle = .roundedRect
        textField.font = .systemFont(ofSize: 16)
        return textField
    }()
    
    private let descriptionTextView: UITextView = {
        let textView = UITextView()
        textView.font = .systemFont(ofSize: 14)
        textView.layer.borderColor = UIColor.systemGray4.cgColor
        textView.layer.borderWidth = 1
        textView.layer.cornerRadius = 8
        return textView
    }()
    
    private let activityIndicator = UIActivityIndicatorView(style: .large)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupNavigationBar()
        presenter.viewDidLoad()
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        [titleTextField, descriptionTextView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            titleTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            titleTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            titleTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            titleTextField.heightAnchor.constraint(equalToConstant: 44),
            
            descriptionTextView.topAnchor.constraint(equalTo: titleTextField.bottomAnchor, constant: 16),
            descriptionTextView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            descriptionTextView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            descriptionTextView.heightAnchor.constraint(equalToConstant: 200)
        ])
        
        view.addSubview(activityIndicator)
        activityIndicator.center = view.center
    }
    
    private func setupNavigationBar() {
        title = presenter.isEditMode ? "Редактировать" : "Новая задача"
        
        let saveButton = UIBarButtonItem(
            title: "Сохранить",
            style: .done,
            target: self,
            action: #selector(saveButtonTapped)
        )
        navigationItem.rightBarButtonItem = saveButton
        
        let cancelButton = UIBarButtonItem(
            title: "Отмена",
            style: .plain,
            target: self,
            action: #selector(cancelButtonTapped)
        )
        navigationItem.leftBarButtonItem = cancelButton
    }
    
    @objc private func saveButtonTapped() {
        guard let title = titleTextField.text, !title.isEmpty else {
            showError(ValidationError.emptyTitle)
            return
        }
        
        presenter.saveTask(
            title: title,
            description: descriptionTextView.text
        )
    }
    
    @objc private func cancelButtonTapped() {
        presenter.cancelEditing()
    }
    
    func configure(with presenter: TaskDetailPresenterProtocol) {
        self.presenter = presenter
    }
}

extension TaskDetailViewController: TaskDetailViewProtocol {
    func updateView(with task: TaskEntity?) {
        titleTextField.text = task?.title
        descriptionTextView.text = task?.description
    }
    
    func showError(_ error: Error) {
        let alert = UIAlertController(
            title: "Ошибка",
            message: error.localizedDescription,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    func showLoading() {
        activityIndicator.startAnimating()
        view.isUserInteractionEnabled = false
    }
    
    func hideLoading() {
        activityIndicator.stopAnimating()
        view.isUserInteractionEnabled = true
    }
    
    func close() {
        dismiss(animated: true)
    }
}

enum ValidationError: LocalizedError {
    case emptyTitle
    
    var errorDescription: String? {
        switch self {
        case .emptyTitle:
            return "Название задачи не может быть пустым"
        }
    }
} 