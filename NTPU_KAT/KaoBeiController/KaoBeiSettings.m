//
//  KaoBeiSettings.m
//  NTPU_KAT
//
//  Created by KuoAiTe on 2014/8/23.
//  Copyright (c) 2014年 KuoAiTe. All rights reserved.
//

#import "KaoBeiSettings.h"
#import "HistoryCell.h"
#import <FacebookSDK/FacebookSDK.h>

@interface KaoBeiSettings (){
    UITableView *tableview;
    NSMutableArray *SearchResult;
    UISearchBar *searchBar;
    NSMutableDictionary* params;
    UILabel *lblLoading;
    UIView *loadingView;
    NSInteger did_select_index;
}

@end

@implementation KaoBeiSettings

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self initViews];
    [self initData];

    
}

-(void) initData{
    //資料庫讀取
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documents = [paths objectAtIndex:0];
    NSString *database_path = [documents stringByAppendingPathComponent:DBNAME];
    if (sqlite3_open([database_path UTF8String], &db) != SQLITE_OK) {
        sqlite3_close(db);
        NSLog(@"數據打開失敗");
    }else{
        NSLog(@"OPEN Database Succeed!");
        [self execSql:@"CREATE TABLE IF NOT EXISTS FavPage (ID INTEGER PRIMARY KEY AUTOINCREMENT ,page_id TEXT ,page_name TEXT)"];
    }
    
    SearchResult = [[NSMutableArray alloc]init];
    NSDictionary *ntpu_1 = @{ @"id" : @"201584686528903", @"name" : @"國立臺北大學學生會 NTPU Student Union", @"likes" : @"-1"};
    //NSDictionary *ntpu_2 = @{ @"id" : @"300246033476997", @"name" : @"靠北北大", @"likes" : @"-1"};
    NSDictionary *ntpu_3 = @{ @"id" : @"887656441259960", @"name" : @"告白北大 NTPU Crushes", @"likes" : @"-1"};
    NSDictionary *ntpu_4= @{ @"id" : @"1537695379797386", @"name" : @"失戀北大 NTPU Lovelorn", @"likes" : @"-1"};
    [SearchResult addObject:ntpu_1];
    //[SearchResult addObject:ntpu_2];
    [SearchResult addObject:ntpu_3];
    [SearchResult addObject:ntpu_4];
    sqlite3_stmt *statement =nil;
    NSString *querySQL = @"SELECT page_id,page_name FROM FavPage; ";
    if (sqlite3_prepare_v2(db, [querySQL UTF8String], -1, &statement, NULL) == SQLITE_OK) {
        while (sqlite3_step(statement) == SQLITE_ROW) {
            NSDictionary *temp= @{ @"id" : [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 0)], @"name" : [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 1)], @"likes" : @"-2"};
            [SearchResult addObject:temp];
        }
        sqlite3_finalize(statement);
    }

    [self setTitle:@"我的最愛"];
    self.title = @"頁面設定";
    
    
    params= [[NSMutableDictionary alloc] init];
    [params setObject:Access_Token forKey:@"access_token"];
    
    
}
-(void)initViews{
    // table
    tableview = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, DeviceWidth, DeviceHeight - TabBarHeight)];
    [self.view addSubview:tableview];
    tableview.delegate=self;
    tableview.dataSource=self;
    if ([tableview respondsToSelector:@selector(setSeparatorInset:)]) {
        [tableview setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([tableview respondsToSelector:@selector(setLayoutMargins:)]) {
        [tableview setLayoutMargins:UIEdgeInsetsZero];
    }
    
    [tableview setTableFooterView:[[UIView alloc] initWithFrame:CGRectZero]];
    [tableview registerNib:[UINib nibWithNibName:@"HistoryCell" bundle:nil] forCellReuseIdentifier:@"HSCell"];
    // SearchBar
    searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, DeviceWidth, 44)];
    searchBar.delegate = self;
    tableview.tableHeaderView=searchBar;
    // loadingView
    loadingView = [[UIView alloc]initWithFrame:CGRectMake(85, (DeviceHeight-NavHeight-StatusBarHeight)/2 +NavHeight+StatusBarHeight- 67.5, 150, 125)];
    loadingView.backgroundColor = [UIColor colorWithWhite:0. alpha:0.6];
    loadingView.layer.cornerRadius = 5;
    
    UIActivityIndicatorView *activityView=[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    activityView.center = CGPointMake(loadingView.frame.size.width / 2.0, 35);
    [activityView startAnimating];
    activityView.tag = 100;
    [loadingView addSubview:activityView];
    
    lblLoading = [[UILabel alloc]initWithFrame:CGRectMake(0, 52, 150, 60)];
    lblLoading.text = @"讀取中" ;
    lblLoading.backgroundColor = [UIColor clearColor];
    lblLoading.textColor = [UIColor whiteColor];
    lblLoading.font = [UIFont fontWithName:lblLoading.font.fontName size:15];
    lblLoading.textAlignment = NSTextAlignmentCenter;
    lblLoading.numberOfLines = 0;
    [loadingView addSubview:lblLoading];
    
    // edit
    UIButton *btnToggle = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnToggle setImage:[UIImage imageNamed:@"delete.png"] forState:UIControlStateNormal];
    btnToggle.frame = CGRectMake(0, 0, 30,30);
    UIBarButtonItem *menuBarButton = [[UIBarButtonItem alloc] initWithCustomView:btnToggle];
    [btnToggle addTarget:self action:@selector(editClick:) forControlEvents:UIControlEventTouchUpInside];
    
    self.navigationItem.rightBarButtonItem = menuBarButton;
}
-(void)editClick:(id)sender{
    UIButton *btn = (UIButton *)sender;
    [btn setSelected:!btn.selected];
    [tableview setEditing:btn.selected animated:YES];
    
}
-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if([[[SearchResult objectAtIndex:indexPath.row] objectForKey:@"likes"] integerValue] == -1)
        return UITableViewCellEditingStyleNone;
    return UITableViewCellEditingStyleDelete;
    
}



- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    //判斷編輯表格的類型為「刪除」
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        //刪除對應的陣列元素
        NSString *obj_id = [[SearchResult objectAtIndex:indexPath.row] objectForKey:@"id"];
        NSString *sql=[NSString stringWithFormat:@"DELETE FROM Favorite WHERE POST_ID='%@'",obj_id];
        [self execSql:sql];
        [SearchResult removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                         withRowAnimation:UITableViewRowAnimationFade];
    }
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [SearchResult count];
}
-(void)searchBarSearchButtonClicked:(UISearchBar *)_searchBar
{
    [self.view addSubview:loadingView];
    loadingView.alpha=1.0;
    NSLog(@"%@",[NSString stringWithFormat:@"/search?q=%@&type=page&fields=name,likes&limit=100",searchBar.text]);
    [FBRequestConnection startWithGraphPath:[NSString stringWithFormat:@"/search?q=%@&type=page&fields=name,likes&limit=100",[searchBar.text stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding ]]
                                 parameters:params
                                 HTTPMethod:@"GET"
                          completionHandler:^(
                                              FBRequestConnection *connection,
                                              id result,
                                              NSError *error){
                              [UIView animateWithDuration:0.5f
                                               animations:^{loadingView.alpha = 0.0;}
                                               completion:^(BOOL finished){ [loadingView removeFromSuperview]; }];
                              NSLog(@"%@ %@",error,result);
                              if(error==nil){
                                  SearchResult=[result objectForKey:@"data"];
                                  [tableview reloadData];
                              }else{
                                  
                                  // message
                                  UIAlertView* message= [[UIAlertView alloc] initWithTitle:@"網路連接錯誤"
                                                                                   message:@"請檢查網路連線設定\r\n ErrCode: -6"
                                                                                  delegate:nil
                                                                         cancelButtonTitle:@"確定"
                                                                         otherButtonTitles:nil];
                                  [message show];
                              }
                          }];

    [_searchBar resignFirstResponder];
    
    [tableview setEditing:NO animated:YES];
}
- (UITableViewCell *)tableView:(HistoryCell *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = [indexPath row];
    HistoryCell *cell = [tableview dequeueReusableCellWithIdentifier:@"HSCell" forIndexPath:indexPath];
    cell.tag=row;
    //NSLog(@"%d %@",indexPath.row,[[SearchResult objectAtIndex:indexPath.row] objectForKey:@"likes"]);
    NSNumberFormatter* numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setFormatterBehavior: NSNumberFormatterBehavior10_4];
    [numberFormatter setNumberStyle: NSNumberFormatterDecimalStyle];
    NSString *numberString = [numberFormatter stringFromNumber: [NSNumber numberWithInteger: [[[SearchResult objectAtIndex:indexPath.row] objectForKey:@"likes"] intValue]]];
    if( [[[SearchResult objectAtIndex:indexPath.row] objectForKey:@"likes"] integerValue ] == -1)
        cell.page_name.text = @"臺北大學";
    else if( [[[SearchResult objectAtIndex:indexPath.row] objectForKey:@"likes"] integerValue ] == -2)
        cell.page_name.text = @"我的最愛";
    else
        cell.page_name.text = [NSString stringWithFormat:@"%@ likes", numberString];
    cell.title.text = [[SearchResult objectAtIndex:indexPath.row] objectForKey:@"name"];
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [searchBar resignFirstResponder];
    [tableview setEditing:NO animated:YES];
    NSLog(@"hey");
    [Settings setValue:[[SearchResult objectAtIndex:indexPath.row] objectForKey:@"name"] forKey:@"page_name"];
    [Settings setValue:[[SearchResult objectAtIndex:indexPath.row] objectForKey:@"id"] forKey:@"page_id"];
    [Settings setValue:@"YES" forKey:@"clear"];
    [Settings synchronize];
    did_select_index = indexPath.row;
    if([[[SearchResult objectAtIndex:indexPath.row] objectForKey:@"likes"] integerValue] == -1){
        UIAlertView *success_message= [[UIAlertView alloc] initWithTitle:@"成功設定頁面"
                                                                 message:[NSString stringWithFormat:@"將頁面設「%@」",[[SearchResult objectAtIndex:indexPath.row] objectForKey:@"name"]]
                                                                delegate:nil
                                                       cancelButtonTitle:@"確定"
                                                       otherButtonTitles:nil];
        [success_message show];
    }else if([[[SearchResult objectAtIndex:indexPath.row] objectForKey:@"likes"] integerValue] == -2){
        UIAlertView *success_message= [[UIAlertView alloc] initWithTitle:@"成功設定頁面"
                                            message:[NSString stringWithFormat:@"將頁面設「%@」",[[SearchResult objectAtIndex:indexPath.row] objectForKey:@"name"]]
                                           delegate:nil
                                  cancelButtonTitle:@"確定"
                                  otherButtonTitles:nil];
        [success_message show];

    }else{
        
        // message
        UIAlertView* message= [[UIAlertView alloc] initWithTitle:@"成功設定頁面"
                                            message:[NSString stringWithFormat:@"是否將「%@」設為我的最愛",[[SearchResult objectAtIndex:indexPath.row] objectForKey:@"name"]]
                                           delegate:nil
                                  cancelButtonTitle:@"取消"
                                  otherButtonTitles:@"確定",nil];
        message.delegate=self;
        [message show];
    }
    
    
    
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 1){
        sqlite3_stmt *statement =nil;
        const char *nsql = "INSERT INTO FavPage (page_id,page_name) SELECT ?,? WHERE NOT EXISTS ( SELECT 1 FROM FavPage WHERE page_id = ?);";
        if (sqlite3_prepare_v2(db, nsql, -1, &statement, NULL) == SQLITE_OK) {
            sqlite3_bind_text(statement, 1, [[[SearchResult objectAtIndex:did_select_index] objectForKey:@"id"] UTF8String], -1, SQLITE_TRANSIENT);
            sqlite3_bind_text(statement, 2, [[[SearchResult objectAtIndex:did_select_index] objectForKey:@"name"] UTF8String], -1, SQLITE_TRANSIENT);
            sqlite3_bind_text(statement, 3, [[[SearchResult objectAtIndex:did_select_index] objectForKey:@"id"] UTF8String], -1, SQLITE_TRANSIENT);
            if (sqlite3_step(statement) != SQLITE_DONE) {
                NSLog(@"SQL execution failed: %s", sqlite3_errmsg(db));
            }else{
                NSLog(@"有成功嗎");
            }
            
        }
        sqlite3_finalize(statement);
        }
}
-(void)execSql:(NSString *)sql
{
    char *err;
    if (sqlite3_exec(db, [sql UTF8String], NULL, NULL, &err) != SQLITE_OK) {
        sqlite3_close(db);
        NSLog(@"失敗操作數據:%@",sql);
        NSLog(@"錯誤:%s",err);
    }else{
        NSLog(@"成功操作數據:%@",sql);
    }
}
@end
