//
//  SettingsViewController.swift
//  spotifyClone
//
//  Created by Ahmed Mac on 13/6/2023.
//

import UIKit

class SettingsViewController: UIViewController , UITableViewDelegate ,UITableViewDataSource {
    
  
    
    var sections : [Section] = [] // or simply like this var secctions  = [Section]()
    private let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return tableView
    }()
    // we used self optional here because we are going to add weak self here so that we don't make a memory leak
    private func configureModels() {
        sections.append(Section(title: "Profile", options: [Option(title: "View Your Profile", handler: { [weak self] in
            DispatchQueue.main.async {
                self?.viewProfile()
            }
            
        })]))
        
        sections.append(Section(title: "Account", options: [Option(title: "Sign Out", handler: { [weak self] in
            DispatchQueue.main.async {
                self?.signOutTapped()
            }
            
        })]))
                        
    }
    
    func viewProfile (){
        let pfC = ProfileViewController()
        pfC.title = "Profile"
        pfC.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(pfC, animated: true)
        
    }
    private func signOutTapped() {
        let actionSheet = UIAlertController(title: "Sign Out", message: "Do you want to sign out?", preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        actionSheet.addAction(UIAlertAction(title: "Sign Out", style: .destructive, handler: { _ in
            AuthManager.shared.signOut { [weak self] success in
                if success {
                    DispatchQueue.main.async {
                        let navC = UINavigationController(rootViewController: WelcomeViewController())
                        navC.navigationBar.prefersLargeTitles = true
                        navC.modalPresentationStyle = .fullScreen
                        self?.present(navC, animated: true, completion: {
                            self?.navigationController?.popToRootViewController(animated: true)
                        })
                    }
                }
            }
        }))
        present(actionSheet, animated: true)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Setting"
        configureModels()
        view.backgroundColor = .systemBackground
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        // delegate hiya object w f case mta tableVIew hiya du type UITableVIewDelegate
        // In iOS development, a delegate is an object that conforms to a specific protocol and is responsible for handling certain events or providing customization options for another object (TableView). In the case of a table view, the delegate is an object that adopts the UITableViewDelegate protocol.
        // The UITableViewDelegate protocol defines a set of methods that allow you to customize the behavior and appearance of a table view. By implementing these methods in your delegate object, you can respond to events such as selecting a table view cell, editing the table view, or managing the appearance of headers and footers.
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
    }
    
    //Asks the data source to return the number of sections in the table view.
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
        
    }
    //Tells the data source to return the number of rows in a given section of a table view.
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].options.count
    }
    
    // Asks the data source for a cell to insert in a particular location of the table view.
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = sections[indexPath.section].options[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = model.title
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        let model = sections[indexPath.section].options[indexPath.row]
        model.handler()
        
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section].title
        
    }

 

}
