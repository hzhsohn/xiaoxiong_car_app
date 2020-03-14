//
//  ViewController.m
//  helloProject
//
//  Created by Han.zh on 2017/6/13.
//  Copyright © 2017年 Han.zhihong. All rights reserved.
//

#import "ZipController.h"
#import "ZipFile.h"
#import "ZipException.h"
#import "FileInZipInfo.h"
#import "ZipWriteStream.h"
#import "ZipReadStream.h"

@interface ViewController ()
{
    bool g_iphone_uncompress_thread;
    IBOutlet UIActivityIndicatorView *indUncompress;
}

-(void) extractBegin:(NSString*)filename;
-(void) extractEnd;
-(NSString*) documentPath:(NSString*)str;
@end

@implementation ViewController


///////////// 解压帮助文档数据 ///////////////////
- (void) uncompress_help_data:(NSString*)filename
{
    NSString *filePath = [[NSBundle mainBundle] pathForResource:filename ofType:@"zip"];
    g_iphone_uncompress_thread=true;
    
    //延时效果
    [NSThread sleepForTimeInterval:0.5f];
    @autoreleasepool {
    
        @try {
            NSLog(@"%@",filePath);
            
            ZipFile *unzipFile= [[ZipFile alloc] initWithFileName:filePath mode:ZipFileModeUnzip];
            
            NSLog(@"Opening zip file for reading..");
            
            //开始解压
            NSArray *infos= [unzipFile listFileInZipInfos];
            [unzipFile goToFirstFileInZip];
            for (FileInZipInfo *info in infos) {
                //延时效果
                //[NSThread sleepForTimeInterval:0.01f];
                if (false==g_iphone_uncompress_thread) {
                    [unzipFile close];
                   // [unzipFile release];
                    unzipFile=nil;
                    return;
                }
                
                //生成文件
                ZipReadStream *read1= [unzipFile readCurrentFileInZip];
                
                NSString*str=[NSString stringWithFormat:@"Extract %@...",info.name];
                NSLog(@"%@",str);
                
                //字节数据
                NSMutableData *data1= [[NSMutableData alloc] initWithLength:info.length];
                int bytesRead1= [read1 readDataWithBuffer:data1];
                
                //全部文件解压到同一目录
                //NSString *wfiles= [self documentPath:[info.name lastPathComponent]];
                NSString *wfiles= [self documentPath:info.name];
                NSLog(@"wfiles=%@",wfiles);
                
                //建立目录
                NSString *dir=[wfiles stringByDeletingLastPathComponent];
                if (access([dir UTF8String], 0))
                {
                    //不存在目录就新建
                    [[NSFileManager defaultManager] createDirectoryAtPath:dir
                                              withIntermediateDirectories:YES
                                                               attributes:nil
                                                                    error:nil];
                }
                else
                {
                    //判断存放路径是否是目录
                    NSFileManager *fileManager = [NSFileManager defaultManager];
                    BOOL isDir = NO;
                    [fileManager fileExistsAtPath:dir isDirectory:(&isDir)];
                    if (false==isDir) {
                        //如果是文件就删除掉
                        [[NSFileManager defaultManager] removeItemAtPath:dir error:nil];
                        //重新创建目录就新建
                        [[NSFileManager defaultManager] createDirectoryAtPath:dir
                                                  withIntermediateDirectories:YES
                                                                   attributes:nil
                                                                        error:nil];
                    }
                }
                
                BOOL ok=[data1 writeToFile:wfiles atomically:YES];
                //[data1 release];
                data1=nil;
                if (ok)
                {
                    NSString*str=[NSString stringWithFormat:@"Done. bytes=%d",bytesRead1];
                    NSLog(@"%@",str);
                }
                else
                {
                    NSString*str=[NSString stringWithFormat:@"Done. extract fail"];
                    NSLog(@"%@",str);
                }
                [read1 finishedReading];
                [unzipFile goToNextFileInZip];
            }
            [unzipFile close];
            //[unzipFile release];
            unzipFile=nil;
            
        } @catch (ZipException *ze) {
            NSString*str=[NSString stringWithFormat:@"ZipException caught: %ld - %@\r\n", (long)ze.error, [ze reason]];
            NSLog(@"%@",str);
        } @catch (id e) {
            NSString*str=[NSString stringWithFormat:@"Exception caught: %@ - %@\r\n", [[e class] description], [e description]];
            NSLog(@"%@",str);
        }
        
        //写入帮助文档版本号
        NSDictionary* infoDict = [[NSBundle mainBundle] infoDictionary];
        NSString *version =[infoDict valueForKey:@"CFBundleVersion"];
        NSString *versFiles= [self documentPath:@"help_version"];
        NSLog(@"versFiles=%@",versFiles);
        NSData*verData=[NSData dataWithBytes:[version UTF8String] length:[version length]];
        [verData writeToFile:versFiles atomically:YES];
        
        //跳到读取
        [self extractEnd];
    
    }
}

-(void) extractBegin:(NSString*)filename
{
    [indUncompress setHidden:NO];
    [indUncompress setAlpha:1];
    //解压文档
    [self performSelector:@selector(uncompress_help_data) withObject:filename afterDelay:0.5f];
}


-(void) extractEnd
{
    [indUncompress setHidden:YES];
    [indUncompress setAlpha:0];
    
    [self performSegueWithIdentifier:@"segNext" sender:nil];
}

-(NSString*) documentPath:(NSString*)str
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDir = [paths objectAtIndex:0];
    
    if (nil!=str) {
        return [documentsDir stringByAppendingPathComponent:str];
    }
    return documentsDir;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    //显示和隐藏导航栏
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    
    g_iphone_uncompress_thread=false;
    //[self extractBegin:@"aaa"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
