//
//  InfoMovies.swift
//  StreamnationMovies
//
//  Created by Arthur Papailhau on 25/11/15.
//  Copyright © 2015 Arthur Papailhau. All rights reserved.
//

import Foundation
import CoreData


public class InfoMovies: NSManagedObject {

// Insert code here to add functionality to your managed object subclass
    @NSManaged var coverImage: NSData?
    @NSManaged var name: String?

}
