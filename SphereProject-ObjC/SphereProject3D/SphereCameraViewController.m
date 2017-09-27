//
//  SphereCameraViewController.m
//  SphereProject3D
//
//  Created by Philip Williams on 3/24/14.
//  Copyright (c) 2014 Philip Williams. All rights reserved.
//

#import "SphereCameraViewController.h"
#import "SphereProjectLayer.h"
#import "SphereProjectScene.h"
#import "SphereCameraViewController.h"
#import "CC3EAGLView.h"
#import "SphereProjectAppDelegate.h"
#import "CC3UIViewController.h"

#define kAnimationFrameRate	60// Animation frame rate

@interface SphereCameraViewController (){
    
    SphereProjectLayer *cc3Layer;
    SphereProjectScene *resourceScene;
    CCDirector *director;
    CC3ControllableLayer* mainLayer;
    CC3UIViewController *cc3VC;
}

@end

@implementation SphereCameraViewController
@synthesize resourceName;

- (id)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //Makes Navigation and Status bars transparent
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [UIImage new];
    self.navigationController.navigationBar.translucent = YES;
    
    //Disables swiping from left to right on left edge of screen to go back to table of resources
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
}

- (void) viewWillLayoutSubviews {
    
    // Default texture format for PNG/BMP/TIFF/JPEG/GIF images.
    // It can be RGBA8888, RGBA4444, RGB5_A1, RGB565. You can change anytime.
    CCTexture2D.defaultAlphaPixelFormat = kCCTexture2DPixelFormat_RGBA8888;
    
    // Create the view controller for the 3D view.
    //viewController = [CC3DeviceCameraOverlayUIViewController new];
    //self.supportedInterfaceOrientations = UIInterfaceOrientationMaskAll;
    
    // Establish the type of CCDirector to use.
    // Try to use CADisplayLink director and if it fails (SDK < 3.1) use the default director.
    // This must be the first thing we do and must be done before establishing view controller.
    if( ! [CCDirector setDirectorType: kCCDirectorTypeNSTimer] )
        [CCDirector setDirectorType: kCCDirectorTypeDefault];
    
    director = CCDirector.sharedDirector;
    
    //if(![director runningScene]){
        
        NSLog(@"Director View 1 %@", director.openGLView);
        director.openGLView = self.view;
        NSLog(@"Director View 2 %@", director.openGLView);
        //director.animationInterval = (1.0f / kAnimationFrameRate);
        director.displayFPS = YES;
        [director enableRetinaDisplay: YES];
    //}
    
    // ******** START OF COCOS3D SETUP CODE... ********
    
    // Create the customized CC3Layer that supports 3D rendering and schedule it for automatic updates.
    cc3Layer = [SphereProjectLayer node];
    resourceScene = [SphereProjectScene alloc];
    resourceScene.resourceName = resourceName;
    [resourceScene initWithTag:nil withName:nil];
    cc3Layer.cc3Scene = resourceScene;
    [cc3Layer scheduleUpdate];
    
    NSLog(@"Resource Scene  %@", resourceScene);
    NSLog(@"Layer  %@", cc3Layer.self);
    NSLog(@"Layer Scene  %@", cc3Layer.cc3Scene);
    
    // Assign to a generic variable so we can uncomment options below to play with the capabilities
    mainLayer = cc3Layer;
    
    CCScene *scene = [CCScene node];
    [scene addChild: mainLayer];
    [director runWithScene:scene];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Navigation

-(void) viewWillDisappear:(BOOL)animated {
    if ([self.navigationController.viewControllers indexOfObject:self]==NSNotFound){
        [director end];
    }
    [super viewWillDisappear:animated];
}

@end
