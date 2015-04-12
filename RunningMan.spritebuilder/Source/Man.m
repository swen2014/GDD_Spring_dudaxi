//
//  Man.m
//  RunningMan
//
//  Created by steven on 2/22/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "Man.h"

@implementation Man
- (void)didLoadFromCCB{
    self.position = ccp(115, 250);
//    self.zOrder = DrawingOrderHero;
    self.physicsBody.collisionType = @"man";
}

//- (id)init {
//    self = [super init];
//
//    if (self) {
//        CCLOG(@"Man created");
//    }
//    
//    return self;
//}

- (void)jump{
    
    OALSimpleAudio *jumpaudio = [OALSimpleAudio sharedInstance];
    [jumpaudio playEffect:@"jump.wav"];
    
}
@end
