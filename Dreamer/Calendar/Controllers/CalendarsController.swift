//
//  CalendarsController.swift
//  Dreamer
//
//  Created by Justin Rose on 5/9/18.
//  Copyright © 2018 justncode LLC. All rights reserved.
//

import UIKit

class CalendarsController: UIViewController {
    var entryStore: EntryStore!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        populateEntries()
        navigationController?.delegate = self
        setupNotificationObserver()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        Gradient.updateFrame(to: view.bounds)
        tableView.reloadData()
    }
    
    // MARK: - Entry Data
    private func populateEntries() {
        _ = entryStore.entries.map { entry in
            guard let date = entry.date else { return }
            entryStore.update(entry, for: (day: Int(date.day), month: Int(date.month), year: Int(date.year)))
        }
    }
    
    private func showEntry(for day: Int, month: Int, year: Int) {
        let entryController = EntryController()
        
        entryController.entryStore = entryStore
        entryController.entry = entryStore.entry(for: (day: day, month: month, year: year))
        entryController.date = (day, month, year)
        
        navigationController?.pushViewController(entryController, animated: true)
    }
    
    @objc private func reloadEntries(notification: NSNotification) {
        tableView.reloadData()
    }
    
    private func setupNotificationObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(reloadEntries), name: .entriesUpdated, object: nil)
    }
    
    @objc private func showDailyEntry() {
        let today = Date()
        showEntry(for: today.day-1, month: today.month, year: today.year)
    }
    
    // MARK: - Interface Setup
    private func setupViews() {
        setupNavigationBar()
        setupTableView()
        setupView()
        
        view.addSubview(weekdayView)
        weekdayView.anchor(top: (anchor: view.safeAreaLayoutGuide.topAnchor, constant: 0),
                           leading: (anchor: view.leadingAnchor, constant: 26),
                           trailing: (anchor: view.trailingAnchor, constant: -26))
        weekdayView.heightAnchor.constraint(equalToConstant: 22.0).isActive = true
        
        view.addSubview(separatorView)
        separatorView.anchor(top: weekdayView.bottomAnchor, leading: view.leadingAnchor, trailing: view.trailingAnchor)
        separatorView.heightAnchor.constraint(equalToConstant: 0.5).isActive = true
        
        view.addSubview(tableView)
        tableView.anchor(top: separatorView.bottomAnchor, leading: separatorView.leadingAnchor, bottom: view.bottomAnchor, trailing: separatorView.trailingAnchor)
    }
    
    private func setupNavigationBar() {
        navigationItem.title = "Dreamer"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(showDailyEntry))
    }
    
    private func setupTableView() {
        tableView.showsVerticalScrollIndicator = false
        tableView.register(CalendarCell.self, forCellReuseIdentifier: "cell")
    }
    
    private func setupView() {
        view.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0)
        Gradient.mask(colors: [#colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0), #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0)], locations: [0.8, 1], to: view)
    }
    
    let weekdayView = WeekdayView()
    let separatorView = SeparatorView()
    
    lazy var paddingView: UIView = {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 18.0, height: 1.0))
        return view
    }()
    
    lazy var tableView: UITableView = {
        let tv = UITableView()
        tv.delegate = self
        tv.dataSource = self
        tv.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0)
        tv.separatorStyle = .none
        tv.translatesAutoresizingMaskIntoConstraints = false
        return tv
    }()
}

// MARK: - UINavigationControllerDelegate
extension CalendarsController: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationControllerOperation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        return NavigationAnimator(operation)
    }
}

// MARK: - UITableViewDelegate
extension CalendarsController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 400
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 400
    }
}

// MARK: - UITableViewDataSource
extension CalendarsController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        /* We must subtract the difference based on our current month to avoid going out of bounds */
        return (entryStore.years.count * 12) - (12 - (Date().month + 1))
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! CalendarCell
        
        cell.calendarView.entryStore = entryStore
        cell.month = indexPath.row
        cell.dateSelected = { [weak self] (day, month, year) in
            self?.showEntry(for: day, month: month, year: year)
        }
        return cell
    }
}
