//
//  Objc_Sqlite.m
//  monitor
//
//  Created by Han Sohn on 12-6-9.
//  Copyright (c) 2012年 Han.zhihong. All rights reserved.
//

#import "DevPasswdMagr.h"
#import <sqlite3.h>

@interface DevPasswdMagr()
{
    sqlite3* m_database;
}

//【1】打开和关闭数据库，如果没有，那么创建一个
-(BOOL) open:(NSString*)filepath;
-(void) close;
//【2】创建表格
-(BOOL) createDevInfoTable;

@end

@implementation DevPasswdMagr


-(id)init
{
    if ((self=[super init])) {
        NSString*str=[self documentPath:@"devpwd_1"];
        NSLog(@"db_path=%@",str);
        [self open:str];
        [self createDevInfoTable];
    }
    return self;
}

-(void)dealloc
{
    
}

+(void)newPasswdByDevUUID:(NSString*)username :(NSString*)pwd :(NSString*)devUUID
{
    //先删除后添加
    [self deletePasswdByDevUUID:devUUID];
    //
    TzhPasswdMgr info={0};
    DevPasswdMagr* d=[[DevPasswdMagr alloc] init];
    strcpy(info.devUUID, [devUUID UTF8String]);
    strcpy(info.username, [username UTF8String]);
    strcpy(info.passwd, [pwd UTF8String]);
    [d insertDevInfo:&info];
    d=nil;
}

+(void)deletePasswdByDevUUID:(NSString*)devUUID
{
    DevPasswdMagr* d=[[DevPasswdMagr alloc] init];
    [d deletePasswd:devUUID];
    d=nil;
}

+(TzhPasswdMgr)infoByDevUUID:(NSString*)devUUID
{
    TzhPasswdMgr mgr;
    DevPasswdMagr* d=[[DevPasswdMagr alloc] init];
    mgr=[d getInfoByUUID:devUUID];
    d=nil;
    return mgr;
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
    char *sql = "CREATE TABLE [DevPwd] (autoID integer PRIMARY KEY,devUUID varchar(128),username varchar(256),passwd varchar(128))";
    
    sqlite3_stmt *statement;
    if(sqlite3_prepare_v2(m_database, sql, -1, &statement, nil) != SQLITE_OK) {
        NSLog(@"Error: failed to prepare statement:create table");
        return NO;
    }
    int success = sqlite3_step(statement);
    sqlite3_finalize(statement);
    if ( success != SQLITE_DONE) {
        NSLog(@"Error: failed to dehydrate:CREATE TABLE DevPwd");
        return NO;
    }
    NSLog(@"Create table 'DevPwd' successed.");
    return YES;
}

//添加一条主机记录的内容。
- (BOOL) insertDevInfo:(TzhPasswdMgr*)info
                    
{
    sqlite3_stmt *statement;
    static char *sql = "INSERT INTO DevPwd(devUUID,username,passwd) VALUES(?,?,?)";

    int success = sqlite3_prepare_v2(m_database, sql, -1, &statement, NULL);
    if (success != SQLITE_OK) {
        NSLog(@"Error: failed to insert");
        return NO;
    }

    //这里的数字1，2，3代表第几个问号
    sqlite3_bind_text(statement, 1, info->devUUID, -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(statement, 2, info->username, -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(statement, 3, info->passwd, -1, SQLITE_TRANSIENT);
    
    success = sqlite3_step(statement);
    sqlite3_finalize(statement);
    
    if (success == SQLITE_ERROR) {
        NSLog(@"Error: failed to insert DevPwd table");
        return NO;
    } 
    return YES;
}

- (BOOL) updatePassword:(NSString*)username :(NSString*)password devUUID:(NSString*)uuid
{
    sqlite3_stmt *statement;
    static char *sql = "update DevPwd set username=?,passwd=? where devUUID=?";
    
    int success = sqlite3_prepare_v2(m_database, sql, -1, &statement, NULL);
    if (success != SQLITE_OK) {
        NSLog(@"Error: failed to update");
        return NO;
    }
    
    //这里的数字1，2，3，4代表第几个问号
    sqlite3_bind_text(statement, 1, [username UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(statement, 2, [password UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(statement, 3, [uuid UTF8String], -1, SQLITE_TRANSIENT);
    
    success = sqlite3_step(statement);
    sqlite3_finalize(statement);
    
    if (success == SQLITE_ERROR) {
        NSLog(@"Error: failed to update DevPwd table uuid=%s",[uuid UTF8String]);
        return NO;
    }
    
    return YES;
}

-(BOOL) deletePasswd:(NSString*)uuid
{
    sqlite3_stmt *statement;
    static char *sql = "delete from DevPwd where devUUID=?";
    
    int success = sqlite3_prepare_v2(m_database, sql, -1, &statement, NULL);
    if (success != SQLITE_OK) {
        NSLog(@"Error: failed to delete host");
        return NO;
    }
    
    sqlite3_bind_text(statement, 1, [uuid UTF8String], -1, SQLITE_TRANSIENT);
    
    success = sqlite3_step(statement);
    sqlite3_finalize(statement);
    
    if (success == SQLITE_ERROR) {
        NSLog(@"Error: failed to delete DevPwd recordset uuid=%@",uuid);
        return NO;
    } 
    
    return YES;
}

/*
 TzhPasswdMgr 判断是否获取到记录通过devUUID是否为空字符串
 */
-(TzhPasswdMgr) getInfoByUUID:(NSString*)devUUID
{
    TzhPasswdMgr pm={0};
    char *sql = "SELECT username,passwd,devUUID FROM DevPwd where devUUID=?";
    
    sqlite3_stmt *statement = nil;
    if (sqlite3_prepare_v2(m_database, sql, -1, &statement, NULL) != SQLITE_OK) {
        NSLog(@"Error: failed to prepare statement with message:get DevPwd.");
    }
    
    sqlite3_bind_text(statement, 1, [devUUID UTF8String], -1, SQLITE_TRANSIENT);
    
    //查询结果集中一条一条的遍历所有的记录，这里的数字对应的是列值。
    if (sqlite3_step(statement) == SQLITE_ROW) {
        strcpy(pm.username,(char*)sqlite3_column_text(statement, 0));
        strcpy(pm.passwd,(char*)sqlite3_column_text(statement, 1));
        strcpy(pm.devUUID,(char*)sqlite3_column_text(statement, 2));
    }
    sqlite3_finalize(statement);
    return pm;
}

@end
