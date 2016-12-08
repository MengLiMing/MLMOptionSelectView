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

@interface MLMOptionSelectView () <UITableViewDelegate,UITableViewDataSource>
{
    ///向下或者向上展开超出屏幕时偏移的距离
    CGFloat _start_offSetY;
    CGFloat _start_offSetX;
    
    
    //箭头的三个顶点坐标
    CGPoint arrow1;
    CGPoint arrow2;
    CGPoint arrow3;
    
    CAShapeLayer *arrow_layer;
    //弹出视图的origin
    CGPoint point;
    //弹出之后的宽高
    CGFloat viewHeight;
    CGFloat viewWidth;
    //弹出之后的起点
    CGPoint startPoint;
    //箭头高
    CGFloat arrowHeight;
    //显示时的行数
    NSInteger end_Line;
    //cell行高
    CGFloat cell_height;
    
    //是否有参照view
    UIView *_targetView;
    //targetRect
    CGRect _targetRect;
    //弹出点在对应方向上的比例
    CGFloat _target_scale;
    //是否翻转
    BOOL overturn;
    
}
///弹出朝向
@property (nonatomic, assign) MLMOptionSelectViewDirection diretionType;
///view
@property (nonatomic, strong) UIView *showView;
///背景层
@property (nonatomic, strong) UIView *cover;
///箭头顶点的位置和动画开始位置
@property (nonatomic, assign) CGFloat arrow_offset;//(0 - 1之间)

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
    _edgeInsets = UIEdgeInsetsMake(64, 10, 10, 10);
}


- (void)setBackColor:(UIColor *)backColor {
    _backColor = backColor;
    self.backgroundColor = _backColor;
}

- (void)setCornerRadius:(CGFloat)cornerRadius {
    _cornerRadius = cornerRadius;
    self.layer.cornerRadius = cornerRadius;
}

#pragma mark - 计算弹出位置
+ (CGRect)targetView:(UIView *)targetView {
    CGRect rect = [KEYWINDOW convertRect:targetView.frame fromView:targetView.superview];
    return rect;
}

#pragma mark - 显示多少行
- (CGFloat)showLine {
    NSInteger row = _rowNumber?_rowNumber():0;
    NSInteger line = row > _maxLine ? _maxLine : row;
    return line;
}


#pragma mark - 弹出之前计算行数、高度等
- (void)beforeShow:(CGPoint)viewPoint
             width:(CGFloat)width
        targetView:(UIView *)targetView
         direction:(MLMOptionSelectViewDirection)directionType {
    //显示行数
    NSInteger line = [self showLine];
    if (line == 0) {
        return;
    }

    point = viewPoint;


    //计算高度
    cell_height = _optionCellHeight?_optionCellHeight():cell_height;
    viewHeight = line * cell_height;
    
    _targetView = targetView;

    [self reloadData];
    
    CGFloat maxWidth = SCREEN_WIDTH - _edgeInsets.left - _edgeInsets.right;
    
    viewWidth = width > maxWidth ? maxWidth : width;
    //添加视图
    [KEYWINDOW addSubview:self.cover];
    [self.showView addSubview:self];
    [self addConstraintToCover];
    //弹出方向和动画效果 改变
    _diretionType = directionType;
    
    if (_optionType == MLMOptionSelectViewTypeArrow) {
        arrowHeight = arrow_H;
    } else {
        arrowHeight = 0;
    }
}


#pragma mark - 弹出的方法
- (void)showTapPoint:(CGPoint)tapPoint
           viewWidth:(CGFloat)width
           direction:(MLMOptionSelectViewDirection)directionType {
    [self beforeShow:tapPoint width:width targetView:nil direction:directionType];
    //调节显示
    [self showByDiretionType];
    [self showAndDraw];
}

#pragma mark - 弹出的方法
- (void)showOffSetScale:(CGFloat)offset_Scale
              viewWidth:(CGFloat)width
             targetView:(UIView *)targetView
              direction:(MLMOptionSelectViewDirection)directionType {
    _target_scale = offset_Scale;
    _targetRect = [MLMOptionSelectView targetView:targetView];
    CGPoint showP;
    switch (directionType) {
        case MLMOptionSelectViewTop:
        {
            showP = CGPointMake(_targetRect.origin.x + _targetRect.size.width * _target_scale, _targetRect.origin.y);
        }
            break;
        case MLMOptionSelectViewBottom:
        {
            showP = CGPointMake(_targetRect.origin.x + _targetRect.size.width * _target_scale, _targetRect.origin.y+_targetRect.size.height);
        }
            break;
        case MLMOptionSelectViewLeft:
        {
            showP = CGPointMake(_targetRect.origin.x, _targetRect.origin.y + _targetRect.size.height * _target_scale);
        }
            break;
        case MLMOptionSelectViewRight:
        {
            showP = CGPointMake(_targetRect.origin.x + _targetRect.size.width, _targetRect.origin.y + _targetRect.size.height * _target_scale);
        }
            break;
        default:
            break;
    }
    [self beforeShow:showP width:width targetView:targetView direction:directionType];
    //调节显示
    [self showByDiretionType];
    [self showAndDraw];
}

