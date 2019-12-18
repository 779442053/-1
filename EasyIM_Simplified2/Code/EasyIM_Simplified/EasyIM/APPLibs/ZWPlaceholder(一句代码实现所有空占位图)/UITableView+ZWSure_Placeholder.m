//
//  UITableView+ZWSure_Placeholder.m
//  EasyIM
//
//  Created by step_zhang on 2019/11/26.
//  Copyright © 2019 Looker. All rights reserved.
//

#import "UITableView+ZWSure_Placeholder.h"

#import "UITableView+PlaceholderView.h"
#import "NSObject+ZWSwizzling.h"
#import "ZWSurePlaceholderView.h"//默认占位图

@implementation UITableView (ZWSure_Placeholder)
+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self methodSwizzlingWithOriginalSelector:@selector(reloadData)
                               bySwizzledSelector:@selector(sure_reloadData)];
    });
}
- (void)sure_reloadData {
    if (!self.firstReload) {
        [self checkEmpty];
    }
    //self.firstReload = NO;
    [self sure_reloadData];
}

- (void)checkEmpty {
    BOOL isEmpty = YES;//flag标示
    id <UITableViewDataSource> dataSource = self.dataSource;
    NSInteger sections = 1;//默认一组
    if ([dataSource respondsToSelector:@selector(numberOfSectionsInTableView:)]) {
        sections = [dataSource numberOfSectionsInTableView:self];//获取当前TableView组数
    }
    
    for (NSInteger i = 0; i < sections; i++) {
        NSInteger rows = [dataSource tableView:self numberOfRowsInSection:i];//获取当前TableView各组行数
        if (rows) {
            isEmpty = NO;//若行数存在，不为空
        }
    }
    if (isEmpty) {//若为空，加载占位图
        //默认占位图
        if (!self.placeView) {
            [self makeDefaultplaceView];
        }
        self.placeView.hidden = NO;
        [self addSubview:self.placeView];
    } else {//不为空，移除占位图
        self.placeView.hidden = YES;
    }
}

- (void)makeDefaultplaceView {
    self.bounds = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    UIView *placeholderView;
    if (self.placeholderView) {
        placeholderView = self.placeholderView;
        placeholderView.frame = self.bounds;
        if (!placeholderView.backgroundColor) {
            placeholderView.backgroundColor = [UIColor colorWithRed:231/255.0 green:231/255.0 blue:231/255.0 alpha:1];
        }
        placeholderView.contentMode = UIViewContentModeCenter;
    }else {
        placeholderView = [[ZWSurePlaceholderView alloc] initWithFrame:self.bounds];
        ((ZWSurePlaceholderView *)placeholderView).title = self.placeholderText;
        ((ZWSurePlaceholderView *)placeholderView).image = self.placeholderImg;
        __weak typeof(self) weakSelf = self;
        [(ZWSurePlaceholderView *)placeholderView setReloadClickBlock:^{
            if (weakSelf.reloadBlock) {
                weakSelf.reloadBlock();
            }
        }];
    }
    self.placeView = placeholderView;
}

- (UIView *)placeView {
    return objc_getAssociatedObject(self, @selector(placeView));
}

- (void)setPlaceView:(UIView *)placeView {
    objc_setAssociatedObject(self, @selector(placeView), placeView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
////get方法
- (BOOL)firstReload {
    //用来获取一个对象
    return [objc_getAssociatedObject(self, @selector(firstReload)) boolValue];
}

- (void)setFirstReload:(BOOL)firstReload {
    objc_setAssociatedObject(self, @selector(firstReload), @(firstReload), OBJC_ASSOCIATION_ASSIGN);
}

//////////block
- (void (^)(void))reloadBlock {
    return objc_getAssociatedObject(self, @selector(reloadBlock));
}

- (void)setReloadBlock:(void (^)(void))reloadBlock {
    objc_setAssociatedObject(self, @selector(reloadBlock), reloadBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
}
@end
