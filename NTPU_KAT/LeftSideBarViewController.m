//
//  LeftSideBarViewController.m
//  XWQSBK
//
//  Created by Ren XinWei on 13-4-28.
//  Copyright (c) 2013年 renxinwei. All rights reserved.
//

#import "LeftSideBarViewController.h"

@interface LeftSideBarViewController ()
{
    NSArray *_dataList;
}
@property (retain, nonatomic) NSIndexPath *selectIndexPath;

@end

@implementation LeftSideBarViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    _dataList = @[@"1",@"2",@"3",@"4",@"5"];
    if ([_delegate respondsToSelector:@selector(leftSideBarSelectWithController:)]) {
        [_delegate leftSideBarSelectWithController:[self subConWithIndex:0]];
        self.selectIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
        [self.sideMenuTableView selectRowAtIndexPath:_selectIndexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
    }
    [self initViews];
}

- (void)viewDidUnload
{
    [self setSideFaceButton:nil];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return NO;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    NSLog(@"rotate");
}

- (BOOL)shouldAutorotate
{
    return NO;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

#pragma mark - UITableView datasource methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger rows = 0;
    switch (section) {
        case 0:
            rows = 4;
            break;
        case 1:
            rows = 2;
            break;
        case 2:
            rows = 3;
            break;
        default:
            break;
    }
    
    return rows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"SIDEMENUCELL";
    UITableViewCell *menuCell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!menuCell) {
        menuCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    NSString *menuTitle = @"";
    switch (indexPath.section) {
        case 0:
            switch (indexPath.row) {
                case 0:
                    menuTitle = @"随便逛逛";
                    break;
                case 1:
                    menuTitle = @"精华";
                    break;
                case 2:
                    menuTitle = @"有图有真相";
                    break;
                case 3:
                    menuTitle = @"穿越";
                    break;
                default:
                    break;
            }
            break;
        case 1:
            switch (indexPath.row) {
                case 0:
                    menuTitle = @"我收藏的";
                    break;
                case 1:
                    menuTitle = @"我参与的";
                    break;
                default:
                    break;
            }
            break;
        case 2:
            switch (indexPath.row) {
                case 0:
                    menuTitle = @"热门囧图";
                    break;
                case 1:
                    menuTitle = @"内涵图片";
                    break;
                case 2:
                    menuTitle = @"视频集锦";
                    break;
                default:
                    break;
            }
            break;
        default:
            break;
    }
    [self configCellAttribute:menuCell];
    menuCell.textLabel.text = menuTitle;
    
    return menuCell;
}

#pragma mark - UITableView delegate methods

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    CGFloat headerHeight = 0;
    if (section != 0) {
        headerHeight = 9;
    }
    
    return headerHeight;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headerView = nil;
    if (section != 0) {
        headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 9)];
        UIImageView *backgroundImageView = [[UIImageView alloc] initWithFrame:headerView.frame];
//        UIImage *titleBackground = [UIImage imageNamed:@"side_title_background.png"];
//        titleBackground = [titleBackground resizableImageWithCapInsets:UIEdgeInsetsMake(4, 5, 5, 4)];
        [backgroundImageView setImage:[self getSideTitleBackgroundImage]];
        [headerView addSubview:backgroundImageView];
    }

    return headerView;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //点击侧拉栏cell，已选中直接关闭侧拉
    if ([_delegate respondsToSelector:@selector(leftSideBarSelectWithController:)]) {
        if ([indexPath isEqual:_selectIndexPath]) {
            [_delegate leftSideBarSelectWithController:nil];
        }
        else {
            [_delegate leftSideBarSelectWithController:[self subConWithIndex:indexPath]];
        }
    }
    self.selectIndexPath = indexPath;
}

#pragma mark - AuthViewController delegate method

