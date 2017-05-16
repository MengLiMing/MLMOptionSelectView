//
//  MainViewController.m
//  MLMOptionSelectView
//
//  Created by my on 2016/11/30.
//  Copyright © 2016年 MS. All rights reserved.
//

#import "MainViewController.h"
#import "MLMOptionSelectView.h"

@interface MainViewController ()
{
    NSMutableArray *listArray;
    BOOL h_v_Screen;
}
@property (nonatomic, strong) MLMOptionSelectView *cellView;


@property (nonatomic, assign) BOOL topOrRight;
@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"点击下方view";
    listArray = [NSMutableArray array];
    
    [self listArray];
    
    UIBarButtonItem *right1 = [[UIBarButtonItem alloc] initWithTitle:@"下个页面" style:UIBarButtonItemStylePlain target:self action:@selector(nextvc)];
    
    //如果你的项目是适应横竖屏的  不需要设置此值，如果你的项目是竖屏状态，但是这个页面需要旋转180度，假横屏，则使用此值
    UIBarButtonItem *right2 = [[UIBarButtonItem alloc] initWithTitle:@"横竖屏" style:UIBarButtonItemStylePlain target:self action:@selector(changeV_h)];
    
    self.navigationItem.rightBarButtonItems = @[right1,right2];
    
    self.topOrRight = YES;
    
    
    _cellView = [[MLMOptionSelectView alloc] initOptionView];

}

- (void)listArray {
    if (listArray.count) {
        return;
    }
    for (NSInteger i = 0; i < 7; i++) {
        [listArray addObject:[NSString stringWithFormat:@"%@",@(i)]];
    }
}

- (void)defaultCell {
    WEAK(weaklistArray, listArray);
    WEAK(weakSelf, self);
    _cellView.canEdit = YES;
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
    
    _cellView.removeOption = ^(NSIndexPath *indexPath){
        [weaklistArray removeObjectAtIndex:indexPath.row];
        if (weaklistArray.count == 0) {
            [weakSelf.cellView dismiss];
        }
    };
    
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self listArray];

    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self.view];
    [self defaultCell];
    _cellView.vhShow = NO;
    _cellView.h_v_Screen = h_v_Screen;
    _cellView.edgeInsets = UIEdgeInsetsMake(64, 10, 10, 10);
    _cellView.optionType = MLMOptionSelectViewTypeArrow;
    [_cellView showTapPoint:point viewWidth:150 direction:_topOrRight?MLMOptionSelectViewBottom:MLMOptionSelectViewRight];
}


- (void)setTopOrRight:(BOOL)topOrRight {
    _topOrRight = topOrRight;
    NSString *title;
    if (topOrRight) {
        title = @"上下";
    } else {
        title = @"左右";
    }
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:title style:UIBarButtonItemStylePlain target:self action:@selector(changeTR)];
}

- (void)changeTR {
    self.topOrRight = !self.topOrRight;
}

- (void)changeV_h {
    h_v_Screen = !h_v_Screen;
}

- (void)nextvc {
    UIViewController *vc = [NSClassFromString(@"CustomViewController") new];
    [self.navigationController pushViewController:vc animated:YES];
}
@end
