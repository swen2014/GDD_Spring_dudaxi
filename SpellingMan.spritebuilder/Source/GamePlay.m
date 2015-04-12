//
//  GamePlay.m
//  SpellingMan
//
//  Created by steven on 4/10/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "GamePlay.h"
#import "GamePlayScene.h"
#import "Man.h"
#import "Level.h"
#import "test.h"
//
static const CGFloat scrollSpeed = 80.f;
static NSString *selectedLevel = @"test1";

@implementation GamePlay{
    Man *_man;

    CCPhysicsNode *_physicsNode;
    
    CCNode *_levelNode;
    CCNode *_level1Node;
    CCNode *_level2Node;
    NSArray *_levels;

    Level *_loadedLevel;
    Level *_level1;
    Level *_level2;

    
    CCLabelTTF *_scoreLabel;
    
    BOOL _jumped;
    BOOL _gameOver;
    
    CCNode *_ground1;
    CCNode *_ground2;
    NSArray *_grounds;
}

- (void)didLoadFromCCB
{
    self.userInteractionEnabled = TRUE;
    _physicsNode.collisionDelegate = self;
    
    
    _loadedLevel = (Level *) [CCBReader load:selectedLevel owner:self];
    _level1 = (Level *) [CCBReader load:@"test" owner:self];
    _level2 = (Level *) [CCBReader load:@"test1" owner:self];
    [_levelNode addChild:_loadedLevel];
    [_level1Node addChild:_level1];
    [_level2Node addChild:_level2];
    
    _man = (Man *)[CCBReader load:@"Man"];
    [_physicsNode addChild:_man];
//    [_physicsNode addChild:_levelNode];
    
    // your code here
    NSLog(@"MAN Find, level1 %@, level2 %@", NSStringFromCGPoint(_level1Node.position), NSStringFromCGPoint(_level2Node.position));
    NSLog(@"size %@, %@", NSStringFromCGSize(_level1.contentSize), NSStringFromCGSize(_level2.contentSize));
    
    _grounds = @[_ground1, _ground2];
    _levels = @[_level1Node, _level2Node];
    NSLog(@"%@", _levels);
    
//    [_physicsNode addChild:_man];
//    [self addObstacle];
//    timeSinceObstacle = 0.0f;
    
}

-(void)update:(CCTime)delta
{
//    NSLog(@" level screen %@, %@", NSStringFromCGPoint(_man.position), NSStringFromCGPoint(_levelNode.position));
    
//    NSLog(@" man physics node %@, physics world: %@", NSStringFromCGPoint(_man.physicsBody.velocity), NSStringFromCGPoint(_physicsNode.position));

    _man.position = ccp(100, _man.position.y);
    _levelNode.position = ccp(_levelNode.position.x - (scrollSpeed * delta), _levelNode.position.y);
//    _level1Node.position = ccp(_level1Node.position.x - (scrollSpeed * delta), _level1Node.position.y);
//    _level2Node.position = ccp(_level2Node.position.x - (scrollSpeed * delta), _level2Node.position.y);

//    NSLog(@"ground1: %@, ground2: %@", NSStringFromCGPoint(_ground1.position), NSStringFromCGPoint(_ground2.position));
//    _levelNode.position = ccp(_levelNode.position.x - (_man.physicsBody.velocity.x * delta), _levelNode.position.y);
    
    
    // loop the ground
    for (CCNode *ground in _grounds) {
        // get the world position of the ground
        CGPoint groundWorldPosition = [_levelNode convertToWorldSpace:ground.position];
        // get the screen position of the ground
        CGPoint groundScreenPosition = [self convertToNodeSpace:groundWorldPosition];
//        NSLog(@"ground screen %@, %.2f", NSStringFromCGPoint(groundScreenPosition),ground.contentSize.width);
//        NSLog(@"gorund %@",NSStringFromCGPoint(ground.position));
        // if the left corner is one complete width off the screen, move it to the right
        if (groundScreenPosition.x <= (-1.1 * ground.contentSize.width)) {
            ground.position = ccp(ground.position.x + 2 * ground.contentSize.width, ground.position.y);
        }
    }

//    for (CCNode *level in _levels) {
        CGPoint levelWorldPosition = [_levelNode convertToWorldSpace:_level1Node.position];
        CGPoint levelScreenPosition = [self convertToNodeSpace:levelWorldPosition];
        
//        NSLog(@"%@", NSStringFromCGPoint(_level1Node.position));
//        NSLog(@"level screen %@, %@, ", NSStringFromCGPoint(levelScreenPosition),NSStringFromCGPoint(levelWorldPosition));
        if (levelScreenPosition.x <= (-1 * _level1.contentSize.width)) {
            //            NSLog(@"leve screen %@, %@", NSStringFromCGPoint(levelScreenPosition), NSStringFromCGPoint(_levelNode.position));
            _level1Node.position = ccp(_level1Node.position.x + 2 * _level1.contentSize.width, _level1Node.position.y);
        }
//    }
    
    

//    NSLog(@"level1 %@, level2 %@", NSStringFromCGPoint(_level1Node.position), NSStringFromCGPoint(_level2Node.position));
    
    
//    for (CCNode *level in _levels) {
//        // get the world position of the ground
//        CGPoint levelWorldPosition = [_physicsNode convertToWorldSpace:level.position];
//        // get the screen position of the ground
//        CGPoint levelScreenPosition = [self convertToNodeSpace:levelWorldPosition];
//        
//        // if the left corner is one complete width off the screen, move it to the right
//        if (levelScreenPosition.x <= (-1 * level.contentSize.width)) {
//            level.position = ccp(level.position.x + 2 * level.contentSize.width, level.position.y);
//        }
//    }
    
    if (!_gameOver)
    {
        @try
        {
//            _man.physicsBody.velocity = ccp(80.f, clampf(_man.physicsBody.velocity.y, -MAXFLOAT, 200.f));
            
//            [self update:delta];
        }
        @catch(NSException* ex)
        {
            
        }
    }
    
    if (CGRectGetMaxY([_man boundingBox]) <   CGRectGetMinY([_loadedLevel boundingBox])) {
        [self gameOver];
    }
}

#pragma mark - Touch Handling

- (void)touchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
    // this will get called every time the player touches the screen
    if (!_jumped) {
        _man.physicsBody.velocity = ccp(0,200);
        OALSimpleAudio *jumpaudio = [OALSimpleAudio sharedInstance];
        [jumpaudio playEffect:@"jump.wav"];
        _jumped = TRUE;
        [self performSelector:@selector(resetJump) withObject:nil afterDelay:0.3f];
    }
//    [_man.physicsBody applyImpulse:ccp(0, 1000.f)];
//    float yVelocity = clampf(_man.physicsBody.velocity.y, -1 * MAXFLOAT, 200.f);
//    _man.physicsBody.velocity = ccp(0, yVelocity);
//    [_man jump];
}

- (void)resetJump{
    _jumped = FALSE;
}

- (void)fixedUpdate:(CCTime)delta
{
//    _man.physicsBody.velocity = ccp(40.f, _man.physicsBody.velocity.y);
}


- (void)gameOver {
    CCScene *restartScene = [CCBReader loadAsScene:@"Gameplay"];
    CCTransition *transition = [CCTransition transitionFadeWithDuration:0.8f];
    [[CCDirector sharedDirector] presentScene:restartScene withTransition:transition];
}
@end
