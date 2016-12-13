//
//  RootViewController.m
//  3DTouch
//
//  Created by abnerzhang on 2016/12/12.
//  Copyright © 2016年 abnerzhang. All rights reserved.
//

#import "RootViewController.h"
#import "TestOneViewController.h"
#import "TestTwoViewController.h"

static NSString *const cellIdentifier = @"cellIdentifier";

#define kScreenWidth [UIScreen mainScreen].bounds.size.width
#define kScreenHeight [UIScreen mainScreen].bounds.size.height


@interface RootViewController ()<UIViewControllerPreviewingDelegate>

@property (nonatomic) NSArray *items;
@property (nonatomic, assign) CGRect sourceRect;       // 用户手势点 对应需要突出显示的rect
@property (nonatomic, strong) NSIndexPath *indexPath;  // 用户手势点 对应的indexPath
@property (nonatomic, strong) UILabel *popLabel;
@property (nonatomic, strong) UIView *bgView;


@end

@implementation RootViewController
- (instancetype)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        self.items = @[@"数据1", @"数据2", @"数据3", @"数据4", @"数据5", @"数据6", @"数据7", @"数据8", @"数据9", @"数据10", @"数据11", @"数据12", @"数据13", @"数据14"];
    }
    return self;
}



- (void)gotoVC:(NSNotification *)noti {
    NSString *type = noti.userInfo[@"type"];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 100, kScreenWidth, 50)];
    label.textAlignment = NSTextAlignmentCenter;
    label.text = [NSString stringWithFormat:@"这是第%@个页面\n轻触页面返回", type];
    label.numberOfLines = 0;
    label.textColor = [UIColor blackColor];
    
    TestOneViewController *testVC = [[TestOneViewController alloc] init];
    testVC.view.backgroundColor = [UIColor whiteColor];
    [testVC.view addSubview:label];
    [self presentViewController:testVC animated:YES completion:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gotoVC:) name:@"gotoVC" object:nil];
    self.navigationController.navigationBar.translucent = NO;
    [self setupTableView];
    // 注册3D touch, 先判断是否可用
    if (self.traitCollection.forceTouchCapability == UIForceTouchCapabilityAvailable) {
        [self registerForPreviewingWithDelegate:self sourceView:self.view];
    } else {
        NSLog(@"不支持3d touch");
    }
    // Do any additional setup after loading the view.
}

- (void)setupTableView {
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:cellIdentifier];
    self.tableView.rowHeight = 100;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.items.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    cell.textLabel.text = self.items[indexPath.row];
    
    cell.contentView.backgroundColor = [self randomColor];
    return cell;
}

- (UIColor *)randomColor {
    CGFloat r = arc4random() % 256;
    CGFloat g = (arc4random() % 200) + 50;
    CGFloat b = arc4random() % 254;
    UIColor *color = [UIColor colorWithRed:r / 255.0 green:g / 255.0 blue:b / 255.0 alpha:1];
    return color;
}


/** peek手势  */
- (nullable UIViewController *)previewingContext:(id <UIViewControllerPreviewing>)previewingContext viewControllerForLocation:(CGPoint)location {
    
    // 获取用户手势点所在cell的下标。同时判断手势点是否超出tableView响应范围。
    if (![self getShouldShowRectAndIndexPathWithLocation:location]) return nil;
    // 如果想实现有的cell有3d touch, 有的没有, 则可以这样设置
//    if (self.indexPath.row == 0 || self.indexPath.row == 6) {
//        return nil;
//    }
    TestTwoViewController *childVC = [[TestTwoViewController alloc] init];
    previewingContext.sourceRect = self.sourceRect;
    
    // 加个白色背景
    _bgView =[[UIView alloc] initWithFrame:CGRectMake(20, 10, kScreenWidth - 40, kScreenHeight - 20 - 64 * 2)];
    _bgView.backgroundColor = [UIColor whiteColor];
    _bgView.layer.cornerRadius = 10;
    _bgView.clipsToBounds = YES;
    [childVC.view addSubview:_bgView];
    
    // 加个lable
    _popLabel = [[UILabel alloc] initWithFrame:_bgView.bounds];
    _popLabel.textAlignment = NSTextAlignmentCenter;
    _popLabel.text = self.items[self.indexPath.row];
    [_bgView addSubview:_popLabel];
    
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
    btn.backgroundColor = [UIColor redColor];
    btn.frame = CGRectMake(10, 10, 200, 200);
    [_bgView addSubview:btn];
    [btn addTarget:self action:@selector(btnAction) forControlEvents:UIControlEventTouchUpInside];
    
    return childVC;
}

/** pop手势  */
- (void)previewingContext:(id <UIViewControllerPreviewing>)previewingContext commitViewController:(UIViewController *)viewControllerToCommit {
    [self showViewController:viewControllerToCommit sender:self];
    viewControllerToCommit.view.backgroundColor = [UIColor redColor];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction)];
    tap.numberOfTapsRequired = 3;
    [viewControllerToCommit.view addGestureRecognizer:tap];
    _bgView.frame = viewControllerToCommit.view.bounds;
    _popLabel.frame = _bgView.frame;
    // [self tableView:self.tableView didSelectRowAtIndexPath:self.indexPath];
}



- (void)tapAction {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)btnAction {
    [self tapAction];
}

/** 获取用户手势点所在cell的下标。同时判断手势点是否超出tableView响应范围。*/
- (BOOL)getShouldShowRectAndIndexPathWithLocation:(CGPoint)location {
    // location.y: tableView从(0, 0)开始
    NSInteger row = location.y / 100;
    self.sourceRect = CGRectMake(0, row * 100, kScreenWidth, 100);
    self.indexPath = [NSIndexPath indexPathForItem:row inSection:0];
    return YES;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
