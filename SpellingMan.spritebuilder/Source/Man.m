//
//  Man.m
//  SpellingMan
//
//  Created by steven on 4/10/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "Man.h"
#import "GamePlayScene.h"

@implementation Man
- (void)didLoadFromCCB
{
    self.position = ccp(100, 70);
    self.physicsBody.velocity = CGPointZero;
}

@end
