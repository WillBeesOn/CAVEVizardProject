//
//  ComputerResourceTableViewController.m
//  SphereProject3D
//
//  Created by project on 1/3/17.
//  Copyright © 2017 Willem Beeson. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ComputerResourceTableViewContoller.h"

#define socketURL @"ws://10.128.1.156:8080/VizardServer/DataPointServer/2"

@interface ComputerResourceTableViewController()

@property(nonatomic)char downloadMode;

@end

@implementation ComputerResourceTableViewController

-(void) viewDidLoad{
    
    [super viewDidLoad];
    
    //Restricts user control while data is loading
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.scrollEnabled = NO;
    
    //Images in preview view will maintain aspect ratio after downloading
    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    
    //Setup and start activity indicator
    _activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle: UIActivityIndicatorViewStyleWhiteLarge];
    _activityIndicator.center = CGPointMake(512, 320);
    [self.view addSubview: _activityIndicator];
    [_activityIndicator startAnimating];
    
    //Initialize array for list of file names from computer
    _computerResourceNameList = [[NSMutableArray alloc] init];
    
    [self connectToServer];

    //Wait for connection to be open on background thread and then
    //send message to retreive list of image files names from computer
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{

        while(![self webSocketIsOpen]){}
        [_serverWebSocket send: [NSString stringWithFormat: @"td"]];
    });
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark SocketFunctions

-(void) connectToServer{
    
    _serverWebSocket.delegate = nil;
    [_serverWebSocket close];
    
    _serverWebSocket = [[SRWebSocket alloc] initWithURL:[NSURL URLWithString:socketURL]];
    _serverWebSocket.delegate = self;
    
    [_serverWebSocket open];
}

-(void)webSocket:(SRWebSocket *)webSocket didReceiveMessage:(id)message{
    
    //If the message is bytes (image/video resources)
    if([message class]==NSClassFromString(@"OS_dispatch_data")){
        NSLog(@"---Data message received---");
        if(self.downloadMode=='d')
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                [self saveImage:message];
            });
        else if(self.downloadMode=='p')
            [self setPreviewImage:message];
    }
    //If server is finished processing all file names in resource directory
    else if([message isEqualToString:[NSString stringWithFormat:@"done"]]){
        [self.tableView reloadData];
        [_activityIndicator stopAnimating];
        self.tableView.scrollEnabled = YES;
    }
    //Adds names of available computer resources to array
    else
        [_computerResourceNameList addObject:message];
}

-(BOOL)webSocketIsOpen{
    
    if(_serverWebSocket.readyState == SR_OPEN)
        return YES;
    return NO;
}

#pragma mark ImageFunctions

-(void)saveImage:(id)message{
    
    NSLog(@"Downloading...");
    
    [self.tableView reloadData];
}

-(void)setPreviewImage:(id)message{
    
    //Sets up data and buffer to convert to NSData which is converted to UIImage
    const void *buffer = NULL;
    size_t size = 0;
    dispatch_data_t messageDataFile = dispatch_data_create_map(message, &buffer, &size);
    
    NSData *imageData = [[NSData alloc] initWithBytes:buffer length:size];
    UIImage *resource = [[UIImage alloc] initWithData:imageData];
    
    self.imageView.image = resource;
    
    //Restore interactivity to user
    [_activityIndicator stopAnimating];
    self.tableView.scrollEnabled = YES;
    [self.tableView setUserInteractionEnabled:YES];
    [self.tableView reloadData];
}

#pragma mark - Table view data source

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_computerResourceNameList count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //Creates table cells, sets their text labels to names of resources, and adds to table
    static NSString *cellIdentifier = @"ComputerResourceCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if(!cell)
        cell = [[UITableViewCell alloc] initWithStyle: UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
    
    NSArray *cellSubviews = [cell subviews];
    
    int i;
    for(i=0; i<[cellSubviews count]; i++)
        if([cellSubviews[i] class]==NSClassFromString(@"UIActivityIndicatorView"))
            break;
    if(i==[cellSubviews count]){
        UIActivityIndicatorView *cellActivityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle: UIActivityIndicatorViewStyleGray];
        cellActivityIndicator.center = CGPointMake(950, 22);
        [cell addSubview: cellActivityIndicator];
    }
    cell.textLabel.text = [_computerResourceNameList objectAtIndex:indexPath.row];
    
    return cell;
}

-(NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    //Creates action upon swiping left. Both actions restrict user interactivity as download is being processed
    //This is meant to download the image and save it to the iPad.
    UITableViewRowAction *downloadAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:@"Download" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath){
        
        NSArray *cellSubviews = [[self.tableView cellForRowAtIndexPath:indexPath] subviews];
        int i;
        for(i=0; i<[cellSubviews count]; i++)
            if([cellSubviews[i] class]==NSClassFromString(@"UIActivityIndicatorView"))
                break;

        self.downloadMode = 'd';
        [[[self.tableView cellForRowAtIndexPath:indexPath] subviews][i] setHidden:NO];
        [[[self.tableView cellForRowAtIndexPath:indexPath] subviews][i] startAnimating];
        [self.tableView setEditing:NO animated:YES];

        [_serverWebSocket send: [NSString stringWithFormat:@"d %@", [_computerResourceNameList objectAtIndex:indexPath.row]]];
    }];
    downloadAction.backgroundColor = [UIColor colorWithRed:0.0f/255.0f green:122.0f/255.0f blue:255.0f/255.0f alpha:1.0f];
    
    //This is meant to download the image and give a preview of it in the table view.
    UITableViewRowAction *previewAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:@"Preview" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath){
        
        self.downloadMode = 'p';
        
        [_activityIndicator startAnimating];
        self.tableView.scrollEnabled = NO;
        [self.tableView setEditing:NO animated:YES];
        [self.tableView setUserInteractionEnabled:NO];
        [self.tableView reloadData];
        
        [_serverWebSocket send: [NSString stringWithFormat:@"d %@", [_computerResourceNameList objectAtIndex:indexPath.row]]];
    }];
    previewAction.backgroundColor = [UIColor colorWithRed:34.0f/255.0f green:139.0f/255.0f blue:34.0f/255.0f alpha:1.0f];
    
    return @[downloadAction, previewAction];
}

-(void)didMoveToParentViewController:(UIViewController *)parent{
    
    //When the back button is pressed, the socket is closed
    if(![parent isEqual:self.parentViewController])
        [_serverWebSocket close];
}
@end