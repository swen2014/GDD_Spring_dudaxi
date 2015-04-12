//
//  MainScenePlay.h
//  RunningMan
//
//  Created by steven on 4/10/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "CCNode.h"
#import "Man.h"

@interface MainScenePlay : CCNode <CCPhysicsCollisionDelegate>
{
    Man* _man;
    CCPhysicsNode* _physicsNode;
    float timeSinceObstacle;
}
-(void) initialize;
-(void) addLetter;

-(void) showScore;

@end
