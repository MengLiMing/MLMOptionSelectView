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
}
@property (nonatomic, strong) MLMOptionSelectView *cellView;


@property (nonatomic, assign) BOOL topOrRight;
@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"点击下方view";
    listArray = [NSMutableArray array];
    for (NSInteger i = 0; i < 7; i++) {
        [listArray addObject:[NSString stringWithFormat:@"%@",@(i)]];
    }
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"下个页面" style:UIBarButtonItemStylePlain target:self action:@selector(nextvc)];
    
    self.topOrRight = YES;
    
    
    _cellView = [[MLMOptionSelectView alloc] initOptionView];

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

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self.view];
    [self defaultCell];
    _cellView.vhShow = NO;
    _cellView.optionType = MLMOptionSelectViewTypeArrow;
    [_cellView showTapPoint:point viewWidth:200 direction:_topOrRight?MLMOptionSelectViewTop:MLMOptionSelectViewRight];
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


- (void)nextvc {
    UIViewController *vc = [NSClassFromString(@"CustomViewController") new];
    [self.navigationController pushViewController:vc animated:YES];
}
@end
