//
//  BubbleAd.m
//  Penguin
//
//  Created by Inova5 on 4/23/15.
//
//

#import "BubbleAd.h"

@implementation BubbleAd

-(void)startNormalAnimation{
    [self.sprite removeAnimationHasEndedObserver];
    [self _setAnimationWithAnimationName:@"Ad_Bubble_Movement"];
}

-(void)startCollisionAnimation{
    [self _setAnimationWithAnimationName:@"Ad_Bubble_Collision"];
    [self.sprite setAnimationHasEndedObserver:self selector:@selector(startNormalAnimation)];
}

-(void)startBurstAnimation{
    [self.spriteAd removeFromParentAndCleanup:YES];
    [self _setAnimationWithAnimationName:@"Ad_Bubble_Burst"];
    [self.sprite setAnimationHasEndedObserver:self selector:@selector(_destroySpriteAndClickAd)];
}

-(void)_setAnimationWithAnimationName:(NSString*)animName
{
    if( [self.sprite.animationName isEqual:animName] ) return;
    [self.sprite prepareAnimationNamed:animName fromSHScene:@"AdBubbleAssetsSpriteSheet"];
    [self.sprite playAnimation];
}

-(void)fadeIn{
    self.sprite.opacity = 0;
    self.spriteAd.opacity = 0;
    id fadeIn = [CCFadeIn actionWithDuration:BUBBLE_FADEIN_TIME];
    id fadeIn2 = [CCFadeIn actionWithDuration:BUBBLE_FADEIN_TIME];
    [self.sprite runAction:fadeIn];
    [self.spriteAd runAction:fadeIn2];
}

-(void)fadeoutAndDestroy{
    id fadeout = [CCFadeOut actionWithDuration:BUBBLE_FADEOUT_TIME];
    id fadeout2 = [CCFadeOut actionWithDuration:BUBBLE_FADEOUT_TIME];
    id myCallFunc = [CCCallFunc actionWithTarget:self selector:@selector(_destroySprite)];
    [self.spriteAd runAction:fadeout];
    [self.sprite runAction:[CCSequence actions:fadeout2, myCallFunc,nil]];
}

-(void)_destroySprite{
    [self.sprite removeFromParentAndCleanup:YES];
}

-(void)_destroySpriteAndClickAd{
    [self.sprite removeAnimationHasEndedObserver];
    [self.ad openWithView:nil];
    [self.sprite removeFromParentAndCleanup:YES];
}

-(void) dealloc{
    [super dealloc];
}

//------------------------------------------------------------------------------
-(id) initWithSprite:(LHSprite*)spr{
    if (self = [super init]){
        self.sprite = spr;
        [self.sprite setAnchorPoint:CGPointMake(0.5f, 0.5f)];
    }
    return self;
}
@end
