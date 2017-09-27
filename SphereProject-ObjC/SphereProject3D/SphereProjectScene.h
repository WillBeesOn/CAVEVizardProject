/**
 *  SphereProjectScene.h
 *  SphereProject
 *
 *  Created by Philip Williams on 1/14/14.
 *  Copyright __MyCompanyName__ 2014. All rights reserved.
 */

#import "CC3Scene.h"

//Create a CC3Scene
@interface SphereProjectScene : CC3Scene {

    //Create a Base Plane And Our Spherical Viewer Node
    CC3MeshNode *sphericalViewer;
    CC3PlaneNode *basePlane;
    CC3Camera* cam;
    CC3Texture* videoTexture;
    float vizardXDimension;
    float vizardYDimension;
    float offsetXDimensionFloor;
    float offsetYDimensionFloor;
    
    float cameraXlocation;
    float cameraYlocation;
    float cameraZlocation;
    float cameraZrotation;
}

@property (nonatomic, strong) NSString *resourceName;
@property (nonatomic) float cameraXrotation;
@property (nonatomic) float cameraYrotation;

//Method To Add Spherical Environment To Application
-(void) addSphericalViewerEnvironment;
-(BOOL) copyResourceToDocuments: (NSString*) fileName;

//Pauses the Video File
- (void) pauseVideo;

//Adjust Camera Positions
-(void) moveCameraWithVelocity: (CGFloat)xVelocity withYVelocity: (CGFloat)yVelocity;
-(void) zoomCamera: (CGFloat) velocity;
-(void)updateOffsets: (NSString*) vizardDimensions;
-(float) getPointerX: (CGFloat) x;
-(float) getPointerY: (CGFloat) y;
-(CGFloat) getCameraHorizFOV;
-(CGFloat) getCameraVertFOV;
/*
-(void) moveCameraIn: (CGFloat) velocity;
-(void) moveCameraOut: (CGFloat) velocity;
-(void) moveCameraRight: (CGFloat) val;
-(void) moveCameraUp: (CGFloat) val;
-(void) moveCameraDown: (CGFloat) val;
-(void) moveCameraLeft: (CGFloat) val;
*/

@end
