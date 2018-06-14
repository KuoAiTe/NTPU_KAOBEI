//
//  KaoBeiFavorite.m
//  NTPU_KAT
//
//  Created by KuoAiTe on 2014/6/2.
//  Copyright (c) 2014年 KuoAiTe. All rights reserved.
//

#import "KaoBeiFavorite.h"
#import "KaoBeiDetailController.h"
#import "HistoryCell.h"
#import "ArticleObject.h"
@interface KaoBeiFavorite ()

@end

@implementation KaoBeiFavorite

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initData];
    [self initViews];
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
    [self setTitle:@"我的最愛"];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    [_tableView setTableFooterView:[[UIView alloc
                                     ] initWithFrame:CGRectZero]];
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
#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [FavoriteResult count];
}

-(void)refreshFavorite{
    FavoriteResult = [[NSMutableArray alloc] init];
    //statement 將存放查詢結果
    sqlite3_stmt *statement =nil;
    NSString *querySQL = @"SELECT title,POST_ID,body,page_name FROM Favorite order by date DESC; ";
    if (sqlite3_prepare_v2(db, [querySQL UTF8String], -1, &statement, NULL) == SQLITE_OK) {
        while (sqlite3_step(statement) == SQLITE_ROW) {
            ArticleObject * article = [[ArticleObject alloc] init];
            article.title = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 0)];
            article.object_ID = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 1)];
            article.POST_ID = [article.object_ID componentsSeparatedByString:@"_"][1];
            article.message = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 2)];
            article.page_name = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 3)];
            [FavoriteResult addObject:article];
        }
        [_tableView reloadData];
        //使用完畢後將statement清空
        sqlite3_finalize(statement);
    }
}

- (UITableViewCell *)tableView:(HistoryCell *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = [indexPath row];
    HistoryCell *cell = [_tableView dequeueReusableCellWithIdentifier:@"HSCell" forIndexPath:indexPath];
    cell.tag=row;
    cell.page_name.text = ((ArticleObject *)[FavoriteResult objectAtIndex:row]).page_name;
    cell.title.text = ((ArticleObject *)[FavoriteResult objectAtIndex:row]).title;
    return cell;
}

-(void)viewWillAppear:(BOOL)animated{
    [self refreshFavorite];
    self.title = @"我的最愛";
}
-(void)viewWillDisappear:(BOOL)animated{
    self.title = @"";
}

#pragma mark - Table view delegate

// In a xib-based application, navigation from a table can be handled in -tableView:didSelectRowAtIndexPath:
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = [indexPath row];
    KaoBeiDetailController *detailView = [[KaoBeiDetailController alloc] init];
    detailView.data = [FavoriteResult objectAtIndex:row];
    [self.navigationController pushViewController:detailView animated:YES];
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    //判斷編輯表格的類型為「刪除」
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        //刪除對應的陣列元素
        ArticleObject *row = [FavoriteResult objectAtIndex:indexPath.row];
        NSString *sql=[NSString stringWithFormat:@"DELETE FROM Favorite WHERE POST_ID='%@'",row.object_ID];
        [self execSql:sql];
        [FavoriteResult removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                         withRowAnimation:UITableViewRowAnimationFade];
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
