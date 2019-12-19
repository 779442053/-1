//
//  ZWChatHandlerViewModel.h
//  EasyIM
//
//  Created by step_zhang on 2019/12/18.
//  Copyright © 2019 Looker. All rights reserved.
//

#import "ZWBaseViewModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface ZWChatHandlerViewModel : ZWBaseViewModel
@property(nonatomic,strong)RACCommand *GetuploadFileUrlCommand;
@property(nonatomic,strong)RACCommand *uploadFileCommand;
@property(nonatomic,strong)RACCommand *UploadImageToSeverCommand;
@end

NS_ASSUME_NONNULL_END