#pragma mark - 改变弹出方向
- (void)showByDiretionType {
    _start_offSetY = _targetView?_targetView.height:0;
    _start_offSetX = _targetView?_targetView.width:0;
    switch (_diretionType) {
        case MLMOptionSelectViewBottom:
        {
            if ((SCREEN_HEIGHT - point.y - arrowHeight - _edgeInsets.bottom) > viewHeight ||(point.y - _edgeInsets.top - _start_offSetY) < (SCREEN_HEIGHT - _edgeInsets.top - _edgeInsets.bottom - _start_offSetY)/2 ) {
                self.diretionType = MLMOptionSelectViewBottom;
            } else {
                point.y -= _start_offSetY;
                self.diretionType = MLMOptionSelectViewTop;
            }
        }
            break;
        case MLMOptionSelectViewTop:
        {
            if ((point.y - arrowHeight - _edgeInsets.top) > viewHeight || (point.y - _edgeInsets.top) > (SCREEN_HEIGHT - _edgeInsets.top - _edgeInsets.bottom - _start_offSetY)/2) {
                self.diretionType = MLMOptionSelectViewTop;
            } else {
                point.y += _start_offSetY;
                self.diretionType = MLMOptionSelectViewBottom;
            }
        }
            break;
        case MLMOptionSelectViewLeft:
        {
            if ((point.x- arrowHeight - _edgeInsets.left) >viewWidth || (point.x - _edgeInsets.left) > (SCREEN_WIDTH - _edgeInsets.left - _edgeInsets.right- _start_offSetX)/2) {//左
                self.diretionType = MLMOptionSelectViewLeft;
            } else {
                point.x += _start_offSetX;
                self.diretionType = MLMOptionSelectViewRight;
            }
        }
            break;
        case MLMOptionSelectViewRight:
        {
            if ((SCREEN_WIDTH-point.x-arrowHeight - _edgeInsets.right)>viewWidth || (point.x - _edgeInsets.left - _start_offSetX) < (SCREEN_WIDTH - _edgeInsets.left - _edgeInsets.right - _start_offSetX)/2 ) {
                self.diretionType = MLMOptionSelectViewRight;
            } else {
                point.x -= _start_offSetX;
                self.diretionType = MLMOptionSelectViewLeft;
            }
        }
            break;
        default:
            break;
    }
}

