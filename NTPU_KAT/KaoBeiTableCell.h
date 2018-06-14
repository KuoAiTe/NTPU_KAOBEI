//
//  UMTableViewCell.h
//  SWTableViewCell
//
//  Created by Matt Bowman on 12/2/13.
//  Copyright (c) 2013 Chris Wendel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <sqlite3.h>
#import "ArticleObject.h"
/*
 *  Example of a custom cell built in Storyboard
 */
@interface KaoBeiTableCell : UITableViewCell{
    sqlite3 *db;
}

@property (strong, nonatomic) UILabel *Title;
@property (strong, nonatomic) UILabel *Like;
@property (strong, nonatomic) UILabel *created_time;
@property (retain, nonatomic) UIImageView *Favorite;
-(void)setStatus:(ArticleObject*)Article;
@end
