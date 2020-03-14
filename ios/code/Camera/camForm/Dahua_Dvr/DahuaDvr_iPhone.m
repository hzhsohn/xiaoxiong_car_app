//
//  dahua_dvr.m
//  iPadClient
//
//  Created by sohn on 11-7-7.
//  Copyright 2011年 Han.zhihong. All rights reserved.
//

#import "DahuaDvr_iPhone.h"
#import "dh_socket.h"
#import "UIViewController+BackButtonHandler.h"

#define DEFAULT_SHOW_IMG        [imgCameraShow setImage:[UIImage imageNamed:@"screen_0.png"]]


@implementation DahuaDvr_iPhone

- (void)dealloc
{
    NSLog(@"DahuaDvr_iPhone dealloc");
    
    ZH_DisconnectAll(&tds);
    if(bIsInit){
        for(int i=0;i<ZH_DVR_CAMERA_SOCK;i++)
        {
            free(dvrData[i].btBuf);
            dvrData[i].btBuf=NULL;
            dvrData[i].nSize=0;
            free(rgbData[i].btBuf);
            rgbData[i].btBuf=NULL;
        }
        
        free(recvData.btBuf);
        recvData.btBuf=NULL;
        
        free(dvrData);
        dvrData=NULL;
        free(rgbData);
        rgbData=NULL;
        zhH264ToRgbFree();
    }
    
    
    bIsInit=false;
    
    m_saveImg=nil;
}

//--------------------------------------------------------
//检测是否返回
- (void)willMoveToParentViewController:(UIViewController*)parent{
    [super willMoveToParentViewController:parent];
    NSLog(@"%s,%@",__FUNCTION__,parent);
}
- (void)didMoveToParentViewController:(UIViewController*)parent{
    [super didMoveToParentViewController:parent];
    NSLog(@"%s,%@",__FUNCTION__,parent);
    if(!parent){
        NSLog(@"页面pop成功了");
        if(timer)
        {
            [timer invalidate];
            timer = nil;
        }
    }
}

