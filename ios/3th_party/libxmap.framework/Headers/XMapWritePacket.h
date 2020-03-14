//
//  XMapWritePacket.h
//  libxmap
//
//  Created by Han.zh on 2019/10/6.
//  Copyright © 2019年 Han.zhihong. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XMapWritePacket : NSObject

-(id) init;
-(id) initWithSize:(int)len;

-(void) writeInit;

-(NSData*) getBuffData;
-(unsigned char *) getBuff;
-(int) getBuffSize;
-(void) writeChar:(char) c;
-(void) writeUnsignedChar:(unsigned char) uc;
-(void) writeShort:(short) s;
-(void) writeUnsignedShort:(unsigned short) us;
-(void) writeInt:(int) i;
-(void) writeUnsignedInt:(unsigned int) ui;
-(void) writeString:(NSString*) str;
-(void) writeByte:(char*) buff :(int)len;
-(void) writeByte:(NSData*) data;



@end
