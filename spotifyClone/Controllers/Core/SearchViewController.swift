//
//  SearchViewController.swift
//  spotifyClone
//
//  Created by Ahmed Mac on 13/6/2023.
//

import UIKit
import SafariServices
class SearchViewController: UIViewController, UISearchResultsUpdating  , UICollectionViewDelegate , UICollectionViewDataSource, UISearchBarDelegate , SearchResultViewControllerDelegate {
    
    func didTapResult(_ selectedRowType: SearchResult) {
       
        switch selectedRowType {
        case .artist(let artist):
            guard let url = URL(string: artist.external_urls["spotify"] ?? "") else {
                return
            }
            let vc = SFSafariViewController(url: url)
            present(vc, animated: true)
        case .album(let album):
            let vc = DetailedAlbumViewController(album: album)
            navigationController?.pushViewController(vc, animated: true)
        case .playlist(let playlist):
            let vc = DetailedPlayListViewController(playlist: playlist)
            navigationController?.pushViewController(vc, animated: true)
        case .track(let track):
            
            print("hello")
            
        }
    }
    
    
    
 /*  func showDetailedResult(_ vc: UIViewController) {
        vc.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(vc, animated: true)
    }   */
    
   
    
 private var categories = [Category]()
    
    //1) define your search bar
    let searchController :  UISearchController  = {
        let searchResult = SearchResultViewController()
        let searchView = UISearchController(searchResultsController: searchResult)
        searchView.searchBar.placeholder  = "Songs , Artists , Albums"
        searchView.searchBar.searchBarStyle = .minimal
        return searchView
    }()
    
    // define categories
    let collectionView : UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: SearchViewController.createLayout())
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
        item.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 5, bottom: 10, trailing: 5)
          //Group
          let group = NSCollectionLayoutGroup.horizontal(
              layoutSize: NSCollectionLayoutSize(
                  widthDimension: .fractionalWidth(1),
                  heightDimension: .absolute(140)),
              subitem: item,
              count: 2)
          //Section
          let section = NSCollectionLayoutSection(group: group)
          return UICollectionViewCompositionalLayout(section: section)
      }
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        //2) set the navigationItem to search bar
        navigationItem.searchController = searchController
        //3) we need to be able to get the result typed out of the searchController
        searchController.searchResultsUpdater = self
        searchController.searchBar.delegate = self
        view.addSubview(collectionView)
        //we need to configure the cells 
        collectionView.register(CategoryCollectionViewCell.self, forCellWithReuseIdentifier: CategoryCollectionViewCell.identifier)
        
        collectionView.delegate = self
        collectionView.dataSource = self 
        collectionView.backgroundColor = .systemBackground

        fetchData()
        
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
         collectionView.frame = view.bounds
    }
    
    func fetchData() {
        
        APICaller.shared.getAllCategories {  [weak self ]  result in
            DispatchQueue.main.async {
                switch result {
                case .success(let responseCategories) :
                    self?.categories = responseCategories.categories.items

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
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let searchResultController = searchController.searchResultsController as? SearchResultViewController, let query = searchController.searchBar.text ,  !query.trimmingCharacters(in: .whitespaces).isEmpty  else {
            return
        }
        //when ever we create and initialize the searchResult controller we gonna set the delegate
        searchResultController.delegate = self
        APICaller.shared.searchResult(query: query) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let results):
                    searchResultController.update(with: results)
                    break
                case .failure(let error):
                    break
                }
            }
            
        }
    }
    
    func updateSearchResults(for searchController: UISearchController) {

    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return categories.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard  let cell =  collectionView.dequeueReusableCell(withReuseIdentifier: CategoryCollectionViewCell.identifier, for: indexPath) as? CategoryCollectionViewCell else {
            return UICollectionViewCell()
        }
        cell.backgroundColor = .systemGreen
        let singleCategory = categories[indexPath.row]
        cell.update(with: singleCategory )
        return cell
            
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        let selectedCategory = categories[indexPath.row]
        let vc = CategoryViewController(withSelected: selectedCategory)
        vc.navigationItem.title = selectedCategory.name
        vc.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(vc, animated: true)
    }
}
