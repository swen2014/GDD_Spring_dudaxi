////
////  Gameplay.m
////  RunningMan
////
////  Created by steven on 2/22/15.
////  Copyright (c) 2015 Apportable. All rights reserved.
////
//
//#import "Gameplay.h"
//#import "Level.h"
//#import "Actionfollow.h"
//#import "CCPhysics+ObjectiveChipmunk.h"
//#import "Man.h"
////#define CP_ALLOW_PRIVATE_ACCESS 1
//
//static NSString *selectedLevel = @"LevelFinal";
//static int levelSpeed = 40;
//static NSString * const kFirstLevel = @"LevelFinal";
////static NSString *selectedLevel = @"Level1";
////static int levelSpeed = 0;
//
//
//
//@implementation Gameplay {
////    __weak CCSprite *_man;
////    __weak CCSprite *_robot;
//    
////    CCPhysicsNode *_physicsNode;
//    CCNode *_levelNode;
//    Level *_loadedLevel;
//    CCLabelTTF *_scoreLabel;
//    
//    BOOL _jumped;
//    int xVel, yVel;
//    int _score;
//}
//
//- (void)didLoadFromCCB {
////    _physicsNode.collisionDelegate = self;
//    _loadedLevel = (Level *) [CCBReader load:selectedLevel owner:self];
//    [_levelNode addChild:_loadedLevel];
//    
////    xVel = 0;
////    yVel = 0;
////    [NSTimer scheduledTimerWithTimeInterval:0.01 target:self selector:@selector(check) userInfo:nil repeats:YES];
//
////    _physicsNode.debugDraw=true;
//}
//
//- (void)initialize
//{
//    // your code here
//    _man = (Man*)[CCBReader load:@"RunningMan"];
//    [_physicsNode addChild:_man];
////    [self addObstacle];
////    timeSinceObstacle = 0.0f;
//}
//
//- (void)onEnter {
//    [super onEnter];
//    
//    CCActionFollow *follow = [CCActionFollow actionWithTarget:_man worldBoundary:[_loadedLevel boundingBox]];
//    _physicsNode.position = [follow currentOffset];
//    [_physicsNode runAction:follow];
//    // access audio object
////    OALSimpleAudio *audio = [OALSimpleAudio sharedInstance];
//
//
//    // play background sound
////    [audio playBg:@"True Love Ways.mp3" loop:YES];
////    [_physicsNode.physicsBody setVelocity:ccpMult(_man.physicsBody.velocity, -1)];//
//}
//
//- (void)onEnterTransitionDidFinish {
//    [super onEnterTransitionDidFinish];
//
//    self.userInteractionEnabled = YES;
//}
//
//#pragma mark - Touch Handling
//
//- (void)touchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
//    if (!_jumped) {
//        [_man.physicsBody applyImpulse:ccp(0,110)];
//    }
////    [_man.physicsBody.chipmunkObjects[0] eachArbiter:^(cpArbiter *arbiter) {
////        if (!_jumped) {
////            [_man.physicsBody applyImpulse:ccp(5, 500)];
//////            [man jump:]
////            // access audio object
//////            OALSimpleAudio *jumpaudio = [OALSimpleAudio sharedInstance];
//////            [jumpaudio playEffect:@"jump.wav"];
//////            [jumpaudio]
////            // play sound effect
////            _jumped = TRUE;
////            [self performSelector:@selector(resetJump) withObject:nil afterDelay:0.1];
////        }
////    }];
//}
//
//#pragma mark - Player Movement
//
//- (void)resetJump {
//    _jumped = FALSE;
//}
////
//- (void)fixedUpdate:(CCTime)delta
//{
//    _man.physicsBody.velocity = ccp(levelSpeed, _man.physicsBody.velocity.y);
////    _physicsNode.position = ccp(_physicsNode.position.x - (levelSpeed *delta), _physicsNode.position.y);
//}
//
//
//#pragma mark - Collision Handling
////- (BOOL)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair hero:(CCNode *)hero flag:(CCNode *)flag {
////    self.paused = YES;
////    
////    WinPopup *popup = (WinPopup *)[CCBReader load:@"WinPopup" owner:self];
////    popup.positionType = CCPositionTypeNormalized;
////    popup.position = ccp(0.5, 0.5);
////    [self addChild:popup];
////    
////    return YES;
////}
//
//
//
//- (BOOL)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair man:(CCNode *)man poo:(CCNode *)poo {
//    [poo removeFromParent];
//    [self gameOver];
//    return NO;
//}
//
//-(BOOL)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair man:(CCNode *)man heart:(CCNode *)heart{
//    [heart removeFromParent];
//        _score++;
//        _scoreLabel.string = [NSString stringWithFormat:@"%d", _score];
//    return NO;
//}
//#pragma mark - Update
//
//- (void)update:(CCTime)delta {
//    _man.position = ccp(_man.position.x + delta * levelSpeed, _man.position.y);
//
//    if (CGRectGetMaxY([_man boundingBox]) <   CGRectGetMinY([_loadedLevel boundingBox])) {
//        [self gameOver];
//    }
//}
//
//
//#pragma mark - Game Over
//
//- (void)gameOver {
//    CCScene *restartScene = [CCBReader loadAsScene:@"Gameplay"];
//    CCTransition *transition = [CCTransition transitionFadeWithDuration:0.8f];
//    [[CCDirector sharedDirector] presentScene:restartScene withTransition:transition];
//}
//@end
