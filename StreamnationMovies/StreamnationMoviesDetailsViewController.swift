//
//  StreamnationMoviesDetailsViewController.swift
//  StreamnationMovies
//
//  Created by Arthur Papailhau on 24/11/15.
//  Copyright © 2015 Arthur Papailhau. All rights reserved.
//

import UIKit

class StreamnationMoviesDetailsViewController: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    var nameVariable:String!
    var imageVariable:UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        imageView.contentMode = .ScaleAspectFit
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        nameLabel.text = "Name: "+nameVariable
        imageView.image = imageVariable.image
    }
    
    /*
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    // Get the new view controller using segue.destinationViewController.
    // Pass the selected object to the new view controller.
    }
    */
    
}
