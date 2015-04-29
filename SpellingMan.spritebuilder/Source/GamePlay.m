//
//  GamePlay.m
//  SpellingMan
//
//  Created by steven on 4/10/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "GamePlay.h"
#import "Man.h"
#import "Level.h"
#import "test.h"
#import "Letter.h"
#import "Lose.h"
#import "Instruction.h"

#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKShareKit/FBSDKShareKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
//
static const CGFloat scrollSpeed = 160.f;
static NSString *const highscore = @"highest";

@implementation GamePlay{
    Man *_man;

    CCPhysicsNode *_physicsNode;
    
    CCNode *_levelNode;
    CCNode *_level1Node;
    CCNode *_level2Node;

    Level *_level1;
    Level *_level2;
    
    CCLabelTTF *_scoreLabel;
    CCLabelTTF *_goalLabel;
    CCLabelTTF *_countLabel;
    
    BOOL _jumped;
    BOOL _gameOver;
    BOOL _begin;
    BOOL _stop;// Flag to determined if the game pause or not
    BOOL _donotcalltwice;
    
    CCNode *_ground1;
    CCNode *_ground2;
    NSArray *_grounds;
    
    NSMutableArray *_letters1;
    NSMutableArray *_letters2;
    
    NSArray *data;
    NSMutableString *word;
    NSString *goal;
    NSMutableArray *solution;
    char solution1[10];
    int score;
    
    NSMutableArray *offScreen;
    
    CCButton *pause;
    CCButton *ok;
    
    Instruction *guide;
}

- (void)didLoadFromCCB
{
    self.userInteractionEnabled = TRUE;
    _physicsNode.collisionDelegate = self;
    _donotcalltwice = NO;
    
    _level1 = (Level *) [CCBReader load:@"Levels/Level4" owner:self];
    _level2 = (Level *) [CCBReader load:@"Levels/Level2" owner:self];

    [_level1Node addChild:_level1];
    [_level2Node addChild:_level2];
    
    _man = (Man *)[CCBReader load:@"Man"];
    [_physicsNode addChild:_man];
    
    [self initilization];
    
    [self instruction];
    
    [self generateWord:data];
}

- (void)initilization{
    word = [[NSMutableString alloc] initWithCapacity:10];
        
    data = [[NSArray alloc] initWithObjects:@"cmu", @"dudaxi",@"wendy", @"jeremy", @"curry",
            @"dion", @"larson",@"sv",nil];
    solution = [NSMutableArray array];
//    [[OALSimpleAudio sharedInstance] playBg:@".mp3" loop:YES];
    
    _letters1 = [NSMutableArray array];
    _letters2 = [NSMutableArray array];
    _grounds = @[_ground1, _ground2];
}

#pragma mark - Guide Scene

- (void)instruction{
    guide = (Instruction *) [CCBReader load:@"Guide" owner:self];
    [self addChild:guide];
    pause.enabled = NO;
    self.userInteractionEnabled = FALSE;
    self.paused = YES;
    _begin = FALSE;
}

// Button OK
-(void)OK {
    _begin = TRUE;
    [guide removeFromParent];
    pause.enabled = YES;
    self.userInteractionEnabled = TRUE;
    self.paused = NO;
}


#pragma mark - Word Matching

- (void)generateWord:(NSArray *)resource{
    int num = (arc4random() % resource.count);
    goal = [resource objectAtIndex:num];
    NSString *cap = [goal uppercaseString];
    for (int i=0; i < cap.length; i++) {
        char c = [cap characterAtIndex:i];
        [solution addObject:[NSString stringWithFormat:@"%c",c]];
    }
    _goalLabel.string = [NSString stringWithFormat:@"Goal:%@", cap];
}

- (void)removeExist
{
    NSString *temp = [NSString stringWithFormat:@"%@", word ];
    for (int i= 0; i<word.length; i++) {
        [solution removeObject:[NSString stringWithFormat:@"%c", [temp characterAtIndex:i]]];
    }
}

