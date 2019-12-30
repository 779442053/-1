//
//  QRCodeViewController.m
//  EasyIM
//
//  Created by apple on 2019/7/23.
//  Copyright © 2019 Looker. All rights reserved.
//

#import "QRCodeViewController.h"

//创建UI
#import "BaseUIView.h"

//绘制二维码
#import "LCQrcodeUtil.h"


static CGFloat const margin_content = 30;
static CGFloat const content_foot_h = 70;
static CGFloat const margin_qrcode = 20;

@interface QRCodeViewController (){
    NSInteger _qrcode_type;
    NSString  *_qrcode_fid;
    NSString  *_qrcode_fname;
    NSString   *_qrcode_fpic;
}

//////////////////////////////////////////////////
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) UIView *content_bottom_view;
@property (nonatomic, strong) UIImageView *imgQrcode;

//群、用户图像
@property (nonatomic, strong) UIImageView *imgUser;
//群名、用户名
@property (nonatomic, strong) UILabel *labName;
//描述
@property (nonatomic, strong) UILabel *labDescription;


@end

@implementation QRCodeViewController

/**
 二维码视图初始化
 
 @param type 二维码类型 0个人、1群聊、2会议室
 @param fid 个人或群或会议室编号
 @param fname 个人或群或会议室名称
 @param fpic 个人或群或会议室图片
 @return QRCodeViewController
 */
- (instancetype)initWithType:(NSInteger)type
                   AndFromId:(NSString *_Nonnull)fid
                 AndFromName:(NSString *_Nonnull)fname
                 WithFromPic:(NSString  *)fpic{
    if (self = [super init]) {
        _qrcode_type = type;
        _qrcode_fid = fid;
        _qrcode_fname = fname;
        _qrcode_fpic = fpic;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self initView];
}
-(void)zw_addSubviews{
    //二维码类型 0个人、1群聊、2会议室
    switch (_qrcode_type) {
        case 0:
            [self setTitle:@"我的二维码"];
            break;
            
        case 1:
            [self setTitle:@"群聊二维码"];
            break;
            
        case 2:
            [self setTitle:@"会议室二维码"];
            break;
            
        default:
            [self setTitle:@"二维码"];
            break;
    }
    [self showLeftBackButton];
    
}

//MARK: - initview
-(void)initView{
    //MARK:主题内容
    [self.view addSubview:self.contentView];
    //MARK:绘制二维码 二维码类型 0个人、1群聊、2会议室
    NSString *strContent = [NSString stringWithFormat:@"%@://%@",K_APP_QRCODE_USER,_qrcode_fid];
    if (_qrcode_type == 1) {
        strContent = [NSString stringWithFormat:@"%@://%@",K_APP_QRCODE_GROUP,_qrcode_fid];
    }
    else if(_qrcode_type == 2){
        strContent = [NSString stringWithFormat:@"%@://%@",K_APP_QRCODE_MEETING,_qrcode_fid];
    }
    
   UIImage *imgQRCode = [LCQrcodeUtil creatQRImageWithContent:strContent
                                                      andSize:self.imgQrcode.frame.size
                                                     andColor:[UIColor blackColor]
                                                andAdditional:nil];
    self.imgQrcode.image = imgQRCode;
}



//MARK: - lazy load
-(UIView *)contentView{
    if (!_contentView) {
        CGFloat y = 40 + ZWStatusAndNavHeight;
        CGFloat w = G_SCREEN_WIDTH - 2 * margin_content;
        CGFloat h = content_foot_h + w/0.896;
        _contentView = [BaseUIView createView:CGRectMake(margin_content, y, w, h)
                           AndBackgroundColor:[UIColor whiteColor]
                                  AndisRadius:NO
                                    AndRadiuc:0
                               AndBorderWidth:1
                               AndBorderColor:RGBCOLOR(240, 240, 240)];
        
        //MARK:二维码
        [_contentView addSubview:self.imgQrcode];
        
        //MARK:底部信息视图
        [_contentView addSubview:self.content_bottom_view];
    }
    return _contentView;
}

