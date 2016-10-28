//
//  MLMOptionSelectView.m
//  MLMOptionSelectView
//
//  Created by my on 16/10/12.
//  Copyright © 2016年 MS. All rights reserved.
//

#import "MLMOptionSelectView.h"


static NSInteger maxOption = 5;//默认最大5行

static CGFloat arrow_H = 8;//箭头高
static CGFloat arrow_W = 15;//箭头宽


typedef enum : NSUInteger {
    MLMOptionSelectViewEndShowTopLeft,//上左
    MLMOptionSelectViewEndShowTopRight,//上右

    MLMOptionSelectViewEndShowBottomLeft,//下左
    MLMOptionSelectViewEndShowBottomRight,//下右
    
    MLMOptionSelectViewEndShowLeftTop,//左上
    MLMOptionSelectViewEndShowLeftBottom,//左下

    MLMOptionSelectViewEndShowRightTop,//右上
    MLMOptionSelectViewEndShowRightBottom//右下
    
} MLMOptionSelectViewEndShow;

@interface MLMOptionSelectView () <UITableViewDelegate,UITableViewDataSource>
{
    ///向下或者向上展开超出屏幕时偏移的距离
    CGFloat _start_offSetY;
    CGFloat _start_offSetX;
    
    
    //箭头的三个顶点坐标
    CGPoint arrow1;
    CGPoint arrow2;
    CGPoint arrow3;
    
    CALayer *arrow_layer;
    
    //弹出视图的origin
    CGPoint point;
    
    //弹出之后的宽高
    CGFloat viewHeight;
    CGFloat viewWidth;
    //箭头高
    CGFloat arrowHeight;
    //显示时的行数
    CGFloat end_Line;
    //cell行高
    CGFloat cell_height;

}
///弹出朝向
@property (nonatomic, assign) MLMOptionSelectViewDirection diretionType;
///背景层
@property (nonatomic, strong) UIView *cover;
///弹出时展示的方向
@property (nonatomic, assign) MLMOptionSelectViewEndShow endShowType;

@end

@implementation MLMOptionSelectView

#pragma mark - 初始化
- (instancetype)initOptionView {
    if (self = [super initWithFrame:CGRectZero style:UITableViewStylePlain]) {
        self.delegate = self;
        self.dataSource = self;
        self.layer.cornerRadius = 5;
        self.layer.masksToBounds = YES;
        self.showsVerticalScrollIndicator = NO;
        self.bounces = NO;
        self.separatorStyle = UITableViewCellSeparatorStyleNone;
        [self initSetting];
    }
    return self;
}

#pragma mark - 默认设置
- (void)initSetting {
    _maxLine = maxOption;
    cell_height = 40.f;
    self.backColor = [UIColor whiteColor];
    _coverColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:.3];
}


- (void)setBackColor:(UIColor *)backColor {
    _backColor = backColor;
    self.backgroundColor = _backColor;
}

#pragma mark - 计算弹出位置
+ (CGRect)targetView:(UIView *)targetView {
    CGRect rect = [KEYWINDOW convertRect:targetView.frame fromView:targetView.superview];
    return rect;
}

#pragma mark - 显示多少行
- (CGFloat)showLine {
    NSInteger row = [self numberOfRowsInSection:0];
    NSInteger line = row > _maxLine ? _maxLine : row;
    return line;
}