- (void)check{
    NSUInteger len = [word length];
    NSUInteger len1 = [goal length];
    if (len > len1) {
        _gameOver = YES;
    }
    if(len < len1){
        if ([ [goal uppercaseString] hasPrefix:word]) {
        }else{
            _gameOver = YES;
        }
    }
    if (len == len1)
{    BOOL _gameWin = [[goal uppercaseString] isEqualToString:word];
    if (_gameWin) {
        score++;
        _countLabel.string = [NSString stringWithFormat:@"%d", score];
        [word setString:@""];
        _scoreLabel.string = [NSString stringWithFormat:@"%@", word];
        [solution removeAllObjects];
//        NSLog(@"word:%@", word);
//        NSLog(@"solution %@", [solution lastObject]);
        [self generateWord:data];
    }else{
        _gameOver = YES;
    }
    }
}

//-(void)resetcheck{
//    _donotcalltwice = TRUE;
//}

#pragma mark - update

-(void)update:(CCTime)delta
{
    _man.position = ccp(100, _man.position.y);
    // Move the LevelNode to shift left
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
    
    // loop the scene and load different level
    [self BGReplace1];
    [self BGReplace2];
    
    
    // remove the out screen letters
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
        
        if (letterScreenPosition.x < 0) {
            if (!offScreen) {
                offScreen = [NSMutableArray array];
            }
            [offScreen addObject:letter];
        }
    }

    for (CCNode *letterToRemove in offScreen) {
        [letterToRemove removeFromParent];
        if ([_letters1 containsObject:letterToRemove]) {
            [_letters1 removeObject:letterToRemove];
        }
        if([_letters2 containsObject:letterToRemove]){
            [_letters2 removeObject:letterToRemove];
        }
    }
    
    
    if (!_gameOver)
    {
        @try
        {
            _man.physicsBody.velocity = ccp(0, clampf(_man.physicsBody.velocity.y, -MAXFLOAT, 290.f));
            [self removeExist];
        }
    @catch(NSException* ex)
        {
            
        }
    }else{
//        _gameOver = NO;
//        NSLog(@"collision");
        self.paused = YES;
        [self LosePopup];
    }
}

-(void)BGReplace1{
    // loop the level node to create infinite scene
    CGPoint levelWorldPosition = [_levelNode convertToWorldSpace:_level1Node.position];
    CGPoint levelScreenPosition = [self convertToNodeSpace:levelWorldPosition];
    
    if (levelScreenPosition.x <= (-1 * _level1.contentSize.width)) {
        _level1Node.position = ccp(_level1Node.position.x + 2 * _level1.contentSize.width, _level1Node.position.y);
        [_level1Node removeChild:_level1];
        int levelNum = (arc4random() % 2) + 1;
        NSString *name = [NSString stringWithFormat: @"Levels/Level%d", levelNum];
        _level1 = (Level *) [CCBReader load:name owner:self];
        [_level1Node addChild:_level1];

        [self addLetter1:250.0f positionx:60.0f];
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

        [self random:240.0f position_y:60.0f];
        [self random:80.0f position_y:230.0f];
    }
}

#pragma mark - Object adding

- (void)addLetter1:(CGFloat)y positionx:(CGFloat)x{
    int randomLetter = arc4random()%50;
    NSString *LetterName = [NSString stringWithFormat:@"Letter/Letter%@",[self randomletter] ];
    
    Letter *letter = (Letter *)[CCBReader load:LetterName];
    CGPoint screenPosition = [self convertToNodeSpace:ccp(randomLetter + 100 + x, y)];
    
    letter.position = screenPosition;
    
    [_level1Node addChild:letter];
    [_letters1 addObject:letter];
}

