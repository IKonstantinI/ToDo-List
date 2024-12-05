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
    
    private let emptyStateLabel: UILabel = {
        let label = UILabel()
        label.text = "Нет задач"
        label.textColor = .systemGray
        label.textAlignment = .center
        label.isHidden = true
        return label
    }()
    
    private let taskCountLabel: UILabel = {
        let label = UILabel()
        label.textColor = .systemGray
        label.font = .systemFont(ofSize: 14)
        return label
    }()
    
    private let addButton: UIButton = {
        let button = UIButton()
        let image = UIImage(systemName: "plus.circle.fill")
        button.setImage(image, for: .normal)
        button.tintColor = .systemYellow
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let activityIndicator = UIActivityIndicatorView(style: .large)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupTableView()
        setupNavigationBar()
        setupSearchController()
        setupBottomBar()
        presenter.viewDidLoad()
    }
    
    private func setupUI() {
        view.backgroundColor = .black
        tableView.backgroundColor = .black
        tableView.separatorStyle = .none
        
        [tableView, emptyStateLabel].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -50),
            
            emptyStateLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStateLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
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
    
    private func setupBottomBar() {
        let bottomBar = UIView()
        bottomBar.backgroundColor = .black
        bottomBar.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(bottomBar)
        
        bottomBar.addSubview(taskCountLabel)
        bottomBar.addSubview(addButton)
        
        NSLayoutConstraint.activate([
            bottomBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bottomBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bottomBar.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            bottomBar.heightAnchor.constraint(equalToConstant: 50),
            
            taskCountLabel.centerYAnchor.constraint(equalTo: bottomBar.centerYAnchor),
            taskCountLabel.leadingAnchor.constraint(equalTo: bottomBar.leadingAnchor, constant: 16),
            
            addButton.centerYAnchor.constraint(equalTo: bottomBar.centerYAnchor),
            addButton.trailingAnchor.constraint(equalTo: bottomBar.trailingAnchor, constant: -16),
            addButton.widthAnchor.constraint(equalToConstant: 44),
            addButton.heightAnchor.constraint(equalToConstant: 44)
        ])
        
        addButton.addTarget(self, action: #selector(addButtonTapped), for: .touchUpInside)
    }
    
    private func updateTaskCount() {
        taskCountLabel.text = "\(tasks.count) Задач"
        emptyStateLabel.isHidden = !tasks.isEmpty
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
        tableView.reloadData()
        updateTaskCount()
    }
    
    func removeTask(_ task: TaskEntity) {
        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            tasks.remove(at: index)
            tableView.deleteRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
            updateTaskCount()
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
        presenter.searchTasks(query: query)
    }
} 