-(BOOL)navigationShouldPopOnBackButton
{
    return YES;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void) handleTimer: (NSTimer *) timer
{
    short rCurShow;
    DWORD dwTmp;
    int w,h;
    TDvrDataType dType;
    w=h=0;
	/*返回值为处理后的结果
	 1 	没有账号
	 2	密码错误
	 3   账户锁定
	 4	登录成功
	 5	退出设备
	 6	断开连接
	 7	连接超时*/
	switch(ZH_MainThread(&tds))//#
	{
		case 1:
            NSLog(@"沒有賬戶");
            lbStaus.text=NSLocalizedString(@"dahua_noaccount", nil);
            isDisconnect=false;
            [self dataLoading:NO];
            break;
        case 2:
            NSLog(@"密碼錯誤");
            lbStaus.text=NSLocalizedString(@"dahua_passwd_err", nil);
            isDisconnect=false;
            [self dataLoading:NO];
            break;
        case 3:
            NSLog(@"賬戶已鎖");
            lbStaus.text=NSLocalizedString(@"dahua_lockAccount", nil);
            isDisconnect=false;
            [self dataLoading:NO];
            break;
        case 4:
            NSLog(@"大華DVR登錄成功");
            lbStaus.text=NSLocalizedString(@"dahua_connectok", nil);
            isDisconnect=false;
            //[self dataLoading:NO];
            break;
        case 5:
            NSLog(@"退出");
            lbStaus.text=NSLocalizedString(@"dahua_exit", nil);
            [self dataLoading:NO];
            break;
        case 6:
        {
            if (false==isDisconnect) {
                NSLog(@"與大華DVR斷開連接");
                lbStaus.text=NSLocalizedString(@"dahua_disconnect", nil);
                isReconnect=true;
                isDisconnect=true;
                memset(&tds,0, sizeof(TagDvrSession));
                [tabCameraList reloadData];
                [self performSelector:@selector(dvrConnect) withObject:nil afterDelay:2/*秒数*/];
            }
        }
			break;
		case 7:
        {
            NSLog(@"連接超時");
            lbStaus.text=NSLocalizedString(@"dahua_timeout", nil);
            isReconnect=true;
            isDisconnect=true;
            [self performSelector:@selector(dvrConnect) withObject:nil afterDelay:2/*秒数*/];
        }
			break;
        case 8:
        {
            //DVR设备数据1
            //tds.dvrInfo
            [tabCameraList reloadData];
            [self dataLoading:NO];
        }
            break;
        case 9:
        {
            //DVR设备数据2
            //tds.dvrInfo
        }
            break;
	}
	
	if(tds.bLogin)
	{
        rCurShow=0;
        dwTmp=Sys_GetTime();
        
        //播放
        for(rCurShow=0;rCurShow<ZH_DVR_CAMERA_SOCK;)
        {
            //接收数据
            if(ZH_DvrData(&tds,rCurShow,(char*)recvData.btBuf,&recvData.nSize,&dType))
            {
                if(recvData.nSize>0)
                {
                    switch (dType) {
                        case ZH_DVR_DATA_TYPE_H264:
                        {
                            if(dvrData[rCurShow].nSize+recvData.nSize>H264_STREAM_BUF)
                            {
                                dvrData[rCurShow].nSize=0;
                            }
                            else
                            {
                                NSLog(@"dahua dvr pos=%d recv=%0.1fkb nSize=%d",rCurShow,(float)recvData.nSize/1024.0f,dvrData[rCurShow].nSize);
                                memcpy(&dvrData[rCurShow].btBuf[dvrData[rCurShow].nSize],recvData.btBuf,recvData.nSize);
                                dvrData[rCurShow].nSize+=recvData.nSize;
                                
                                //Sys_print16(60, recvData[rCurShow].btBuf);
                                //printf("\n");
                            }
                            
                        }
                            break;
                        case ZH_DVR_DATA_TYPE_G711A:
                            
                            break;
                    }
                    
                    sumDataForSec+=recvData.nSize;
                    
                    if (dwTmp-dwDataForSec>1000) {
                        dwDataForSec=Sys_GetTime();
                        lbData.text=[NSString stringWithFormat:NSLocalizedString(@"dahua_recv_str", nil) ,m_rCurChannel+1,(float)(sumDataForSec/1024.0f)];
                        sumDataForSec=0;
                    }
                }
            }
            
            //播放
            if(tds.CamaSock[rCurShow].bUsing && dvrData[rCurShow].nSize>0)
            {
                if(dwTmp-tds.CamaSock[rCurShow].dwLastFrameTime>tds.CamaSock[rCurShow].dwFrameTime)
                {
                    tds.CamaSock[rCurShow].dwLastFrameTime=Sys_GetTime();
                    
                    if((rgbData[rCurShow].nSize=zhH264ToRGBStream(rCurShow,dvrData[rCurShow].btBuf,dvrData[rCurShow].nSize,rgbData[rCurShow].btBuf,&w,&h)))
                    {
                        if(w && h)
                        {
                            [self dataLoading:NO];
                            //NSLog(@"Pos=%d,nLen=%d,nSize=%d",pCameraNode->camera.channel,nLen,dvrData[rCurShow].nSize);
                            CGDataProviderRef provider = CGDataProviderCreateWithData(NULL,rgbData[rCurShow].btBuf,RGB_BUF,NULL);
                            if (provider) {
                                CGImageRef iref = CGImageCreate(w,h,8,24,w*3,CGColorSpaceCreateDeviceRGB(),
                                                                kCGImageAlphaNone,provider,NULL,NO,kCGRenderingIntentDefault);
                                if (iref) {
                                    UIGraphicsBeginImageContext(CGSizeMake(w, h));
                                    
                                    CGContextRef ctx = UIGraphicsGetCurrentContext();
                                    CGContextDrawImage(ctx, CGRectMake(0.0, 0.0, w, h), iref);
                                    UIImage* outputImage =  UIGraphicsGetImageFromCurrentImageContext();
                                    if (outputImage) {
                                        imgCameraShow.image = outputImage;
                                    }
                                    else
                                    {
                                        dvrData[rCurShow].nSize=0;
                                    }
                                    UIGraphicsEndImageContext();
                                    CGImageRelease(iref);
                                }
                                CGDataProviderRelease(provider);
                            }
                            dvrData[rCurShow].nSize -= rgbData[rCurShow].nSize;
                            if(dvrData[rCurShow].nSize<0)dvrData[rCurShow].nSize=0;
                            memmove(dvrData[rCurShow].btBuf,dvrData[rCurShow].btBuf+rgbData[rCurShow].nSize,dvrData[rCurShow].nSize);
                        }
                    }
                }
            }
            rCurShow++;
        }
    }
}

