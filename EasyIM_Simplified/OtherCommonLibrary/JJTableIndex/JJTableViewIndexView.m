//
//  JJTableViewIndexView.m
//  索引
//
//  Created by 欧家俊 on 16/12/21.
//  Copyright © 2016年 欧家俊. All rights reserved.
//

#import "JJTableViewIndexView.h"

//屏幕宽高
#define WIDTH [UIScreen mainScreen].bounds.size.width
#define HEIGHT [UIScreen mainScreen].bounds.size.height

@implementation JJTableViewIndexView
#pragma mark - 实例化方法
- (instancetype)initWithFrame:(CGRect)frame imageNameArray:(NSArray *)array
{
    self = [super initWithFrame:frame];
    
    if (self)
    {
        //通过实例化参数,赋值给类属性
        self.imageNameArray = [NSArray arrayWithArray:array];

        //通过数据的长度,获取image的高度
        CGFloat imageHeight = self.frame.size.height/self.imageNameArray.count;

        //遍历数组
        for (int i = 0; i < self.imageNameArray.count; i ++)
        {
            //生成图片视图
            UIImageView * imageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:self.imageNameArray[i]]];

            //设置坐标大小
            imageView.frame =CGRectMake(0, i * imageHeight, self.frame.size.width, self.frame.size.width);

            //设置tag
            imageView.tag = TAG + i;

            //添加到视图
            [self addSubview:imageView];

            //允许交互
            imageView.userInteractionEnabled = YES;
        }
        
        [self addSubview:self.centerImageShowView];
    }
    
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame stringNameArray:(NSArray *)array{

    self = [super initWithFrame:frame];

    if (self)
    {
        //通过实例化参数,赋值给类属性
        self.stringNameArray = [NSArray arrayWithArray:array];

        //通过数据的长度,获取高度
        CGFloat _height = self.frame.size.height/self.stringNameArray.count;

        //遍历数组
        UILabel *labString;
        for (int i = 0,len = (int)self.stringNameArray.count; i < len; i ++)
        {
            //生成视图
            labString = [[UILabel alloc] init];

            //设置坐标大小
            labString.frame = CGRectMake(0, i * _height, self.frame.size.width, self.frame.size.width);

            //设置tag
            labString.tag = TAG + i;

            //文本
            labString.text = [NSString stringWithFormat:@"%@",self.stringNameArray[i]];
            labString.textColor = [[UIColor alloc] initWithRed:26/255 green:26/255 blue:26/255 alpha:1.f];
            labString.font = [UIFont systemFontOfSize:9];
            labString.textAlignment = NSTextAlignmentCenter;

            //添加到视图
            [self addSubview:labString];

            //允许交互
            labString.userInteractionEnabled = YES;
        }

        [self addSubview:self.centerLableShowView];
    }

    return self;
}


#pragma mark - 懒加载 中心视图
- (UIImageView *)centerImageShowView{
    if (!_centerImageShowView)
    {
        //设置中心提示视图的坐标大小
        //        _animationLabel = [[UILabel alloc]initWithFrame:CGRectMake(-WIDTH/2 + self.frame.size.width/2, 100, 60, 60)];
        _centerImageShowView = [[UIImageView alloc]init];
        _centerImageShowView.frame = CGRectMake(-WIDTH/2 + self.frame.size.width/2, 100, 60, 60);
        //遮罩
        _centerImageShowView.layer.masksToBounds = YES;
        //圆角
        _centerImageShowView.layer.cornerRadius = 5.0f;

        //边框
        _centerImageShowView.layer.borderWidth = 1;

        //背景颜色
        _centerImageShowView.backgroundColor = [UIColor orangeColor];

        //将视图隐藏,刚开始本应该隐藏
        _centerImageShowView.alpha = 0;
      
    }
    
    return _centerImageShowView;
}

- (UILabel *)centerLableShowView{

    if (!_centerLableShowView){

        //设置中心提示视图的坐标大小
        _centerLableShowView = [[UILabel alloc]init];
        _centerLableShowView.textAlignment = NSTextAlignmentCenter;
        _centerLableShowView.frame = CGRectMake(-WIDTH/2 + self.frame.size.width/2, 100, 60, 60);

        //圆角
        _centerLableShowView.layer.masksToBounds = YES;
        _centerLableShowView.layer.cornerRadius = 5.0f;

        _centerLableShowView.layer.borderWidth = 0.5;
        _centerLableShowView.layer.borderColor = [UIColor lightGrayColor].CGColor;

        //背景颜色
        _centerLableShowView.backgroundColor = [UIColor whiteColor];

        //将视图隐藏,刚开始本应该隐藏
        _centerLableShowView.alpha = 0;

    }

    return _centerLableShowView;
}


