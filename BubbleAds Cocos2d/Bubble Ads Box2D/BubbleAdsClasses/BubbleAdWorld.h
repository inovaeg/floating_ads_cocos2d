//
//  BubbleAdWorld.h
//  Penguin
//
//  Created by Inova5 on 4/22/15.
//  Copyright 2015 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AdFactory.h"
#import "cocos2d.h"

@protocol BubbleAdWorldDelegate
-(void)adEnableTouch;
-(void)adDisableTouch;
@end

@interface BubbleAdWorld : CCLayerColor {
    __weak id<BubbleAdWorldDelegate> _delegate;
}

@property(nonatomic) BOOL activeState;

-(BOOL)areBubblesShowing;
-(void)enableAdBubbleScene;
-(void)disableAdBubbleScene;
-(id)initWithDelegate:(id)delegate;
-(void)createBubbleWithAd:(AdFactory*) ad;
@end
