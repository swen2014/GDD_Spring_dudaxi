//
//  Gameplay.m
//  RunningMan
//
//  Created by steven on 2/22/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "Gameplay.h"
#import "Level.h"
#import "Actionfollow.h"
#import "CCPhysics+ObjectiveChipmunk.h"
//#define CP_ALLOW_PRIVATE_ACCESS 1

static NSString *selectedLevel = @"LevelFinal";
static int levelSpeed = 20;
static NSString * const kFirstLevel = @"LevelFinal";
//static NSString *selectedLevel = @"Level1";
//static int levelSpeed = 0;


@implementation Gameplay {
    CCSprite *_robot;
    CCPhysicsNode *_physicsNode;
    CCNode *_levelNode;
    Level *_loadedLevel;
    CCLabelTTF *_scoreLabel;
    BOOL _jumped;
    int xVel, yVel;
    int _score;
}

- (void)didLoadFromCCB {
    _physicsNode.collisionDelegate = self;
    _loadedLevel = (Level *) [CCBReader load:selectedLevel owner:self];
    [_levelNode addChild:_loadedLevel];
//    xVel = 0;
//    yVel = 0;
//    [NSTimer scheduledTimerWithTimeInterval:0.01 target:self selector:@selector(check) userInfo:nil repeats:YES];

//    _physicsNode.debugDraw=true;
}

- (void)onEnter {
    [super onEnter];
    
    CCActionFollow *follow = [CCActionFollow actionWithTarget:_robot worldBoundary:[_loadedLevel boundingBox]];
    _physicsNode.position = [follow currentOffset];
    [_physicsNode runAction:follow];
//    [_physicsNode.physicsBody setVelocity:ccpMult(_robot.physicsBody.velocity, -1)];//
}

- (void)onEnterTransitionDidFinish {
    [super onEnterTransitionDidFinish];
    
    self.userInteractionEnabled = YES;
}

#pragma mark - Touch Handling

- (void)touchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
    [_robot.physicsBody.chipmunkObjects[0] eachArbiter:^(cpArbiter *arbiter) {
        if (!_jumped) {
//            yVel = 20;
//            xVel = 0.5;
            
            [_robot.physicsBody applyImpulse:ccp(20, 3000)];
//            [_robot.physicsBody applyForce:ccp(20,1200)];
//            b2Vec2 vel = body->GetLinearVelocity();
//            vel.y = 10;//upwards - don't change x velocity
//            body->SetLinearVelocity( vel );
            _jumped = TRUE;
            [self performSelector:@selector(resetJump) withObject:nil afterDelay:0.1];
        }
    }];
}

#pragma mark - Player Movement

- (void)resetJump {
    _jumped = FALSE;
}
//
- (void)fixedUpdate:(CCTime)delta
{
    _robot.physicsBody.velocity = ccp(levelSpeed, _robot.physicsBody.velocity.y);
//    _physicsNode.position = ccp(_physicsNode.position.x - (levelSpeed *delta), _physicsNode.position.y);
}


#pragma mark - Collision Handling
//- (BOOL)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair hero:(CCNode *)hero flag:(CCNode *)flag {
//    self.paused = YES;
//    
//    WinPopup *popup = (WinPopup *)[CCBReader load:@"WinPopup" owner:self];
//    popup.positionType = CCPositionTypeNormalized;
//    popup.position = ccp(0.5, 0.5);
//    [self addChild:popup];
//    
//    return YES;
//}

- (BOOL)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair robot:(CCNode *)robot poo:(CCNode *)poo {
    [poo removeFromParent];
    [self gameOver];
    return NO;
}

-(BOOL)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair robot:(CCNode *)robot heart:(CCNode *)heart{
    [heart removeFromParent];
        _score++;
        _scoreLabel.string = [NSString stringWithFormat:@"%d", _score];
    return NO;
}
#pragma mark - Update

- (void)update:(CCTime)delta {
    _robot.position = ccp(_robot.position.x + delta * levelSpeed, _robot.position.y);

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
