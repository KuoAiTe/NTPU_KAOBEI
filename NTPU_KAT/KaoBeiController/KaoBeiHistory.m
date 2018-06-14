//
//  KaoBeiHistory.m
//  NTPU_KAT
//
//  Created by KuoAiTe on 2014/6/2.
//  Copyright (c) 2014年 KuoAiTe. All rights reserved.
//

#import "KaoBeiHistory.h"
#import "KaoBeiDetailController.h"
#import "HistoryCell.h"

@interface KaoBeiHistory ()

@end

@implementation KaoBeiHistory
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initData];
    [self initViews];
    [self refreshHistory];
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
        [self execSql:@"CREATE TABLE IF NOT EXISTS Favorite (ID INTEGER PRIMARY KEY AUTOINCREMENT ,page_name TEXT,title TEXT,body TEXT, POST_ID TEXT ,date DATETIME)"];
    }
    [self setTitle:@"瀏覽紀錄"];
}
-(void) initViews{
    //靠北北大
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, DeviceWidth,  DeviceHeight - TabBarHeight)];
    [_tableView registerNib:[UINib nibWithNibName:@"HistoryCell" bundle:nil] forCellReuseIdentifier:@"HSCell"];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableView.backgroundColor=[UIColor whiteColor];
    if ([_tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [_tableView setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([_tableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [_tableView setLayoutMargins:UIEdgeInsetsZero];
    }
    [_tableView setTableFooterView:[[UIView alloc] initWithFrame:CGRectZero]];
    [self.view addSubview:_tableView];
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
    [_tableView setEditing:btn.selected animated:YES];
    
}
-(void)refreshHistory{
    HistoryData = [[NSMutableArray alloc] init];
    //statement 將存放查詢結果
    sqlite3_stmt *statement =nil;
    NSString *querySQL = @"SELECT title,POST_ID,body,page_name FROM KaoBeiHistory order by date DESC; ";
    if (sqlite3_prepare_v2(db, [querySQL UTF8String], -1, &statement, NULL) == SQLITE_OK) {
        while (sqlite3_step(statement) == SQLITE_ROW) {
            ArticleObject * article = [[ArticleObject alloc] init];
            char *title = (char *)sqlite3_column_text(statement, 0);
            char *object_ID = (char *)sqlite3_column_text(statement, 1);
            char *message = (char *)sqlite3_column_text(statement, 2);
            
            char *page_name = (char *)sqlite3_column_text(statement, 3);
            article.title = [NSString stringWithUTF8String:title?title:nil];
            article.object_ID = [NSString stringWithUTF8String:object_ID?object_ID:nil];
            article.POST_ID = [article.object_ID componentsSeparatedByString:@"_"][1];
            article.message = [NSString stringWithUTF8String:message?message:nil];
            article.page_name = [NSString stringWithUTF8String:page_name?page_name:nil];
            [HistoryData addObject:article];
        }
        [_tableView reloadData];
        //使用完畢後將statement清空
        sqlite3_finalize(statement);
    }
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [HistoryData count];
}

- (UITableViewCell *)tableView:(HistoryCell *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = [indexPath row];
    HistoryCell *cell = [_tableView dequeueReusableCellWithIdentifier:@"HSCell" forIndexPath:indexPath];
    cell.tag=row;
    cell.page_name.text = ((ArticleObject *)[HistoryData objectAtIndex:row]).page_name;
    cell.title.text = ((ArticleObject *)[HistoryData objectAtIndex:row]).title;
    return cell;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = [indexPath row];
    KaoBeiDetailController *detailView = [[KaoBeiDetailController alloc] init];
    detailView.data = [HistoryData objectAtIndex:row ];
    [self.navigationController pushViewController:detailView animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
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

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    //判斷編輯表格的類型為「刪除」
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        //刪除對應的陣列元素
        ArticleObject *row = [HistoryData objectAtIndex:indexPath.row];
        NSString *sql=[NSString stringWithFormat:@"DELETE FROM KaoBeiHistory WHERE POST_ID='%@'",row.object_ID];
        [self execSql:sql];
        [HistoryData removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                         withRowAnimation:UITableViewRowAnimationFade];
    }
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    [self refreshHistory];
    self.title = @"瀏覽紀錄";
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:YES];
    self.title = @"";
}

@end
