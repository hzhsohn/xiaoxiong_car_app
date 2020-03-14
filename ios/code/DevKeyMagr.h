//
//  Objc_Sqlite.h
//  monitor
//
//  Created by Han Sohn on 12-6-9.
//  Copyright (c) 2012年 Han.zhihong. All rights reserved.
//

/*//////////////////////////
 
 例子:
 
 DevKeyMagr *sqlMage=[[DevKeyMagr alloc] init];
 [sqlMage insertData:"a" :"b" :"cde" :4];
 //[sqlMage release];
 sqlMage=NULL;
 
 //////////////////////////*/
#import <Foundation/Foundation.h>

typedef struct _TzhKeyMgr
{
    int autoID;
    char devUUID[256];
    char devname[256];              //设备名称
    char devflag[256];              //设备协议标识
}TzhKeyMgr;

typedef struct _TzhKeyMgrSaveInfo
{
    char devUUID[256];
    char devname[256];              //设备名称
    char devflag[256];              //设备协议标识
}TzhKeyMgrSaveInfo;

//首先要引入 libsqlite3.0.dylib 的lib库
@interface DevKeyMagr : NSObject

-(id)init;

//获取文档路径
-(NSString*) documentPath:(NSString*)dbname;

//【3】向表格中插入一条记录
-(BOOL) insertDevInfo:(TzhKeyMgrSaveInfo*)info;
//更新记录
- (BOOL) updateDevInfo:(TzhKeyMgrSaveInfo*)info :(int)autoID;
- (BOOL) updateDevname:(NSString*)devname :(int)autoID;
- (BOOL) updateDevname:(NSString*)devname devUUID:(NSString*)devUUID;
//删除记录
-(BOOL) deleteDevInfo:(int)autoID;
//数据库查询
-(BOOL) getDevInfoAllKeyMgr:(NSMutableArray*)dst_ary;
//获取单条记录内容
-(BOOL) getDevInfoByAutoID:(int)autoID :(TzhKeyMgr*)info;
//
//检测是否设备名称在数据库里
-(BOOL) getDevCheckDevname:(NSString*)devflag :(NSString*)devname;
-(BOOL) getDevCheckDevUUID:(NSString*)devUUID;

//获取最后插入的ID值
-(int) getDevLastInsertID;
@end
