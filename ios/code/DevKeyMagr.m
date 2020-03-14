//
//  Objc_Sqlite.m
//  monitor
//
//  Created by Han Sohn on 12-6-9.
//  Copyright (c) 2012年 Han.zhihong. All rights reserved.
//

#import "DevKeyMagr.h"
#import <sqlite3.h>

@interface DevKeyMagr()
{
    sqlite3* m_database;
}

//【1】打开和关闭数据库，如果没有，那么创建一个
-(BOOL) open:(NSString*)filepath;
-(void) close;
//【2】创建表格
-(BOOL) createDevInfoTable;

@end

@implementation DevKeyMagr


-(id)init
{
    if ((self=[super init])) {
        NSString*str=[self documentPath:@"devdb_4"];
        NSLog(@"db_path=%@",str);
        [self open:str];
        [self createDevInfoTable];
    }
    return self;
}

-(void)dealloc
{
    
}

-(NSString*) documentPath:(NSString*)dbname
{
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	
	if (nil!=dbname) {
		return [NSString stringWithFormat:@"%@/%@",documentsDirectory,dbname];
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
- (BOOL) createDevInfoTable
{
    //devname设备名
    //password密码
    //devtype设备类型
    char *sql = "CREATE TABLE [DevInfo] (autoID integer PRIMARY KEY,devname varchar(256),devflag varchar(128),devUUID varchar(128))";
    
    sqlite3_stmt *statement;
    if(sqlite3_prepare_v2(m_database, sql, -1, &statement, nil) != SQLITE_OK) {
        NSLog(@"Error: failed to prepare statement:create table");
        return NO;
    }
    int success = sqlite3_step(statement);
    sqlite3_finalize(statement);
    if ( success != SQLITE_DONE) {
        NSLog(@"Error: failed to dehydrate:CREATE TABLE DevInfo");
        return NO;
    }
    NSLog(@"Create table 'DevInfo' successed.");
    return YES;
}

//添加一条主机记录的内容。
- (BOOL) insertDevInfo:(TzhKeyMgrSaveInfo*)info
                    
{
    sqlite3_stmt *statement;
    static char *sql = "INSERT INTO DevInfo(devname,devflag,devUUID) VALUES(?,?,?)";

    int success = sqlite3_prepare_v2(m_database, sql, -1, &statement, NULL);
    if (success != SQLITE_OK) {
        NSLog(@"Error: failed to insert");
        return NO;
    }

    //这里的数字1，2，3，4代表第几个问号
    sqlite3_bind_text(statement, 1, info->devname, -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(statement, 2, info->devflag, -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(statement, 3, info->devUUID, -1, SQLITE_TRANSIENT);
    
    success = sqlite3_step(statement);
    sqlite3_finalize(statement);
    
    if (success == SQLITE_ERROR) {
        NSLog(@"Error: failed to insert DevInfo table");
        return NO;
    } 
    return YES;
}

//修改一条主机记录的内容。
- (BOOL) updateDevInfo:(TzhKeyMgrSaveInfo*)info :(int)autoID
{
    sqlite3_stmt *statement;
    static char *sql = "update DevInfo set devname=?,devflag=?,devUUID=? where autoID=?";

    int success = sqlite3_prepare_v2(m_database, sql, -1, &statement, NULL);
    if (success != SQLITE_OK) {
        NSLog(@"Error: failed to update");
        return NO;
    }
    
    //这里的数字1，2，3，4代表第几个问号
    sqlite3_bind_text(statement, 1, info->devname, -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(statement, 2, info->devflag, -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(statement, 3, info->devUUID, -1, SQLITE_TRANSIENT);
    sqlite3_bind_int(statement, 4, autoID);
    
    success = sqlite3_step(statement);
    sqlite3_finalize(statement);
    
    if (success == SQLITE_ERROR) {
        NSLog(@"Error: failed to update DevInfo table autoidID=%d",autoID);
        return NO;
    }
    
    return YES;
}

- (BOOL) updateDevname:(NSString*)devname :(int)autoID
{
    sqlite3_stmt *statement;
    static char *sql = "update DevInfo set devname=? where autoID=?";
    
    int success = sqlite3_prepare_v2(m_database, sql, -1, &statement, NULL);
    if (success != SQLITE_OK) {
        NSLog(@"Error: failed to update");
        return NO;
    }
    
    //这里的数字1，2，3，4代表第几个问号
    sqlite3_bind_text(statement, 1, [devname UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_int(statement, 2, autoID);
    
    success = sqlite3_step(statement);
    sqlite3_finalize(statement);
    
    if (success == SQLITE_ERROR) {
        NSLog(@"Error: failed to update DevInfo table autoidID=%d",autoID);
        return NO;
    }
    
    return YES;
}

- (BOOL) updateDevname:(NSString*)devname devUUID:(NSString*)devUUID
{
    sqlite3_stmt *statement;
    static char *sql = "update DevInfo set devname=? where devUUID=?";
    
    int success = sqlite3_prepare_v2(m_database, sql, -1, &statement, NULL);
    if (success != SQLITE_OK) {
        NSLog(@"Error: failed to update");
        return NO;
    }
    
    //这里的数字1，2，3，4代表第几个问号
    sqlite3_bind_text(statement, 1, [devname UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(statement, 2, [devUUID UTF8String], -1, SQLITE_TRANSIENT);
    
    success = sqlite3_step(statement);
    sqlite3_finalize(statement);
    
    if (success == SQLITE_ERROR) {
        NSLog(@"Error: failed to update DevInfo table devUUID=%@",devUUID);
        return NO;
    }
    
    return YES;
}

-(BOOL) deleteDevInfo:(int)autoID
{
    sqlite3_stmt *statement;
    static char *sql = "delete from DevInfo where autoID=?";
    
    int success = sqlite3_prepare_v2(m_database, sql, -1, &statement, NULL);
    if (success != SQLITE_OK) {
        NSLog(@"Error: failed to delete host");
        return NO;
    }
    
    sqlite3_bind_int(statement, 1, autoID);
    
    success = sqlite3_step(statement);
    sqlite3_finalize(statement);
    
    if (success == SQLITE_ERROR) {
        NSLog(@"Error: failed to delete DevInfo recordset autoID=%d",autoID);
        return NO;
    } 
    
    return YES;
}

//【4】数据库查询
-(BOOL) getDevInfoAllKeyMgr:(NSMutableArray*)dst_ary
{
    char *sql = "SELECT autoID,devname,devflag,devUUID FROM DevInfo";
    
    [dst_ary removeAllObjects];

    sqlite3_stmt *statement = nil;
    if (sqlite3_prepare_v2(m_database, sql, -1, &statement, NULL) != SQLITE_OK) {
        NSLog(@"Error: failed to prepare statement with message:getDevInfoAllKeyMgr");
        return NO;
    }
    //查询结果集中一条一条的遍历所有的记录，这里的数字对应的是列值。
    while (sqlite3_step(statement) == SQLITE_ROW) {
        TzhKeyMgr info={0};

        info.autoID=sqlite3_column_int(statement, 0);
        strcpy(info.devname,(char*)sqlite3_column_text(statement, 1));
        strcpy(info.devflag,(char*)sqlite3_column_text(statement, 2));
        strcpy(info.devUUID,(char*)sqlite3_column_text(statement, 3));
        
        //////添加到链表
        NSData *nsData=[NSData dataWithBytes:&info length:sizeof(TzhKeyMgr)];
        [dst_ary addObject:nsData];
    }
    sqlite3_finalize(statement);
    
    return YES;
}

-(BOOL) getDevInfoByAutoID:(int)autoID :(TzhKeyMgr*)info
{
    BOOL bRet=false;
    char *sql = "SELECT autoID,devname,devflag FROM DevInfo where autoID=?";
    
    if (info) {
        memset(info, 0, sizeof(TzhKeyMgr));
    }
    
    sqlite3_stmt *statement = nil;
    if (sqlite3_prepare_v2(m_database, sql, -1, &statement, NULL) != SQLITE_OK) {
        NSLog(@"Error: failed to prepare statement with message:getDevInfoByAutoID");
        return bRet;
    }
    
    sqlite3_bind_int(statement, 1, autoID);
    
    //查询结果集中一条一条的遍历所有的记录，这里的数字对应的是列值。
    if (sqlite3_step(statement) == SQLITE_ROW)
    {
        bRet=YES;
        if (info) {
            info->autoID=sqlite3_column_int(statement, 0);
            strcpy(info->devname,(char*)sqlite3_column_text(statement, 1));
            strcpy(info->devflag,(char*)sqlite3_column_text(statement, 2));
            strcpy(info->devUUID,(char*)sqlite3_column_text(statement, 3));
        }
    }
    sqlite3_finalize(statement);
    return bRet;
}

-(BOOL) getDevCheckDevname:(NSString*)devflag :(NSString*)devname
{
    BOOL bRet=false;
    char *sql = "SELECT * FROM DevInfo where devname=? and devflag=?";
    
    sqlite3_stmt *statement = nil;
    if (sqlite3_prepare_v2(m_database, sql, -1, &statement, NULL) != SQLITE_OK) {
        NSLog(@"Error: failed to prepare statement with message:getDevCheckDevname");
        return bRet;
    }
    
    sqlite3_bind_text(statement, 1, [devname UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(statement, 2, [devflag UTF8String], -1, SQLITE_TRANSIENT);
    
    //查询结果集中一条一条的遍历所有的记录，这里的数字对应的是列值。
    if (sqlite3_step(statement) == SQLITE_ROW)
    {
        bRet=YES;
    }
    sqlite3_finalize(statement);
    return bRet;
}

-(BOOL) getDevCheckDevUUID:(NSString*)devUUID
{
    BOOL bRet=false;
    char *sql = "SELECT * FROM DevInfo where devUUID=?";
    
    sqlite3_stmt *statement = nil;
    if (sqlite3_prepare_v2(m_database, sql, -1, &statement, NULL) != SQLITE_OK) {
        NSLog(@"Error: failed to prepare statement with message:getDevCheckDevUUID");
        return bRet;
    }
    
    sqlite3_bind_text(statement, 1, [devUUID UTF8String], -1, SQLITE_TRANSIENT);
    
    //查询结果集中一条一条的遍历所有的记录，这里的数字对应的是列值。
    if (sqlite3_step(statement) == SQLITE_ROW)
    {
        bRet=YES;
    }
    sqlite3_finalize(statement);
    return bRet;
}

//获取最后插入的ID值
-(int) getDevLastInsertID
{
    int rowID;
    char *sql = "select last_insert_rowid() from DevInfo";
    
    rowID=0;
    sqlite3_stmt *statement = nil;
    if (sqlite3_prepare_v2(m_database, sql, -1, &statement, NULL) != SQLITE_OK) {
        NSLog(@"Error: failed to prepare statement with message:getDevLastInsertID");
    }
    
    if (sqlite3_step(statement) == SQLITE_ROW) {
         rowID = sqlite3_column_int(statement, 0);      
    }
    sqlite3_finalize(statement);
    return rowID;
}

@end
