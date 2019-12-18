//
//  MMDetailHeadView.h
//  EasyIM
//
//  Created by momo on 2019/4/22.
//  Copyright © 2019年 Looker. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

static const CGFloat ICTopImageH =  150;

@protocol MMDetailHeadDelegate <NSObject>

- (void)deleteBtnClicked;
- (void)addBtnClicked;
- (void)headBtnClicked:(NSInteger)index;
- (void)changeGroupName;
- (void)changeGroupHeadImg;

@end

@interface MMDetailHeadView : UIView
@property (nonatomic, weak) id<MMDetailHeadDelegate>headDelegate;
@property (nonatomic, strong) NSArray *users;

@property (nonatomic, assign) BOOL isMaster;
@property (nonatomic, strong) MMGroup *group;

@property (nonatomic, strong) UIView *topView;
@end

NS_ASSUME_NONNULL_END
