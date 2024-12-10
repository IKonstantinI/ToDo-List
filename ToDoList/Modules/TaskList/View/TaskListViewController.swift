import UIKit

protocol TaskListViewProtocol: AnyObject {
    func updateTasks(with tasks: [TaskEntity])
    func removeTask(_ task: TaskEntity)
    func showLoading()
    func hideLoading()
    func showError(_ error: Error)
}

final class TaskListViewController: UIViewController {
    private var presenter: TaskListPresenterProtocol!
    private let tableView = UITableView()
    private var tasks: [TaskEntity] = []
    private let searchController = UISearchController(searchResultsController: nil)
    private let emptyStateView = EmptyStateView()
    
    private let bottomPanel: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGray6
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: -2)
        view.layer.shadowOpacity = 0.1
        view.layer.shadowRadius = 4
        return view
    }()
    
    private let taskCountLabel: UILabel = {
        let label = UILabel()
        label.textColor = .label
        label.font = .systemFont(ofSize: 14)
        label.textAlignment = .center
        return label
    }()
    
    private let addButton: UIButton = {
        let button = UIButton()
        let config = UIImage.SymbolConfiguration(pointSize: 24, weight: .medium)
        let image = UIImage(systemName: "square.and.pencil", withConfiguration: config)
        button.setImage(image, for: .normal)
        button.tintColor = .systemYellow
        button.contentHorizontalAlignment = .fill
        button.contentVerticalAlignment = .fill
        return button
    }()
    
    private let activityIndicator = UIActivityIndicatorView(style: .large)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupTableView()
        setupNavigationBar()
        setupSearchController()
        setupBottomPanel()
        presenter.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        presenter.viewWillAppear()
    }
    
    private func setupUI() {
        view.backgroundColor = .black
        tableView.backgroundColor = .black
        tableView.separatorStyle = .none
        
        [tableView, emptyStateView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -50),
            
            emptyStateView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStateView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        
        view.addSubview(activityIndicator)
        activityIndicator.center = view.center
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(TaskCell.self, forCellReuseIdentifier: TaskCell.reuseIdentifier)
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 88
        
        // Настраиваем нативный разделитель
        tableView.separatorStyle = .singleLine
        tableView.separatorColor = .systemGray.withAlphaComponent(0.2)
        tableView.separatorInset = .zero
        tableView.cellLayoutMarginsFollowReadableWidth = false
    }
    
    private func setupNavigationBar() {
        title = "Задачи"
        
        // Настройка стиля навигации
        navigationController?.navigationBar.barStyle = .black
        navigationController?.navigationBar.tintColor = .white
        
        // Настройка Large Title
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always
        
        // Настройка шрифта и цвета для Large Title
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .black
        appearance.largeTitleTextAttributes = [
            .foregroundColor: UIColor.white,
            .font: UIFont.systemFont(ofSize: 34, weight: .bold)
        ]
        appearance.titleTextAttributes = [
            .foregroundColor: UIColor.white,
            .font: UIFont.systemFont(ofSize: 17, weight: .semibold)
        ]
        
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.compactAppearance = appearance
    }
    
    private func setupSearchController() {
        searchController.searchResultsUpdater = self
        searchController.delegate = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.searchTextField.backgroundColor = .systemGray6.withAlphaComponent(0.1)
        searchController.searchBar.tintColor = .white
        searchController.searchBar.searchTextField.textColor = .white
        searchController.searchBar.searchTextField.leftView?.tintColor = .systemGray
        searchController.searchBar.searchTextField.attributedPlaceholder = NSAttributedString(
            string: "Search",
            attributes: [.foregroundColor: UIColor.systemGray]
        )
        navigationItem.searchController = searchController
        definesPresentationContext = true
    }
    
    private func setupBottomPanel() {
        view.addSubview(bottomPanel)
        bottomPanel.translatesAutoresizingMaskIntoConstraints = false
        
        bottomPanel.addSubview(taskCountLabel)
        bottomPanel.addSubview(addButton)
        
        taskCountLabel.translatesAutoresizingMaskIntoConstraints = false
        addButton.translatesAutoresizingMaskIntoConstraints = false
        
        let bottomPadding = view.safeAreaInsets.bottom
        
        NSLayoutConstraint.activate([
            bottomPanel.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bottomPanel.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bottomPanel.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            bottomPanel.heightAnchor.constraint(equalToConstant: 83 + bottomPadding),
            
            taskCountLabel.centerXAnchor.constraint(equalTo: bottomPanel.centerXAnchor),
            taskCountLabel.centerYAnchor.constraint(equalTo: bottomPanel.centerYAnchor, constant: -(bottomPadding/2 + 8)),
            
            addButton.trailingAnchor.constraint(equalTo: bottomPanel.trailingAnchor, constant: -16),
            addButton.centerYAnchor.constraint(equalTo: bottomPanel.centerYAnchor, constant: -(bottomPadding/2 + 8)),
            addButton.widthAnchor.constraint(equalToConstant: 32),
            addButton.heightAnchor.constraint(equalToConstant: 32)
        ])
        
        // Обновляем констрейнты tableView
        if let tableViewBottomConstraint = tableView.constraints.first(where: { $0.firstAttribute == .bottom }) {
            tableViewBottomConstraint.isActive = false
        }
        tableView.bottomAnchor.constraint(equalTo: bottomPanel.topAnchor).isActive = true
        
        addButton.addTarget(self, action: #selector(addButtonTapped), for: .touchUpInside)
    }
    
    private func updateUI() {
        let isEmpty = tasks.isEmpty
        emptyStateView.isHidden = !isEmpty
        tableView.isHidden = isEmpty
        
        updateTaskCount()
        tableView.reloadData()
    }
    
    private func updateTaskCount() {
        let totalTasks = tasks.count
        taskCountLabel.text = "\(totalTasks) задач"
    }
    
    @objc private func addButtonTapped() {
        presenter.addNewTask()
    }
    
    func configure(with presenter: TaskListPresenterProtocol) {
        self.presenter = presenter
    }
}

