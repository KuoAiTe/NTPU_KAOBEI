//
//  SettingCtrl.m
//  NTPU_KAT
//
//  Created by KuoAiTe on 2014/11/16.
//  Copyright (c) 2014年 KuoAiTe. All rights reserved.
//

#import "SettingCtrl.h"
#import "SettingCell.h"
#import "KaoBeiSettings.h"
#import <FacebookSDK/FacebookSDK.h>
#import "AboutAiTe.h"

@implementation SettingCtrl{
    bool connectFacebook;
    FBProfilePictureView *avatar;

}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    //avatar
    avatar = [[FBProfilePictureView alloc]initWithFrame:CGRectMake(DeviceWidth/2 - 100, DeviceHeight /2 - 200,200, 200)];
    [self.view addSubview:avatar];
    
    _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0 , CGRectGetMaxY(avatar.frame) + 20, DeviceWidth , DeviceHeight - CGRectGetMaxY(avatar.frame) )];
    _tableView.backgroundColor=[UIColor clearColor];
    _tableView.delegate=self;
    _tableView.dataSource=self;
    _tableView.scrollEnabled=FALSE;
    _tableView.separatorStyle=UITableViewCellSeparatorStyleNone;
    
    [_tableView registerNib:[UINib nibWithNibName:@"SettingCell" bundle:nil] forCellReuseIdentifier:@"SettingCellIdentefier"];
    [self.view addSubview:_tableView];

    connectFacebook=false;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger row = [indexPath row];
    SettingCell *cell = [_tableView dequeueReusableCellWithIdentifier:@"SettingCellIdentefier" forIndexPath:indexPath];
    switch (indexPath.row) {
        case 0:
            cell.image.image =[UIImage imageNamed:@"facebook.png"];
            if(connectFacebook)
                cell.text.text = @"登出 Facebook";
            else
                cell.text.text = @"登入 Facebook";
            break;
        case 1:
            cell.image.image =[UIImage imageNamed:@"menu-3.png"];
            cell.text.text = @"頁面設定";
            break;
        case 2:
            cell.image.image =[UIImage imageNamed:@"contact.png"];
            cell.text.text = @"關於作者";
            break;
        default:
            break;
    }
    return cell;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 3;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    if(indexPath.row == 0){
        if(connectFacebook){
            [FBSession.activeSession closeAndClearTokenInformation];
            connectFacebook=false;
            UIAlertView *message= [[UIAlertView alloc] initWithTitle:@"登出"
                                                             message:@"登出成功"
                                                            delegate:self
                                                   cancelButtonTitle:@"確定"
                                                   otherButtonTitles:nil, nil, nil];
            [message show];
            [_tableView reloadData];
        }else{
            NSArray *permissons = [[NSArray alloc] initWithObjects:@"publish_actions", nil];
            [FBSession openActiveSessionWithReadPermissions:permissons
                                               allowLoginUI:YES
                                          completionHandler:
             ^(FBSession *session,
               FBSessionState state, NSError *error) {
                 if(!error){
                     connectFacebook=true;
                     [_tableView reloadData];
                 }
             }];
        }
    }else if(indexPath.row == 1){
        KaoBeiSettings *ctl4 = [[KaoBeiSettings alloc] init];
        [self.navigationController pushViewController:ctl4 animated:YES];
    }else if(indexPath.row == 2){
        AboutAiTe *Aite = [[AboutAiTe alloc] init];
        [self.navigationController pushViewController:Aite animated:YES];
    }
    
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 44;
}

-(void)viewWillDisappear:(BOOL)animated{
    self.title =@"";
}
-(void)viewWillAppear:(BOOL)animated{
    self.title = @"設定";
    connectFacebook = FBSession.activeSession.isOpen;
    if (connectFacebook)
    {
        [[FBRequest requestForMe] startWithCompletionHandler:^(FBRequestConnection *connection, NSDictionary<FBGraphUser> *user, NSError *error) {
            if (!error){
                avatar.profileID = user.objectID;
                NSLog(@"%@",user);
            }
        }];
    }
    [_tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
