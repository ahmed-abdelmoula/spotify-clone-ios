//
//  CategoryViewController.swift
//  spotifyClone
//
//  Created by Ahmed Mac on 24/6/2023.
//

import UIKit

class CategoryViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    let selectedCategory: Category
    private var viewModels = [PlaylistCellViewModel]()
    private var playlists = [Playlist]()

    
    // if you working with no need for intilazion and register of cell
    // all will be done inside the the storyboard
    let collectionView  : UICollectionView  = {
        var collectionView = UICollectionView(frame: .zero , collectionViewLayout: CategoryViewController.createLayout())
        return collectionView
    }()

    static func createLayout() -> UICollectionViewCompositionalLayout {

          //Item
          let item = NSCollectionLayoutItem(
              layoutSize: NSCollectionLayoutSize(
                  widthDimension: .fractionalWidth(1),
                  heightDimension: .fractionalHeight(1)))
          item.contentInsets = NSDirectionalEdgeInsets(top: 2, leading: 2, bottom: 2, trailing: 2)
          //Group
          let group = NSCollectionLayoutGroup.horizontal(
              layoutSize: NSCollectionLayoutSize(
                  widthDimension: .fractionalWidth(1),
                  heightDimension: .absolute(200)),
              subitem: item,
              count: 2)
          //Section
          let section = NSCollectionLayoutSection(group: group)
          return UICollectionViewCompositionalLayout(section: section)
      }
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        view.addSubview(collectionView)
        collectionView.delegate = self
          collectionView.dataSource = self
        collectionView.register(PlaylistsCollectionViewCell.self, forCellWithReuseIdentifier: PlaylistsCollectionViewCell.identifier)
        fetchPlaylistOfCategories()
    }
    func  fetchPlaylistOfCategories() {
        APICaller.shared.getCategoryPlaylist(category: selectedCategory) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let playlists):
                    self?.playlists = playlists
                    self?.viewModels = playlists.compactMap({
                        return PlaylistCellViewModel(
                            name: $0.name,
                            artworkURL: URL(string:$0.images.first?.url ?? "-"),
                            creatorName: $0.owner.display_name,
                            description: nil)
                    })
                    self?.collectionView.reloadData()
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
        }
    }
    override func viewDidLayoutSubviews() {
         super.viewDidLayoutSubviews()
         collectionView.frame = view.bounds
     }
    
    init(withSelected category :Category) {
        self.selectedCategory = category
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
        
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModels.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PlaylistsCollectionViewCell.identifier,
                                                            for: indexPath) as? PlaylistsCollectionViewCell else {
            return UICollectionViewCell()
        }
        cell.backgroundColor = .secondarySystemBackground
        cell.configure(with: viewModels[indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        let selectedPlaylist = playlists[indexPath.row]
        let vc =  DetailedPlayListViewController(playlist: selectedPlaylist)
        vc.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(vc, animated: true)
    }
 }




