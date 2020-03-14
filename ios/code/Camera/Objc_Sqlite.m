//
//  Objc_Sqlite.m
//  monitor
//
//  Created by Han Sohn on 12-6-9.
//  Copyright (c) 2012年 Han.zhihong. All rights reserved.
//

#import "Objc_Sqlite.h"
#import "assist_function.h"

@implementation Objc_Sqlite

-(NSString*) documentPath:(NSString*)str
{
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	
	if (nil!=str) {
		return [NSString stringWithFormat:@"%@/%@",documentsDirectory,str];
	}
	return [NSString stringWithFormat:@"%@",documentsDirectory];
}

//【1】打开数据库，如果没有，那么创建一个
-(BOOL) open:(NSString*)filepath
{
    if(sqlite3_open([filepath UTF8String], &m_database) == SQLITE_OK) {
        return YES;
    } 
    sqlite3_close(m_database);
    NSLog(@"Error: open database file.");
    return NO;
}

- (void) close
{
    sqlite3_close(m_database);
}

//创建设备HOST记录表格
- (BOOL) createHostInfoTable
{
    char *sql = "CREATE TABLE [hostInfo] (autoID integer PRIMARY KEY,title varchar(256),host varchar(256),port integer,devID integer,username varchar(128),password varchar(128),parameter varchar[2048])";
    
    sqlite3_stmt *statement;
    if(sqlite3_prepare_v2(m_database, sql, -1, &statement, nil) != SQLITE_OK) {
        NSLog(@"Error: failed to prepare statement:create table");
        return NO;
    }
    int success = sqlite3_step(statement);
    sqlite3_finalize(statement);
    if ( success != SQLITE_DONE) {
        NSLog(@"Error: failed to dehydrate:CREATE TABLE hostInfo");
        return NO;
    }
    NSLog(@"Create table 'hostInfo' successed.");
    return YES;
}

//添加一条主机记录的内容。
- (BOOL) insertHostInfo:(char*)title :(char*)host :(int)port 
                       :(TDevceID)devID :(char*)username :(char*)password 
                       :(char*)parameter
                    
