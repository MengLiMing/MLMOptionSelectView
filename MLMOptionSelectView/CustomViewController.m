//
//  CustomViewController.m
//  MLMOptionSelectView
//
//  Created by my on 16/10/12.
//  Copyright © 2016年 MS. All rights reserved.
//

#import "CustomViewController.h"
#import "MLMOptionSelectView.h"
#import "UIView+Category.h"
#import "CustomCell.h"

@interface CustomViewController ()
{
    NSMutableArray *listArray;
    
    
    UIView *leftRightView;
    UILabel *topBottomView;
}

@property (nonatomic, strong) MLMOptionSelectView *cellView;

@end

@implementation CustomViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    listArray = [NSMutableArray array];
    for (NSInteger i = 0; i < 7; i++) {
        [listArray addObject:[NSString stringWithFormat:@"%@",@(i)]];
    }
    _cellView = [[MLMOptionSelectView alloc] initOptionView];

    
    [self leftRight];

    [self topBottom];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"展开" style:UIBarButtonItemStylePlain target:self action:@selector(showView)];
    
}

- (void)showView {
    [self defaultCell];
    _cellView.arrow_offset = 0.9;
    _cellView.vhShow = NO;
    _cellView.optionType = MLMOptionSelectViewTypeArrow;
    [_cellView showViewFromPoint:CGPointMake(SCREEN_WIDTH - 200 -10, 64 + 1) viewWidth:200 targetView:nil direction:MLMOptionSelectViewBottom];
}


- (void)leftRight {
    leftRightView = [[UIView alloc] initWithFrame:CGRectMake(0, 70, 40, 100)];
    leftRightView.backgroundColor = [UIColor redColor];
    [self.view addSubview:leftRightView];
    UIPanGestureRecognizer *pan1 = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(moveLRView:)];
    [leftRightView addGestureRecognizer:pan1];
    
    
    [leftRightView tapHandle:^{
        CGRect label3Rect = [MLMOptionSelectView targetView:leftRightView];
        [self customCell];
        _cellView.arrow_offset = 0.1;
        _cellView.vhShow = NO;
        _cellView.optionType = MLMOptionSelectViewTypeArrow;
        _cellView.selectedOption = nil;
        [_cellView showViewFromPoint:CGPointMake(label3Rect.origin.x+40, label3Rect.origin.y) viewWidth:200 targetView:leftRightView direction:MLMOptionSelectViewRight];
    }];
}


- (void)topBottom {
    topBottomView = [[UILabel alloc] initWithFrame:CGRectMake(0, 80, 200, 40)];
    topBottomView.backgroundColor = [UIColor greenColor];
    [self.view addSubview:topBottomView];
    UIPanGestureRecognizer *pan2 = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(moveLRView:)];
    [topBottomView addGestureRecognizer:pan2];
    
    
    WEAK(weakTopB, topBottomView);
    WEAK(weaklistArray, listArray);
    [topBottomView tapHandle:^{
        CGRect label3Rect = [MLMOptionSelectView targetView:topBottomView];
        [self defaultCell];
        _cellView.arrow_offset = .5;
        _cellView.vhShow = YES;
        _cellView.optionType = MLMOptionSelectViewTypeCustom;
        _cellView.selectedOption = ^(NSIndexPath *indexPath) {
            weakTopB.text = weaklistArray[indexPath.row];
        };
        
        [_cellView showViewFromPoint:CGPointMake(label3Rect.origin.x, label3Rect.origin.y+label3Rect.size.height) viewWidth:200 targetView:topBottomView direction:MLMOptionSelectViewBottom];
    }];
    
    
    
}


#pragma mark - 设置——cell
- (void)customCell {
    WEAK(weaklistArray, listArray);
    WEAK(weakSelf, self);
    _cellView.canEdit = YES;
    [_cellView registerNib:[UINib nibWithNibName:@"CustomCell" bundle:nil] forCellReuseIdentifier:@"CustomCell"];
    _cellView.cell = ^(NSIndexPath *indexPath){
        CustomCell *cell = [weakSelf.cellView dequeueReusableCellWithIdentifier:@"CustomCell"];
        cell.label1.text = weaklistArray[indexPath.row];
        return cell;
    };
    _cellView.optionCellHeight = ^{
        return 60.f;
    };
    _cellView.rowNumber = ^(){
        return (NSInteger)weaklistArray.count;
    };
    _cellView.removeOption = ^(NSIndexPath *indexPath){
        [weaklistArray removeObjectAtIndex:indexPath.row];
        if (weaklistArray.count == 0) {
            [weakSelf.cellView dismiss];
        }
    };
}


- (void)defaultCell {
    WEAK(weaklistArray, listArray);
    WEAK(weakSelf, self);
    _cellView.canEdit = NO;
    [_cellView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"DefaultCell"];
    _cellView.cell = ^(NSIndexPath *indexPath){
        UITableViewCell *cell = [weakSelf.cellView dequeueReusableCellWithIdentifier:@"DefaultCell"];
        cell.textLabel.text = [NSString stringWithFormat:@"DefaultCell：%@",weaklistArray[indexPath.row]];
        return cell;
    };
    _cellView.optionCellHeight = ^{
        return 40.f;
    };
    _cellView.rowNumber = ^(){
        return (NSInteger)weaklistArray.count;
    };
}


- (void)moveLRView:(UIGestureRecognizer *)ges {
    if (ges.state != UIGestureRecognizerStateEnded && ges.state != UIGestureRecognizerStateFailed){
        //通过使用 locationInView 这个方法,来获取到手势的坐标
        CGPoint location = [ges locationInView:ges.view.superview];
        ges.view.center = location;
    }
}

@end
