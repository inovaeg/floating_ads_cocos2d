//
//  BubbleAd.h
//  Penguin
//
//  Created by Inova5 on 4/23/15.
//
//

#import "LHSprite.h"
#import "AdFactory.h"

#define BUBBLE_FADEIN_TIME 0.5f
#define BUBBLE_FADEOUT_TIME 0.33f

@interface BubbleAd : NSObject
{

}

@property(nonatomic, retain) LHSprite* sprite;
@property(nonatomic, retain) LHSprite* spriteAd;
@property(nonatomic, retain) AdFactory * ad;

-(id) initWithSprite:(LHSprite*)spr;

-(void)fadeIn;
-(void)fadeoutAndDestroy;
-(void)startBurstAnimation;
-(void)startNormalAnimation;
-(void)startCollisionAnimation;


@end
