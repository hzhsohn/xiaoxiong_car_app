//
//  Objc_Sqlite.h
//  monitor
//
//  Created by Han Sohn on 12-6-9.
//  Copyright (c) 2012年 Han.zhihong. All rights reserved.
//

/*//////////////////////////
 
 例子:
 
 Objc_Sqlite *m_sqlMage=[[Objc_Sqlite alloc] init];
 Objc_Sqlite *sqlMage=[[Objc_Sqlite alloc] init];
 if ([sqlMage open:[sqlMage documentPath:@"db.sqlite"]]) {
 [sqlMage createTable];
 [sqlMage insertData:"a" :"b" :"cde" :4];
 int i=[sqlMage getLastInsertID:"channels"];
 NSLog(@"i=%d",i);
 }
 
 //////////////////////////*/
#import <Foundation/Foundation.h>
#import <sqlite3.h>
#include "info_structs_define.h"

//首先要引入 libsqlite3.0.dylib 的lib库
@interface Objc_Sqlite : NSObject
{
    sqlite3* m_database;
}

//获取文档路径
-(NSString*) documentPath:(NSString*)str;
//【1】打开和关闭数据库，如果没有，那么创建一个
-(BOOL) open:(NSString*)filepath;
-(void) close;
//【2】创建表格
-(BOOL) createHostInfoTable;
//【3】向表格中插入一条记录
-(BOOL) insertHostInfo:(char*)title 
                      :(char*)host 
                      :(int)port 
                      :(TDevceID)devID 
                      :(char*)username 
                      :(char*)password
                      :(char*)parameter;
//更新记录
- (BOOL) updateHostInfo:(int)autoID :(char*)title :(char*)host :(int)port 
                       :(TDevceID)devID :(char*)username :(char*)password
                       :(char*)parameter;
//删除记录
-(BOOL) deleteHostInfo:(int)autoID;

//数据库查询
-(BOOL) getHostInfo:(NSMutableArray*)dst_ary;

//获取最后插入的ID值
-(int) getHostInfoLastInsertID;
@end
