//
//  LibraryAlbumsViewController.swift
//  spotifyClone
//
//  Created by Ahmed Mac on 26/6/2023.
//

import UIKit

class LibraryAlbumsViewController: UIViewController {
    private var observer : NSObjectProtocol?
    
    var albums = [Album]()
    
    var selectionHandler: ((Album) -> Void)?
    private let noAlbumView = LabelReusableView()
    
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
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        setNoPlaylistView()
        fetchAlbums()
        
        if selectionHandler != nil {
            navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .close, target: self, action: #selector(didTapDismiss))
        }
        // observer for notification whether is fired or not
        observer = NotificationCenter.default.addObserver(
            forName: .albumSavedNotication,
            object: nil,
            queue: .main,
            using: { _ in
            self.fetchAlbums()
        })
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
        noAlbumView.frame = CGRect(
            x: (view.width - 150 )/2,
            y: (view.height - 150 )/2,
            width: 150,
            height: 150)
//        noAlbumView.center = view.center
    }
    @objc private func didTapDismiss() {
        dismiss(animated: true)
    }
    private func setNoPlaylistView() {
        view.addSubview(noAlbumView)
        noAlbumView.configure(with: LabelReusableViewModel(label: "You don't have any playlists yet.", buttonName: "Create"))
        noAlbumView.delegate = self
    }
    
    func fetchAlbums() {
        albums.removeAll()
        APICaller.shared.getSavedAlbums { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let album):
                    self?.albums = album
                    self?.updateUI()
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
        }
    }
    
    private func updateUI() {
        if albums.isEmpty {
            noAlbumView.isHidden = false
            tableView.isHidden = true
        } else {
            tableView.reloadData()
            tableView.isHidden = false
            noAlbumView.isHidden = true
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
                        self?.fetchAlbums()
                        self?.tableView.isHidden = false
                        self?.tableView.reloadData()
                    } else {
                        print("Failed to create playlist.")
                    }
                }
                
                
            }
        }))
        present(alert, animated: true)
    }
}


extension LibraryAlbumsViewController: LabelReusableViewDelegate {
    func actionLabelViewDidTapButton(_ actionView: LabelReusableView) {
        tabBarController?.selectedIndex = 0
    }
}

//MARK: - Table View
extension LibraryAlbumsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        albums.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: SearchResultDefaultTableViewCell.identifier, for: indexPath) as? SearchResultDefaultTableViewCell else {
            return UITableViewCell()
        }
        let playlist = albums[indexPath.row]
        cell.configure(with: SearchResultCellViewModel(title: playlist.name, imageURL: playlist.images.first?.url  ?? "", description: playlist.artists.first?.name))
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        70
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let album = albums[indexPath.row]
        let vc = DetailedAlbumViewController(album: album)
        vc.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(vc, animated: true)
    }
  
    
}
