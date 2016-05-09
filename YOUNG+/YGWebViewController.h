//
//  WebViewController.h
//  TestWebView
//
//  Created by xuehan on 15/7/17.
//  Copyright (c) 2015年 xuehan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DefaultTipView.h"
#import "YGBaseViewController.h"
#import "HappyPartyModel.h"
@interface YGWebViewController : YGBaseViewController<DefaultTipViewDelegate>{
    DefaultTipView *defaultView;
    NSURLRequest *myRequest;
}

@property (nonatomic,copy) NSString *urlString;
@property (nonatomic,copy) NSString *webTitle;
@property (nonatomic,assign)YGWEBVIEW_TYPE ygwebviewType;
@property (nonatomic,retain)HappyPartyModel *happyPartyModel;

@end
