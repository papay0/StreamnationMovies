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

class StreamnationMoviesCollectionViewController: UICollectionViewController {
    
    var directory = [InfoMovies]()
    var newDirectory = [InfoMovies]()
    var directoryCoreData = [NSManagedObject]()
    var listProfileImageUrl = [String]()
    var indexPage: Int = 1
    var indexPerPage: Int = 10
    
    struct InfoMovies {
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

    
    
    /*  Function to check if a name is already in CoreData
        If it is not, I will download the picture
    */
    func nameImagePresentInCoreData(name:String) -> Bool {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        let fetchRequest = NSFetchRequest(entityName:"InfoMovies")
        do {
            let fetchedResults = try managedContext.executeFetchRequest(fetchRequest) as? [NSManagedObject]
            if let results = fetchedResults {
                for info in results {
                    let nameCoreData = info.valueForKey("name") as! String
                    if (nameCoreData == name){
                        return true
                    }
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
        return false
    }
    
    /* 
        Function to save the name and the cover picture in CoreData
    */
    func saveNameAndCover(name: String, cover:UIImage) {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        let entity =  NSEntityDescription.entityForName("InfoMovies",
            inManagedObjectContext:managedContext)
        let infoMovie = NSManagedObject(entity: entity!,
            insertIntoManagedObjectContext: managedContext)
        
        infoMovie.setValue(name, forKey: "name")
        infoMovie.setValue(UIImageJPEGRepresentation(cover, 1), forKey: "coverImage")
        
        do {
            try managedContext.save()
            directoryCoreData.append(infoMovie)
        } catch let error as NSError  {
            print("Could not save \(error), \(error.userInfo)")
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
        I load my data from CoreData
    */
    override func viewWillAppear(animated: Bool) {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        let fetchRequest = NSFetchRequest(entityName: "InfoMovies")
        do {
            let results =
            try managedContext.executeFetchRequest(fetchRequest)
            directoryCoreData = results as! [NSManagedObject]
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
    }

    
    /*
        Function to send data to the detailsViewController
        It is useful if you don't want to use CoreData
    */
    /*
        override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
            if segue.identifier == showDetailsSegueIndentifier {
                if let indexPath = collectionView?.indexPathForCell(sender as! UICollectionViewCell) {
                    let detailsVC = segue.destinationViewController as! StreamnationMoviesDetailsViewController
                    detailsVC.nameVariable = directory[indexPath.row].name
                    detailsVC.imageVariable = directory[indexPath.row].cover
                }
            }
        }
    */
    
    
    /*
        Function to send data to the detailsViewController with CoreData
    */
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == showDetailsSegueIndentifier {
            if let indexPath = collectionView?.indexPathForCell(sender as! UICollectionViewCell) {
                let detailsVC = segue.destinationViewController as! StreamnationMoviesDetailsViewController
                let infoMovie = directoryCoreData[indexPath.row]
                let name = infoMovie.valueForKey("name") as! String
                let coverImage = UIImage(data: infoMovie.valueForKey("coverImage") as! NSData)
                detailsVC.nameVariable = name
                detailsVC.imageVariable = coverImage
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
        return directoryCoreData.count
    }
    
    /*
        Function to set information to the cell (without CoreData)
    
    */
    /*
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! StreamnationCoverMoviesCollectionViewCell
    
    let coverImage = directory[indexPath.row].cover
    cell.coverImageView.image = coverImage
    cell.coverImageView.layer.borderWidth = 0.3
    cell.nameLabel.text = directory[indexPath.row].name
    return cell
    }
    */
    
    
    /*
        Function to set information to the cell (with CoreData)
    */
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! StreamnationCoverMoviesCollectionViewCell
        
        let infoMovie = directoryCoreData[indexPath.row]
        let name = infoMovie.valueForKey("name") as! String
        let coverImage = UIImage(data: infoMovie.valueForKey("coverImage") as! NSData)
        cell.coverImageView.image = coverImage
        cell.coverImageView.layer.borderWidth = 0.3
        cell.nameLabel.text = name
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
