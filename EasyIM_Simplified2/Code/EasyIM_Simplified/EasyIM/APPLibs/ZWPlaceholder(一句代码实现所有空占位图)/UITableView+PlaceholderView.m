//
//  UITableView+PlaceholderView.m
//  EasyIM
//
//  Created by step_zhang on 2019/11/26.
//  Copyright © 2019 Looker. All rights reserved.
//

#import "UITableView+PlaceholderView.h"
#import <objc/runtime.h>
static const void *placeholderImgKey = &placeholderImgKey;
static const void *placeholderTextKey = &placeholderTextKey;
static const void *placeholderViewKey = &placeholderViewKey;


@implementation UITableView (PlaceholderView)
- (void)setPlaceholderImg:(UIImage *)placeholderImg {
    objc_setAssociatedObject(self, placeholderImgKey, UIImagePNGRepresentation(placeholderImg), OBJC_ASSOCIATION_COPY_NONATOMIC);
}
- (UIImage *)placeholderImg {
    return [[UIImage alloc] initWithData:objc_getAssociatedObject(self, placeholderImgKey)];
}
- (void)setPlaceholderText:(NSString *)placeholderText {
    objc_setAssociatedObject(self, placeholderTextKey, placeholderText, OBJC_ASSOCIATION_COPY_NONATOMIC);
}
- (NSString *)placeholderText {
    return objc_getAssociatedObject(self, placeholderTextKey);
}
- (void)setPlaceholderView:(UIView *)placeholderView {
    objc_setAssociatedObject(self, placeholderViewKey, placeholderView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (UIView *)placeholderView {
    return objc_getAssociatedObject(self, placeholderViewKey);
}

@end
