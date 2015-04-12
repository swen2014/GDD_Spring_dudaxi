#import "MainScene.h"

@implementation MainScene

-(void) Start{
    NSLog(@"OK");
    CCScene *gameplayScene = [CCBReader loadAsScene:@"Gameplay"];
    [[CCDirector sharedDirector] replaceScene:gameplayScene];
    
}

-(void)gameOver{
    NSLog(@"Gameover");
}

@end
