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
#import "Letter.h"
#import "Lose.h"
//
static const CGFloat scrollSpeed = 140.f;
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
    CCLabelTTF *_goalLabel;
    CCLabelTTF *_countLabel;
    
    BOOL _jumped;
    BOOL _gameOver;
    BOOL _gameWin;
    BOOL _stop;
    
    CCNode *_ground1;
    CCNode *_ground2;
    NSArray *_grounds;
    
//    NSMutableString *goal;
    NSMutableString *word;
    NSString *goal;
    int score;
}

- (void)didLoadFromCCB
{
    self.userInteractionEnabled = TRUE;
    _physicsNode.collisionDelegate = self;
    
    _loadedLevel = (Level *) [CCBReader load:selectedLevel owner:self];
    _level1 = (Level *) [CCBReader load:@"Level1" owner:self];
    _level2 = (Level *) [CCBReader load:@"test1" owner:self];
    [_levelNode addChild:_loadedLevel];
    [_level1Node addChild:_level1];
    [_level2Node addChild:_level2];
    
    _man = (Man *)[CCBReader load:@"Man"];
    [_physicsNode addChild:_man];
    

    word = [[NSMutableString alloc] initWithCapacity:10];
    
    _grounds = @[_ground1, _ground2];
    _levels = @[_level1Node, _level2Node];
    
    [self solution];
//    NSLog(@"%@", _levels);
    
//    [_physicsNode addChild:_man];
//    [self addObstacle];
//    timeSinceObstacle = 0.0f;
    
}

- (void) solution{
//    NSLog(@"Solution");
    goal = @"RI";
//    [goal appendString: @"RA"];
    _goalLabel.string = [NSString stringWithFormat:@"%@", goal];
}

- (void)check{
    NSUInteger len = [word length];
    NSUInteger len1 = [goal length];
    if (len > len1) {
        _gameOver = YES;
    }else{
    _gameWin = [goal isEqualToString:word];
//    return _gameWin;
    if (_gameWin) {
        score++;
        _countLabel.string = [NSString stringWithFormat:@"%d", score];
    }
    }
}

-(void)update:(CCTime)delta
{
    // Move the LevelNode to shift left
    _man.position = ccp(100, _man.position.y);
    _levelNode.position = ccp(_levelNode.position.x - (scrollSpeed * delta), _levelNode.position.y);

    // loop the ground
    for (CCNode *ground in _grounds) {
        // get the world position of the ground
        CGPoint groundWorldPosition = [_levelNode convertToWorldSpace:ground.position];
        // get the screen position of the ground
        CGPoint groundScreenPosition = [self convertToNodeSpace:groundWorldPosition];
        // if the left corner is one complete width off the screen, move it to the right
        if (groundScreenPosition.x <= (-1.1 * ground.contentSize.width)) {
            ground.position = ccp(ground.position.x + 2 * ground.contentSize.width, ground.position.y);
        }
    }
    
    // loop the level node to create infinite scene
        CGPoint levelWorldPosition = [_levelNode convertToWorldSpace:_level1Node.position];
        CGPoint levelScreenPosition = [self convertToNodeSpace:levelWorldPosition];

        if (levelScreenPosition.x <= (-1 * _level1.contentSize.width)) {
            _level1Node.position = ccp(_level1Node.position.x + 2 * _level1.contentSize.width, _level1Node.position.y);
            [_level1Node removeChild:_level1];
            _level1 = (Level *) [CCBReader load:@"Level2" owner:self];
            [_level1Node addChild:_level1];
        }
    
    if (!_gameOver)
    {
        @try
        {
            _man.physicsBody.velocity = ccp(0, clampf(_man.physicsBody.velocity.y, -MAXFLOAT, 150.f));
        }
        @catch(NSException* ex)
        {
            
        }
    }else{
        self.paused = YES;
        
        Lose *popup = (Lose *)[CCBReader load:@"Lose" owner:self];
        popup.positionType = CCPositionTypeNormalized;
        popup.position = ccp(0.5, 0.5);
        [self addChild:popup];
    }
    
    if (_gameWin) {
        [word setString:@""];
//        NSLog(@"HAHAHAHA");
    }
    
    if (CGRectGetMaxY([_man boundingBox]) < CGRectGetMinY([_loadedLevel boundingBox])) {
        [self gameOver];
    }
}

#pragma mark - Touch Handling

- (void)touchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
    // this will get called every time the player touches the screen
    if (!_jumped) {
        _man.physicsBody.velocity = ccp(0,2500);
        OALSimpleAudio *jumpaudio = [OALSimpleAudio sharedInstance];
        [jumpaudio playEffect:@"jump.wav"];
        _jumped = TRUE;
        [self performSelector:@selector(resetJump) withObject:nil afterDelay:0.03f];
    }
}

- (void)resetJump{
    _jumped = FALSE;
}

-(void)Restart{
    [self gameOver];
}

- (void)Pause{
    if (!_stop) {
        self.paused = YES;
        _stop = YES;
    }else{
        self.paused = NO;
        _stop = NO;
    }
}

- (void)gameOver {
    CCScene *restartScene = [CCBReader loadAsScene:@"GamePlay"];
    CCTransition *transition = [CCTransition transitionFadeWithDuration:0.8f];
    [[CCDirector sharedDirector] presentScene:restartScene withTransition:transition];
}

#pragma mark - Collision Handle

- (BOOL)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair Man:(CCNode *)Man a:(CCNode *)a {
    [a removeFromParent];
    NSString *letter = @"A";
    [word appendString:letter];
    _scoreLabel.string = [NSString stringWithFormat:@"%@", word];
    [self check];
    return NO;
}

- (BOOL)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair Man:(CCNode *)Man b:(CCNode *)b {
    [b removeFromParent];
    NSString *letter = @"B";
    [word appendString:letter];
    _scoreLabel.string = [NSString stringWithFormat:@"%@", word];
    [self check];
    return NO;
}

- (BOOL)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair Man:(CCNode *)Man r:(CCNode *)r {
    [r removeFromParent];
    NSString *letter = @"R";
    [word appendString:letter];
    _scoreLabel.string = [NSString stringWithFormat:@"%@", word];
    [self check];
    return NO;
}

- (BOOL)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair Man:(CCNode *)Man i:(CCNode *)i {
    [i removeFromParent];
    NSString *letter = @"I";
    [word appendString:letter];
    _scoreLabel.string = [NSString stringWithFormat:@"%@", word];
    [self check];
    return NO;
}

- (BOOL)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair Man:(CCNode *)Man poo:(CCNode *)poo {
    [poo removeFromParent];
    [self gameOver];
    return NO;
}

@end
