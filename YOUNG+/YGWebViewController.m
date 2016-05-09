//
//  WebViewController.m
//  TestWebView
//
//  Created by xuehan on 15/7/17.
//  Copyright (c) 2015年 xuehan. All rights reserved.
//

#import "YGWebViewController.h"
#import "UnpreventableUILongPressGestureRecognizer.h"
#import "UIWebView+WebViewAdditions.h"
#import "CoreDateManager.h"
#import "ChatScreenViewCtrl.h"
#import "YGCommentTools.h"
#import "JoinPartyMsgCtrl.h"
#import "UIView+Extend.h"
#define SCREEN_SIZE [UIScreen mainScreen].bounds.size

@interface YGWebViewController ()<UIWebViewDelegate,UIActionSheetDelegate>{
    UIActionSheet *_actionActionSheet;
    NSString *selectedLinkURL;
    NSString *selectedImageURL;
    CoreDateManager *coreData;
}
@property (nonatomic,strong) UIWebView *webView;

@property (nonatomic,copy) NSString *str;
@end

@implementation YGWebViewController

#pragma mark - 初始化
- (void)viewDidLoad {
    [super viewDidLoad];
    
    _str = [NSString stringWithFormat:@"%@#",self.urlString];
    
    _webView = [[UIWebView alloc] init];
    _webView.frame = CGRectMake(0, 64, SCREEN_SIZE.width, SCREEN_SIZE.height);
    [self.view addSubview:_webView];
    self.webView.backgroundColor=[UIColor whiteColor];

    _webView.delegate  =self;
    
    NSURL *url = [NSURL URLWithString:_urlString];
    myRequest = [NSURLRequest requestWithURL:url];
    [self.webView loadRequest:myRequest];
    
    [self addGesture];
    [self initDefaultView];
    
}

#pragma mark - ---------------Overwrite---------------

//子类自定义nav
-(void)initCustomerNavView{
    self.navbarHeadView.centerSegmentBtn.hidden = YES;
    self.navbarHeadView.navTitle.hidden = NO;
    [self.navbarHeadView.leftBtn setTitle:NAVBAR_LEFTBACK_TITLE forState:UIControlStateNormal];
    
    if (self.ygwebviewType == YGWEBVIEW_TYPE_SHOW_RIGHT_PARTY) {//参加party
        self.navbarHeadView.rightBtn.hidden = NO;
        [self setRightBtnStatus];
    }else{
        coreData = [[CoreDateManager alloc] init];
        ContactListModel *model = [coreData selectUserFromContactList:TEST_USER_ID];
        if (model) {
            if (self.ygwebviewType == YGWEBVIEW_TYPE_SHOW_RIGHT_BTN) {
                self.navbarHeadView.rightBtn.hidden = NO;
                [self.navbarHeadView.rightBtn setTitle:@"直接聊天" forState:UIControlStateNormal];
            }else{
                self.navbarHeadView.rightBtn.hidden = YES;
            }
        }else{
            self.navbarHeadView.rightBtn.hidden = YES;
        }
    }
    
}

/**报名活动的H5才用到*/
-(void)setRightBtnStatus{
    
    if ([_happyPartyModel.hJoinState isEqualToString:@"0"]) {//未报名
        [self setHightBtnState:@"报 名"];
    }else if ([_happyPartyModel.hJoinState isEqualToString:@"1"]) {//已报名
        [self setGrayJoinBtnState:@"已报名"];
    }else if ([_happyPartyModel.hJoinState isEqualToString:@"2"]) {//爆满了
        [self setGrayJoinBtnState:@"名额已满"];
    }else if ([_happyPartyModel.hJoinState isEqualToString:@"3"]) {//报名结束
        [self setGrayJoinBtnState:@"报名结束"];
    }
}

