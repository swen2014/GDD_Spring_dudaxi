//
//  PlayScene.h
//  RunningMan
//
//  Created by steven on 4/10/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "CCNode.h"
#import "MainScenePlay.h"
@interface PlayScene : MainScenePlay <CCPhysicsCollisionDelegate>

- (void) gameOver;

@end
