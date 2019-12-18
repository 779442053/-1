//
//  MMAboutCell.m
//  EasyIM
//
//  Created by momo on 2019/7/25.
//  Copyright © 2019 Looker. All rights reserved.
//

#import "MMAboutCell.h"

@interface MMAboutCell ()

@property (weak, nonatomic) IBOutlet UIImageView *appIcon;
@property (weak, nonatomic) IBOutlet UILabel *appName;
@property (weak, nonatomic) IBOutlet UILabel *appVersion;

@end

@implementation MMAboutCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    NSDictionary *infoPlist = [[NSBundle mainBundle] infoDictionary];
    NSString *icon = [[infoPlist valueForKeyPath:@"CFBundleIcons.CFBundlePrimaryIcon.CFBundleIconFiles"] lastObject];
    UIImage* image = [UIImage imageNamed:icon];
    
    [self.appIcon setImage:image];
    
    NSString *appName = [infoPlist objectForKey:@"CFBundleDisplayName"];
    self.appName.text = appName;
    
    //MARK:app 版本 及 app build版本
    NSString *appVersion = [infoPlist objectForKey:@"CFBundleShortVersionString"];
    NSString *appBuild = [infoPlist objectForKey:@"CFBundleVersion"];
    
    self.appVersion.text = [NSString stringWithFormat:@"Version:%@(%@)",appVersion,appBuild];
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
