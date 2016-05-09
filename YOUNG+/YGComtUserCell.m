//
//  YGComtUserCell.m
//  YOUNG+
//
//  Created by XPress on 15/10/5.
//  Copyright © 2015年 YOUNG+. All rights reserved.
//

#import "YGComtUserCell.h"
#import "YGCommentTools.h"
#import "UIButton+WebCache.h"
#import "UIImageView+WebCache.h"
@implementation YGComtUserCell{
    //user
    __weak IBOutlet UILabel *userInfo;
    __weak IBOutlet UIButton *userImage;
    __weak IBOutlet UILabel *userLabs;
    __weak IBOutlet UIButton *focusOnBtn;
    __weak IBOutlet UIImageView *myImgIcon;
}

- (void)awakeFromNib {
    // Initialization code
}

#pragma mark - Data
-(void)setUserInfoModel:(UserInfoModel*)userInfoModel{
    _userInfoModel = userInfoModel;
    
    NSString *imgName = userInfoModel.personIcon;
    NSURL *url = [YGCommentTools getImageUrl:imgName];
    [myImgIcon sd_setImageWithURL:url placeholderImage:[YGCommentTools getDefaultImage]];
    
//    [userImage sd_setBackgroundImageWithURL:url forState:UIControlStateNormal];
    
    
//    UIImage *img = [userImage backgroundImageForState:UIControlStateNormal];
//    if (!img) {
//        [userImage setBackgroundImage:[YGCommentTools getDefaultImage] forState:UIControlStateNormal];
//    }
//    [userImage.imageView setContentMode:UIViewContentModeScaleAspectFill];
    
    NSString *name = userInfoModel.name;
    NSString *info = userInfoModel.info;
    info = [NSString stringWithFormat:@" | %@",info];
    
    NSMutableAttributedString *temp = [YGCommentTools getAttributeStr:name withStr:info];
    
    //TODO:区分名称与描述
    userInfo.attributedText = temp;
    userLabs.text = userInfoModel.comment;
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