#pragma mark - 弹出的方法
- (void)showViewFromPoint:(CGPoint)viewPoint
                viewWidth:(CGFloat)width
               targetView:(UIView *)targetView
                direction:(MLMOptionSelectViewDirection)directionType {
    //显示行数
    NSInteger line = [self showLine];
    if (line == 0) {
        return;
    }
    
    [self reloadData];
    
    //计算高度
    cell_height = _optionCellHeight?_optionCellHeight():cell_height;
    viewHeight = line * cell_height;
    point = viewPoint;
    viewWidth = width;
    
    //添加视图
    [KEYWINDOW addSubview:self.cover];
    [KEYWINDOW addSubview:self];

    [self addConstraintToCover];
    //弹出方向和动画效果 改变
    _diretionType = directionType;

    
    //展开时为了，能够让展开视图更好的展示,可能会调整左右偏移的位置，如果弹出是围绕一块区域，就可以通过下方的数据进行适配调整上下左右展开的方式
    _start_offSetX = targetView?targetView.width:0;
    _start_offSetY = targetView?targetView.height:0;
    
//    //没有参考view时
//    _arrow_offset = targetView?_arrow_offset:0;

    if (_optionType == MLMOptionSelectViewTypeArrow) {
        arrowHeight = arrow_H;
    } else {
        arrowHeight = 0;
    }
    
    //调节显示
    switch (_diretionType) {
        case MLMOptionSelectViewBottom:
        {
            if ((SCREEN_HEIGHT-point.y-arrowHeight) > viewHeight || (SCREEN_HEIGHT-_start_offSetY)/2 > point.y) {
                end_Line = (SCREEN_HEIGHT-point.y-arrowHeight)/cell_height;
                end_Line = end_Line>line?line:end_Line;
                if ((SCREEN_WIDTH-point.x)>viewWidth || point.x < (SCREEN_WIDTH - _start_offSetX)/2) {
                    self.endShowType = MLMOptionSelectViewEndShowBottomRight;
                    self.origin = CGPointMake(point.x, point.y+arrowHeight);
                } else {
                    self.endShowType = MLMOptionSelectViewEndShowBottomLeft;
                    self.origin = CGPointMake(point.x+_start_offSetX-viewWidth, point.y+arrowHeight);
                }
            } else {
                end_Line = (point.y-_start_offSetY-arrowHeight)/cell_height;
                end_Line = end_Line>line?line:end_Line;
                if ((SCREEN_WIDTH-point.x)>viewWidth || point.x < (SCREEN_WIDTH - _start_offSetX)/2) {
                    self.endShowType = MLMOptionSelectViewEndShowTopRight;
                    self.origin = CGPointMake(point.x, point.y-_start_offSetY-viewHeight-arrowHeight);
                } else {
                    self.endShowType = MLMOptionSelectViewEndShowTopLeft;
                    self.origin = CGPointMake(point.x+_start_offSetX-viewWidth, point.y-_start_offSetY-viewHeight-arrowHeight);
                }
            }
        }
            break;
        case MLMOptionSelectViewTop:
        {
            if ((point.y-arrowHeight) > viewHeight || point.y > (SCREEN_HEIGHT-_start_offSetY)/2) {
                end_Line = (point.y-arrowHeight)/cell_height;
                end_Line = end_Line>line?line:end_Line;
                if ((SCREEN_WIDTH-point.x)>viewWidth || point.x < (SCREEN_WIDTH - _start_offSetX)/2) {
                    self.endShowType = MLMOptionSelectViewEndShowTopRight;
                    self.origin = CGPointMake(point.x, point.y-viewHeight-arrowHeight);
                } else {
                    self.endShowType = MLMOptionSelectViewEndShowTopLeft;
                    self.origin = CGPointMake(point.x+_start_offSetX-viewWidth, point.y-viewHeight-arrowHeight);
                }
            } else {
                end_Line = (SCREEN_HEIGHT - point.y -_start_offSetY-arrowHeight)/cell_height;
                end_Line = end_Line>line?line:end_Line;
                if ((SCREEN_WIDTH-point.x)>viewWidth || point.x < (SCREEN_WIDTH - _start_offSetX)/2) {
                    self.endShowType = MLMOptionSelectViewEndShowBottomRight;
                    self.origin = CGPointMake(point.x, point.y+_start_offSetY+arrowHeight);
                } else {
                    self.endShowType = MLMOptionSelectViewEndShowBottomLeft;
                    self.origin = CGPointMake(point.x+_start_offSetX - viewWidth, point.y+_start_offSetY+arrowHeight);
                }
            }
        }
            break;
        case MLMOptionSelectViewLeft:
        {
            if ((point.x-arrowHeight) >viewWidth || point.x > (SCREEN_WIDTH - _start_offSetX)/2) {//左
                viewWidth = viewWidth < (point.x-arrowHeight) ? viewWidth : (point.x-arrowHeight);
                
                if ((SCREEN_HEIGHT -point.y)>viewHeight || point.y<(SCREEN_HEIGHT -_start_offSetY)/2) {
                    self.endShowType = MLMOptionSelectViewEndShowLeftBottom;
                    self.origin = CGPointMake(point.x - viewWidth-arrowHeight, point.y);
                } else {
                    self.endShowType = MLMOptionSelectViewEndShowLeftTop;
                    self.origin = CGPointMake(point.x - viewWidth-arrowHeight, point.y+_start_offSetY - viewHeight);
                }
            } else {
                viewWidth = viewWidth > (SCREEN_WIDTH - point.x-_start_offSetX-arrowHeight)?(SCREEN_WIDTH - point.x-arrowHeight):viewWidth;
                
                if ((SCREEN_HEIGHT -point.y)>viewHeight || point.y<(SCREEN_HEIGHT -_start_offSetY)/2) {
                    self.endShowType = MLMOptionSelectViewEndShowRightBottom;
                    self.origin = CGPointMake(point.x + _start_offSetX+arrowHeight, point.y);
                } else {
                    self.endShowType = MLMOptionSelectViewEndShowRightTop;
                    self.origin = CGPointMake(point.x + _start_offSetX+arrowHeight, point.y+_start_offSetY-viewHeight);
                }
                
            }
        }
            break;
        case MLMOptionSelectViewRight:
        {
            if ((SCREEN_WIDTH-point.x-arrowHeight)>viewWidth || point.x < (SCREEN_WIDTH - _start_offSetX)/2) {
                viewWidth = viewWidth > (SCREEN_WIDTH - point.x-arrowHeight)?(SCREEN_WIDTH - point.x-arrowHeight):viewWidth;

                if ((SCREEN_HEIGHT -point.y)>viewHeight || point.y<(SCREEN_HEIGHT -_start_offSetY)/2) {
                    self.endShowType = MLMOptionSelectViewEndShowRightBottom;
                    self.origin = CGPointMake(point.x + arrowHeight, point.y);
                } else {
                    self.endShowType = MLMOptionSelectViewEndShowRightTop;
                    self.origin = CGPointMake(point.x + arrowHeight, point.y+_start_offSetY-viewHeight);
                }
                
            } else {
                viewWidth = viewWidth < (point.x-_start_offSetX-arrowHeight) ? viewWidth : (point.x-_start_offSetX-arrowHeight);
                if ((SCREEN_HEIGHT -point.y)>viewHeight || point.y<(SCREEN_HEIGHT -_start_offSetY)/2) {
                    self.endShowType = MLMOptionSelectViewEndShowLeftBottom;
                    self.origin = CGPointMake(point.x - _start_offSetX -viewWidth-arrowHeight, point.y);
                } else {
                    self.endShowType = MLMOptionSelectViewEndShowLeftTop;
                    self.origin = CGPointMake(point.x - _start_offSetX - viewWidth-arrowHeight, point.y+_start_offSetY-viewHeight);
                }
            }
        }
            break;
        default:
            break;
    }
    if (_optionType == MLMOptionSelectViewTypeArrow) {
        [self drowArrow];
    }
    [self animation_show];
}

