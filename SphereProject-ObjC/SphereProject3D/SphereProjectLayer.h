/**
 *  SphereProjectLayer.h
 *  SphereProject
 *
 *  Created by Philip Williams on 1/14/14.
 *  Copyright __MyCompanyName__ 2014. All rights reserved.
 */


#import "CC3Layer.h"
#import "SphereProjectScene.h"
#import "SRWebSocket.h"

/** A sample application-specific CC3Layer subclass. */
@interface SphereProjectLayer : CC3Layer {
    
    CCSprite *outButton;
    CCSprite *inButton;
    NSTimer *timer;
    UISlider *slider;

}

@property(nonatomic, strong) SphereProjectScene* sphereScene;
@end
