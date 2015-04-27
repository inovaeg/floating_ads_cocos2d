//
//  BubbleAdWorld.m
//  Penguin
//
//  Created by Inova5 on 4/22/15.
//  Copyright 2015 __MyCompanyName__. All rights reserved.
//

#import "Box2D.h"
#import "BubbleAd.h"
#import "BubbleAd.h"
#import "BubbleAdWorld.h"
#import "BubbleAdsManager.h"
#import "MyContactListener.h"

//#define BUBBLE_RADIUS 160
#define PTM_RATIO 32
#define BUBBLE_SPEED 0.7f
#define BUBBLES_COUNT 5
#define BUBBLES_NEW_ANGLE_DIFF 70 // angle difference between new and old bubble velocity
#define SHADOWVIEW_TIME 0.33f

#define RADIANS_TO_DEGREES(radians) ((radians) * (180.0 / M_PI))
#define DEGREES_TO_RADIANS(angle) ((angle) / 180.0 * M_PI)

@interface BubbleAdWorld()
{
    b2World *_world;
    b2Body * selectedNode;
    BOOL isClick ;
    NSTimeInterval _lastUpdateTimeInterval;
    b2MouseJoint *_mouseJoint;
    CGSize _winSize;
    b2Body *groundBody;
    LevelHelperLoader *layerLoader;
    MyContactListener *_contactListener;
    NSInteger bubblesCount;
    CGFloat bubbleScale;
}


@end

@implementation BubbleAdWorld

static inline b2Vec2 getRandomVelocity(b2Vec2 oldVelocity){
    CGFloat angle = arc4random() % (BUBBLES_NEW_ANGLE_DIFF*2);
    angle -= BUBBLES_NEW_ANGLE_DIFF;
    
    CGFloat oldAngle = RADIANS_TO_DEGREES(atan2f(oldVelocity.y, oldVelocity.x));
    
    CGFloat newAngle = oldAngle + angle;
    
    CGFloat y = sinf(DEGREES_TO_RADIANS(newAngle))* BUBBLE_SPEED;
    CGFloat x = cosf(DEGREES_TO_RADIANS(newAngle))* BUBBLE_SPEED;
    
    return b2Vec2(x, y);
}

-(CGPoint)geRandomPointAtScreenBoundriesForBubbleSize:(CGSize)bubbleSize{
    
    CGFloat minX = bubbleSize.width/2;
    CGFloat maxX = _winSize.width - bubbleSize.width/2;
    CGFloat minY = bubbleSize.height/2;
    CGFloat maxY = _winSize.height - bubbleSize.height/2;
    
    return [self getRandomPointForMinX:minX maxX:maxX minY:minY maxY:maxY];
}

-(CGPoint)getRandomPointForMinX:(CGFloat)minX maxX:(CGFloat)maxX minY:(CGFloat)minY maxY:(CGFloat)maxY{
    
    CGFloat x = arc4random() % (NSInteger)(maxX - minX);
    CGFloat y = arc4random() % (NSInteger)(maxY - minY);
    return CGPointMake(x+minX, y+minY);
}

