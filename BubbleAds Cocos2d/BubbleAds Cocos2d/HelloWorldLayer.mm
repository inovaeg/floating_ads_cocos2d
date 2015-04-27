//
//  HelloWorldLayer.mm
//  BubbleAds Cocos2d
//
//  Created by Inova5 on 4/27/15.
//  Copyright Inova5 2015. All rights reserved.
//

// Import the interfaces
#import "HelloWorldLayer.h"

// Needed to obtain the Navigation Controller
#import "AppDelegate.h"
#import "BubbleAdWorld.h"

#pragma mark - HelloWorldLayer

@interface HelloWorldLayer()
-(void) initPhysics;
@end

@implementation HelloWorldLayer

+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	HelloWorldLayer *layer = [HelloWorldLayer node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

-(id) init
{
	if( (self=[super init])) {
		
		// enable events
		
		self.touchEnabled = YES;
//		self.accelerometerEnabled = YES;
		
		// init physics
//		[self initPhysics];
		
        loader = [[LevelHelperLoader alloc] initWithContentOfFile:@"GameMain"];
        [loader addObjectsToWorld:world cocos2dLayer:self];
        
//		[self scheduleUpdate];
	}
	return self;
}

-(void) dealloc
{
	delete world;
	world = NULL;
	
	delete m_debugDraw;
	m_debugDraw = NULL;
    [loader release];
    loader = nil;
	[super dealloc];
}

-(void)onEnterTransitionDidFinish{
    BubbleAdWorld* _bubbleAdWorld = [[[BubbleAdWorld alloc] initWithDelegate:nil] autorelease];
    [self addChild:_bubbleAdWorld];
}

//
//-(void) initPhysics
//{
//	
//	CGSize s = [[CCDirector sharedDirector] winSize];
//	
//	b2Vec2 gravity;
//	gravity.Set(0.0f, -10.0f);
//	world = new b2World(gravity);
//	
//	
//	// Do we want to let bodies sleep?
//	world->SetAllowSleeping(true);
//	
//	world->SetContinuousPhysics(true);
//}
//
//-(void) draw
//{
//	//
//	// IMPORTANT:
//	// This is only for debug purposes
//	// It is recommend to disable it
//	//
//	[super draw];
//	
//	ccGLEnableVertexAttribs( kCCVertexAttribFlag_Position );
//	
//	kmGLPushMatrix();
//	
//	world->DrawDebugData();	
//	
//	kmGLPopMatrix();
//}
//
//-(void) update: (ccTime) dt
//{
//	//It is recommended that a fixed time step is used with Box2D for stability
//	//of the simulation, however, we are using a variable time step here.
//	//You need to make an informed choice, the following URL is useful
//	//http://gafferongames.com/game-physics/fix-your-timestep/
//	
//	int32 velocityIterations = 8;
//	int32 positionIterations = 1;
//	
//	// Instruct the world to perform a single step of simulation. It is
//	// generally best to keep the time step and iterations fixed.
//	world->Step(dt, velocityIterations, positionIterations);	
//}
//
//- (void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
//{
//	//Add a new body/atlas sprite at the touched location
//	for( UITouch *touch in touches ) {
//		CGPoint location = [touch locationInView: [touch view]];
//		
//		location = [[CCDirector sharedDirector] convertToGL: location];
//	}
//}

@end