#pragma mark - 计算后的展示方向
- (void)setDiretionType:(MLMOptionSelectViewDirection)diretionType {
    _diretionType = diretionType;
    NSInteger line = viewHeight/cell_height;
    
    switch (diretionType) {
        case MLMOptionSelectViewBottom:
        case MLMOptionSelectViewTop:
        {
            if (_targetView) {
                CGFloat centerX = _targetRect.origin.x + _targetRect.size.width/2;
                if ((centerX - _edgeInsets.left) <= (SCREEN_WIDTH - _edgeInsets.left - _edgeInsets.right)/2 || viewWidth <= (SCREEN_WIDTH - _targetRect.origin.x - _edgeInsets.right)) {
                    viewWidth = MIN(viewWidth, SCREEN_WIDTH - _targetRect.origin.x - _edgeInsets.right);
                    _arrow_offset = _targetRect.size.width * _target_scale / viewWidth;
                } else {
                    viewWidth = MIN(viewWidth, CGRectGetMaxX(_targetRect) - _edgeInsets.left);
                    _arrow_offset = (1 - _targetRect.size.width *(1 - _target_scale) / viewWidth);
                }
            } else {
                if (point.x < (viewWidth/2 + _edgeInsets.left)) {
                    _arrow_offset = (point.x - _edgeInsets.left)/ viewWidth;
                } else if (point.x > (viewWidth/2 + _edgeInsets.left)&& point.x < (SCREEN_WIDTH - viewWidth/2  - _edgeInsets.right)) {
                    _arrow_offset = .5;
                } else {
                    _arrow_offset = (1 - (SCREEN_WIDTH - point.x - _edgeInsets.right) / viewWidth);
                }
            }
            if (_diretionType == MLMOptionSelectViewTop) {
                end_Line = MIN(line, (point.y-arrowHeight- _edgeInsets.top)/cell_height);
                viewHeight = end_Line * cell_height;
                startPoint = CGPointMake(point.x - viewWidth * _arrow_offset, point.y - arrowHeight - viewHeight);
                self.showView.layer.anchorPoint = CGPointMake(_arrow_offset, 1);
            } else {
                end_Line = MIN(line, (SCREEN_HEIGHT - point.y-arrowHeight - _edgeInsets.bottom)/cell_height);
                viewHeight = end_Line * cell_height;
                startPoint = CGPointMake(point.x - viewWidth * _arrow_offset, point.y + arrowHeight);
                self.showView.layer.anchorPoint = CGPointMake(_arrow_offset,0);
            }
        }
            break;
        case MLMOptionSelectViewLeft:
        case MLMOptionSelectViewRight:
        {
            if (_targetView) {
                CGFloat centerY = _targetRect.origin.y + _targetRect.size.height/2;
                if ((centerY - _edgeInsets.top) <= (SCREEN_HEIGHT - _edgeInsets.top - _edgeInsets.bottom)/2 || viewHeight <= (SCREEN_HEIGHT - _targetRect.origin.y - _edgeInsets.bottom)) {
                    end_Line = MIN(line, (SCREEN_HEIGHT - _targetRect.origin.y - _edgeInsets.bottom)/cell_height);
                    viewHeight = end_Line * cell_height;
                    _arrow_offset = _targetRect.size.height * _target_scale / viewHeight;
                } else {
                    end_Line = MIN(line, (CGRectGetMaxY(_targetRect) - _edgeInsets.top)/cell_height);
                    viewHeight = end_Line * cell_height;
                    _arrow_offset = (1 - _targetRect.size.height *(1 - _target_scale) / viewHeight);
                }
            } else {
                end_Line = MIN(line, (SCREEN_HEIGHT - _edgeInsets.top - _edgeInsets.bottom)/cell_height);
                viewHeight = end_Line * cell_height;
                if (point.y < (viewHeight/2 + _edgeInsets.top)) {
                    _arrow_offset = (point.y - _edgeInsets.top)/ viewHeight;
                } else if (point.y > (viewHeight/2 + _edgeInsets.top)&& point.y < (SCREEN_HEIGHT - viewHeight/2 - _edgeInsets.bottom)) {
                    _arrow_offset = .5;
                } else {
                    _arrow_offset = (1 - (SCREEN_HEIGHT - point.y - _edgeInsets.bottom) / viewHeight);
                }
            }
            if (_diretionType == MLMOptionSelectViewLeft) {
                viewWidth = MIN(viewWidth, point.x - arrowHeight - _edgeInsets.left);
                startPoint = CGPointMake(point.x - arrowHeight - viewWidth, point.y - viewHeight * _arrow_offset);
                self.showView.layer.anchorPoint = CGPointMake(1, _arrow_offset);
            } else {
                viewWidth = MIN(viewWidth, SCREEN_WIDTH - point.x-arrowHeight-_edgeInsets.right);
                startPoint = CGPointMake(point.x + arrowHeight, point.y - viewHeight * _arrow_offset);
                self.showView.layer.anchorPoint = CGPointMake(0, _arrow_offset);
            }
        }
            break;
        default:
            break;
    }
}



#pragma mark - showAndDraw
- (void)showAndDraw {
    //startPoint计算是以self为准，此处变换为backView
    CGRect showFrame;
    switch (_diretionType) {
        case MLMOptionSelectViewTop:
        {
            showFrame = CGRectMake(startPoint.x, startPoint.y, viewWidth, viewHeight + arrowHeight);
            self.origin = CGPointZero;
        }
            break;
        case MLMOptionSelectViewBottom:
        {
            showFrame = CGRectMake(startPoint.x, startPoint.y - arrowHeight, viewWidth, viewHeight + arrowHeight);
            self.origin = CGPointMake(0, arrowHeight);
        }
            break;
        case MLMOptionSelectViewLeft:
        {
            showFrame = CGRectMake(startPoint.x, startPoint.y, viewWidth + arrowHeight, viewHeight);
            self.origin = CGPointZero;
        }
            break;
        case MLMOptionSelectViewRight:
        {
            showFrame = CGRectMake(startPoint.x - arrowHeight, startPoint.y, viewWidth + arrowHeight, viewHeight);
            self.origin = CGPointMake(arrowHeight, 0);
        }
            break;
        default:
            break;
    }
    self.showView.frame = showFrame;
    [KEYWINDOW addSubview:self.showView];
    
    self.size = CGSizeMake(viewWidth, viewHeight);
    
    if (_optionType == MLMOptionSelectViewTypeArrow) {
        [self drowArrow];
    } else {
        if (arrow_layer) {
            [arrow_layer removeFromSuperlayer];
            arrow_layer = nil;
        }
    }
    [self animation_show];
}



