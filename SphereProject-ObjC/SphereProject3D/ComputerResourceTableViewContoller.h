//
//  ComputerResourceTableViewContoller.h
//  SphereProject3D
//
//  Created by project on 1/3/17.
//  Copyright © 2017 Willem Beeson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SRWebSocket.h"

@interface ComputerResourceTableViewController : UITableViewController <SRWebSocketDelegate>;

@property(strong, nonatomic) SRWebSocket *serverWebSocket;
@property(strong, nonatomic) UIActivityIndicatorView *activityIndicator;
@property(strong, nonatomic) NSMutableArray *computerResourceNameList;
@property(weak, nonatomic) IBOutlet UIImageView *imageView;

@end