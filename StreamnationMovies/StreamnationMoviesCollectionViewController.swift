//
//  StreamnationMoviesCollectionViewController.swift
//  StreamnationMovies
//
//  Created by Arthur Papailhau on 24/11/15.
//  Copyright © 2015 Arthur Papailhau. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import AlamofireImage
import UIScrollView_InfiniteScroll
import CoreData


private let reuseIdentifier = "StreamnationMoviesCell"
private let sectionInsets = UIEdgeInsets(top: 50.0, left: 20.0, bottom: 50.0, right: 20.0)
private let showDetailsSegueIndentifier = "showDetails"

class StreamnationMoviesCollectionViewController: UICollectionViewController, NSFetchedResultsControllerDelegate {
    
    var sharedContext: NSManagedObjectContext {
        get {
            return CoreDataStackManager.sharedInstance().managedObjectContext
        }
    }
    
    lazy var fetchedResultsController: NSFetchedResultsController = {
        let fetchRequest = NSFetchRequest(entityName: "InfoMovies")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
            managedObjectContext: self.sharedContext,
            sectionNameKeyPath: nil,
            cacheName: nil)
        
        return fetchedResultsController
        
    }()
    
    var directory = [InfoMovie]()
    var newDirectory = [InfoMovie]()
    var directoryCoreData = [NSManagedObject]()
    var listProfileImageUrl = [String]()
    var indexPage: Int = 1
    var indexPerPage: Int = 10
    
    struct InfoMovie {
        var name:String!
        var cover:UIImage!
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView?.infiniteScrollIndicatorView = CustomInfiniteIndicator(frame: CGRectMake(0, 0, 24, 24))
        collectionView?.infiniteScrollIndicatorMargin = 20
        collectionView?.addInfiniteScrollWithHandler { [weak self] (scrollView) -> Void in
            self?.fetchData() {
                scrollView.finishInfiniteScroll()
            }
        }
        collectionView?.alwaysBounceVertical = true
        fetchData(nil)
        
        do {
            try fetchedResultsController.performFetch()
        } catch {}
        fetchedResultsController.delegate = self
        
        /*
        -_- CoreData -_-
        -_- If you want to try, and check that I use well a persistent system, you can remove the Data and run again
        -_- Use the function removeData() just above
        */
        //removeData()
    }
    
    
    
    private func fetchData(handler: (Void -> Void)?) {
        loadData(indexPage++)
    }
    
    
    func loadData(indexPage: Int){
        print("I load data")
    }
    
    func nameimagePresentInCoreData(name:String) -> Bool {
        let infoMoviesFetchRequest = NSFetchRequest(entityName: "InfoMovies")
        let primarySortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        
        infoMoviesFetchRequest.sortDescriptors = [primarySortDescriptor]
        
        let allMovies = (try! sharedContext.executeFetchRequest(infoMoviesFetchRequest)) as! [InfoMovies]
        
        for movie in allMovies {
            if (movie.name == name){
                return true
            }
        }
        return false
    }
    
    func deleteAll(){
        fetchedResultsController.fetchedObjects?.forEach({sharedContext.deleteObject($0 as! NSManagedObject)})
    }
    
    func saveNameAndCover(name:String, cover:UIImage){
        let newInfoMovie = NSEntityDescription.insertNewObjectForEntityForName("InfoMovies", inManagedObjectContext: sharedContext) as! InfoMovies
        newInfoMovie.coverImage = UIImageJPEGRepresentation(cover, 1)
        newInfoMovie.name = name
        do {
            CoreDataStackManager.sharedInstance().saveContext()
            collectionView?.reloadData()
        } catch _ {
        }
    }
    
    
    
    /*
    Function to remove data from CoreData
    It is useful if you want to check if CoreData works well
    (Remove and then reload)
    */
    func removeData () {
        directoryCoreData = [NSManagedObject]()
        let appDelegate =
        UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        let fetchRequest = NSFetchRequest(entityName:"InfoMovies")
        do {
            let fetchedResults = try managedContext.executeFetchRequest(fetchRequest) as? [NSManagedObject]
            if let results = fetchedResults {
                for info in results {
                    managedContext.deleteObject(info)
                }
                do {
                    try managedContext.save()
                } catch {
                    fatalError("Failure to save context: \(error)")
                }
                
            } else {
                print("Could not fetch")
            }
        } catch {
            fatalError("Failure to save context: \(error)")
        }
    }

    
    /*
    Function to send data to the detailsViewController with CoreData
    */
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == showDetailsSegueIndentifier {
            if let indexPath = collectionView?.indexPathForCell(sender as! UICollectionViewCell) {
                let detailsVC = segue.destinationViewController as! StreamnationMoviesDetailsViewController
                let infoMovie = fetchedResultsController.objectAtIndexPath(indexPath) as! InfoMovies
                let name = infoMovie.name
                let coverImage = UIImage(data: infoMovie.coverImage!)
                let imageView = UIImageView(image: coverImage)
                detailsVC.nameVariable = name
                detailsVC.imageVariable = imageView
            }
        }
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /*
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    }
    */
    
    // MARK: UICollectionViewDataSource
    
    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    
    
    /*
    Count the number of movies, source: CoreData
    If you don't want to use CoreData, use: return directory.count
    */
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return fetchedResultsController.fetchedObjects!.count
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! StreamnationCoverMoviesCollectionViewCell
        let infoMovies = fetchedResultsController.objectAtIndexPath(indexPath) as! InfoMovies
        cell.nameLabel?.text = infoMovies.name
        cell.coverImageView?.image = UIImage(data: infoMovies.coverImage!)
        cell.coverImageView.contentMode = .ScaleAspectFit
        return cell
    }

    // Return the size of my image
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSize(width: 100, height: 100)
    }
    
    // return spacing between cells, header and footer
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return sectionInsets
    }
    
    
    // MARK: UICollectionViewDelegate
    
    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(collectionView: UICollectionView, shouldHighlightItemAtIndexPath indexPath: NSIndexPath) -> Bool {
    return true
    }
    */
    
    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(collectionView: UICollectionView, shouldSelectItemAtIndexPath indexPath: NSIndexPath) -> Bool {
    return true
    }
    */
    
    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(collectionView: UICollectionView, shouldShowMenuForItemAtIndexPath indexPath: NSIndexPath) -> Bool {
    return false
    }
    
    override func collectionView(collectionView: UICollectionView, canPerformAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) -> Bool {
    return false
    }
    
    override func collectionView(collectionView: UICollectionView, performAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) {
    
    }
    */
    
}
