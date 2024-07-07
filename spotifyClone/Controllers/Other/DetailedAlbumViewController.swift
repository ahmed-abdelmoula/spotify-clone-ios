//
//  AlbumViewController.swift
//  spotifyClone
//
//  Created by Ahmed Mac on 21/6/2023.
//

import UIKit

class DetailedAlbumViewController : UIViewController {
    // it should own the property for givven album
    var album : Album
    public var isOwner = false
    let collectionView : UICollectionView = {
        var collectionView = UICollectionView(frame: .zero,
                                                  collectionViewLayout: DetailedAlbumViewController.createLayout())
        return collectionView
    }()
    
    static func createLayout() -> UICollectionViewCompositionalLayout {
          let supplementaryHeader = NSCollectionLayoutBoundarySupplementaryItem(
              layoutSize: NSCollectionLayoutSize(
                  widthDimension: .fractionalWidth(1),
                  heightDimension: .fractionalWidth(1)),
              elementKind: UICollectionView.elementKindSectionHeader,
              alignment: .top)
          //Item
          let item = NSCollectionLayoutItem(
              layoutSize: NSCollectionLayoutSize(
                  widthDimension: .fractionalWidth(1),
                  heightDimension: .fractionalHeight(1)))
          item.contentInsets = NSDirectionalEdgeInsets(top: 2, leading: 2, bottom: 2, trailing: 2)
          //Group
          let group = NSCollectionLayoutGroup.vertical(
              layoutSize: NSCollectionLayoutSize(
                  widthDimension: .fractionalWidth(1),
                  heightDimension: .absolute(80)),
              subitem: item,
              count: 1)
          //Section
          let section = NSCollectionLayoutSection(group: group)
          section.boundarySupplementaryItems = [supplementaryHeader]
          return UICollectionViewCompositionalLayout(section: section)
      }
    
    
    
    init(album : Album) {
        self.album = album
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
            title = "Album"
        view.backgroundColor = .systemBackground
        view.addSubview(collectionView)
        collectionView.register(AlbumDetailsCollectionViewCell.self,
                                forCellWithReuseIdentifier: AlbumDetailsCollectionViewCell.identifier)
        collectionView.register(AlbumHeaderCollectionReusableView.self,
                                    forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                    withReuseIdentifier: AlbumHeaderCollectionReusableView.identifier)
        collectionView.dataSource = self
        collectionView.delegate = self
        fetchData()
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: .done, target: self, action: #selector(didTapSave))

    }
    
    @objc private func didTapSave() {
        // here we will do the api call to save
        let actionSheet = UIAlertController(title: album.name , message : "Actions" ,preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Save ALbum", style: .default , handler: { [weak self] _ in
            guard let strongSelf = self else { return }
            APICaller.shared.saveAlbum(album: strongSelf.album) { success in
                if success {
                    HapticsManager.shared.vibrate(for: .success)

                    NotificationCenter.default.post(name : .albumSavedNotication , object: nil)
                    print("Saved.")
                } else {
                    HapticsManager.shared.vibrate(for: .error)

                    print("Unable to save album.")
                }
            }
        }))
        present(actionSheet, animated: true)
 
     
    }
    override func viewDidLayoutSubviews() {
          super.viewDidLayoutSubviews()
          collectionView.frame = view.bounds
      }
    var viewModel = [RecommendedTrackCellViewModel]()
    
    func fetchData() {
        APICaller.shared.getAlbumDetails(album: album) {  [weak self ]  result in
            DispatchQueue.main.async {
                switch result {
                case .success(let detailsAlbum) :
                    print(detailsAlbum)
                    self?.viewModel =     detailsAlbum.tracks.items.compactMap({
                          RecommendedTrackCellViewModel(name: $0.name,
                                                        artistName: $0.artists.first?.name ?? "-",
                                                        artworkURL:URL(string: $0.album?.images.first?.url ?? "")
                          )
                    })
                    self?.collectionView.reloadData()
                    break
                case .failure(let error):
                    print("error")
                    print(error.localizedDescription)
                    break
                }
            }
        }
    }
    
 
    


}

extension DetailedAlbumViewController : UICollectionViewDelegate, UICollectionViewDataSource,AlbumHeaderCollectionReusableViewDelegate {
    func albumHeaderCollectionReusableViewDidTapPlayAll(_ header: AlbumHeaderCollectionReusableView) {
        //
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
    return 1
    }
 
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: AlbumDetailsCollectionViewCell.identifier, for: indexPath) as? AlbumDetailsCollectionViewCell else {
                  return UICollectionViewCell()
              }
              cell.configure(with: viewModel[indexPath.row])
              return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard let header = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: AlbumHeaderCollectionReusableView.identifier,
            for: indexPath) as? AlbumHeaderCollectionReusableView,
              kind == UICollectionView.elementKindSectionHeader else {
            return UICollectionReusableView()
        }
        let headerViewModel = AlbumDetailsHeaderViewModel(
            albumCoverImage: URL(string: album.images.first?.url ?? "-"),
            albumName: album.name,
            releaseDate: "Release Date: \(String.formattedDate(string: album.release_date))",
            artistName: album.artists.first?.name ?? "-")
        header.configure(with: headerViewModel)
        header.delegate = self
        return header
    }
    
   
}
