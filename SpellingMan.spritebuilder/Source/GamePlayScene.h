//
//  GamePlayScene.h
//  SpellingMan
//
//  Created by steven on 4/10/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "CCNode.h"
#import "Man.h"

@interface GamePlayScene : CCNode
{
// define variables here;
//Man*     man;
//CCPhysicsNode *_physicsNode;
float timeSinceObstacle;
}

-(void) initialize;

@end
