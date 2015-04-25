#import "MainScene.h"
//#import <FacebookSDK/FacebookSDK.h>
#import "CCTextureCache.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKShareKit/FBSDKShareKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>

@implementation MainScene{
    FBSDKLoginButton *loginButton;
    UIView *view;
}

-(void) Start{
//    NSLog(@"Start Button OK");
    CCScene *gameplayScene = [CCBReader loadAsScene:@"GamePlay"];
    [[CCDirector sharedDirector] replaceScene:gameplayScene];
    [loginButton removeFromSuperview];
}

-(void)gameOver{
    NSLog(@"Gameover");
}

// uncomment to add in FB login button -- needed for other features like
// OpenGraph posts
-(void) onEnter {
  [super onEnter];

  loginButton = [[FBSDKLoginButton alloc] init];
  view = [CCDirector sharedDirector].view;
  loginButton.center = ccpAdd(view.center, CGPointMake(0, 120));
  [view addSubview:loginButton];
}

@end