#pragma mark - 中心视图的数据源方法
-(void)centerImageShowViewWithSection:(NSInteger)section
{
    self.selectedBlock(section);
    
    _centerImageShowView.image = [UIImage imageNamed:self.imageNameArray[section]];
    _centerImageShowView.alpha = 1.0;
}

-(void)centerLableShowViewWithSection:(NSInteger)section
{
    self.selectedBlock(section);

    _centerLableShowView.text = self.stringNameArray[section];
    _centerLableShowView.alpha = 1.0;
}


#pragma mark - 手势结束
-(void)panAnimationFinish
{
    int count;
    CGFloat _height;

    if (self.imageNameArray != nil && self.imageNameArray.count > 0) {
        count = (int)self.imageNameArray.count;

        _height = self.frame.size.height/count;
    }
    else{
        count = (int)self.stringNameArray.count;

        _height = self.frame.size.height/count;
    }
    
    for (int i = 0; i < count; i ++)
    {
        UIView *_view = [self viewWithTag:TAG + i];
        
        [UIView animateWithDuration:0.2 animations:^{
            _view.center = CGPointMake(self.frame.size.width/2, i * _height + _height/2);
            _view.alpha = 1.0;
            //_view.frame = CGRectMake(_view.frame.origin.x, _view.frame.origin.y, self.frame.size.width, self.frame.size.width);
        }];
    }
    
    [UIView animateWithDuration:1 animations:^{

        if (self.imageNameArray != nil && self.imageNameArray.count > 0) {
            self.centerImageShowView.alpha = 0;
        }
        else{
           self.centerLableShowView.alpha = 0;
        }
        
    }];
}

#pragma mark - 手势开始
-(void)panAnimationBeginWithToucher:(NSSet<UITouch *> *)touches
{
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self];

    int count = self.imageNameArray != nil ? (int)self.imageNameArray.count : (int)self.stringNameArray.count;
    CGFloat hh = self.frame.size.height/count;

    __block int selectIndex;
    for (int i = 0; i < count; i ++)
    {
        UIView *_view = [self viewWithTag:TAG + i];

        if (fabs(_view.center.y - point.y) <= ANIMATION_RADIUS)
        {
            [UIView animateWithDuration:0.2 animations:^{
                
                _view.frame = CGRectMake(_view.frame.origin.x, _view.frame.origin.y, self.frame.size.width+10, self.frame.size.width+10);
                
                _view.center = CGPointMake(_view.bounds.size.width/2 - sqrt(fabs(ANIMATION_RADIUS * ANIMATION_RADIUS - fabs(_view.center.y - point.y) * fabs(_view.center.y - point.y))), _view.center.y);
              
                
                if (fabs(_view.center.y - point.y) * ALPHA_RATE <= 0.08)
                {
                    //label.textColor = MARK_COLOR;
                    _view.alpha = 1.0;

                if (self->_imageNameArray != nil && self->_imageNameArray.count > 0) {
                        [self centerImageShowViewWithSection:i];
                    }
                    else{
                        [self centerLableShowViewWithSection:i];
                        selectIndex = i;
                    }
                    
                    for (int j = 0; j < count; j ++)
                    {
                        UIView *tempView = [self viewWithTag:TAG + j];
                        if (i != j)
                        {
                            tempView.alpha = fabs(tempView.center.y - point.y) * ALPHA_RATE;
                        }

                    if(selectIndex == j && self->_stringNameArray != nil && self->_stringNameArray.count > 0) {
                            //选中颜色
                            ((UILabel *)tempView).textColor = [UIApplication sharedApplication].keyWindow.tintColor;
                        }
                        else{
                            if (self->_stringNameArray != nil && self->_stringNameArray.count > 0) {
                                ((UILabel *)tempView).textColor = [UIColor colorWithRed:26/255 green:26/255 blue:26/255 alpha:1];
                            }
                        }
                    }
                }
            }];
        }
        else {
            [UIView animateWithDuration:0.2 animations:^
             {
                 _view.center = CGPointMake(self.frame.size.width/2, i * hh + hh/2);
                 _view.frame = CGRectMake(_view.frame.origin.x, _view.frame.origin.y, self.frame.size.width, self.frame.size.width);
                 _view.alpha = 1.0;
             }];
        }
    }
}


#pragma mark - 点击事件
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self panAnimationBeginWithToucher:touches];
}

-(void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self panAnimationBeginWithToucher:touches];
}

-(void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self panAnimationFinish];
}

-(void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self panAnimationFinish];
}


#pragma mark - 选中索引的回调
-(void)selectIndexBlock:(MyBlock)block
{
    self.selectedBlock = block;
}

@end
