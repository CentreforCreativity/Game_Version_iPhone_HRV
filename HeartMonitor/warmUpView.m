//
//  UIView+warmUpView.m
//  HeartMonitor
//
//  Created by Dimitrios Zampelis on 07/12/2015.
//  Copyright © 2015 GENIESOFT STUDIOS. All rights reserved.
//

#import "warmUpView.h"

@implementation UIView (warmUpView)



-(void)animateIndicator{
    
    __block int i =0;
        [UIImageView animateWithDuration:i
                                   delay:0.0
                                 options:UIViewAnimationOptionCurveLinear
                              animations:^{
                                  i+=100;

                                  //moving the cloud across the screen here
                              }
                              completion:^(BOOL finished) {
                                  if (finished) {
                                      NSLog(@"Done!");
                                      [self animateIndicator];
                                  }
                              }];
}

@end