//- (void)addLetter2:(CGFloat)y positionx:(CGFloat)x{
//    int randomLetter = CCRANDOM_0_1() * 100;
//    NSString *LetterName = [NSString stringWithFormat:@"Letter/Letter%@",[self randomletter] ];
//    Letter *letter = (Letter *)[CCBReader load:LetterName];
//    CGPoint screenPosition = [self convertToNodeSpace:ccp(randomLetter+100 + x, y)];
//    letter.position = screenPosition;
//
//    [_level2Node addChild:letter];
//    [_letters2 addObject:letter];
//}

// used to generate letters in the GOAL to appear on the level1 scene
-(void)random:(CGFloat)x position_y:(CGFloat)y{
    int length = (int)solution.count;
    int k = arc4random()% length;
    int randomLetter = arc4random() % 50;
    NSString *random_result = [solution objectAtIndex:k];
    NSString *letterName = [NSString stringWithFormat:@"Letter/Letter%@", random_result];
    Letter *letter = (Letter *)[CCBReader load:letterName];
    CGPoint screenPosition = [self convertToNodeSpace:ccp(randomLetter + x, y)];
    letter.position = screenPosition;
    
    [_level2Node addChild:letter];
    [_letters2 addObject:letter];
}

// used to generate random letter to appear on the level1 scene
-(NSString *)randomletter{
    int pickLetter = (arc4random() % 1310)+ 261; //+ 261;//%1310

    if (pickLetter<=10 && (400 < pickLetter <=490)) {
        return @"A";
    }
    if (10 < pickLetter && pickLetter <= 20){
        return @"B";
    }
    if ((20 < pickLetter && pickLetter <= 30) || (490 < pickLetter && pickLetter <= 550)){
        return @"C";
    }
    if ((30 < pickLetter && pickLetter <= 40) || (550 < pickLetter&& pickLetter <= 670)){
        return @"D";
    }
    if ((40 < pickLetter && pickLetter<= 50) || (670 < pickLetter && pickLetter<= 790)){
        return @"E";
    }
    if (50 < pickLetter && pickLetter<= 60){
        return @"F";
    }
    if (60 < pickLetter && pickLetter<= 70){
        return @"G";
    }
    if ((70 < pickLetter && pickLetter<= 80) || (790 < pickLetter && pickLetter<= 820)){
        return @"H";
    }else if ((80 < pickLetter && pickLetter<= 90) || (820 < pickLetter && pickLetter<= 880)){
        return @"I";
    }else if ((90 < pickLetter && pickLetter<= 100) || (880 < pickLetter && pickLetter<= 910)){
        return @"J";
    }else if ((100 < pickLetter && pickLetter<= 110) || (910 < pickLetter && pickLetter<= 940)){
        return @"K";
    }else if ((110 < pickLetter && pickLetter<= 120) || (940 < pickLetter && pickLetter<= 1000)){
        return @"L";
    }else if ((120 < pickLetter && pickLetter<= 130) || (1000 < pickLetter && pickLetter<= 1090)){
        return @"M";
    }else if ((130 < pickLetter && pickLetter <= 140) || (1090 < pickLetter && pickLetter <= 1180)){
        return @"N";
    }else if ((140 < pickLetter && pickLetter <= 150) || (1180 < pickLetter && pickLetter <= 1300)){
        return @"O";
    }else if (150 < pickLetter && pickLetter <= 160){
        return @"P";
    }else if (160 < pickLetter && pickLetter <= 170){
        return @"Q";
    }else if ((170 < pickLetter && pickLetter <= 180) || (1300 < pickLetter && pickLetter<= 1360)){
        return @"R";
    }else if ((180 < pickLetter && pickLetter <= 190) || (1360 < pickLetter && pickLetter<= 1420)){
        return @"S";
    }else if (190 < pickLetter && pickLetter <= 200){
        return @"T";
    }else if ((200 < pickLetter && pickLetter <= 210) || (1420 < pickLetter && pickLetter<= 1480)){
        return @"U";
    }else if (210 < pickLetter && pickLetter<= 220){
        return @"V";
    }else if ((220 < pickLetter && pickLetter<= 230) || (1480 < pickLetter && pickLetter<= 1510)){
        return @"W";
    }else if ((230 < pickLetter && pickLetter<= 240) || (260 < pickLetter && pickLetter<= 400)){
        return @"X";
    }else if ((240 < pickLetter && pickLetter<= 250) || (1510 < pickLetter && pickLetter <= 1570)){
        return @"Y";
    }else if (250 < pickLetter && pickLetter<= 260){
        return @"Z";
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
        [self performSelector:@selector(resetJump) withObject:nil afterDelay:0.9f];
    }
}

