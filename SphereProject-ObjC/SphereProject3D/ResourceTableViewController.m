//
//  ResourceTableTableViewController.m
//  SphereProject3D
//
//  Created by Philip Williams on 3/24/14.
//  Copyright (c) 2014 Philip Williams. All rights reserved.
//

#import "ResourceTableViewController.h"
#import "SphereCameraViewController.h"

@interface ResourceTableViewController ()

@end

@implementation ResourceTableViewController
@synthesize sphereController = _sphereController;
@synthesize resourceNames;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    self.tableView.allowsMultipleSelectionDuringEditing = NO;
    
    // Loads the Resources
    NSLog(@"Resources Loaded");

    // Loads the Documents Directory
    NSString * documentsPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    NSError  * error;
    NSArray  * fileNames = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:documentsPath error:&error];
    
    // Set the Cell Names to the Files in the Documents Directory
    resourceNames = [[NSArray alloc] initWithArray:fileNames];
    
    // Reloads the Table
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [resourceNames count];
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPat{
    
    if(editingStyle==UITableViewCellEditingStyleDelete){
        
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Delegate Method for the Cells
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ResourceCell" forIndexPath:indexPath];
    cell.textLabel.text = [resourceNames objectAtIndex:indexPath.row];
    
    return cell;
}

#pragma mark - Navigation
//******************************
// Preparation Before Navigation
//******************************

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    _sphereController = [segue destinationViewController];
    
    NSLog(@"String %@", [resourceNames objectAtIndex:[self.tableView indexPathForSelectedRow].row]);
    _sphereController.resourceName = [resourceNames objectAtIndex:[self.tableView indexPathForSelectedRow].row];
}

@end
