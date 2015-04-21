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

    Level *_loadedLevel;
    Level *_level1;
    Level *_level2;
    
    CCLabelTTF *_scoreLabel;
    CCLabelTTF *_goalLabel;
    CCLabelTTF *_countLabel;
    
    BOOL _jumped;
    BOOL _gameOver;
    BOOL _gameWin;
    BOOL _stop;// Flag to determined if the game pause or not
    
    CCNode *_ground1;
    CCNode *_ground2;
    NSArray *_grounds;
    
    NSMutableArray *_letters1;
    NSMutableArray *_letters2;
    
    NSMutableString *word;
    NSString *goal;
    int score;
    
    float timeSince;
    CGFloat screenHeight;
    CGFloat screenWidth;
    
    NSMutableArray *offScreen;
}

- (void)didLoadFromCCB
{
    self.userInteractionEnabled = TRUE;
    _physicsNode.collisionDelegate = self;
    
    _loadedLevel = (Level *) [CCBReader load:selectedLevel owner:self];
    _level1 = (Level *) [CCBReader load:@"Levels/Level1" owner:self];
    _level2 = (Level *) [CCBReader load:@"Levels/Level2" owner:self];
    [_levelNode addChild:_loadedLevel];
    [_level1Node addChild:_level1];
    [_level2Node addChild:_level2];
    
    _man = (Man *)[CCBReader load:@"Man"];
    [_physicsNode addChild:_man];
    
    [self initilization];
    [self solution];
//    [self dirHome];
//    [self readFile];
}

- (void)initilization{
    word = [[NSMutableString alloc] initWithCapacity:10];
    _grounds = @[_ground1, _ground2];
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    screenHeight = screenRect.size.height;
    screenWidth = screenRect.size.width;
    
    _letters1 = [NSMutableArray array];
    _letters2 = [NSMutableArray array];
}

////读文件
//-(void)readFile{
//    NSString *documentsPath =[self dirDoc];
////    NSString *testDirectory = [documentsPath stringByAppendingPathComponent:@"test"];
//    NSString *testPath = [documentsPath stringByAppendingPathComponent:@"test_word.txt"];
//    //    NSData *data = [NSData dataWithContentsOfFile:testPath];
//    //    NSLog(@"文件读取成功: %@",[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
//    NSString *content=[NSString stringWithContentsOfFile:testPath encoding:NSUTF8StringEncoding error:nil];
//    
//    NSString *textFileContents = [NSString stringWithContentsOfFile:[[NSBundle mainBundle]
//                                  pathForResource:@"text_word"
//                                  ofType:@"txt"]
//                                  encoding:NSUTF8StringEncoding
//                                  error: nil];
//    // If there are no results, something went wrong
//    if (textFileContents == nil) {
//        // an error occurred
//        NSLog(@"Error reading text file.");
//    }
//    NSArray *lines = [textFileContents componentsSeparatedByString:@""];
////    NSLog(@"Number of lines in the file:%d", [lines count] );
////    NSLog(@"文件读取成功: %@",content);
//}
//
////获取Documents目录
//-(NSString *)dirDoc{
//    //[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
//    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//    NSString *documentsDirectory = [paths objectAtIndex:0];
////    NSLog(@"app_home_doc: %@",documentsDirectory);
//    return documentsDirectory;
//}
//
//-(void)dirHome{
//    NSString *dirHome=NSHomeDirectory();
////    NSLog(@"app_home: %@",dirHome);
//}

#pragma mark - Word Matching

- (void) solution{
    goal = @"RIB";
    _goalLabel.string = [NSString stringWithFormat:@"Goal:%@", goal];
}