-(id)initWithDelegate:(id)delegate{
    if ((self=[super init])) {
        _delegate = delegate;
        _winSize = [CCDirector sharedDirector].winSize;
        // Create a world
        b2Vec2 gravity = b2Vec2(0.0f, -0.0f);
        _world = new b2World(gravity);
        
        self.touchEnabled = YES;
        self.touchSwallow = YES;
        
        layerLoader = [[LevelHelperLoader alloc] initWithContentOfFile:@"Bubble Ad Scene"];
        [layerLoader addSpritesToLayer:self];
        
        // Create contact listener
        _contactListener = new MyContactListener();
        _world->SetContactListener(_contactListener);
        
        bubbleScale = (_winSize.width > _winSize.height)? _winSize.width / 1024 : _winSize.height / 1024;
        bubblesCount = ceil( BUBBLES_COUNT * bubbleScale );
        
//        for(int i=0; i < 5; i++){
//            [self createBubbleWithPosition: [self geRandomPointAtScreenBoundriesForBubbleSize:CGSizeMake(280, 280)] ];
//        }
        
        b2_velocityThreshold;
        // Create edges around the entire screen
        b2BodyDef groundBodyDef;
        groundBodyDef.position.Set(0,0);
        
        groundBody = _world->CreateBody(&groundBodyDef);
        b2EdgeShape groundEdge;
        b2FixtureDef boxShapeDef;
        boxShapeDef.shape = &groundEdge;
        boxShapeDef.density = 5.0f;
        boxShapeDef.friction = 0.0f;
        boxShapeDef.restitution = 1.0f;
        
        //wall definitions
        groundEdge.Set(b2Vec2(0,0), b2Vec2(_winSize.width/PTM_RATIO, 0));
        groundBody->CreateFixture(&boxShapeDef);
        
        groundEdge.Set(b2Vec2(0,0), b2Vec2(0,_winSize.height/PTM_RATIO));
        groundBody->CreateFixture(&boxShapeDef);
        
        groundEdge.Set(b2Vec2(0, _winSize.height/PTM_RATIO), b2Vec2(_winSize.width/PTM_RATIO, _winSize.height/PTM_RATIO));
        groundBody->CreateFixture(&boxShapeDef);
        
        groundEdge.Set(b2Vec2(_winSize.width/PTM_RATIO, _winSize.height/PTM_RATIO),b2Vec2(_winSize.width/PTM_RATIO, 0));
        groundBody->CreateFixture(&boxShapeDef);
        
        [self enableAdBubbleScene];
        [self scheduleUpdate];
    }
    return self;
}

- (void)enableAdBubbleScene{
    self.activeState = true;
    [[BubbleAdsManager sharedManager] attachSceneBubbleAdWorld:self];
    for(NSInteger i = 0 ; i < bubblesCount; i++){
        [[BubbleAdsManager sharedManager] requestAd];
    }
}

-(void)createBubbleWithPosition:(CGPoint)point withAd:(AdFactory*) ad{
    
    // Create sprite and add it to the layer
    b2Body *_body;
    BubbleAd *_ball = [(BubbleAd*)[BubbleAd alloc] initWithSprite:[layerLoader createSpriteWithName:@"bubble_movement_0" fromSheet:@"BubbleMovement" fromSHFile:@"AdBubbleAssetsSpriteSheet"] ];
    _ball.ad = ad;
    _ball.sprite.scale = 2;
    _ball.sprite.position = point;
    _ball.sprite.tag = 1;
    [_ball startNormalAnimation];
//    [self addChild:_ball];
    
    // Create ball body and shape
    b2BodyDef ballBodyDef;
    ballBodyDef.type = b2_dynamicBody;
    ballBodyDef.position.Set(point.x/PTM_RATIO, point.y/PTM_RATIO);
    ballBodyDef.userData = _ball;
    ballBodyDef.fixedRotation = true;
    _body = _world->CreateBody(&ballBodyDef);
    
    b2CircleShape circle;
    NSLog(@"%f", ( _ball.sprite.boundingBox.size.width / 2 - 10 * bubbleScale ) );
    circle.m_radius = ( _ball.sprite.boundingBox.size.width / 2 - 10 * bubbleScale )/PTM_RATIO;
    
    b2FixtureDef ballShapeDef;
    ballShapeDef.shape = &circle;
    ballShapeDef.density = 5.0f;
    ballShapeDef.friction = 0.0f;
    ballShapeDef.restitution = 1.0f;
    _body->CreateFixture(&ballShapeDef);
    
    b2Vec2 force = getRandomVelocity( _body->GetLinearVelocity() );
    _body->SetLinearVelocity(force);
    
    [self addAdImage:[ad getImage] toBubble:_ball];
    [_ball fadeIn];
}

