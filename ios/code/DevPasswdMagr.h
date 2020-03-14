//
//  Objc_Sqlite.h
//  monitor
//
//  Created by Han Sohn on 12-6-9.
//  Copyright (c) 2012年 Han.zhihong. All rights reserved.
//

/*//////////////////////////
 
 例子:
 
 DevPasswdMagr *sqlMage=[[DevPasswdMagr alloc] init];
 [sqlMage insertData:"a" :"b" :"cde" :4];
 //[sqlMage release];
 sqlMage=NULL;
 
 //////////////////////////*/
#import <Foundation/Foundation.h>

typedef struct _TzhPasswdMgr
{
    char devUUID[256];
    char username[256];              //设备用户名
    char passwd[256];                //控制密码
}TzhPasswdMgr;

//首先要引入 libsqlite3.0.dylib 的lib库
@interface DevPasswdMagr : NSObject

-(id)init;

+(void)newPasswdByDevUUID:(NSString*)username :(NSString*)pwd :(NSString*)devUUID;
//清空密码方便子设备调用
+(void)deletePasswdByDevUUID:(NSString*)devUUID;
+(TzhPasswdMgr)infoByDevUUID:(NSString*)devUUID;

//获取文档路径
-(NSString*) documentPath:(NSString*)dbname;

//【3】向表格中插入一条记录
-(BOOL) insertDevInfo:(TzhPasswdMgr*)info;
//更新记录
- (BOOL) updatePassword:(NSString*)username :(NSString*)password devUUID:(NSString*)uuid;
//删除记录
-(BOOL) deletePasswd:(NSString*)uuid;
/*
 TzhPasswdMgr 判断是否获取到记录通过devUUID是否为空字符串
 */
-(TzhPasswdMgr) getInfoByUUID:(NSString*)devUUID;

@end
