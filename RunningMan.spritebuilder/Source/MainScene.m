#import "MainScene.h"

@implementation MainScene

- (void)startGame {     // Strat Button
//    CCLOG(@"play button pressed");
    
    CCScene *firstLevel = [CCBReader loadAsScene:@"Gameplay"];
    CCTransition *transition = [CCTransition transitionFadeWithDuration:0.8f];
    [[CCDirector sharedDirector] presentScene:firstLevel withTransition:transition];
}

@end