-(void) dvrConnectThread
{
    //初始化DVR的连接
    char *ip=NULL;
    ZH_DvrInit(&tds);
    
    if((ip=dhsGetIp(m_pHostInfo->host)))
    {
        ZH_DvrConnect(ip,m_pHostInfo->port,m_pHostInfo->username,
                      m_pHostInfo->password,&tds,true);
    }
}

-(void)dvrConnect
{
	if (tds.bLogin)
    {return; }
    if (!bIsInit)
    {return; }
    
    if(!isReconnect)
    {
        [lbStaus setText:NSLocalizedString(@"dahua_connecting", nil)];
    }
    [self dataLoading:YES];
	
    NSThread* thread;
    thread = [[NSThread alloc] initWithTarget:self selector:@selector(dvrConnectThread) object:nil];
    [thread setName:@"Thread-2"];
    [thread start];
    thread=nil;
}


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        sumDataForSec=0;
        m_saveImg=[[Objc_SaveImageMage alloc] init];
        
        //初始化逻辑变量
        dvrData=calloc(ZH_DVR_CAMERA_SOCK,sizeof(Tag_H264_MutBuf));
        rgbData=calloc(ZH_DVR_CAMERA_SOCK,sizeof(Tag_H264_MutBuf));
        for(int i=0;i<ZH_DVR_CAMERA_SOCK;i++)
        {
            dvrData[i].btBuf=(BYTE*)malloc(H264_STREAM_BUF);
            memset(dvrData[i].btBuf, 0, H264_STREAM_BUF);
            dvrData[i].nSize=0;
            rgbData[i].btBuf=(BYTE*)malloc(RGB_BUF);
            memset(rgbData[i].btBuf, 0, RGB_BUF);
        }
        
        recvData.btBuf=(BYTE*)malloc(RECV_DATA_BUF);
        memset(recvData.btBuf, 0, RECV_DATA_BUF);
        
        bIsInit=true;
        isDisconnect=true;
        zhInitH264ToRgb(ZH_DVR_CAMERA_SOCK);
        
        isReconnect=false;
        
        DEFAULT_SHOW_IMG;
        //初始化数据
        timer = [NSTimer scheduledTimerWithTimeInterval: 0.001
                                                 target: self
                                               selector: @selector(handleTimer:)
                                               userInfo: nil
                                                repeats: YES];
        

    }
    return self;
}

#pragma mark - View lifecycle

//初始化窗体
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    //显示导航栏
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    
    [self dvrConnect];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    DEFAULT_SHOW_IMG;
    m_rCurChannel=-1;
    lbData.text=@"";
    
    //初始化Loading大小
    [viBgCamera setFrame:CGRectMake(0,0,imgCameraShow.frame.size.width,imgCameraShow.frame.size.height)];
    [indCamera setCenter:viBgCamera.center];
    
    //
    [btnCutPhoto setTitle:NSLocalizedString(@"screenshot", nil) forState:0];

    //加入到栏里
    UIBarButtonItem *righttomItem = [[UIBarButtonItem alloc] initWithCustomView:btnPTZCtrl];
    self.navigationItem.rightBarButtonItem = righttomItem;
    self.navigationController.navigationBar.translucent = NO;
    
    btnPTZ1.alpha=0;
    btnPTZ2.alpha=0;
    btnPTZ3.alpha=0;
    btnPTZ4.alpha=0;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;

    lbStaus=nil;
    lbData=nil;
    tabCameraList=nil;
    imgCameraShow=nil;
    btnCutPhoto=nil;
    btnPTZCtrl=nil;
    viBgCamera=nil;
    indCamera=nil;
}