#pragma mark - 计算弹出方向之后
- (void)setEndShowType:(MLMOptionSelectViewEndShow)endShowType {
    _endShowType = endShowType;
    
    NSInteger line = [self showLine];
    switch (endShowType) {
        case MLMOptionSelectViewEndShowTopRight:
        {
            viewWidth = (SCREEN_WIDTH-point.x)>viewWidth?viewWidth:(SCREEN_WIDTH-point.x);
            self.layer.anchorPoint = CGPointMake(_arrow_offset, 1);
        }
            break;
        case MLMOptionSelectViewEndShowTopLeft:
        {
            _arrow_offset = 1-_arrow_offset;
            viewWidth = (point.x+_start_offSetX)>viewWidth?viewWidth : point.x+_start_offSetX;
            self.layer.anchorPoint = CGPointMake(_arrow_offset,1);
        }
            break;
        case MLMOptionSelectViewEndShowBottomRight:
        {
            viewWidth = (SCREEN_WIDTH-point.x)>viewWidth?viewWidth:(SCREEN_WIDTH-point.x);
            self.layer.anchorPoint = CGPointMake(_arrow_offset, 0);
        }
            break;
        case MLMOptionSelectViewEndShowBottomLeft:
        {
            _arrow_offset = 1-_arrow_offset;
            viewWidth = (point.x+_start_offSetX)>viewWidth?viewWidth : point.x+_start_offSetX;
            self.layer.anchorPoint = CGPointMake(_arrow_offset,0);
        }
            break;
        case MLMOptionSelectViewEndShowRightTop:
        {
            _arrow_offset = 1-_arrow_offset;
            end_Line = point.y/cell_height;
            end_Line = end_Line>line?line:end_Line;
            self.layer.anchorPoint = CGPointMake(0, _arrow_offset);
        }
            break;
        case MLMOptionSelectViewEndShowRightBottom:
        {
            end_Line = (SCREEN_HEIGHT - point.y)/cell_height;
            end_Line = end_Line>line?line:end_Line;
            self.layer.anchorPoint = CGPointMake(0, _arrow_offset);
        }
            break;
        case MLMOptionSelectViewEndShowLeftTop:
        {
            _arrow_offset = 1-_arrow_offset;
            end_Line = point.y/cell_height;
            end_Line = end_Line>line?line:end_Line;
            self.layer.anchorPoint = CGPointMake(1, _arrow_offset);
        }
            break;
        case MLMOptionSelectViewEndShowLeftBottom:
        {
            end_Line = (SCREEN_HEIGHT - point.y)/cell_height;
            end_Line = end_Line>line?line:end_Line;
            self.layer.anchorPoint = CGPointMake(1, _arrow_offset);
        }
            break;
        default:
            break;
    }
    viewHeight = end_Line * cell_height;
    self.size = CGSizeMake(viewWidth, viewHeight);
}


