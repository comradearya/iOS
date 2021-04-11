//
//  ViewController.swift
//  FeedApp
//
//  Created by orpan on 08.04.2021.
//

import UIKit
import Realm

class ViewController: UIViewController {
    //MARK: - Properties
    let identifier = "cell"
    
    var newsList = [NewsForView] ()
    @IBOutlet var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        
        let anonymousFunction = { (fetchedNewsList: [News]) in
            DispatchQueue.main.async { [self] in
            if fetchedNewsList.isEmpty {
                let lastNewsForViewList = RealmHelper.getObjects()
                self.newsList = lastNewsForViewList
                self.tableView.reloadData()
            }
            else {
                for news in fetchedNewsList {
                    let newsForView = NewsForView()
                    newsForView.imageUrl = news.urlToImage ?? ""
                    newsForView.newsDescription = news.newsDescription ?? ""
                    newsForView.title = news.title ?? ""
                    self.newsList.append(newsForView)
                }
                RealmHelper.saveObjects(objects: newsList)
                    self.tableView.reloadData()
                }
            }
        }
        NewsRepository.shared.fetchNewsList(onCompletion: anonymousFunction)
    }
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.newsList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as? CellViewController {
            cell.configureCell(item: newsList[indexPath.row])
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        if let detailsViewController = storyBoard.instantiateViewController(withIdentifier: "DetailViewControllerIdentifier") as? DetailViewController {
            self.present(detailsViewController, animated: true, completion: nil)
            print(newsList[indexPath.row].title)
            detailsViewController.titleLabel.text = newsList[indexPath.row].title
            detailsViewController.descriptionLabel.text = newsList[indexPath.row].newsDescription
            detailsViewController.setNavBarToTheView(with: newsList[indexPath.row].title )
            detailsViewController.configure(with: newsList[indexPath.row])
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
}
