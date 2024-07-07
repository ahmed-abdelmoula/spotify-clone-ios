//
//  LibraryPlaylistViewController.swift
//  spotifyClone
//
//  Created by Ahmed Mac on 26/6/2023.
//

import UIKit

class LibraryPlaylistViewController: UIViewController {
    
    var playlists : [Playlist] = []
    var selectionHandler : ((Playlist) -> Void)?
     private let noPlaylistsView  = LabelReusableView()
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(SearchResultDefaultTableViewCell.self,
                           forCellReuseIdentifier: SearchResultDefaultTableViewCell.identifier)
        tableView.isHidden = true
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        //1)add the resusable Label
        view.addSubview(noPlaylistsView)
        view.addSubview(tableView)
                tableView.delegate = self
                tableView.dataSource = self
        //configue the resuable label
        noPlaylistsView.configure(with: LabelReusableViewModel(label: "You don't have any playlists yet.", buttonName: "Create"))
        noPlaylistsView.delegate = self
        fetchData()
        if selectionHandler != nil { //mean user is selecting the we will add a new UI part 
            navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(didTapClose))
        }
    }
    @objc func didTapClose () {
        dismiss(animated: true)
    }
    override func viewDidLayoutSubviews() {
          super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
          noPlaylistsView.frame = CGRect(
              x: 0,
              y: 0,
              width: 150,
              height: 150)
        noPlaylistsView.center = view.center
      }
    func fetchData() {
        APICaller.shared.getCurrentUserPlaylist { [ weak self] results in
            DispatchQueue.main.async {
                switch(results) {
                case .success(let playlist) :
                    self?.playlists = playlist
                    //check if playlist empty or not
                    
                    if (playlist.isEmpty){
                        // print the label
                        self?.noPlaylistsView.isHidden = false
                        self?.tableView.isHidden = true

                    } else {
                        // show available playlist
                        self?.tableView.reloadData()
                        self?.tableView.isHidden = false
                        self?.noPlaylistsView.isHidden = true
                        
                    }
                    break
                case .failure(let error ) :
                    print(error.localizedDescription)
                    break
                }
            }
            
        }
    }
    
    func showCreatePlaylistAlert() {
          let alert = UIAlertController(title: "New Playlist", message: "Enter playlist namee", preferredStyle: .alert)
          alert.addTextField { textfield in
              textfield.placeholder = "Playlist"
          }
          alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
          alert.addAction(UIAlertAction(title: "Create", style: .default, handler: { _ in
              guard let field = alert.textFields?.first, let text = field.text, !text.trimmingCharacters(in: .whitespaces).isEmpty else {
                  return
              }
              APICaller.shared.createPlaylist(with: text) { [weak self] success in
                  DispatchQueue.main.async {
                      if success {
                          HapticsManager.shared.vibrate(for: .success)
                          self?.fetchData()
                      } else {
                          print("Failed to create playlist.")
                      }
                  }
                  
                  
              }
          }))
          present(alert, animated: true)
      }
}

extension LibraryPlaylistViewController: LabelReusableViewDelegate {
    func actionLabelViewDidTapButton(_ actionView: LabelReusableView) {
            // on tap open alert create
        showCreatePlaylistAlert()

    }
}
extension LibraryPlaylistViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        playlists.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: SearchResultDefaultTableViewCell.identifier, for: indexPath) as? SearchResultDefaultTableViewCell else {
            return UITableViewCell()
        }
        let playlist = playlists[indexPath.row]
        cell.configure(with: SearchResultCellViewModel(title: playlist.name, imageURL: playlist.images.first?.url  ?? "", description: playlist.owner.display_name))
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        70
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        var selectedCell = playlists[indexPath.row]
        guard selectionHandler == nil else {
            selectionHandler?(selectedCell)
            tableView.reloadData()
            dismiss(animated: true)
            return
        }
        var vc = DetailedPlayListViewController(playlist: selectedCell)
        vc.isOwner = true 
        vc.title = "Playlist"
        vc.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(vc, animated: true)
        
    }
}
