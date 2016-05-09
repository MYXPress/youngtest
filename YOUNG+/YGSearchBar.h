//
//  YGSearchBar.h
//  YOUNG+
//
//  Created by XPress on 15/10/5.
//  Copyright © 2015年 YOUNG+. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^SearchBlock)();

@interface YGSearchBar : UIView
@property (weak, nonatomic) IBOutlet UITextField *searchField;

/** 搜索 */
@property (nonatomic,copy) SearchBlock searchBlock;

@end
