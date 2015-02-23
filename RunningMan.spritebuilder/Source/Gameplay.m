//
//  Gameplay.m
//  RunningMan
//
//  Created by steven on 2/22/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "Gameplay.h"
#import "Level.h"

static NSString *selectedLevel = @"LevelFinal";


@implementation Gameplay {
    CCSprite *_robot;
    CCPhysicsNode *_physicsNode;
    CCNode *_levelNode;
    Level *_loadedLevel;
    CCLabelTTF *_scoreLabel;
    BOOL _jumped;
    
    int _score;
}

- (void)didLoadFromCCB {
    _physicsNode.collisionDelegate = self;
    _loadedLevel = (Level *) [CCBReader load:selectedLevel owner:self];
    [_levelNode addChild:_loadedLevel];
    
//    levelSpeed = _loadedLevel.levelSpeed;
}


#pragma mark - Update

- (void)update:(CCTime)delta {
    if (CGRectGetMaxY([_robot boundingBox]) <   CGRectGetMinY([_loadedLevel boundingBox])) {
        [self gameOver];
    }
}

#pragma mark - Game Over

- (void)gameOver {
    CCScene *restartScene = [CCBReader loadAsScene:@"Gameplay"];
    CCTransition *transition = [CCTransition transitionFadeWithDuration:0.8f];
    [[CCDirector sharedDirector] presentScene:restartScene withTransition:transition];
}
@end
