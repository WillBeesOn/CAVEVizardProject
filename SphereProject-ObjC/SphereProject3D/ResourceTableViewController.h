//
//  ResourceTableTableViewController.h
//  SphereProject3D
//
//  Created by Philip Williams on 3/24/14.
//  Copyright (c) 2014 Philip Williams. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SphereCameraViewController;

@interface ResourceTableViewController : UITableViewController {
    
    
}

@property (nonatomic, strong) SphereCameraViewController *sphereController;
@property (nonatomic, strong) NSArray *resourceNames;

@end
