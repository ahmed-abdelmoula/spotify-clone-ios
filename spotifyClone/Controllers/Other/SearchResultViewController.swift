//
//  SearchResultViewController.swift
//  spotifyClone
//
//  Created by Ahmed Mac on 13/6/2023.
//

import UIKit
// every section will have it own result
struct SearchSection {
    let title : String
   let results : [SearchResult]
}
// in the result controller we create a protocole to proxy back the call to search controller via deleegate
protocol SearchResultViewControllerDelegate : AnyObject{ // AnyObject to declare the delegate weak
//   func showDetailedResult(_ vc : UIViewController)
    func didTapResult(_ result: SearchResult)
}

class SearchResultViewController : UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var sections : [SearchSection] = [] // this can to be an array of search Section
    // Section : Artist  role : print list of artist
    
     weak var delegate: SearchResultViewControllerDelegate?

  
   let  tableView : UITableView = {
       var tableView = UITableView(frame: .zero , style: .grouped)
       tableView.register(SearchResultDefaultTableViewCell.self,
                              forCellReuseIdentifier: SearchResultDefaultTableViewCell.identifier)
       tableView.isHidden = true
       return tableView
    }()
    //when you enter in the searchbar and start typing the searchResultViewController will appear
    // and since the background is red we will see a red color but this in case the array is hidden
    // if array appear when you enter the search query we will see only the array since the tableView.frame is equal to view.bounds and color red disppear because he is overlapping it
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        view.addSubview(tableView)
        tableView.delegate  = self
        tableView.dataSource = self
        tableView.frame = view.bounds
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
    }
    
    //define a generic search result  that we can return from the api back to the caller 
    
    func update (with results : [SearchResult]) {
// self.results =  insted of assinging result directly we gonna filter veriious type of result to give every section it type  , switch result cannot happen because result is an array we have to switch over the element of the array
        let artists = results.filter({
                switch $0 {
                case .artist: return true
                default: return false
                }
            })
            let albums = results.filter({
                switch $0 {
                case .album: return true
                default: return false
                }
            })
            let playlists = results.filter({
                switch $0 {
                case .playlist: return true
                default: return false
                }
            })
            let tracks = results.filter({
                switch $0 {
                case .track: return true
                default: return false
                }
            })
            
            self.sections = [
                SearchSection(title: "Songs", results: tracks),
                SearchSection(title: "Artists", results: artists),
                SearchSection(title: "Albums", results: albums),
                SearchSection(title: "Playlists", results: playlists)
            ]
            tableView.reloadData()
            tableView.isHidden = results.isEmpty
        
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].results.count
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
          return sections[section].title
      }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
          return 60
      }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true )
        let selectedRowType  = sections[indexPath.section].results[indexPath.row]
        delegate?.didTapResult(selectedRowType)
  /*      switch selectedRowType {
        case .album(let model) :
            // navigate to view controller with this model but using delegate
            let vc = DetailedAlbumViewController(album: model)
            delegate?.showDetailedResult(vc)
            break
        case .artist(model: let model):
            break
        case .track(model: let model):
            break
        case .playlist(model: let model):
            break
        }*/
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let selectedSection = sections[indexPath.section].results[indexPath.row]
        guard let customCell = tableView.dequeueReusableCell(
            withIdentifier: SearchResultDefaultTableViewCell.identifier, for: indexPath) as? SearchResultDefaultTableViewCell else {
            return UITableViewCell()
        }
        switch selectedSection {
        case .album(let album) :
            let viewModel = SearchResultCellViewModel(
                title: album.name,
                imageURL: album.images.first?.url ?? "",
                description: album.artists.first?.name ?? "-")
            customCell.configure(with: viewModel)
            return customCell
        case .artist(let artist) :
            let viewModel = SearchResultCellViewModel(
                title: artist.name,
                imageURL: artist.images?.first?.url ?? "",
                description: nil)
            customCell.configure(with: viewModel)
            return customCell
        case .playlist(let playlist) :
            let viewModel = SearchResultCellViewModel(
                title: playlist.name,
                imageURL: playlist.images.first?.url ?? "",
                description: playlist.owner.display_name)
            customCell.configure(with: viewModel)
            return customCell
        case .track(let song) :
            let viewModel = SearchResultCellViewModel(
                title: song.name,
                imageURL: song.album?.images.first?.url ?? "",
                description: song.artists.first?.name ?? "-")
            customCell.configure(with: viewModel)
            return customCell
        }
        return customCell
    }



}