//用户登录成功后回调设置侧拉栏的头像和名称
- (void)QBUserDidLoginSuccessWithQBName:(NSString *)name andImage:(NSString *)imageUrl
{
    if (imageUrl) {
        [_sideFaceButton setImageWithURL:[NSURL URLWithString:imageUrl] placeholderImage:[UIImage imageNamed:@"side_user_avatar.png"]];
    }
    if (name) {
        [_sideJoinQBButton setTitle:name forState:UIControlStateNormal];
    }
    else {
        [_sideJoinQBButton setTitle:@"你还没有名字哦" forState:UIControlStateNormal];
    }
}

#pragma mark - MineQBInfoViewControllerDelegate method

//退出登录后回调重置头像和名称
- (void)QBUserDidLogOutSuccess
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:nil forKey:@"QBToken"];
    [defaults setObject:nil forKey:@"QBUser"];
    
    [_sideJoinQBButton setTitle:@"加入糗百" forState:UIControlStateNormal];
    [_sideFaceButton setImage:[UIImage imageNamed:@"side_user_avatar.png"] forState:UIControlStateNormal];
}

- (void)initViews
{
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"side_menu_textural.png"]]];
    //[_sideJoinQBButton setBackgroundImage:[self getButtonBackgroundImage] forState:UIControlStateNormal];
    [_sideSettingButton setBackgroundImage:[self getSideTitleBackgroundImage] forState:UIControlStateNormal];
    [_sideTitleButton setBackgroundImage:[self getSideTitleBackgroundImage] forState:UIControlStateNormal];
    if ([Toolkit getQBTokenLocal]) {
        QBUser *user = [Toolkit getQBUserLocal];
        [self QBUserDidLoginSuccessWithQBName:user.login andImage:user.icon];
    }
}

- (UIImage *)getButtonBackgroundImage
{
    UIImage *image = [UIImage imageNamed:@"side_button_background.png"];
    image = [image resizableImageWithCapInsets:UIEdgeInsetsMake(17, 17, 17, 16)];
    return image;
}

- (UIImage *)getSideTitleBackgroundImage
{
    UIImage *image = [UIImage imageNamed:@"side_title_background.png"];
    image = [image resizableImageWithCapInsets:UIEdgeInsetsMake(5, 4, 4, 4)];
    return image;
}

- (UINavigationController *)configNavigationController:(UINavigationController *)nav withRootVC:(UIViewController *)vc
{
    nav = [[UINavigationController alloc] initWithRootViewController:vc];
    [nav.navigationBar setBackgroundImage:[UIImage imageNamed:@"head_background.png"] forBarMetrics:UIBarMetricsDefault];
    return nav;
}

- (void)configCellAttribute:(UITableViewCell *)cell
{
    @autoreleasepool {
        cell.textLabel.textColor = [UIColor whiteColor];
        cell.textLabel.font = [UIFont systemFontOfSize:15];
        cell.backgroundView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"side_menu_background.png"]] autorelease];
        cell.selectedBackgroundView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"side_menu_background_active.png"]] autorelease];
        UIImageView *arrowImageView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"side_menu_arrow.png"]] autorelease];
        CGRect rect = arrowImageView.frame;
        rect.origin.x = 230;
        arrowImageView.frame = rect;
        [cell.contentView addSubview:arrowImageView];
    }
}

#pragma mark - UIAction methods

//头像按钮
- (IBAction)faceTitleView:(id)sender
{
    UIViewController *vc = nil;
    
    if (![Toolkit getQBTokenLocal]) {
        vc = [[AuthViewController alloc] initWithNibName:@"AuthViewController" bundle:nil];
        ((AuthViewController *)vc).delegate = self;
    }
    else {
        vc = [[MineQBInfoViewController alloc] initWithNibName:@"MineQBInfoViewController" bundle:nil];
        ((MineQBInfoViewController *)vc).delegate = self;
    }
    
    [self presentSemiViewController:vc];
    [vc release];
}

//设置按钮
- (IBAction)sideSettingButtonClicked:(id)sender
{
    SettingViewController *settingVC = [[SettingViewController alloc] initWithNibName:@"SettingViewController" bundle:nil];
    [self presentSemiViewController:settingVC];
    [settingVC release];
}

@end
