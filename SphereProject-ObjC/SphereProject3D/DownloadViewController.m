//
//  DownloadViewController.m
//  SphereProject3D
//
//  Created by Philip Williams on 4/26/14.
//  Copyright (c) 2014 Philip Williams. All rights reserved.
//

#import "DownloadViewController.h"

@interface DownloadViewController ()

@end

@implementation DownloadViewController
@synthesize downloadTextField;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//*************************************************************************************
// Currently a Hardcoded Link to an Image, so It Does not Have to be Entered Every Time
// Can change to Allow the Link to be Entered into the 
//*************************************************************************************

-(IBAction) downloadVideoFromLink
{
    // Download the File on a Background Thread
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    
        // NSURL *url = [NSURL URLWithString:[downloadTextField text]];
        
        NSData *videoData = [NSData dataWithContentsOfURL:[NSURL URLWithString:@"http://www.ptgrey.com/products/ladybug3/samples/Uncompressed/ladybug_Panoramic_5400x2700_00000082.png"]];
        
        if (videoData != nil)
        {
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString *documentsDirectory = [paths objectAtIndex:0];
            
            NSString  *filePath = [NSString stringWithFormat:@"%@/%@", documentsDirectory, @"thefile.mp4"];
            
            // Saving is done on the Main Thread
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [videoData writeToFile:filePath atomically:YES];
                NSLog(@"File Saved !");
            });
        }
    });
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
