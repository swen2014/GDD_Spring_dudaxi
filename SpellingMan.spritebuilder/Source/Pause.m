//
//  Pause.m
//  SpellingMan
//
//  Created by steven on 5/2/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "Pause.h"

@implementation Pause
- (void)didLoadFromCCB{
    self.positionType = CCPositionTypeNormalized;
    self.position = ccp(0.5, 0.5);
}
@end