-(IBAction)btnMoveChannel_click:(id)sender
{
    int nChannel=0;
    if (tds.bLogin) {
            UIButton*btn=(UIButton*)sender;
            if(0>m_rCurChannel)
            {
                m_rCurChannel=0;
            }
            else if(0<=m_rCurChannel && m_rCurChannel<=(tds.dvrInfo.btChanNum-1))
            {
                if (1==btn.tag) {
                    m_rCurChannel--;
                } else if(2==btn.tag){
                    m_rCurChannel++;
                }
                if(m_rCurChannel<0){m_rCurChannel=(tds.dvrInfo.btChanNum-1);}
                if(m_rCurChannel>(tds.dvrInfo.btChanNum-1)){m_rCurChannel=0;}
                nChannel=m_rCurChannel;
            }
            else
            {
                nChannel=tds.dvrInfo.btChanNum-1;
            }
            [self changeChannel:nChannel];
            [tabCameraList selectRowAtIndexPath:[NSIndexPath indexPathForRow:nChannel inSection:0] animated:YES scrollPosition:UITableViewScrollPositionTop];
    }
}
-(void)changeChannel:(short)channel
{
    btnPTZCtrl.selected=NO;
    
    DEFAULT_SHOW_IMG;
    m_rCurChannel=channel;
    if (tds.bLogin) {
        [imgCameraShow setDahuaInfo:&tds :m_pHostInfo :channel];
        ZH_DvrConnectOnceCamera(&tds,channel,1);
        lbData.text=[NSString stringWithFormat
                     :NSLocalizedString(@"dahua_connect_camera", nil),channel+1];
        [self dataLoading:YES];
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{    
    return (interfaceOrientation == UIInterfaceOrientationPortrait) || (interfaceOrientation == UIDeviceOrientationLandscapeRight) ||
    (interfaceOrientation == UIDeviceOrientationLandscapeLeft);
}

-(void)dataLoading:(boolean_t)b
{
    if (b==m_bLoading) {
        return;
    }
    
    m_bLoading=b;
    if (b) {
        [indCamera startAnimating];
        [imgCameraShow addSubview:viBgCamera];
    }
    else
    {
        [indCamera stopAnimating];
        [viBgCamera removeFromSuperview];
    }
}
-(IBAction)btnPTZCtrl_click:(id)sender
{
    btnPTZCtrl.selected=!btnPTZCtrl.selected;
    [imgCameraShow setCtrlSwith:btnPTZCtrl.selected];
    
    btnPTZ1.alpha=btnPTZCtrl.selected?1:0;
    btnPTZ2.alpha=btnPTZCtrl.selected?1:0;
    btnPTZ3.alpha=btnPTZCtrl.selected?1:0;
    btnPTZ4.alpha=btnPTZCtrl.selected?1:0;
}

-(IBAction)btnSavePhoto_click:(id)sender
{
    [m_saveImg SaveImage:self.view :imgCameraShow.image];
}

- (IBAction)btnMovePTZ_click:(id)sender
{
    if(m_rCurChannel>=0)
    {
        UIButton*btn=(UIButton*)sender;
        switch (btn.tag) {
            case 1:
                ZH_DvrCtrl(&tds,m_rCurChannel,ZH_DVR_CTRL_DOWN,1);
                break;
                
            case 2:
                ZH_DvrCtrl(&tds,m_rCurChannel,ZH_DVR_CTRL_UP,1);
                break;
                
            case 3:
                ZH_DvrCtrl(&tds,m_rCurChannel,ZH_DVR_CTRL_RIGHT,1);
                break;
                
            case 4:
                ZH_DvrCtrl(&tds,m_rCurChannel,ZH_DVR_CTRL_LEFT,1);
                break;

        }
    }
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView 
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
    // Return the number of rows in the section.
    return tds.dvrInfo.btChanNum;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //行高度
    return 50;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) 
	{
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    cell.textLabel.text=[NSString stringWithFormat:NSLocalizedString(@"dahua_cellTxt",nil),indexPath.row+1];
    return cell;
}

#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
    [self changeChannel:indexPath.row];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [NSString stringWithFormat:NSLocalizedString(@"dahua_tbHeader", nil),
            tds.dvrInfo.btChanNum];
}
- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    return NSLocalizedString(@"dahua_tbFooter", nil);
}

@end