-(void)update:(ccTime)delta
{
    _lastUpdateTimeInterval+=delta;
    _world->Step(delta, 10, 10);
    for(b2Body *b = _world->GetBodyList(); b; b=b->GetNext()) {
        if (b->GetUserData() != NULL) {
            BubbleAd *ballData = (BubbleAd *)b->GetUserData();
            ballData.sprite.position = ccp(b->GetPosition().x * PTM_RATIO,
                                    b->GetPosition().y * PTM_RATIO);
            ballData.sprite.rotation = -1 * CC_RADIANS_TO_DEGREES(b->GetAngle());
            if(_lastUpdateTimeInterval >= 1){
                b2Vec2 force = getRandomVelocity(b->GetLinearVelocity() );
                b->SetLinearVelocity(force);
//                b2Vec2 force = b2Vec2(-30,30);
//                b->SetAwake(false);
//                b->ApplyLinearImpulse( force , b->GetPosition() );
            }
        }
    }
    
    if(_lastUpdateTimeInterval >= 1){
        _lastUpdateTimeInterval = 0;
    }
    
    //check contacts
    std::vector<b2Body *>toDestroy;
    std::vector<MyContact>::iterator pos;
    for (pos=_contactListener->_contacts.begin();
         pos != _contactListener->_contacts.end(); ++pos) {
        MyContact contact = *pos;
        
        b2Body *bodyA = contact.fixtureA->GetBody();
        b2Body *bodyB = contact.fixtureB->GetBody();
        if (bodyA->GetUserData() != NULL) {
            BubbleAd *spriteA = (BubbleAd *) bodyA->GetUserData();
            [spriteA startCollisionAnimation];
        }
        if(bodyB->GetUserData() != NULL){
            BubbleAd *spriteB = (BubbleAd *) bodyB->GetUserData();
            [spriteB startCollisionAnimation];
        }
    }
}

-(void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    isClick = YES;
    for( UITouch *touch in touches ) {
        CGPoint location = [touch locationInView: [touch view]];
        
        location = [[CCDirector sharedDirector] convertToGL: location];
        b2Vec2 locationWorld = b2Vec2(location.x/PTM_RATIO, location.y/PTM_RATIO);
        
        // go through every single b2Body
        for(b2Body *b = _world->GetBodyList(); b; b=b->GetNext()) {
            if (b->GetUserData() != NULL) {
                b2Fixture *bf = b->GetFixtureList();
                // check which ball is tapped
                if (bf->TestPoint(locationWorld)) {
                    bf->SetSensor(true); // to disable colliding with other bodies
                    b2Body* body = bf->GetBody();
                    b2MouseJointDef md;
                    md.bodyA = groundBody;
                    md.bodyB = body;
                    md.target = locationWorld;
                    md.collideConnected = true;
                    md.maxForce = 1000.0f * body->GetMass();
                    
                    _mouseJoint = (b2MouseJoint *)_world->CreateJoint(&md);
                    body->SetAwake(true);
                }
            }        
        }
    }
}

-(void)ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    isClick = NO;
    if (_mouseJoint == NULL) return;
    
    UITouch *myTouch = [touches anyObject];
    CGPoint location = [myTouch locationInView:[myTouch view]];
    location = [[CCDirector sharedDirector] convertToGL:location];
    b2Vec2 locationWorld = b2Vec2(location.x/PTM_RATIO, location.y/PTM_RATIO);
    
    _mouseJoint->SetTarget(locationWorld);
}

- (void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    if (_mouseJoint) {
        if(isClick){
            b2Body *b = _mouseJoint->GetBodyB();
            BubbleAd *spriteA = (BubbleAd *) b->GetUserData();
            [spriteA startBurstAnimation];
            _world->DestroyJoint(_mouseJoint);
            _world->DestroyBody(b);
        }else{
            b2Body *b = _mouseJoint->GetBodyB();
            b2Fixture *bf = b->GetFixtureList();
            bf->SetSensor(false); // enable colliding with other bodies
            b2Vec2 force = getRandomVelocity( b->GetLinearVelocity() );
            b->SetLinearVelocity(force);
            _world->DestroyJoint(_mouseJoint);
        }
        _mouseJoint = NULL;
    }else{
        if(_world->GetBodyCount() != 1){ //No bubbles are shown
            self.activeState = false;
            for(b2Body *b = _world->GetBodyList(); b; b=b->GetNext()) {
                if (b->GetUserData() != NULL) {
                    BubbleAd *ballData = (BubbleAd *)b->GetUserData();
                    [ballData fadeoutAndDestroy];
                }
                _world->DestroyBody(b);
            }
            [self fadeOutLayerAndEnableTouch];
        }
    }
}

