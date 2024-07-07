//
//  ProfileViewController.swift
//  spotifyClone
//
//  Created by Ahmed Mac on 13/6/2023.
//

import UIKit
import SDWebImage


class ProfileViewController: UIViewController, UITableViewDataSource, UITableViewDelegate  {
        //before using anynomus closures
    /* var tableView : UITableView = UITableView()
    func configTableView () { // and call this on viewDIdLoad
        tableView.register(UITableView.self, forCellReuseIdentifier: "cell")
    } */
    
    /* if you have things that meant to be static (they won't change like you button)
     title , background color or smth like this so we can do this in cleaner way
    with closure insted of assing the intization we assing a closures and inside the closures
    we create , config and return the table view (the type we defined) and at the end of closures*/
    
    let tableView : UITableView = {
        var tableView = UITableView(frame: .zero, style: .grouped)
        tableView.isHidden = true // because we  may not got data
        //frame set to .zero (which means no initial size or position)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        // this method is called in tablView instance to register a class that will be used in creaeting new table cells
        // where indentifer is the reuse identifier for the cell which is a string that lets you register different kinds of table view cells. For example, you might have a reuse identifier "DefaultCell", another one called "Heading cell", another one "CellWithTextField", and so on. Re-using different cells this way helps save system resources.
        return tableView
    }() // The trailing () at the end of the closure indicates that the closure should be immediately executed to create and assign the UITableView instance to the tableView constant.
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Profile"
        tableView.delegate = self
        tableView.dataSource = self
        view.addSubview(tableView)
        view.backgroundColor = .systemBackground
        fetchProfile()
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
    }
    func fetchProfile() {
        APICaller.shared.getCurrentUserProfile { [weak self] result in
            
            DispatchQueue.main.async {
                switch result {
                case .success(let profile) :
                    self?.updateUI(with : profile )
                    break
                case .failure(let error) :
                    self?.showError()
                    print(error.localizedDescription)
                }
            }
        }
    }
    var models = [String]() // var models  : [String] = []
    func updateUI (with data : UserProfile) {
        tableView.isHidden = false
        //configure table models :  now basacly we gona take the data that we have inside user profile  and convert it in smth that we can show in our cells here
        models.append("Full name: \(data.display_name)")
        models.append("User ID: \(data.id)")
        models.append("Plan: \(data.product)")
        implementHeader (with: data.images.first?.url)
        tableView.reloadData() // reload so it refresh every time we ccall the api
    }
    //Value of optional type 'String?' must be unwrapped to a value of type 'String'
    // because url from sending function can be optional so we must unraped
   func implementHeader (with urlImage : String?) {
       guard let urlImage = urlImage else {
           return
       }
       let url = URL(string: urlImage)
       // tape frame after that
       let headerView = UIView(frame: CGRect(x: 0, y: 0, width: view.width, height: view.height/3))
       let imageSize: CGFloat = headerView.height / 2

       let imageView = UIImageView(frame : CGRect(x: 0, y: 0, width: imageSize, height: imageSize))
       imageView.backgroundColor = .black
       headerView.addSubview(imageView)
       imageView.center = headerView.center
       imageView.sd_setImage(with: url)
       imageView.contentMode = .scaleAspectFill
       imageView.layer.masksToBounds = true
       imageView.layer.cornerRadius = imageSize/2
       
       tableView.tableHeaderView = headerView
       
   }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        models.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = models[indexPath.row]
        cell.selectionStyle = .none // the selection style that determine the color of cell when selected
        return cell
    }
    
    
    func showError() {
        let label = UILabel(frame: .zero)
        label.text = "Error has occured "
        label.sizeToFit()
        label.textColor = .secondaryLabel
        view.addSubview(label)
        label.center = view.center
    }
   

}
