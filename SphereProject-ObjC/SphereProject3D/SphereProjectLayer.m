/**
 *  SphereProjectLayer.m
 *  SphereProject
 *
 *  Created by Philip Williams on 1/14/14.
 *  Copyright __MyCompanyName__ 2014. All rights reserved.
 */

#import "SphereProjectLayer.h"
#import "SphereProjectScene.h"

#define socketURL @"ws://192.168.0.198:8080/VizardServer/DataPointServer/1"
#define panVelocityOffset 100
#define zoomVelocityOffset 20

@interface SphereProjectLayer() <SRWebSocketDelegate>

@property(strong, nonatomic) SRWebSocket *serverWebSocket;


@end

@implementation SphereProjectLayer

-(SphereProjectScene*) sphereScene { return (SphereProjectScene*) cc3Scene; }

- (void)dealloc {
    [_serverWebSocket close];
    [super dealloc];
}

/**
 * Override to set up your 2D controls and other initial state.
 * For more info, read the notes of this method on CC3Layer.
 */
-(void) initializeControls {
    
    NSLog(@"Layer Initialized");
    
    //Connect to Vizard Server
    [self connectToServer];
    
    //Enable Touch on the Layer For Use in the Scene
    self.isTouchEnabled = YES;
    
    UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panRecognized:)];
    panRecognizer.maximumNumberOfTouches = 2;
    [[[CCDirector sharedDirector] openGLView] addGestureRecognizer:panRecognizer];
    
    UIPinchGestureRecognizer *pinchRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchRecognized:)];
    [[[CCDirector sharedDirector] openGLView] addGestureRecognizer: pinchRecognizer];
    
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTapPause:)];
    doubleTap.numberOfTapsRequired = 2;
    [[[CCDirector sharedDirector] openGLView] addGestureRecognizer:doubleTap];
    
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTapVideoControlToggle:)];
    singleTap.numberOfTapsRequired = 1;
    [[[CCDirector sharedDirector] openGLView] addGestureRecognizer:singleTap];
    
    CGRect frame = CGRectMake(462.0, 600.0, 100.0, 10.0);
    slider = [[UISlider alloc] initWithFrame:frame];
    [slider setBackgroundColor:[UIColor clearColor]];
    slider.minimumValue = 0.0;
    slider.maximumValue = 50.0;
    slider.hidden = YES;
    slider.continuous = YES;
    slider.value = 25.0;
    [[[CCDirector sharedDirector] openGLView] addSubview:slider];
}

#pragma mark Updating layer

/**
 * Override to perform set-up activity prior to the scene being opened
 * on the view, such as adding gesture recognizers.
 *
 * For more info, read the notes of this method on CC3Layer.
 */
-(void) onOpenCC3Layer {}

/**
 * Override to perform tear-down activity prior to the scene disappearing.
 *
 * For more info, read the notes of this method on CC3Layer.
 */
-(void) onCloseCC3Layer {}

/**
 * The ccTouchMoved:withEvent: method is optional for the <CCTouchDelegateProtocol>.
 * The event dispatcher will not dispatch events for which there is no method
 * implementation. Since the touch-move events are both voluminous and seldom used,
 * the implementation of ccTouchMoved:withEvent: has been left out of the default
 * CC3Layer implementation. To receive and handle touch-move events for object
 * picking, uncomment the following method implementation.
 */