extension TaskListViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tasks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: TaskCell.reuseIdentifier,
            for: indexPath
        ) as? TaskCell else {
            return UITableViewCell()
        }
        
        let task = tasks[indexPath.row]
        cell.configure(with: task) { [weak self] isCompleted in
            guard let self = self else { return }
            var updatedTask = task
            updatedTask.isCompleted = isCompleted
            self.presenter.updateTaskStatus(updatedTask)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let task = tasks[indexPath.row]
        presenter.didSelectTask(task)
    }
    
    func tableView(
        _ tableView: UITableView,
        trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath
    ) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(
            style: .destructive,
            title: "Удалить"
        ) { [weak self] _, _, completion in
            guard let self = self else { return }
            let task = self.tasks[indexPath.row]
            self.presenter.deleteTask(task)
            completion(true)
        }
        
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
}

extension TaskListViewController: TaskListViewProtocol {
    func updateTasks(with tasks: [TaskEntity]) {
        self.tasks = tasks
        updateUI()
    }
    
    func removeTask(_ task: TaskEntity) {
        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            tasks.remove(at: index)
            
            // Анимируем удаление
            UIView.animate(withDuration: 0.3) {
                self.tableView.deleteRows(at: [IndexPath(row: index, section: 0)], with: .fade)
                self.updateUI()
            }
        }
    }
    
    func showLoading() {
        activityIndicator.startAnimating()
        tableView.isUserInteractionEnabled = false
    }
    
    func hideLoading() {
        activityIndicator.stopAnimating()
        tableView.isUserInteractionEnabled = true
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
}

extension TaskListViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let query = searchController.searchBar.text else { return }
        
        if query.isEmpty {
            presenter.refreshTasks()
        } else {
            presenter.searchTasks(query: query)
        }
    }
}

extension TaskListViewController: UISearchControllerDelegate {
    func didDismissSearchController(_ searchController: UISearchController) {
        presenter.refreshTasks()
    }
    
    func willDismissSearchController(_ searchController: UISearchController) {
        searchController.searchBar.text = nil
    }
}

extension TaskListViewController: TaskDetailDelegate {
    func taskDidUpdate() {
        presenter.refreshTasks()
    }
} 
