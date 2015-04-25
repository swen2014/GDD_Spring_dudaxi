//
//  Instruction.m
//  SpellingMan
//
//  Created by steven on 4/22/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "Instruction.h"

@implementation Instruction
- (void)didLoadFromCCB{
    self.positionType = CCPositionTypeNormalized;
    self.position = ccp(0.5, 0.5);
}
@end