- (void)panRecognized:(UIPanGestureRecognizer *)rec
{
    CGPoint vel = [rec velocityInView:[[CCDirector sharedDirector] openGLView]];
    
    if(rec.numberOfTouches==2){
        
        vel.x /= panVelocityOffset;
        vel.y /=panVelocityOffset;
        
        [self.sphereScene moveCameraWithVelocity:vel.x withYVelocity:vel.y];
        
        if([self webSocketIsOpen]){
            [_serverWebSocket send: [NSString stringWithFormat:@"%f %f", self.sphereScene.cameraXrotation, self.sphereScene.cameraYrotation]];
            [_serverWebSocket send: [NSString stringWithFormat:@"%f z", [self.sphereScene getCameraHorizFOV]]];
        }
    }else{
        NSLog(@"Y: %f", fabs(rec.location.y));
        NSLog(@"X: %f", rec.location.x);
        if([self webSocketIsOpen]){
            [_serverWebSocket send: [NSString stringWithFormat:@"%f %f", self.sphereScene.cameraXrotation, self.sphereScene.cameraYrotation]];
            [_serverWebSocket send: [NSString stringWithFormat:@"%f z", [self.sphereScene getCameraHorizFOV]]];
            [_serverWebSocket send: [NSString stringWithFormat:@"%f %f p", [self.sphereScene getPointerY: rec.location.y],
                                                                           [self.sphereScene getPointerX: rec.location.x]]];
        }
    }
}

- (void)pinchRecognized:(UIPinchGestureRecognizer *)rec{
    
    NSLog(@"Vertical FOV: %f", [self.sphereScene getCameraVertFOV]);
    NSLog(@"Horizontal FOV: %f", [self.sphereScene getCameraHorizFOV]);
    
    [self.sphereScene zoomCamera: rec.velocity];
    if([self webSocketIsOpen]){
        [_serverWebSocket send: [NSString stringWithFormat:@"%f z", [self.sphereScene getCameraHorizFOV]]];
        [_serverWebSocket send: [NSString stringWithFormat:@"%f %f", self.sphereScene.cameraXrotation, self.sphereScene.cameraYrotation]];
    }
}

- (BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
    
    CGPoint location = [touch locationInView: [touch view]];
    location = [[CCDirector sharedDirector] convertToGL:location];

    if (CGRectContainsPoint([inButton boundingBox], location)) {
        [self.sphereScene moveCameraIn: 0.0];
    } else if (CGRectContainsPoint([outButton boundingBox], location)) {
        [self.sphereScene moveCameraOut: 0.0];
    }
    
    return YES;
}

- (void) handleDoubleTapPause:(UITapGestureRecognizer *)rec {

    [self.sphereScene pauseVideo];
}

- (void) handleSingleTapVideoControlToggle:(UITapGestureRecognizer *)rec{
    
    if(slider.hidden)
        slider.hidden = NO;
    else
        slider.hidden = YES;
    
    NSLog(@"Single Tap Detected");
}

- (void)ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event {

    if (timer != nil){
        [timer invalidate];
        timer = nil;
    }
}
-(void) connectToServer{
    
    _serverWebSocket.delegate = nil;
    [_serverWebSocket close];
    
    _serverWebSocket = [[SRWebSocket alloc] initWithURL:[NSURL URLWithString:socketURL]];
    _serverWebSocket.delegate = self;
    
    [_serverWebSocket open];
}

-(void)webSocket:(SRWebSocket *)webSocket didReceiveMessage:(id)message{

    [self.sphereScene updateOffsets: message];
}

-(BOOL)webSocketIsOpen{
    
    if(_serverWebSocket.readyState == SR_OPEN)
        return YES;
    return NO;
}

- (void) sendDataToServer:(NSString *) directionToSend{
    /*
    NSLog(@"%@", directionToSend);
    NSLog(@"%@", self.sphereScene);
    
    // Format a the String With Arguments to Be Send In the Request
    NSURL *urlToSend = [NSURL URLWithString: @"ws://10.0.0.12:8080/VizardServer/DataPointServer/1"];
                        //[NSString stringWithFormat:@"http://153.104.88.214:8080/Vizard/CheckDirectionWrite.jsp?direction=%@", directionToSend]];
    
    // Make the URL the
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:urlToSend];
    
    // Set up the Queue & Name
    NSOperationQueue *queue = [NSOperationQueue new];
    queue.name = @"Text Tune Queue";
    
    // This sends the Request to the Server (On a Background Thread) **We will process the Data Later When Our Web Application Returns JSON Response
    [NSURLConnection sendAsynchronousRequest:urlRequest queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            
        }];
    }];
     */
}

-(void) viewWillDisappear:(BOOL)animated {
    NSLog(@"Nav Called");
}

@end
