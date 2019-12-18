//
//  MMDocumentCell.h
//  EasyIM
//
//  Created by momo on 2019/4/22.
//  Copyright © 2019年 Looker. All rights reserved.
//

#import "MMBaseMessageCell.h"

NS_ASSUME_NONNULL_BEGIN

@protocol MMDocumentCellDelegate <NSObject>

- (void)selectBtnClicked:(id)sender;

@end


@interface MMDocumentCell : MMBaseMessageCell

@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *filePath;

@property (nonatomic, weak) id<MMDocumentCellDelegate> delegate;

+ (instancetype)cellWithTableView:(UITableView *)tableView;

@property (nonatomic, weak) UIButton *selectBtn;



@end

NS_ASSUME_NONNULL_END
