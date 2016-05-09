//
//  YGSearchBar.m
//  YOUNG+
//
//  Created by XPress on 15/10/5.
//  Copyright © 2015年 YOUNG+. All rights reserved.
//

#import "YGSearchBar.h"

@implementation YGSearchBar

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
- (IBAction)searchAction:(id)sender {
    if (self.searchBlock) {
        self.searchBlock();
    }
}

@end