- (void)rightButtonAction{
    
    if (self.ygwebviewType == YGWEBVIEW_TYPE_SHOW_RIGHT_BTN) {
        
        if ([YGCommentTools isLogin]) {
            ChatScreenViewCtrl *chat = [[ChatScreenViewCtrl alloc] init];
            NSString*prodName = [YGCommentTools getProductName];
            NSDictionary *dict = @{@"id":TEST_USER_ID,@"head_img":DEFAULT_IMAGE_APP_ICON,@"realname":prodName,@"title":@"younger"};
            UserInfoModel *model = [UserInfoModel initUserInfoModelWith:dict];
            chat.userInfo = model;
            [self.navigationController pushViewController:chat animated:YES];
        }else{
            [YGCommentTools showToastWithMessage:TIP_PLEASE_LOGIN_TIP showTime:0.8f];
        }
    }else if (self.ygwebviewType == YGWEBVIEW_TYPE_SHOW_RIGHT_PARTY) {//参加party
        [self joinPartyAction:self.happyPartyModel];
    }
    
}

#pragma mark - Actions

-(void)joinPartyAction:(HappyPartyModel *)model{
    if (![YGCommentTools isLogin]) {
        [YGCommentTools showToastWithMessage:TIP_PLEASE_LOGIN_TIP showTime:0.8f];
    }else{
        JoinPartyMsgCtrl *vc = [[JoinPartyMsgCtrl alloc] init];
        vc.happyPartyModel = model;
        [self presentViewController:vc animated:YES completion:nil];
    }
}

/**设置报名不可用状态*/
-(void)setGrayJoinBtnState:(NSString*)title{
    self.navbarHeadView.rightBtn.enabled = NO;
    [self.navbarHeadView.rightBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [self.navbarHeadView.rightBtn setTitle:title forState:UIControlStateNormal];
}

/**设置可用状态*/
-(void)setHightBtnState:(NSString*)title{
    self.navbarHeadView.rightBtn.enabled = YES;
    [self.navbarHeadView.rightBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.navbarHeadView.rightBtn setTitle:title forState:UIControlStateNormal];
}

/**添加手势*/
-(void)addGesture{
    UnpreventableUILongPressGestureRecognizer *longPressRecognizer = [[UnpreventableUILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
    longPressRecognizer.allowableMovement = 20;
    longPressRecognizer.minimumPressDuration = .1f;
    [self.webView addGestureRecognizer:longPressRecognizer];
}

/**处理长按手势*/
-(void)handleLongPress:(UILongPressGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        
        CGPoint pt = [gestureRecognizer locationInView:self.webView];
        
        // convert point from view to HTML coordinate system
        // 뷰의 포인트 위치를 HTML 좌표계로 변경한다.
        CGSize viewSize = [self.webView frame].size;
        CGSize windowSize = [self.webView windowSize];
        CGFloat f = windowSize.width / viewSize.width;
        
        if ([[[UIDevice currentDevice] systemVersion] doubleValue] >= 5.0) {
            pt.x = pt.x * f;
            pt.y = pt.y * f;
        } else {
            // On iOS 4 and previous, document.elementFromPoint is not taking
            // offset into account, we have to handle it
            CGPoint offset = [self.webView scrollOffset];
            pt.x = pt.x * f + offset.x;
            pt.y = pt.y * f + offset.y;
        }
        
        [self openContextualMenuAt:pt];
    }
}

- (void)openContextualMenuAt:(CGPoint)pt{
    // Load the JavaScript code from the Resources and inject it into the web page
    NSBundle *bundle = [NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:@"Naving" ofType:@"bundle"]];
    NSString *path = [[NSBundle mainBundle] pathForResource:@"JSTools" ofType:@"js"];
    NSString *jsCode = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    [self.webView stringByEvaluatingJavaScriptFromString:jsCode];
    
    // get the Tags at the touch location
    NSString *tags = [self.webView stringByEvaluatingJavaScriptFromString:
                      [NSString stringWithFormat:@"MyAppGetHTMLElementsAtPoint(%i,%i);",(NSInteger)pt.x,(NSInteger)pt.y]];
    
    NSString *tagsHREF = [self.webView stringByEvaluatingJavaScriptFromString:
                          [NSString stringWithFormat:@"MyAppGetLinkHREFAtPoint(%i,%i);",(NSInteger)pt.x,(NSInteger)pt.y]];
    
    NSString *tagsSRC = [self.webView stringByEvaluatingJavaScriptFromString:
                         [NSString stringWithFormat:@"MyAppGetLinkSRCAtPoint(%i,%i);",(NSInteger)pt.x,(NSInteger)pt.y]];
    
    NSLog(@"tags : %@",tags);
    NSLog(@"href : %@",tagsHREF);
    NSLog(@"src : %@",tagsSRC);
    
    if (!_actionActionSheet) {
        _actionActionSheet = nil;
    }
    _actionActionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                     delegate:self
                                            cancelButtonTitle:nil
                                       destructiveButtonTitle:nil
                                            otherButtonTitles:nil];
    
    selectedLinkURL = @"";
    selectedImageURL = @"";
    
    // If an image was touched, add image-related buttons.
    if ([tags rangeOfString:@",IMG,"].location != NSNotFound) {
        selectedImageURL = tagsSRC;
        
        if (_actionActionSheet.title == nil) {
            _actionActionSheet.title = tagsSRC;
        }
        
        [_actionActionSheet addButtonWithTitle:@"保存图片"];
//        [_actionActionSheet addButtonWithTitle:@"Copy Image"];
    }
    
    // If a link is pressed add image buttons.
    if ([tags rangeOfString:@",A,"].location != NSNotFound){
        selectedLinkURL = tagsHREF;
        
        _actionActionSheet.title = tagsHREF;
        [_actionActionSheet addButtonWithTitle:@"打开链接"];
        [_actionActionSheet addButtonWithTitle:@"复制链接"];
    }
    
    if (_actionActionSheet.numberOfButtons > 0) {
        [_actionActionSheet addButtonWithTitle:@"取消"];
        _actionActionSheet.cancelButtonIndex = (_actionActionSheet.numberOfButtons-1);
        
        
        [_actionActionSheet showInView:self.webView];
    }
    
}

