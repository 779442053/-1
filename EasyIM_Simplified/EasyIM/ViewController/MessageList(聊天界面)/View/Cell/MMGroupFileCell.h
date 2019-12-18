//
//  MMGroupFileCell.h
//  EasyIM
//
//  Created by momo on 2019/4/22.
//  Copyright © 2019年 Looker. All rights reserved.
//

#import "MMBaseMessageCell.h"

NS_ASSUME_NONNULL_BEGIN

@class MMGroupFileCell;

@protocol GroupFileDelegate <NSObject>

- (void)isFileExisted:(MMGroupFileCell *)cell
            isExisted:(BOOL)isExisted
              fileKey:(NSString *)fileKey
             fileName:(NSString *)fileName;

@end

@interface MMGroupFileCell : MMBaseMessageCell

+ (instancetype)cellWithTableView:(UITableView *)tableView;

@property (nonatomic, strong) MMMessage *message;

@property (nonatomic, weak) id <GroupFileDelegate>delegate;

@property (nonatomic, weak) UIProgressView *progressView;
@property (nonatomic, weak) UIButton *seeBtn;


@end

NS_ASSUME_NONNULL_END
