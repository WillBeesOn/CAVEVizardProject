/**
 *  SphereProjectScene.m
 *  SphereProject
 *
 *  Created by Philip Williams on 1/14/14.
 *  Copyright __MyCompanyName__ 2014. All rights reserved.
 */

#import "SphereProjectScene.h"
#import "CC3PODResourceNode.h"
#import "CC3ActionInterval.h"
#import "CC3MeshNode.h"
#import "CC3ParametricMeshNodes.h"
#import "CC3Camera.h"
#import "CC3Light.h"
#import "CC3Billboard.h"
#import <AVFoundation/AVFoundation.h>
#import <CoreMedia/CoreMedia.h>
#import <CoreVideo/CoreVideo.h>
#import <CoreImage/CoreImage.h>

#define kGlobeName @"Globe"
#define kGroundName	@"Ground"
#define panVelocityOffset 100
#define iPadWidth 1024.0
#define iPadHeight 768.0

@implementation SphereProjectScene
@synthesize resourceName;
@synthesize cameraYrotation;
@synthesize cameraXrotation;

-(void) dealloc {
	[super dealloc];
}

-(void) initializeScene {
    
    NSLog(@"Scene initialzized");
    
	// Create the camera, and set its default locations
	cam = [CC3Camera nodeWithName: @"Camera"];
    cameraXlocation = 0.0;
    cameraYlocation = 0.0;
    cameraZlocation = 0.0;
    cameraZrotation = 0.0;
    
    vizardXDimension = iPadWidth;
    vizardYDimension = iPadHeight;
    offsetXDimensionFloor = 0.0;
    offsetYDimensionFloor = 0.0;
    
	cam.location = cc3v(cameraXlocation, cameraYlocation, cameraZlocation);
    NSLog(@"cam%f", cam.location.x);
    NSLog(@"cam%f", cam.location.y);
    NSLog(@"cam%f", cam.location.z);
	[self addChild: cam];

	// Create a light, place it back and to the left at a specific
	// position (not just directional lighting), and add it to the scene
	CC3Light* lamp = [CC3Light nodeWithName: @"Lamp"];
	lamp.location = cc3v( -2.0, 0.0, 0.0 );
	lamp.isDirectionalOnly = NO;
	//[cam addChild: lamp];
	
    [self addSphericalViewerEnvironment];
 
	// Create OpenGL ES buffers for the vertex arrays to keep things fast and efficient,
	// and to save memory, release the vertex data in main memory because it is now redundant.
	[self createGLBuffers];
	[self releaseRedundantData];
	
    //Useful Message From Cocos3D
    LogCleanDebug(@"The structure of this scene is: %@", [self structureDescription]);
}

-(void) addSphericalViewerEnvironment {
    
	[self copyResourceToDocuments: resourceName];
    NSLog(@"SphereProject %@", resourceName);
	NSString* docDir = [NSHomeDirectory() stringByAppendingPathComponent: @"Documents"];
	NSString* texPath = [docDir stringByAppendingPathComponent: resourceName];
    
    NSString *fileType = [resourceName substringFromIndex: [resourceName length] - 3];
    NSLog(@"File Type %@", fileType);
	
	// Configure the Viewing Environment
	sphericalViewer = [CC3MeshNode nodeWithName: kGlobeName];
	[sphericalViewer populateAsSphereWithRadius:10.0f andTessellation: ccg(230, 230)];
	
    if ([fileType isEqualToString:@"png"]){
        videoTexture = [[CC3Texture alloc] initFromFile:texPath isVideo:NO];
    } else {
        videoTexture = [[CC3Texture alloc] initFromFile:texPath isVideo:YES];
    }
    
    NSLog(@"%@", videoTexture);
    
    sphericalViewer.texture = videoTexture;
	sphericalViewer.location = cc3v(0.0f, 0.0f, 0.0f);
    NSLog(@"%f", sphericalViewer.location.x);
    NSLog(@"%f", sphericalViewer.location.y);
    NSLog(@"%f", sphericalViewer.location.z);
    //sphericalViewer.location = cc3v(0.0, 0.0, -1000.0);
	//sphericalViewer.uniformScale = 1.0;
	//sphericalViewer.ambientColor = kCCC4FLightGray;		// Increase the ambient reflection
	sphericalViewer.isTouchEnabled = YES; // allow this node to be selected by touch events
    sphericalViewer.shouldCullBackFaces = NO;
    sphericalViewer.shouldCullFrontFaces = NO;
    sphericalViewer.shouldUseLighting = NO;
    
	// Rotate the globe
	[self addChild: sphericalViewer];
}

- (void) pauseVideo {
    
    [videoTexture pauseVideoTexture];
}

-(BOOL) copyResourceToDocuments: (NSString*) fileName {
	NSString* srcDir = [[NSBundle mainBundle] resourcePath];
	NSString* srcPath = [srcDir stringByAppendingPathComponent: fileName];
	NSString* dstDir = [NSHomeDirectory() stringByAppendingPathComponent: @"Documents"];
	NSString* dstPath = [dstDir stringByAppendingPathComponent: fileName];
	
	NSError* err = nil;
	NSFileManager* fileMgr = [NSFileManager defaultManager];
	[fileMgr removeItemAtPath: dstPath error: &err];
	if ( [fileMgr copyItemAtPath: srcPath toPath: dstPath error: &err] ) {
		LogRez(@"Copied %@ to %@", srcPath, dstPath);
		return YES;
	} else {
		LogError(@"Could not copy %@ to %@ because (%i) in %@: %@",
                 srcPath, dstPath, err.code, err.domain, err.userInfo);
		return NO;
	}
}

#pragma mark Updating custom activity