//加载默认网络提示View
-(void)initDefaultView{
    defaultView = [[[NSBundle mainBundle] loadNibNamed:@"DefaultTipView" owner:self options:nil] lastObject];
    defaultView.hidden = YES;
    defaultView.delegate = self;
    defaultView.frame = CGRectMake(0, 64, SCREEN_SIZE.width, SCREEN_SIZE.height);
    [self.view addSubview:defaultView];
}

/**设置导航题目*/
-(void)setNavTitle{
    // Set title
    NSString *title = [self getTitle];
    if(title != nil && ![title isEqualToString:@""])
    self.navbarHeadView.navTitle.text = [self getTitle];
}

/**获取webView title*/
- (NSString *)getTitle
{
    return [self.webView stringByEvaluatingJavaScriptFromString:@"document.title"];
}

#pragma mark - initView
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
    [MBProgressHUD showMessag:TIP_LOADING_TEXT toView:self.view];
    return YES;
}

#pragma mark - UIWebViewDelegate
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
    [MBProgressHUD hideAllHUDsForView:self.view animated:NO];
    defaultView.hidden = NO;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView{
    [MBProgressHUD hideAllHUDsForView:self.view animated:NO];
    [self setNavTitle];
    
    defaultView.hidden = YES;
}

#pragma mark - DefaultTipViewDelegate
- (void)ClickReloadDataAction{
    [self.webView loadRequest:myRequest];
    
}


#pragma UIActionSheetDelegate
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:@"打开链接"]){
        [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:selectedLinkURL]]];
    }
    else if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:@"复制链接"]){
        [[UIPasteboard generalPasteboard] setString:selectedLinkURL];
    }
    else if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:@"拷贝图片"]){
        [[UIPasteboard generalPasteboard] setString:selectedImageURL];
    }
    else if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:@"保存图片"]){
        NSOperationQueue *queue = [NSOperationQueue new];
        NSInvocationOperation *operation = [[NSInvocationOperation alloc] initWithTarget:self
                                                                                selector:@selector(saveImageURL:) object:selectedImageURL];
        [queue addOperation:operation];
        //[operation release];
    }
}

-(void)saveImageURL:(NSString*)url{
    [self performSelectorOnMainThread:@selector(showStartSaveAlert)
                           withObject:nil
                        waitUntilDone:YES];
    
    UIImageWriteToSavedPhotosAlbum([UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:url]]], nil, nil, nil);
    
    [self performSelectorOnMainThread:@selector(showFinishedSaveAlert)
                           withObject:nil
                        waitUntilDone:YES];
}

-(void)showStartSaveAlert{
    
}

-(void)showFinishedSaveAlert{
    
}

@end