#pragma mark - 画箭头
- (void)drowArrow {
    //根据锚点的位置画箭头
    switch (_endShowType) {
        case MLMOptionSelectViewEndShowBottomRight:
        case MLMOptionSelectViewEndShowBottomLeft:
        {
            arrow1 = CGPointMake(self.x+self.width*_arrow_offset , self.y-arrow_H);
            arrow2 = CGPointMake(self.x+self.width*_arrow_offset + (arrow_W/2 > self.width*(1-_arrow_offset)?0:arrow_W/2), self.y);
            arrow3 = CGPointMake(self.x+self.width*_arrow_offset - (arrow_W/2 > self.width*_arrow_offset?0:arrow_W/2), self.y);
        }
            break;
        case MLMOptionSelectViewEndShowTopRight:
        case MLMOptionSelectViewEndShowTopLeft:
        {
            arrow1 = CGPointMake(self.x+self.width*_arrow_offset , self.y+self.height+arrow_H);
            arrow2 = CGPointMake(self.x+self.width*_arrow_offset + (arrow_W/2 > self.width*(1-_arrow_offset)?0:arrow_W/2), self.y + self.height);
            arrow3 = CGPointMake(self.x+self.width*_arrow_offset - (arrow_W/2 > self.width*_arrow_offset?0:arrow_W/2), self.y + self.height);
        }
            break;
        case MLMOptionSelectViewEndShowLeftTop:
        case MLMOptionSelectViewEndShowLeftBottom:
        {
            arrow1 = CGPointMake(self.x+self.width+arrow_H, self.y+self.height*_arrow_offset);
            arrow2 = CGPointMake(self.x+self.width, self.y+self.height*_arrow_offset + (arrow_W/2 > self.height*(1-_arrow_offset)?0:arrow_W/2));
            arrow3 = CGPointMake(self.x+self.width, self.y+self.height*_arrow_offset - (arrow_W/2 > self.height*_arrow_offset?0:arrow_W/2));
        }
            break;
        case MLMOptionSelectViewEndShowRightTop:
        case MLMOptionSelectViewEndShowRightBottom:
        {
            arrow1 = CGPointMake(self.x-arrow_H, self.y+self.height*_arrow_offset);
            arrow2 = CGPointMake(self.x, self.y+self.height*_arrow_offset + (arrow_W/2 > self.height*(1-_arrow_offset)?0:arrow_W/2));
            arrow3 = CGPointMake(self.x, self.y+self.height*_arrow_offset - (arrow_W/2 > self.height*_arrow_offset?0:arrow_W/2));
        }
            break;
        default:
            break;
    }
    arrow_layer = [[CALayer alloc] init];
    arrow_layer.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
    arrow_layer.delegate = self;
    [arrow_layer setNeedsDisplay];
    [KEYWINDOW.layer addSublayer:arrow_layer];
}

- (void)drawLayer:(CALayer *)layer inContext:(CGContextRef)ctx {
    CGContextSetFillColorWithColor(ctx, _backColor.CGColor);
    CGContextSetStrokeColorWithColor(ctx, [UIColor clearColor].CGColor);
    
    CGContextMoveToPoint(ctx, arrow1.x, arrow1.y);
    CGContextAddLineToPoint(ctx, arrow2.x, arrow2.y);
    CGContextAddLineToPoint(ctx, arrow3.x, arrow3.y);
    CGContextClosePath(ctx);
    CGContextDrawPath(ctx, kCGPathFillStroke);

}

#pragma mark - 动画
- (void)animation_show {
    [self zoomOrOn];
    [UIView animateWithDuration:.3 animations:^{
        self.cover.alpha = .3;
        self.transform = CGAffineTransformMakeScale(1, 1);
    }];
}