#pragma mark - showView
- (UIView *)showView {
    if (!_showView) {
        _showView = [[UIView alloc] init];
        _showView.backgroundColor = [UIColor clearColor];
    }
    return _showView;
}
#pragma mark - 画箭头
- (void)drowArrow {
    //根据锚点的位置画箭头
    switch (_diretionType) {
        case MLMOptionSelectViewBottom:
        {
            arrow1 = CGPointMake(self.x+self.width*_arrow_offset , self.y-arrow_H);
            arrow2 = CGPointMake(self.x+self.width*_arrow_offset + (arrow_W/2 > self.width*(1-_arrow_offset)?0:arrow_W/2), self.y);
            arrow3 = CGPointMake(self.x+self.width*_arrow_offset - (arrow_W/2 > self.width*_arrow_offset?0:arrow_W/2), self.y);
        }
            break;
        case MLMOptionSelectViewTop:
        {
            arrow1 = CGPointMake(self.x+self.width*_arrow_offset , self.y+self.height+arrow_H);
            arrow2 = CGPointMake(self.x+self.width*_arrow_offset + (arrow_W/2 > self.width*(1-_arrow_offset)?0:arrow_W/2), self.y + self.height);
            arrow3 = CGPointMake(self.x+self.width*_arrow_offset - (arrow_W/2 > self.width*_arrow_offset?0:arrow_W/2), self.y + self.height);
        }
            break;
        case MLMOptionSelectViewLeft:
        {
            arrow1 = CGPointMake(self.x+self.width+arrow_H, self.y+self.height*_arrow_offset);
            arrow2 = CGPointMake(self.x+self.width, self.y+self.height*_arrow_offset + (arrow_W/2 > self.height*(1-_arrow_offset)?0:arrow_W/2));
            arrow3 = CGPointMake(self.x+self.width, self.y+self.height*_arrow_offset - (arrow_W/2 > self.height*_arrow_offset?0:arrow_W/2));
        }
            break;
        case MLMOptionSelectViewRight:
        {
            arrow1 = CGPointMake(self.x-arrow_H, self.y+self.height*_arrow_offset);
            arrow2 = CGPointMake(self.x, self.y+self.height*_arrow_offset + (arrow_W/2 > self.height*(1-_arrow_offset)?0:arrow_W/2));
            arrow3 = CGPointMake(self.x, self.y+self.height*_arrow_offset - (arrow_W/2 > self.height*_arrow_offset?0:arrow_W/2));
        }
            break;
        default:
            break;
    }
    if (!arrow_layer) {
        arrow_layer = [[CAShapeLayer alloc] init];
        arrow_layer.fillColor = _backColor.CGColor;
        [self.showView.layer addSublayer:arrow_layer];
    }
    UIBezierPath *arrowPath = [UIBezierPath bezierPath];
    [arrowPath moveToPoint:arrow1];
    [arrowPath addLineToPoint:arrow2];
    [arrowPath addLineToPoint:arrow3];
    [arrowPath closePath];
    arrow_layer.path = arrowPath.CGPath;
}

#pragma mark - 动画
- (void)animation_show {
    [self zoomOrOn];
    [UIView animateWithDuration:.3 animations:^{
        self.cover.alpha = .3;
        self.showView.transform = CGAffineTransformMakeScale(1, 1);
    }];
}


- (void)dismiss {
    [UIView animateWithDuration:.3 animations:^{
        [self zoomOrOn];
        self.cover.alpha = 0;
    } completion:^(BOOL finished) {
        self.showView.transform= CGAffineTransformIdentity;
        [self.showView removeFromSuperview];
        [self.cover removeFromSuperview];
    }];
}

#pragma mark - 是缩放或者展开
- (void)zoomOrOn {
    if (_vhShow) {
        if (_diretionType==MLMOptionSelectViewBottom || _diretionType==MLMOptionSelectViewTop) {
            self.showView.transform = CGAffineTransformMakeScale(1, 0.001);
        } else {
            self.showView.transform = CGAffineTransformMakeScale(0.001, 1);
        }
    } else {
        self.showView.transform = CGAffineTransformMakeScale(0.001, 0.001);
    }
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.selectedOption) {
        self.selectedOption(indexPath);
    }
    if (!_multiSelect) {
        [self dismiss];
    }
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
    self.height -= cell_height;
    self.showView.height -= cell_height;
    if (_optionType == MLMOptionSelectViewTypeArrow) {
        [self drowArrow];
    }
    [UIView animateWithDuration:.3 animations:^{
        switch (_diretionType) {
            case MLMOptionSelectViewTop:
            {
                self.showView.y += cell_height;
            }
                break;
            case MLMOptionSelectViewRight:
            case MLMOptionSelectViewLeft:
            {
                self.showView.y += cell_height*_arrow_offset;
            }
                break;
            default:
                break;
        }
    }];
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

@end
