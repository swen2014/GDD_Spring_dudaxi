//
//  PlayScene.m
//  RunningMan
//
//  Created by steven on 4/10/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "PlayScene.h"
#import "Level.h"
#import "Man.h"

static NSString *selectedLevel = @"Level";
//static int levelSpeed = 40;
static NSString * const kFirstLevel = @"Level";
static const CGFloat scrollSpeed = 80.f;

@implementation PlayScene
{
    CCNode *_ground1;
    CCNode *_ground2;
    NSArray *_grounds;
    
    NSTimeInterval _sinceTouch;
    
    NSMutableArray *_obstacles;
    
    CCButton *_restartButton;
    
    BOOL _gameOver;
    CCLabelTTF *_scoreLabel;
    CCLabelTTF *_nameLabel;
    
    CCNode *_levelNode;
    Level *_loadedLevel;
    CCPhysicsNode *_physicsNode;

}
- (void)didLoadFromCCB {
    self.userInteractionEnabled = TRUE;

    
    _loadedLevel = (Level *) [CCBReader load:selectedLevel owner:self];
    [_levelNode addChild:_loadedLevel];
    
    
    _grounds = @[_ground1, _ground2];

    for (CCNode *ground in _grounds) {
        // set collision txpe
        ground.physicsBody.collisionType = @"level";
//        ground.zOrder = DrawingOrderGround;
    }
    
    // set this class as delegate
    _physicsNode.collisionDelegate = self;
    
    _obstacles = [NSMutableArray array];
//    points = 0;
    _scoreLabel.visible = true;
    
    [super initialize];
}

- (void)update:(CCTime)delta {
    _man.position = ccp(_man.position.x + delta * scrollSpeed, _man.position.y);
    _physicsNode.position = ccp(_physicsNode.position.x - (scrollSpeed *delta), _physicsNode.position.y);
}


#pragma mark - Game Over
- (void)gameOver {
    CCScene *restartScene = [CCBReader loadAsScene:@"Gameplay"];
    CCTransition *transition = [CCTransition transitionFadeWithDuration:0.8f];
    [[CCDirector sharedDirector] presentScene:restartScene withTransition:transition];
}

@end
