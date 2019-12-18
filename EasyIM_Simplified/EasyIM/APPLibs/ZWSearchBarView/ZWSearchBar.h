//
//  ZWSearchBar.h
//  EasyIM
//
//  Created by step_zhang on 2019/12/5.
//  Copyright © 2019 Looker. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@protocol ZWSearchBarDelegate <NSObject>

- (void)searchWithStr :(NSString *)text;
- (void)cancleWithStr;

@end
@interface ZWSearchBar : UIView
@property(nonatomic,copy)NSString *ZWPlaceholder;
@property(nonatomic,strong)UILabel *placeholderLabel;
@property(nonatomic,strong)UIColor *ZWCursorColor;

@property(nonatomic,weak) id<ZWSearchBarDelegate> SearchDelegate;
@end

NS_ASSUME_NONNULL_END