{
    sqlite3_stmt *statement;
    static char *sql = "INSERT INTO hostInfo (title,host,port,devID,username,password,parameter) VALUES(?,?,?,?,?,?,?)";

    int success = sqlite3_prepare_v2(m_database, sql, -1, &statement, NULL);
    if (success != SQLITE_OK) {
        NSLog(@"Error: failed to insert");
        return NO;
    }

    //这里的数字1，2，3，4代表第几个问号
    sqlite3_bind_text(statement, 1, title, -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(statement, 2, host, -1, SQLITE_TRANSIENT);
    sqlite3_bind_int(statement, 3, port);
    sqlite3_bind_int(statement, 4, devID);
    sqlite3_bind_text(statement, 5, username, -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(statement, 6, password, -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(statement, 7, parameter, -1, SQLITE_TRANSIENT);
    
    success = sqlite3_step(statement);
    sqlite3_finalize(statement);
    
    if (success == SQLITE_ERROR) {
        NSLog(@"Error: failed to insert hostInfo table");
        return NO;
    } 
    return YES;
}

//修改一条主机记录的内容。
- (BOOL) updateHostInfo:(int)autoID :(char*)title :(char*)host :(int)port 
                       :(TDevceID)devID :(char*)username :(char*)password 
                       :(char*)parameter
{
    sqlite3_stmt *statement;
    static char *sql = "update hostInfo set title=?,host=?,port=?,devID=?,username=?,password=?,parameter=? where autoID=?";

    int success = sqlite3_prepare_v2(m_database, sql, -1, &statement, NULL);
    if (success != SQLITE_OK) {
        NSLog(@"Error: failed to update");
        return NO;
    }
    
    //这里的数字1，2，3，4代表第几个问号
    sqlite3_bind_text(statement, 1, title, -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(statement, 2, host, -1, SQLITE_TRANSIENT);
    sqlite3_bind_int(statement, 3, port);
    sqlite3_bind_int(statement, 4, devID);
    sqlite3_bind_text(statement, 5, username, -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(statement, 6, password, -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(statement, 7, parameter, -1, SQLITE_TRANSIENT);
    sqlite3_bind_int(statement, 8, autoID);
    
    success = sqlite3_step(statement);
    sqlite3_finalize(statement);
    
    if (success == SQLITE_ERROR) {
        NSLog(@"Error: failed to update hostInfo table autoidID=%d",autoID);
        return NO;
    }
    
    return YES;
}

-(BOOL) deleteHostInfo:(int)autoID
{
    sqlite3_stmt *statement;
    static char *sql = "delete from hostInfo where autoID=?";
    
    int success = sqlite3_prepare_v2(m_database, sql, -1, &statement, NULL);
    if (success != SQLITE_OK) {
        NSLog(@"Error: failed to delete host");
        return NO;
    }
    
    sqlite3_bind_int(statement, 1, autoID);
    
    success = sqlite3_step(statement);
    sqlite3_finalize(statement);
    
    if (success == SQLITE_ERROR) {
        NSLog(@"Error: failed to delete hostInfo recordset autoID=%d",autoID);
        return NO;
    } 
    
    /////////////
    //删除流量记录
    static char *sql_flows = "delete from flow where hostAutoID=?";
    
    int success_flows = sqlite3_prepare_v2(m_database, sql_flows, -1, &statement, NULL);
    if (success_flows != SQLITE_OK) {
        NSLog(@"Error: failed to delete flows");
        return NO;
    }
    
    sqlite3_bind_int(statement, 1, autoID);
    
    success_flows = sqlite3_step(statement);
    sqlite3_finalize(statement);
    
    if (success_flows == SQLITE_ERROR) {
        NSLog(@"Error: failed to delete hostInfo recordset hostAutoID=%d",autoID);
        return NO;
    } 
    
    return YES;
}

//【4】数据库查询
-(BOOL) getHostInfo:(NSMutableArray*)dst_ary
{
    char *sql = "SELECT autoID,title,host,port,devID,username,password,parameter FROM hostInfo";

    sqlite3_stmt *statement = nil;
    if (sqlite3_prepare_v2(m_database, sql, -1, &statement, NULL) != SQLITE_OK) {
        NSLog(@"Error: failed to prepare statement with message:get hostInfo.");
        return false;
    }
    //查询结果集中一条一条的遍历所有的记录，这里的数字对应的是列值。
    while (sqlite3_step(statement) == SQLITE_ROW) {
        TagHostInfo info={0};

        info.autoID=sqlite3_column_int(statement, 0);
        strcpy(info.title,(char*)sqlite3_column_text(statement, 1));
        strcpy(info.host,(char*)sqlite3_column_text(statement, 2));
        info.port=sqlite3_column_int(statement, 3);
        info.devID=sqlite3_column_int(statement, 4);
        strcpy(info.username,(char*)sqlite3_column_text(statement, 5));
        strcpy(info.password,(char*)sqlite3_column_text(statement, 6));
        strcpy(info.parameter,(char*)sqlite3_column_text(statement, 7));
        
        //////添加到链表
        NSData *nsData=[NSData dataWithBytes:&info length:sizeof(TagHostInfo)];
        [dst_ary addObject:nsData];
    }
    sqlite3_finalize(statement);
    
    return true;
}

//获取最后插入的ID值
-(int) getHostInfoLastInsertID
{
    int rowID;
    char *sql = "select last_insert_rowid() from hostInfo";
    
    rowID=0;
    sqlite3_stmt *statement = nil;
    if (sqlite3_prepare_v2(m_database, sql, -1, &statement, NULL) != SQLITE_OK) {
        NSLog(@"Error: failed to prepare statement with message:get hostInfo last insert ID.");
    }
    
    if (sqlite3_step(statement) == SQLITE_ROW) {
         rowID = sqlite3_column_int(statement, 0);      
    }
    sqlite3_finalize(statement);
    return rowID;
}

@end