-(void)disableAdBubbleScene{
    self.activeState = false;
    for(b2Body *b = _world->GetBodyList(); b; b=b->GetNext()) {
        if (b->GetUserData() != NULL) {
            BubbleAd *ballData = (BubbleAd *)b->GetUserData();
            [ballData.sprite removeFromParentAndCleanup:YES];
        }
        _world->DestroyBody(b);
    }
    [self enableDelegateTouchAndRemoveFromParent];
}

//Get Ad Image
-(UIImage *)getCircleImage:(UIImage *)image withRadius:(CGFloat)radius{
    // create the image with rounded corners
    CGFloat diameter = radius * 2;
    
    CALayer *imageLayer = [CALayer layer];
    imageLayer.frame = CGRectMake(0, 0, diameter, diameter);
    imageLayer.contents = (id) image.CGImage;
    
    imageLayer.backgroundColor=[[UIColor clearColor] CGColor];
    imageLayer.cornerRadius = radius;
    imageLayer.borderWidth = 1.5f;
    imageLayer.masksToBounds = YES;
    imageLayer.borderColor=[[UIColor whiteColor] CGColor];
    
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(diameter,diameter), NO, 0);
    [imageLayer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *roundedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return roundedImage;
}

-(void)addAdImage:(UIImage *)adImage toBubble:(BubbleAd *)bubble{
    //    CGFloat adImagePadding = ADS_IMAGE_PADDING;
    CGFloat minSize = adImage.size.height;
    if(minSize > adImage.size.width){
        minSize = adImage.size.width;
    }
    UIImage * circleAdImage = [self getCircleImage:adImage withRadius:bubble.sprite.boundingBox.size.width / 8];
//    bubble.spriteAd = [LHSprite spriteWithCGImage:circleAdImage.CGImage key:nil];
    
    CCTexture2D *tex = [[CCTexture2D alloc] initWithCGImage:circleAdImage.CGImage resolutionType:kCCResolutionUnknown];
    bubble.spriteAd = [LHSprite spriteWithTexture:tex];
    
    [bubble.spriteAd setAnchorPoint:CGPointMake(-0.5f, -0.5f)];
    [bubble.spriteAd setPosition:CGPointMake(0, 0)];
    [bubble.sprite addChild:bubble.spriteAd];
}

-(void)createBubbleWithAd:(AdFactory*)ad{
    if(!self.activeState)return;
    if(_world->GetBodyCount() >= bubblesCount + 1) return; // 1 is the number of borders bodies. I'm using one body for the borders

    CGPoint bubbleCenter = [self geRandomPointAtScreenBoundriesForBubbleSize:CGSizeMake(280, 280)];
    if(self.opacity == 0){
        [self fadeInLayer];
    }
    [self createBubbleWithPosition:bubbleCenter withAd:ad];
    [_delegate adDisableTouch];
    
}

-(void)fadeOutLayerAndEnableTouch{
    id delayTimeAction = [CCDelayTime actionWithDuration:BUBBLE_FADEOUT_TIME];
    id fadeOut = [CCFadeTo actionWithDuration:SHADOWVIEW_TIME opacity:0];
    id myCallFunc = [CCCallFunc actionWithTarget:self selector:@selector(enableDelegateTouchAndRemoveFromParent)];
    [self runAction:[CCSequence actions:delayTimeAction, fadeOut, myCallFunc, nil]];
}

-(void)fadeInLayer{
    id fadeIn = [CCFadeTo actionWithDuration:SHADOWVIEW_TIME opacity:100];
    [self runAction:fadeIn];
}

-(void)enableDelegateTouchAndRemoveFromParent{
    [[BubbleAdsManager sharedManager] attachSceneBubbleAdWorld:nil];
    [self removeFromParentAndCleanup:YES];
    [_delegate adEnableTouch];
}

-(BOOL)areBubblesShowing{
    return (_world->GetBodyCount() > 1); //There are bubbles showing on the screen.
}

- (void)dealloc {
    delete _world;
    _world = NULL;
    [super dealloc];
}

@end
