//
//  GamePlayScene.m
//  SpellingMan
//
//  Created by steven on 4/10/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "GamePlayScene.h"
#import "Man.h"



@implementation GamePlayScene
- (void)initialize
{
    // your code here
//    man = (Man*)[CCBReader load:@"Man"];
//    [_physicsNode addChild:man];
//    [self addObstacle];
    timeSinceObstacle = 0.0f;
}

-(void)update:(CCTime)delta
{
    // put update code here
    // Increment the time since the last obstacle was added
    timeSinceObstacle += delta; // delta is approximately 1/60th of a second
    
    // Check to see if two seconds have passed
    if (timeSinceObstacle > 2.0f)
    {
        // Add a new obstacle
//        [self addObstacle];
        
        // Then reset the timer.
        timeSinceObstacle = 0.0f;
    }
}

// put new methods here
//- (void)touchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
//    // this will get called every time the player touches the screen
//    [man jump];
//}

//- (void)update:(CCTime)delta {
//    _man.position = ccp(_man.position.x + delta * scrollSpeed, _man.position.y);
//}

@end