- (void)resetJump{
    _jumped = FALSE;
}

#pragma mark - Button

-(void)Restart{
    [self gameOver];
}

- (void)Pause{
    if (!_stop) {
        self.paused = YES;
        self.userInteractionEnabled = FALSE;
//        [[OALSimpleAudio sharedInstance] stopBg];
        _stop = YES;
    }else{
        self.paused = NO;
        self.userInteractionEnabled = TRUE;
        _stop = NO;
    }
}

#pragma mark - Game Over

-(void)LosePopup{
    Lose *popup = (Lose *)[CCBReader load:@"Lose" owner:self];
    [self addChild:popup];
    self.paused = YES;
    self.userInteractionEnabled = FALSE;
    pause.enabled = NO;
    NSLog(@"word %@, solution %@", word, [solution lastObject]);
    
    if([[NSUserDefaults standardUserDefaults] objectForKey:highscore]==nil){
        [[NSUserDefaults standardUserDefaults] setInteger:score forKey:highscore];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
//        level = 1;
//    }else{
//        [[NSUserDefaults standardUserDefaults] setInteger:5 forKey:highscore];
//        int test = (int)[[NSUserDefaults standardUserDefaults] integerForKey:highscore];
//        NSLog(@"%d", test);
//    }
}

- (void)gameOver {
    CCScene *restartScene = [CCBReader loadAsScene:@"GamePlay"];
    CCTransition *transition = [CCTransition transitionFadeWithDuration:0.8f];
    [[CCDirector sharedDirector] presentScene:restartScene withTransition:transition];
}

#pragma mark - Collision Handle

- (BOOL)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair Man:(CCNode *)Man a:(CCNode *)a {
    if (!_donotcalltwice) {
        _donotcalltwice = YES;
        [a removeFromParent];
        NSString *letter = @"A";
        NSLog(@"%@", letter);
        [word appendString:letter];
        _scoreLabel.string = [NSString stringWithFormat:@"%@", word];
        [_scoreLabel runAction:[CCActionDelay actionWithDuration: 1.1f]];
        [self check];
        return YES;
    }
    return [pair ignore];
}

- (void)ccPhysicsCollisionPostSolve:(CCPhysicsCollisionPair *)pair Man:(CCNode *)Man a:(CCNode *)a{
    _donotcalltwice = NO;
}


- (BOOL)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair Man:(CCNode *)Man b:(CCNode *)b {
    if (!_donotcalltwice) {
        _donotcalltwice = YES;
    [b removeFromParent];
    NSString *letter = @"B";
    [word appendString:letter];
    _scoreLabel.string = [NSString stringWithFormat:@"%@", word];
    [self check];
    return YES;
    }
    return [pair ignore];
}

- (void)ccPhysicsCollisionPostSolve:(CCPhysicsCollisionPair *)pair Man:(CCNode *)Man b:(CCNode *)b{
    _donotcalltwice = NO;
}

- (BOOL)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair Man:(CCNode *)Man c:(CCNode *)c {
if (!_donotcalltwice) {
    _donotcalltwice = YES;
    [c removeFromParent];
    NSString *letter = @"C";
    [word appendString:letter];
    _scoreLabel.string = [NSString stringWithFormat:@"%@", word];
    [self check];
    return YES;
}
    return [pair ignore];
}

- (void)ccPhysicsCollisionPostSolve:(CCPhysicsCollisionPair *)pair Man:(CCNode *)Man c:(CCNode *)c{
    _donotcalltwice = NO;
}

- (BOOL)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair Man:(CCNode *)Man d:(CCNode *)d {
        if (!_donotcalltwice) {
            _donotcalltwice = YES;
    [d removeFromParent];
    NSString *letter = @"D";
    [word appendString:letter];
    _scoreLabel.string = [NSString stringWithFormat:@"%@", word];
    [self check];
    return YES;
        }
    return [pair ignore];
}

- (void)ccPhysicsCollisionPostSolve:(CCPhysicsCollisionPair *)pair Man:(CCNode *)Man d:(CCNode *)d{
    _donotcalltwice = NO;
}

- (BOOL)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair Man:(CCNode *)Man e:(CCNode *)e {
        if (!_donotcalltwice) {
            _donotcalltwice = YES;
    [e removeFromParent];
    NSString *letter = @"E";
    [word appendString:letter];
    _scoreLabel.string = [NSString stringWithFormat:@"%@", word];
    [self check];
    return YES;
        }
    return [pair ignore];
}

- (void)ccPhysicsCollisionPostSolve:(CCPhysicsCollisionPair *)pair Man:(CCNode *)Man e:(CCNode *)e{
    _donotcalltwice = NO;
}

- (BOOL)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair Man:(CCNode *)Man f:(CCNode *)f {
        if (!_donotcalltwice) {
            _donotcalltwice = YES;
    [f removeFromParent];
    NSString *letter = @"F";NSLog(@"%@", letter);
    [word appendString:letter];
    _scoreLabel.string = [NSString stringWithFormat:@"%@", word];
    [self check];
    return YES;
        }
    return [pair ignore];
}

- (void)ccPhysicsCollisionPostSolve:(CCPhysicsCollisionPair *)pair Man:(CCNode *)Man f:(CCNode *)f{
    _donotcalltwice = NO;
}

- (BOOL)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair Man:(CCNode *)Man g:(CCNode *)g {
        if (!_donotcalltwice) {
            _donotcalltwice = YES;
    [g removeFromParent];
    NSString *letter = @"G";NSLog(@"%@", letter);
    [word appendString:letter];
    _scoreLabel.string = [NSString stringWithFormat:@"%@", word];
    [self check];
    return YES;
        }
    return [pair ignore];
}

- (void)ccPhysicsCollisionPostSolve:(CCPhysicsCollisionPair *)pair Man:(CCNode *)Man g:(CCNode *)g{
    _donotcalltwice = NO;
}

- (BOOL)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair Man:(CCNode *)Man h:(CCNode *)h {
        if (!_donotcalltwice) {
            _donotcalltwice = YES;
    [h removeFromParent];
    NSString *letter = @"H";NSLog(@"%@", letter);
    [word appendString:letter];
    _scoreLabel.string = [NSString stringWithFormat:@"%@", word];
    [self check];
    return YES;
        }
    return [pair ignore];
}

- (void)ccPhysicsCollisionPostSolve:(CCPhysicsCollisionPair *)pair Man:(CCNode *)Man h:(CCNode *)h{
    _donotcalltwice = NO;
}

- (BOOL)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair Man:(CCNode *)Man i:(CCNode *)i {
        if (!_donotcalltwice) {
            _donotcalltwice = YES;
    [i removeFromParent];
    NSString *letter = @"I";NSLog(@"%@", letter);
    [word appendString:letter];
    _scoreLabel.string = [NSString stringWithFormat:@"%@", word];
    [self check];
    return YES;
        }
    return [pair ignore];
}

- (void)ccPhysicsCollisionPostSolve:(CCPhysicsCollisionPair *)pair Man:(CCNode *)Man i:(CCNode *)i{
    _donotcalltwice = NO;
}

- (BOOL)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair Man:(CCNode *)Man j:(CCNode *)j {
        if (!_donotcalltwice) {
            _donotcalltwice = YES;
    [j removeFromParent];
    NSString *letter = @"J";NSLog(@"%@", letter);
    [word appendString:letter];
    _scoreLabel.string = [NSString stringWithFormat:@"%@", word];
    [self check];
    return YES;
        }
    return [pair ignore];
}

- (void)ccPhysicsCollisionPostSolve:(CCPhysicsCollisionPair *)pair Man:(CCNode *)Man j:(CCNode *)j{
    _donotcalltwice = NO;
}

- (BOOL)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair Man:(CCNode *)Man k:(CCNode *)k {
        if (!_donotcalltwice) {
            _donotcalltwice = YES;
    [k removeFromParent];
    NSString *letter = @"K";NSLog(@"%@", letter);
    [word appendString:letter];
    _scoreLabel.string = [NSString stringWithFormat:@"%@", word];
    [self check];
    return YES;
        }
    return [pair ignore];
}

- (void)ccPhysicsCollisionPostSolve:(CCPhysicsCollisionPair *)pair Man:(CCNode *)Man k:(CCNode *)k{
    _donotcalltwice = NO;
}

- (BOOL)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair Man:(CCNode *)Man l:(CCNode *)l {
        if (!_donotcalltwice) {
            _donotcalltwice = YES;
    [l removeFromParent];
    NSString *letter = @"L";NSLog(@"%@", letter);
    [word appendString:letter];
    _scoreLabel.string = [NSString stringWithFormat:@"%@", word];
    [self check];
    return YES;
        }
    return [pair ignore];
}

- (void)ccPhysicsCollisionPostSolve:(CCPhysicsCollisionPair *)pair Man:(CCNode *)Man l:(CCNode *)l{
    _donotcalltwice = NO;
}

- (BOOL)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair Man:(CCNode *)Man m:(CCNode *)m {
        if (!_donotcalltwice) {
            _donotcalltwice = YES;
    [m removeFromParent];
    NSString *letter = @"M";NSLog(@"%@", letter);
    [word appendString:letter];
    _scoreLabel.string = [NSString stringWithFormat:@"%@", word];
    [self check];
    return YES;
        }
    return [pair ignore];
}

- (void)ccPhysicsCollisionPostSolve:(CCPhysicsCollisionPair *)pair Man:(CCNode *)Man m:(CCNode *)m{
    _donotcalltwice = NO;
}

- (BOOL)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair Man:(CCNode *)Man n:(CCNode *)n {
        if (!_donotcalltwice) {
            _donotcalltwice = YES;
    [n removeFromParent];
    NSString *letter = @"N";NSLog(@"%@", letter);
    [word appendString:letter];
    _scoreLabel.string = [NSString stringWithFormat:@"%@", word];
    [self check];
    return YES;
        }
    return [pair ignore];
}

- (void)ccPhysicsCollisionPostSolve:(CCPhysicsCollisionPair *)pair Man:(CCNode *)Man n:(CCNode *)n{
    _donotcalltwice = NO;
}

- (BOOL)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair Man:(CCNode *)Man o:(CCNode *)o {
        if (!_donotcalltwice) {
            _donotcalltwice = YES;
    [o removeFromParent];
    NSString *letter = @"O";NSLog(@"%@", letter);
    [word appendString:letter];
    _scoreLabel.string = [NSString stringWithFormat:@"%@", word];
    [self check];
    return YES;
        }
    return [pair ignore];
}

- (void)ccPhysicsCollisionPostSolve:(CCPhysicsCollisionPair *)pair Man:(CCNode *)Man o:(CCNode *)o{
    _donotcalltwice = NO;
}

- (BOOL)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair Man:(CCNode *)Man p:(CCNode *)p {
        if (!_donotcalltwice) {
            _donotcalltwice = YES;
    [p removeFromParent];
    NSString *letter = @"P";NSLog(@"%@", letter);
    [word appendString:letter];
    _scoreLabel.string = [NSString stringWithFormat:@"%@", word];
    [self check];
    return YES;
        }
    return [pair ignore];
}

- (void)ccPhysicsCollisionPostSolve:(CCPhysicsCollisionPair *)pair Man:(CCNode *)Man p:(CCNode *)p{
    _donotcalltwice = NO;
}

- (BOOL)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair Man:(CCNode *)Man q:(CCNode *)q {
        if (!_donotcalltwice) {
            _donotcalltwice = YES;
    [q removeFromParent];
    NSString *letter = @"Q";NSLog(@"%@", letter);
    [word appendString:letter];
    _scoreLabel.string = [NSString stringWithFormat:@"%@", word];
    [self check];
    return YES;
        }
    return [pair ignore];
}

- (void)ccPhysicsCollisionPostSolve:(CCPhysicsCollisionPair *)pair Man:(CCNode *)Man q:(CCNode *)q{
    _donotcalltwice = NO;
}

- (BOOL)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair Man:(CCNode *)Man r:(CCNode *)r {
        if (!_donotcalltwice) {
            _donotcalltwice = YES;
    [r removeFromParent];
    NSString *letter = @"R";NSLog(@"%@", letter);
    [word appendString:letter];
    _scoreLabel.string = [NSString stringWithFormat:@"%@", word];
    [self check];
    return YES;
        }
    return [pair ignore];
}

- (void)ccPhysicsCollisionPostSolve:(CCPhysicsCollisionPair *)pair Man:(CCNode *)Man r:(CCNode *)r{
    _donotcalltwice = NO;
}

- (BOOL)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair Man:(CCNode *)Man s:(CCNode *)s {
        if (!_donotcalltwice) {
            _donotcalltwice = YES;
    [s removeFromParent];
    NSString *letter = @"S";NSLog(@"%@", letter);
    [word appendString:letter];
    _scoreLabel.string = [NSString stringWithFormat:@"%@", word];
    [self check];
    return YES;
        }
    return [pair ignore];
}

- (void)ccPhysicsCollisionPostSolve:(CCPhysicsCollisionPair *)pair Man:(CCNode *)Man s:(CCNode *)s{
    _donotcalltwice = NO;
}

- (BOOL)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair Man:(CCNode *)Man t:(CCNode *)t {
        if (!_donotcalltwice) {
            _donotcalltwice = YES;
    [t removeFromParent];
    NSString *letter = @"T";NSLog(@"%@", letter);
    [word appendString:letter];
    _scoreLabel.string = [NSString stringWithFormat:@"%@", word];
    [self check];
    return YES;
        }
    return [pair ignore];
}

- (void)ccPhysicsCollisionPostSolve:(CCPhysicsCollisionPair *)pair Man:(CCNode *)Man t:(CCNode *)t{
    _donotcalltwice = NO;
}

- (BOOL)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair Man:(CCNode *)Man u:(CCNode *)u {
        if (!_donotcalltwice) {
            _donotcalltwice = YES;
    [u removeFromParent];
    NSString *letter = @"U";NSLog(@"%@", letter);
    [word appendString:letter];
    _scoreLabel.string = [NSString stringWithFormat:@"%@", word];
    [self check];
    return YES;
        }
    return [pair ignore];
}

- (void)ccPhysicsCollisionPostSolve:(CCPhysicsCollisionPair *)pair Man:(CCNode *)Man u:(CCNode *)u{
    _donotcalltwice = NO;
}

- (BOOL)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair Man:(CCNode *)Man v:(CCNode *)v {
        if (!_donotcalltwice) {
            _donotcalltwice = YES;
    [v removeFromParent];
    NSString *letter = @"V";NSLog(@"%@", letter);
    [word appendString:letter];
    _scoreLabel.string = [NSString stringWithFormat:@"%@", word];
    [self check];
    return YES;
        }
    return [pair ignore];
}

- (void)ccPhysicsCollisionPostSolve:(CCPhysicsCollisionPair *)pair Man:(CCNode *)Man v:(CCNode *)v{
    _donotcalltwice = NO;
}

- (BOOL)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair Man:(CCNode *)Man w:(CCNode *)w {
        if (!_donotcalltwice) {
            _donotcalltwice = YES;
    [w removeFromParent];
    NSString *letter = @"W";NSLog(@"%@", letter);
    [word appendString:letter];
    _scoreLabel.string = [NSString stringWithFormat:@"%@", word];
    [self check];
    return YES;
        }
    return [pair ignore];
}

- (void)ccPhysicsCollisionPostSolve:(CCPhysicsCollisionPair *)pair Man:(CCNode *)Man w:(CCNode *)w{
    _donotcalltwice = NO;
}

- (BOOL)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair Man:(CCNode *)Man x:(CCNode *)x {
        if (!_donotcalltwice) {
            _donotcalltwice = YES;
    [x removeFromParent];
    NSString *letter = @"X";NSLog(@"%@", letter);
    [word appendString:letter];
    _scoreLabel.string = [NSString stringWithFormat:@"%@", word];
    [self check];
    return YES;
        }
    return [pair ignore];
}

- (void)ccPhysicsCollisionPostSolve:(CCPhysicsCollisionPair *)pair Man:(CCNode *)Man x:(CCNode *)x{
    _donotcalltwice = NO;
}

- (BOOL)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair Man:(CCNode *)Man y:(CCNode *)y {
        if (!_donotcalltwice) {
            _donotcalltwice = YES;
    [y removeFromParent];
    NSString *letter = @"Y";NSLog(@"%@", letter);
    [word appendString:letter];
    _scoreLabel.string = [NSString stringWithFormat:@"%@", word];
    [self check];
    return YES;
        }
    return [pair ignore];
}

- (void)ccPhysicsCollisionPostSolve:(CCPhysicsCollisionPair *)pair Man:(CCNode *)Man y:(CCNode *)y{
    _donotcalltwice = NO;
}

- (BOOL)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair Man:(CCNode *)Man z:(CCNode *)z {
        if (!_donotcalltwice) {
            _donotcalltwice = YES;
    [z removeFromParent];
    NSString *letter = @"Z";NSLog(@"%@", letter);
    [word appendString:letter];
    _scoreLabel.string = [NSString stringWithFormat:@"%@", word];
    [self check];
    return YES;
        }
    return [pair ignore];
}

- (void)ccPhysicsCollisionPostSolve:(CCPhysicsCollisionPair *)pair Man:(CCNode *)Man z:(CCNode *)z{
    _donotcalltwice = NO;
}

- (BOOL)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair Man:(CCNode *)Man poo:(CCNode *)poo {
    [poo removeFromParent];
    [self LosePopup];
//    _physicsNode.collisionDelegate = nil;
    return NO;
}


-(void) shareToFacebook {
    FBSDKShareLinkContent *content = [[FBSDKShareLinkContent alloc] init];
    
    // this should link to FB page for your app or AppStore link if published
    content.contentURL = [NSURL URLWithString:@"https://www.facebook.com/makeschool"];
    // URL of image to be displayed alongside post
    content.imageURL = [NSURL URLWithString:@"https://git.makeschool.com/MakeSchool-Tutorials/News/f744d331484d043a373ee2a33d63626c352255d4//663032db-cf16-441b-9103-c518947c70e1/cover_photo.jpeg"];
    // title of post
    content.contentTitle = [NSString stringWithFormat:@"My Test!"];
    // description/body of post
    content.contentDescription = @"Test ";
}
@end
