//
//  AdAvocarrot.m
//  Bubble Ads
//
//  Created by Inova5 on 4/9/15.
//  Copyright (c) 2015 Kareem. All rights reserved.
//
#import <AvocarrotSDK/AvocarrotCustom.h>
#import "AdAvocarrot.h"

@interface AdAvocarrot(){
    
//    AVCustomAd* ad;
}
@property(strong, nonatomic) AVCustomAd* ad;
@end

@implementation AdAvocarrot

-(id)initWithAd:(id)currentAd{
    if(self = [super initWithAd:currentAd]){
        self.ad = currentAd;
    }
    return self;
}

-(void)openWithView:(UIView*)view{
//    [ad bindToView:view];
    [self.ad handleClick];
}

-(UIImage*)getImage{
    return [self.ad getImage];
}

@end
