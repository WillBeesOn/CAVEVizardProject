/**
 *  SphereProjectAppDelegate.m
 *  SphereProject
 *
 *  Created by Philip Williams on 1/14/14.
 *  Copyright __MyCompanyName__ 2014. All rights reserved.
 */

#import "SphereProjectAppDelegate.h"

@implementation SphereProjectAppDelegate

@synthesize window = _window;
// @synthesize menuViewController = _menuViewController;

-(void) dealloc {
	[super dealloc];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Default texture format for PNG/BMP/TIFF/JPEG/GIF images.
    // It can be RGBA8888, RGBA4444, RGB5_A1, RGB565. You can change anytime.
    CCTexture2D.defaultAlphaPixelFormat = kCCTexture2DPixelFormat_RGBA8888;
    
    // Create the view controller for the 3D view.
    // viewController = [CC3DeviceCameraOverlayUIViewController new];
    // self.supportedInterfaceOrientations = UIInterfaceOrientationMaskAll;
    
    // Establish the type of CCDirector to use.
    // Try to use CADisplayLink director and if it fails (SDK < 3.1) use the default director.
    // This must be the first thing we do and must be done before establishing view controller.
    // if( ! [CCDirector setDirectorType: kCCDirectorTypeDisplayLink] )
    //  [CCDirector setDirectorType: kCCDirectorTypeDefault];
    
    // CCDirector *director = CCDirector.sharedDirector;
    // _menuViewController = [CC3UIViewController new];
    // _menuViewController.supportedInterfaceOrientations = UIInterfaceOrientationMaskAll;
	// _menuViewController.viewPixelSamples = 1;
    
    // director.openGLView = _menuViewController.view;
    
    [self copyDefaultResourceFromBundleSourceName:@"DefaultImage.png" toDocumentFileName:@"DefaultImage.png"];
    [self copyDefaultResourceFromBundleSourceName:@"Jambo.mov" toDocumentFileName:@"Jambo.mov"];
    
    return YES;
}

-(void) applicationDidFinishLaunching: (UIApplication*) application {
    
}

/** Resume the cocos3d/cocos2d action. */
-(void) resumeApp { [CCDirector.sharedDirector resume]; }

-(void) applicationDidBecomeActive: (UIApplication*) application {
	
	 // Workaround to fix the issue of drop to 40fps on iOS4.X on app resume.
	 // Adds short delay before resuming the app.
	[NSTimer scheduledTimerWithTimeInterval: 0.5f
									 target: self
								   selector: @selector(resumeApp)
								   userInfo: nil
									repeats: NO];
	
	// If dropping to 40fps is not an issue, remove above, and uncomment the following to avoid delay.
	[self resumeApp];
}

-(void) applicationDidReceiveMemoryWarning: (UIApplication*) application {
	[CCDirector.sharedDirector purgeCachedData];
}

-(void) applicationDidEnterBackground: (UIApplication*) application {
	[CCDirector.sharedDirector stopAnimation];
}

-(void) applicationWillEnterForeground: (UIApplication*) application {
	[CCDirector.sharedDirector startAnimation];
}

-(void)applicationWillTerminate: (UIApplication*) application {
	[CCDirector.sharedDirector.openGLView removeFromSuperview];
	[CCDirector.sharedDirector end];
}

-(void) applicationSignificantTimeChange: (UIApplication*) application {
	[CCDirector.sharedDirector setNextDeltaTimeZero: YES];
}

//*******************************************************
// Moves our Default Resources to the Documents Directory
// This Makes Them Editable
//*******************************************************

-(BOOL) copyDefaultResourceFromBundleSourceName:(NSString *)bundleSourceName toDocumentFileName:(NSString *)documentFileName {
    
    // Bundle Source Name
	NSString* srcDir = [[NSBundle mainBundle] resourcePath];
	NSString* srcPath = [srcDir stringByAppendingPathComponent:bundleSourceName];
	
    // File Name
    NSString* dstDir = [NSHomeDirectory() stringByAppendingPathComponent: @"Documents"];
	NSString* dstPath = [dstDir stringByAppendingPathComponent:documentFileName];
	
	NSError* err = nil;
	NSFileManager* fileMgr = [NSFileManager defaultManager];
	[fileMgr removeItemAtPath: dstPath error: &err];
	
    if ([fileMgr copyItemAtPath: srcPath toPath: dstPath error: &err] ) {
		return YES;
	} else {
		return NO;
	}
}

@end