- (void)check{
    NSUInteger len = [word length];
    NSUInteger len1 = [goal length];
    if (len > len1) {
        _gameOver = YES;
    }else if(len <= len1){
      
    }
    else{
    _gameWin = [goal isEqualToString:word];
    if (_gameWin) {
        score++;
        _countLabel.string = [NSString stringWithFormat:@"Words Completed: %d", score];
        [word setString:@""];
        _scoreLabel.string = [NSString stringWithFormat:@"%@", word];
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
    
    [self BGReplace1];
    [self BGReplace2];
    
    offScreen = nil;
    
    for (CCNode *letter in _letters1) {
        CGPoint WorldPosition = [_level1Node convertToWorldSpace:letter.position];
        CGPoint letterScreenPosition = [self convertToNodeSpace:WorldPosition];

        if (letterScreenPosition.x < 0) {
            if (!offScreen) {
                offScreen = [NSMutableArray array];
            }
            [offScreen addObject:letter];
        }
    }
    for (CCNode *letter in _letters2) {
        CGPoint WorldPosition = [_level2Node convertToWorldSpace:letter.position];
        CGPoint letterScreenPosition = [self convertToNodeSpace:WorldPosition];
//        NSLog(@"%@", NSStringFromCGPoint(letterScreenPosition));
        
        if (letterScreenPosition.x < 0) {
            if (!offScreen) {
                offScreen = [NSMutableArray array];
            }
            [offScreen addObject:letter];
        }
    }

    for (CCNode *letterToRemove in offScreen) {
        NSLog(@"Delete");
        [letterToRemove removeFromParent];
        if ([_letters1 containsObject:letterToRemove]) {
            [_letters1 removeObject:letterToRemove];
        }else{
            [_letters2 removeObject:letterToRemove];
        }
    }
    
    
    if (!_gameOver)
    {
        @try
        {
            _man.physicsBody.velocity = ccp(0, clampf(_man.physicsBody.velocity.y, -MAXFLOAT, 260.f));
            timeSince += delta;
            if (timeSince > 4.3f) {
//                [self addLetter:210.0f];
//                [self addLetter:100.0f];
                timeSince = 0.0f;
            }
        }
        @catch(NSException* ex)
        {
            
        }
    }else{
        self.paused = YES;
        [self LosePopup];
    }
    
    if (CGRectGetMaxY([_man boundingBox]) < CGRectGetMinY([_loadedLevel boundingBox])) {
        [self gameOver];
    }
}

-(void)LosePopup{
    Lose *popup = (Lose *)[CCBReader load:@"Lose" owner:self];
    popup.positionType = CCPositionTypeNormalized;
    popup.position = ccp(0.5, 0.5);
    [self addChild:popup];
}


-(void)BGReplace1{
    // loop the level node to create infinite scene
    CGPoint levelWorldPosition = [_levelNode convertToWorldSpace:_level1Node.position];
    CGPoint levelScreenPosition = [self convertToNodeSpace:levelWorldPosition];
    
    if (levelScreenPosition.x <= (-1 * _level1.contentSize.width)) {
        _level1Node.position = ccp(_level1Node.position.x + 2 * _level1.contentSize.width, _level1Node.position.y);
        [_level1Node removeChild:_level1];
        int levelNum = (arc4random() % 3) + 1;
        NSString *name = [NSString stringWithFormat: @"Levels/Level%d", levelNum];
        _level1 = (Level *) [CCBReader load:name owner:self];
        [_level1Node addChild:_level1];

        [self addLetter1:140.0f positionx:60.0f];
    }
}

-(void)BGReplace2{
    // loop the level node to create infinite scene
    CGPoint levelWorldPosition = [_levelNode convertToWorldSpace:_level2Node.position];
    CGPoint levelScreenPosition = [self convertToNodeSpace:levelWorldPosition];
    
    if (levelScreenPosition.x <= (-1 * _level2.contentSize.width)) {
        _level2Node.position = ccp(_level2Node.position.x + 2 * _level2.contentSize.width, _level2Node.position.y);
        [_level2Node removeChild:_level2];
        int levelNum = (arc4random() % 3) + 1;
        NSString *name = [NSString stringWithFormat: @"Levels/Level%d", levelNum];
        _level2 = (Level *) [CCBReader load:name owner:self];
        [_level2Node addChild:_level2];
        
        [self addLetter2:240.0f positionx:-600.0f];
    }
}

- (void)addLetter1:(CGFloat)y positionx:(CGFloat)x{
    int randomLetter = CCRANDOM_0_1() * 100;
    NSString *LetterName = [NSString stringWithFormat:@"Letter/Letter%@",[self randomletter] ];
    
    Letter *letter = (Letter *)[CCBReader load:LetterName];
    CGPoint screenPosition = [self convertToNodeSpace:ccp(randomLetter+100 + x, y)];
    
    letter.position = screenPosition;
    
    [_level1Node addChild:letter];
    [_letters1 addObject:letter];
}

- (void)addLetter2:(CGFloat)y positionx:(CGFloat)x{
    int randomLetter = CCRANDOM_0_1() * 100;
    NSString *LetterName = [NSString stringWithFormat:@"Letter/Letter%@",[self randomletter] ];
    
    Letter *letter = (Letter *)[CCBReader load:LetterName];
    CGPoint screenPosition = [self convertToNodeSpace:ccp(randomLetter+100 + x, y)];
    letter.position = screenPosition;

    [_level2Node addChild:letter];
    [_letters2 addObject:letter];
}

-(NSString *)randomletter{
    int pickLetter = arc4random()%40;
    switch (pickLetter) {
        case 0:
            return @"Z";
            break;
            
        case 1:
            return @"B";
            break;
        
        case 2:
            return @"C";
            break;
            
        case 3:
            return @"D";
            break;
            
        case 4:
            return @"Y";
            break;
            
        case 5:
            return @"F";
            break;
            
        case 6:
            return @"G";
            break;
            
        case 7:
            return @"H";
            break;
            
        case 8:
            return @"X";
            break;
            
        case 9:
            return @"J";
            break;
            
        case 10:
            return @"K";
            break;
            
        case 11:
            return @"L";
            break;
            
        case 12:
            return @"M";
            break;
            
        case 13:
            return @"N";
            break;
            
        case 14:
            return @"W";
            break;
            
        case 15:
            return @"P";
            break;
            
        case 16:
            return @"Q";
            break;
            
        case 17:
            return @"R";
            break;
            
        case 18:
            return @"S";
            break;
            
        case 19:
            return @"T";
            break;
            
        case 20:
            return @"V";
            break;
            // A E I O U
        case 21:
            case 22:
            case 23:
            case 24:
            case 25:
            return @"U";
            break;
            
        case 26:
            return @"O";
            break;
            
        case 27:
            case 28:
            case 29:
            return @"I";
            break;
            
        case 30:
            case 31:
        case 32:
            case 33:
            case 34:
            case 35:
            return @"E";
            break;
            
        case 36:
            case 37:
            case 38:
            case 39:
            case 40:
            return @"A";
            break;
            
        default:
            break;
    }
    return @"";
}

#pragma mark - Touch Handling

- (void)touchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
    // this will get called every time the player touches the screen
    if (!_jumped) {
        _man.physicsBody.velocity = ccp(0,2200);
        OALSimpleAudio *jumpaudio = [OALSimpleAudio sharedInstance];
        [jumpaudio playEffect:@"jump.wav"];
        _jumped = TRUE;
        [self performSelector:@selector(resetJump) withObject:nil afterDelay:0.7f];
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

#pragma mark - Game Over

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

- (BOOL)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair Man:(CCNode *)Man c:(CCNode *)c {
    [c removeFromParent];
    NSString *letter = @"C";
    [word appendString:letter];
    _scoreLabel.string = [NSString stringWithFormat:@"%@", word];
    [self check];
    return NO;
}

- (BOOL)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair Man:(CCNode *)Man d:(CCNode *)d {
    [d removeFromParent];
    NSString *letter = @"D";
    [word appendString:letter];
    _scoreLabel.string = [NSString stringWithFormat:@"%@", word];
    [self check];
    return NO;
}

- (BOOL)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair Man:(CCNode *)Man e:(CCNode *)e {
    [e removeFromParent];
    NSString *letter = @"E";
    [word appendString:letter];
    _scoreLabel.string = [NSString stringWithFormat:@"%@", word];
    [self check];
    return NO;
}

- (BOOL)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair Man:(CCNode *)Man f:(CCNode *)f {
    [f removeFromParent];
    NSString *letter = @"F";
    [word appendString:letter];
    _scoreLabel.string = [NSString stringWithFormat:@"%@", word];
    [self check];
    return NO;
}

- (BOOL)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair Man:(CCNode *)Man g:(CCNode *)g {
    [g removeFromParent];
    NSString *letter = @"G";
    [word appendString:letter];
    _scoreLabel.string = [NSString stringWithFormat:@"%@", word];
    [self check];
    return NO;
}

- (BOOL)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair Man:(CCNode *)Man h:(CCNode *)h {
    [h removeFromParent];
    NSString *letter = @"H";
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

- (BOOL)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair Man:(CCNode *)Man j:(CCNode *)j {
    [j removeFromParent];
    NSString *letter = @"J";
    [word appendString:letter];
    _scoreLabel.string = [NSString stringWithFormat:@"%@", word];
    [self check];
    return NO;
}

- (BOOL)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair Man:(CCNode *)Man k:(CCNode *)k {
    [k removeFromParent];
    NSString *letter = @"K";
    [word appendString:letter];
    _scoreLabel.string = [NSString stringWithFormat:@"%@", word];
    [self check];
    return NO;
}

- (BOOL)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair Man:(CCNode *)Man l:(CCNode *)l {
    [l removeFromParent];
    NSString *letter = @"L";
    [word appendString:letter];
    _scoreLabel.string = [NSString stringWithFormat:@"%@", word];
    [self check];
    return NO;
}

- (BOOL)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair Man:(CCNode *)Man m:(CCNode *)m {
    [m removeFromParent];
    NSString *letter = @"M";
    [word appendString:letter];
    _scoreLabel.string = [NSString stringWithFormat:@"%@", word];
    [self check];
    return NO;
}

- (BOOL)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair Man:(CCNode *)Man n:(CCNode *)n {
    [n removeFromParent];
    NSString *letter = @"N";
    [word appendString:letter];
    _scoreLabel.string = [NSString stringWithFormat:@"%@", word];
    [self check];
    return NO;
}

- (BOOL)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair Man:(CCNode *)Man o:(CCNode *)o {
    [o removeFromParent];
    NSString *letter = @"O";
    [word appendString:letter];
    _scoreLabel.string = [NSString stringWithFormat:@"%@", word];
    [self check];
    return NO;
}

- (BOOL)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair Man:(CCNode *)Man p:(CCNode *)p {
    [p removeFromParent];
    NSString *letter = @"P";
    [word appendString:letter];
    _scoreLabel.string = [NSString stringWithFormat:@"%@", word];
    [self check];
    return NO;
}

- (BOOL)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair Man:(CCNode *)Man q:(CCNode *)q {
    [q removeFromParent];
    NSString *letter = @"Q";
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

- (BOOL)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair Man:(CCNode *)Man s:(CCNode *)s {
    [s removeFromParent];
    NSString *letter = @"S";
    [word appendString:letter];
    _scoreLabel.string = [NSString stringWithFormat:@"%@", word];
    [self check];
    return NO;
}

- (BOOL)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair Man:(CCNode *)Man t:(CCNode *)t {
    [t removeFromParent];
    NSString *letter = @"T";
    [word appendString:letter];
    _scoreLabel.string = [NSString stringWithFormat:@"%@", word];
    [self check];
    return NO;
}

- (BOOL)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair Man:(CCNode *)Man u:(CCNode *)u {
    [u removeFromParent];
    NSString *letter = @"U";
    [word appendString:letter];
    _scoreLabel.string = [NSString stringWithFormat:@"%@", word];
    [self check];
    return NO;
}

- (BOOL)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair Man:(CCNode *)Man v:(CCNode *)v {
    [v removeFromParent];
    NSString *letter = @"V";
    [word appendString:letter];
    _scoreLabel.string = [NSString stringWithFormat:@"%@", word];
    [self check];
    return NO;
}

- (BOOL)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair Man:(CCNode *)Man w:(CCNode *)w {
    [w removeFromParent];
    NSString *letter = @"W";
    [word appendString:letter];
    _scoreLabel.string = [NSString stringWithFormat:@"%@", word];
    [self check];
    return NO;
}

- (BOOL)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair Man:(CCNode *)Man x:(CCNode *)x {
    [x removeFromParent];
    NSString *letter = @"X";
    [word appendString:letter];
    _scoreLabel.string = [NSString stringWithFormat:@"%@", word];
    [self check];
    return NO;
}

- (BOOL)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair Man:(CCNode *)Man y:(CCNode *)y {
    [y removeFromParent];
    NSString *letter = @"Y";
    [word appendString:letter];
    _scoreLabel.string = [NSString stringWithFormat:@"%@", word];
    [self check];
    return NO;
}

- (BOOL)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair Man:(CCNode *)Man z:(CCNode *)z {
    [z removeFromParent];
    NSString *letter = @"Z";
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