-(void) updateBeforeTransform: (CC3NodeUpdatingVisitor*) visitor {}
-(void) updateAfterTransform: (CC3NodeUpdatingVisitor*) visitor {}

#pragma mark Scene opening and closing

-(void) onOpen {}
-(void) onClose {}

#pragma mark Handling touch events

-(void) moveCameraWithVelocity: (CGFloat)xVelocity withYVelocity: (CGFloat)yVelocity{
    
    cameraYrotation -= xVelocity;
    cameraXrotation -= yVelocity;
    
    cam.rotation = cc3v(cameraXrotation, cameraYrotation, cameraZrotation);
}

-(void) zoomCamera: (CGFloat) velocity{
    
    if(isnan(cam.fieldOfView));
    else if(cam.fieldOfView - velocity < 20.0)
        cam.fieldOfView = 20.0;
    else if(cam.fieldOfView - velocity > 100.0)
        cam.fieldOfView = 100.0;
    else
        cam.fieldOfView -= velocity;
    
    if(isnan(cam.fieldOfView)){
        cam.fieldOfView = 45.0;
    }
}

-(CGFloat) getCameraHorizFOV{
    return cam.fieldOfView;
}

-(CGFloat) getCameraVertFOV{
    
    float horizFovRadians = cam.fieldOfView*(M_PI/180);
    return (180.0/M_PI)*(2 * atanf(tanf(horizFovRadians/2)*(760.0/1023.0)));
}

-(float) getPointerX: (CGFloat) x{

    NSLog(@"%f", (x+offsetXDimensionFloor)/vizardXDimension);

    //Hardcoded for CAVE
    return (((1.31445*x)+644.318766)/vizardXDimension);
    
    //Supposed to adjust to vizard window resolution
    return ((x+offsetXDimensionFloor)/vizardXDimension);
}

-(float) getPointerY: (CGFloat) y{
    
    //Personal computer use
    //return 1 - ((y+offsetYDimensionFloor)/vizardYDimension);
    
    //CAVE USE
    return 1 - (y/iPadHeight);
}

-(void)updateOffsets: (NSString*) vizardDimensions{
    
    NSLog(vizardDimensions);
    
    NSArray* dimensions = [vizardDimensions componentsSeparatedByString: @" "];
    
    offsetXDimensionFloor = ([[dimensions objectAtIndex: 0] intValue] - iPadWidth)/2;
    vizardXDimension = [[dimensions objectAtIndex: 0] intValue];
    
    offsetYDimensionFloor = ([[dimensions objectAtIndex:1] intValue] - iPadHeight)/2;
    vizardYDimension = [[dimensions objectAtIndex: 1] intValue];
    
    if(offsetXDimensionFloor < 0.0){
        
        offsetXDimensionFloor = 0.0;
        vizardXDimension = iPadWidth;
    }
    if(offsetYDimensionFloor < 0.0){
        
        offsetYDimensionFloor = 0.0;
        vizardYDimension = iPadHeight;
    }
}
/*
-(void) moveCameraIn: (CGFloat) velocity{
    
    if(velocity < 0);
    else if((velocity == NAN) || (cam.uniformScale + velocity > 5.0))
        cam.uniformScale = 5.0;
    else
        cam.uniformScale += velocity;
}

-(void) moveCameraOut: (CGFloat) velocity{

    if(velocity > 0);
    else if((velocity == NAN) || (cam.uniformScale + velocity < 0.5))
        cam.uniformScale = 0.5;
    else
        cam.uniformScale += velocity;
}

-(void) moveCameraLeft: (CGFloat) val {
    if (val < 0 && val > -100){
        val = .5;
    } else if (val < -100){
        val = .5;
    }
     
    cameraYrotation += val;
 
    
    cameraYrotation -= val;
    cam.rotation = cc3v(cameraXrotation, cameraYrotation, cameraZrotation);
}

-(void) moveCameraRight: (CGFloat) val {
    if (val > 0 && val < 100){
        val = .5;
    } else if (val > 100){
        val = .5;
    }
     
    cameraYrotation -= val;
    
    cameraYrotation -= val;
    cam.rotation = cc3v(cameraXrotation, cameraYrotation, cameraZrotation);
}

-(void) moveCameraUp: (CGFloat) val {
    if (val < 0 && val > -100){
        val = .5;
    } else if (val < -100){
        val = .5;
    }
    
    cameraXrotation += val;
    
    cameraXrotation -= val;
    cam.rotation = cc3v(cameraXrotation, cameraYrotation, cameraZrotation);
}

-(void) moveCameraDown: (CGFloat) val {
    if (val > 0 && val < 100){
        val = .5;
    } else if (val > 100){
        val = .5;
    }
    
    cameraXrotation -= val;
    
    cameraXrotation -= val;
    cam.rotation = cc3v(cameraXrotation, cameraYrotation, cameraZrotation);
}

-(void) rotateCameraLeft {
    
    cameraXrotation += 3.0;
    cam.rotation = cc3v(cameraXrotation, cameraYlocation, cameraZlocation);
}

-(void) rotateCameraRight {
    cameraXrotation -= 3.0;
    cam.location = cc3v(cameraXrotation, cameraYrotation, cameraZrotation);
}

-(void) rotateCameraUp {
    //cameraYlocation += 10.0;
    //cam.location = cc3v(cameraXlocation, cameraYlocation, cameraZlocation);
}

-(void) rotateCameraDown {
    //cameraYlocation -= 10.0;
}

-(void) touchEvent: (uint) touchType at: (CGPoint) touchPoint {
    
}

-(void) nodeSelected: (CC3Node*) aNode byTouchEvent: (uint) touchType at: (CGPoint) touchPoint {
    
}
*/
#pragma MARK SEND DATA TO SERVER

@end