-(UIImageView *)imgQrcode{
    if (!_imgQrcode) {
        CGFloat w = _contentView.frame.size.width - 2 * margin_qrcode;
        CGFloat h = w;
        CGFloat y = (_contentView.frame.size.height - content_foot_h - h) * 0.5;
        _imgQrcode = [BaseUIView createImage:CGRectMake(margin_qrcode,y, w, h)
                                    AndImage:nil
                          AndBackgroundColor:nil
                                WithisRadius:NO];
    }
    return _imgQrcode;
}

-(UIView *)content_bottom_view{
    if (!_content_bottom_view) {
        _content_bottom_view = [BaseUIView createView:CGRectMake(0, _contentView.frame.size.height - content_foot_h, _contentView.frame.size.width, content_foot_h)
                                   AndBackgroundColor:[UIColor whiteColor]
                                          AndisRadius:NO
                                            AndRadiuc:0
                                       AndBorderWidth:0
                                       AndBorderColor:nil];
        //MARK:顶部线
        UIView *lab = [BaseUIView createView:CGRectMake(0, 0, _contentView.frame.size.width, 0.3)
                           AndBackgroundColor:RGBCOLOR(240, 240, 240)
                                  AndisRadius:NO
                                    AndRadiuc:0
                               AndBorderWidth:0
                               AndBorderColor:nil];
        [_content_bottom_view addSubview:lab];
        
        //MARK:图像
        [self.imgUser sd_setImageWithURL:[NSURL URLWithString:_qrcode_fpic] placeholderImage:K_DEFAULT_USER_PIC];
        [_content_bottom_view addSubview:self.imgUser];
        
        //MARK:名称
        [_content_bottom_view addSubview:self.labName];
        
        //MARK:描述
        [_content_bottom_view addSubview:self.labDescription];
    }
    return _content_bottom_view;
}

-(UIImageView *)imgUser{
    if (!_imgUser) {
        CGFloat x = 10;
        
        UIImage *userHeadimage;
        if (!_qrcode_fpic) {
            if (_qrcode_type == 0) {
                userHeadimage = K_DEFAULT_USER_PIC;
            }
            else{
                userHeadimage = [UIImage imageNamed:@"contacts_group_icon"];
            }
        }
        _imgUser = [BaseUIView createImage:CGRectMake(x, x, content_foot_h - 2 * x, content_foot_h - 2 * x)
                                  AndImage:userHeadimage
                        AndBackgroundColor:nil
                                 AndRadius:YES
                               WithCorners:3];
    }
    return _imgUser;
}
-(UILabel *)labName{
    if (!_labName) {
        CGFloat x = _imgUser.frame.size.width + 2 * _imgUser.frame.origin.x;
        CGFloat y = _imgUser.frame.origin.y;
        CGFloat w = _content_bottom_view.frame.size.width - x - 10;
        _labName = [BaseUIView createLable:CGRectMake(x, y, w, 21)
                                   AndText:_qrcode_fname
                              AndTextColor:[UIColor blackColor]
                                AndTxtFont:[UIFont zwwNormalFont:13]
                        AndBackgroundColor:nil];
        _labName.textAlignment = NSTextAlignmentLeft;
    }
    return _labName;
}

-(UILabel *)labDescription{
    if (!_labDescription) {
        CGRect rect = _labName.frame;
        rect.origin.y = content_foot_h - rect.size.height - rect.origin.y;
        
        NSString *strInfo = @"扫一扫二维码，加我";
        //二维码类型 0个人、1群聊、2会议室
        if (_qrcode_type == 1) {
            strInfo = @"扫一扫二维码，加入群聊";
        }
        else if (_qrcode_type == 2) {
            strInfo = @"扫一扫二维码，加入会议室";
        }
        _labDescription = [BaseUIView createLable:rect
                                          AndText:strInfo
                                     AndTextColor:[UIColor grayColor]
                                       AndTxtFont:[UIFont zwwNormalFont:13]
                               AndBackgroundColor:nil];
        _labDescription.textAlignment = NSTextAlignmentLeft;
    }
    return _labDescription;
}


@end