- (void)dismiss {
    [UIView animateWithDuration:.3 animations:^{
        [self zoomOrOn];
        self.cover.alpha = 0;
    } completion:^(BOOL finished) {
        self.transform= CGAffineTransformIdentity;
        [self removeFromSuperview];
        [self.cover removeFromSuperview];
        [arrow_layer removeFromSuperlayer];
    }];
}


#pragma mark - 是缩放或者展开
- (void)zoomOrOn {
    if (_vhShow) {
        if (_diretionType==MLMOptionSelectViewBottom || _diretionType==MLMOptionSelectViewTop) {
            self.transform = CGAffineTransformMakeScale(1, 0.001);
        } else {
            self.transform = CGAffineTransformMakeScale(0.001, 1);
        }
    } else {
        self.transform = CGAffineTransformMakeScale(0.001, 0.001);
    }
}





#pragma mark - cover
- (void)setCoverColor:(UIColor *)coverColor {
    _coverColor = coverColor;
    self.cover.backgroundColor = _coverColor;
}

- (void)addConstraintToCover {
    NSLayoutConstraint* leftConstraint = [NSLayoutConstraint constraintWithItem:_cover attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:KEYWINDOW attribute:NSLayoutAttributeLeading multiplier:1.0f constant:0.0f];
    NSLayoutConstraint* rightConstraint = [NSLayoutConstraint constraintWithItem:_cover attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:KEYWINDOW attribute:NSLayoutAttributeTrailing multiplier:1.0f constant:0.0f];
    NSLayoutConstraint* topConstraint = [NSLayoutConstraint constraintWithItem:_cover attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:KEYWINDOW attribute:NSLayoutAttributeTop multiplier:1.0f constant:0.0f];
    NSLayoutConstraint* bottomConstraint = [NSLayoutConstraint constraintWithItem:_cover attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:KEYWINDOW attribute:NSLayoutAttributeBottom multiplier:1.0f constant:0.0f];
    [KEYWINDOW addConstraints:@[leftConstraint, rightConstraint, topConstraint, bottomConstraint]];
}

- (UIView *)cover {
    if (!_cover) {
        _cover = [[UIView alloc] initWithFrame:KEYWINDOW.bounds];
        _cover.backgroundColor = _coverColor;
        _cover.alpha = 0;
        _cover.translatesAutoresizingMaskIntoConstraints = NO;
        __weak typeof(self) weakself = self;
        [_cover tapHandle:^{
            [weakself dismiss];
        }];
    }
    return _cover;
}

#pragma mark - table
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _rowNumber?_rowNumber():0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (_cell) {
        UITableViewCell *cell = _cell(indexPath);
        cell.contentView.backgroundColor = _backColor;
        cell.backgroundColor = _backColor;
        cell.selectionStyle = 0;
        return cell;
    } else {
        return nil;
    }
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return _optionCellHeight?_optionCellHeight():cell_height;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.00001f;

}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0.00001f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.selectedOption) {
        self.selectedOption(indexPath);
    }
    [self dismiss];
}

#pragma mark - table_edit
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return _canEdit;
}

- (NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    __weak typeof(self) weakSelf = self;
    UITableViewRowAction *deleteAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:@"删除" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        if (self.removeOption) {
            self.removeOption(indexPath);
        }
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        [weakSelf changgeFrame];
    }];
    deleteAction.backgroundColor = [UIColor redColor];
    return @[deleteAction];
}


#pragma mark - 删除之后改变frame
- (void)changgeFrame {
    if ([self showLine] == 0) {
        [self dismiss];
    }
    if (end_Line <= [self showLine]) {
        return;
    }
    
    [UIView animateWithDuration:.3 animations:^{
        switch (_endShowType) {
            case MLMOptionSelectViewEndShowBottomLeft:
            case MLMOptionSelectViewEndShowBottomRight:
            case MLMOptionSelectViewEndShowLeftBottom:
            case MLMOptionSelectViewEndShowRightBottom:
            {
                self.height -= cell_height;
            }
                break;
            case MLMOptionSelectViewEndShowTopLeft:
            case MLMOptionSelectViewEndShowTopRight:
            case MLMOptionSelectViewEndShowLeftTop:
            case MLMOptionSelectViewEndShowRightTop:
            {
                self.height -= cell_height;
                self.y += cell_height;
            }
                break;
            default:
                break;
        }
    }];
}

@end
