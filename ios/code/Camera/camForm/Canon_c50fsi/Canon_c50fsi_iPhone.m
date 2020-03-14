//
//  Canon_c50fsi.m
//  monitor
//
//  Created by sohn on 11-10-9.
//  Copyright 2011年 Han.zhihong. All rights reserved.
//

#import "Canon_c50fsi_iPhone.h"
#import "assist_function.h"

@implementation Canon_c50fsi_iPhone

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        m_saveImg=[[Objc_SaveImageMage alloc] init];
    }
    return self;
}

- (void)dealloc
{
    NSLog(@"Canon_c50fsi_iPhone dealloc");
    
    LOCK_CS(&m_cs);
    free(m_Mjpg);
    m_Mjpg=nil;
    UNLOCK_CS(&m_cs);
    DELETE_CS(&m_cs);
    
    m_saveImg=nil;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle
-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    //显示导航栏
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [lbStatus setText:NSLocalizedString(@"c50fsi_lbStatus", nil)];
    [lbStatusText2 setText:NSLocalizedString(@"c50fsi_lbStatusText2_ph", nil)];
    m_dwDataCulTime=0;
    viLoading.frame=viImg.frame;
    [self.view addSubview:viLoading];
    viLoading.hidden=NO;
    [indLoading startAnimating];
    INIT_CS(&m_cs);
    
    LOCK_CS(&m_cs);
    //在这里进行处理
    m_Mjpg=(TagMjpg_C50FSI*)malloc(sizeof(TagMjpg_C50FSI));
    c50fsi_init(m_Mjpg);
    //begin connect
    m_bConnecting=false;
    m_bDisconnected=true;
    [self ConnectMjpeg];
    UNLOCK_CS(&m_cs);
    
    self.navigationController.navigationBar.translucent = NO;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    
    lbStatus=nil;
    lbStatusText=nil;
    lbStatusText2=nil;
    viLoading=nil;
    indLoading=nil;
    viImg=nil;

}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait) || (interfaceOrientation == UIDeviceOrientationLandscapeRight) ||
    (interfaceOrientation == UIDeviceOrientationLandscapeLeft);
}

-(BOOL)shouldAutorotate{
    return YES;
}
-(NSInteger)supportedInterfaceOrientations{
    NSInteger orientationMask = 0;
    if ([self shouldAutorotateToInterfaceOrientation: UIInterfaceOrientationLandscapeLeft])
        orientationMask |= UIInterfaceOrientationMaskLandscapeLeft;
    if ([self shouldAutorotateToInterfaceOrientation: UIInterfaceOrientationLandscapeRight])
        orientationMask |= UIInterfaceOrientationMaskLandscapeRight;
    if ([self shouldAutorotateToInterfaceOrientation: UIInterfaceOrientationPortrait])
        orientationMask |= UIInterfaceOrientationMaskPortrait;
    if ([self shouldAutorotateToInterfaceOrientation: UIInterfaceOrientationPortraitUpsideDown])
        orientationMask |= UIInterfaceOrientationMaskPortraitUpsideDown;
    return orientationMask;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    NSLog(@"to Rotate=%d",toInterfaceOrientation);
    CGRect rx = [ UIScreen mainScreen ].bounds;
    switch (toInterfaceOrientation) {
        case UIInterfaceOrientationPortrait:
        {
            for (UIView*v in self.view.subviews) {
                [v setAlpha:1];
            }
            [viImg setAlpha:1];
            [viLoading setAlpha:0.5f];
            
            
            [[UIApplication sharedApplication]setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
            [viImg setFrame:CGRectMake(0, 0,rx.size.width, 248)];
            [viLoading setFrame:CGRectMake(0, 0,rx.size.width, 248)];
            [indLoading setCenter:CGPointMake(viLoading.frame.size.width/2, viLoading.frame.size.height/2)];
            //显示导航栏
            [self.navigationController setNavigationBarHidden:NO animated:YES];
        }
            break;
        case UIDeviceOrientationLandscapeRight:
        case UIDeviceOrientationLandscapeLeft:
        {
            for (UIView*v in self.view.subviews) {
                [v setAlpha:0];
            }
            [viImg setAlpha:1];
            [viLoading setAlpha:0.5f];
           
            
            [[UIApplication sharedApplication]setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
            //显示导航栏
            [self.navigationController setNavigationBarHidden:YES animated:YES];
            [viImg setFrame:CGRectMake(0, 0,440, rx.size.width)];
            [viLoading setFrame:CGRectMake(0, 0,440, rx.size.width)];
            
            [viImg setCenter:CGPointMake(rx.size.height/2,rx.size.width/2)];
            [viLoading setCenter:CGPointMake(rx.size.height/2,rx.size.width/2)];
            [indLoading setCenter:CGPointMake(viLoading.frame.size.width/2, viLoading.frame.size.height/2)];
        }
            break;
        case UIInterfaceOrientationPortraitUpsideDown:
            break;
    }
}

-(void)connectFail
{
    [lbStatusText setText:NSLocalizedString(@"c50fsi_connectFail",nil)];
}
-(void)connectOK
{
    [lbStatusText setText:NSLocalizedString(@"c50fsi_connectOK",nil)];
}

//connect thread
-(void)c50fsiConnectThread
{
    @autoreleasepool
    {
        //使此线程唯一启动
        if(m_Mjpg)
        {
            m_getBegin=0;
            char *ip=NULL;
            if((ip=dhsGetIp(m_pHostInfo->host)))
            {
                if(c50fsi_connect(m_Mjpg,ip,m_pHostInfo->port,m_pHostInfo->username,m_pHostInfo->password))
                {
                    [self connectFail];
                }
                else
                {
                    m_getBegin=1;
                    [self connectOK];
                    NSLog(@"connect ok");
                }
            }
            else
            {
                [self connectFail];
            }
        }
        //连接消失复位,并清除其它连接事件
        [NSObject cancelPreviousPerformRequestsWithTarget:self 
                                                 selector:@selector(ConnectMjpeg)
                                                   object:nil];
        m_bConnecting=false;
        m_bDisconnected=false;
    }
}

-(void)ConnectMjpeg
{
    if (m_bDisconnected) {
        if (m_bConnecting==false) {
            m_bConnecting=true;
            m_dwDataCul=0;
            [lbStatusText setText:NSLocalizedString(@"c50fsi_connecting",nil)];
            NSThread* thread;
            thread = [[NSThread alloc] initWithTarget:self selector:@selector(c50fsiConnectThread) object:nil];
            [thread setName:@"Thread-1"];
            [thread start];
            thread=nil;
        }
    }
}


- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    timer = [NSTimer scheduledTimerWithTimeInterval: 0.001
                                             target: self
                                           selector: @selector(handleTimer:)
                                           userInfo: nil
                                            repeats: YES];
}


- (void)viewDidDisappear:(BOOL)animated
{
    c50fsi_close(m_Mjpg);
    [timer invalidate];;
    timer=nil;
    [NSObject cancelPreviousPerformRequestsWithTarget:self 
                                             selector:@selector(ConnectMjpeg)
                                               object:nil];
    
	[super viewDidDisappear:animated];
}

- (void) handleTimer: (NSTimer *) timer
{
    [self c50fsi_thread:m_Mjpg];
}

-(void) c50fsi_stream_filter:(TagMjpg_C50FSI*)mjpg:(char *)btBuf:(int) nSize
{
	int nCucl=0;
	
	nCucl=mjpg->nCache+nSize;
	if(nCucl>MJPG_JPG_SIZE)
	{
		printf("mjpg->nCache overflow..\n");
		mjpg->nCache=0;
	}
	if(mjpg->nReadPos>MJPG_JPG_SIZE)
	{
		printf("mjpg->nReadPos overflow..\n");
		mjpg->nReadPos=0;
	}
    
	memcpy(&mjpg->btCache[mjpg->nCache],btBuf,nSize);
	mjpg->nCache=nCucl;
	
	for(;mjpg->nReadPos<nCucl;mjpg->nReadPos++)
	{
		if(mjpg->isget)
		{
			if(mjpg->btCache[mjpg->nReadPos]==0xFF && mjpg->nReadPos+3<=nCucl)
                if(mjpg->btCache[mjpg->nReadPos+1]==0xD9)
                    {
                        mjpg->isget=0;
                        if (mjpg->nReadPos>0) {
                            memcpy(mjpg->btJpg,mjpg->btCache,mjpg->nReadPos);
                            nCucl=mjpg->nCache-=mjpg->nReadPos;
                        }
                        else
                        {mjpg->nReadPos=0;}
                        if (mjpg->nCache>0) {
                            memmove(mjpg->btCache,&mjpg->btCache[mjpg->nReadPos],mjpg->nCache);
                        }
                        else
                        {mjpg->nCache=0;}
                        //jpeg data
                        [self draw:mjpg->btJpg :mjpg->nReadPos];
                        mjpg->nReadPos=0;
                        mjpg->redraw=1;
                    }
		}
		else
		{
			if(mjpg->btCache[mjpg->nReadPos]==0xFF && mjpg->nReadPos+3<=nCucl)
                if(mjpg->btCache[mjpg->nReadPos+1]==0xD8)
                    if(mjpg->btCache[mjpg->nReadPos+2]==0xFF)
                    {
                        //printf("\rbegin recv pic time=%d   ",(int)Sys_GetTime());
                        mjpg->isget=1;
                        mjpg->nCache = nCucl-mjpg->nReadPos;
                        nCucl = mjpg->nCache;
                        if (mjpg->nCache>0) {
                            memmove(mjpg->btCache,&mjpg->btCache[mjpg->nReadPos],mjpg->nCache);
                        }
                        else
                        {mjpg->nCache=0;}
                        
                        mjpg->nReadPos =0;
                    }
		}
	}
}

/* 循环执行 */
-(void)c50fsi_thread:(TagMjpg_C50FSI *)mjpg
{
	int nRet;
	char szTmp[65535];
    
    LOCK_CS(&m_cs);
    
	nRet=dhsRecv(mjpg->s,szTmp,sizeof(szTmp));
	if(nRet>0)
	{
        if(c50fsi_check_authorized(mjpg,szTmp,nRet))
        {
            [self c50fsi_stream_filter:mjpg:szTmp:nRet];
        }
        
	}
    else if(nRet==0){
        if (m_getBegin==1) {
            c50fsi_get_stream(m_Mjpg);
            m_getBegin=2;
        }
    }
    else if(nRet==-1)
    {
        //用户名和密码有错误，不再连接
        if (m_bConnecting==false) {
            if (mjpg->bVerifyNum==1) 
            {
                lbStatusText.text=NSLocalizedString(@"c50fsi_verify_err",nil) ;
            }
            else
            {
                if (false==m_bDisconnected) {
                    lbStatusText.text=[NSString stringWithFormat:NSLocalizedString(@"c50fsi_disconnect",nil),3] ;
                    [self performSelector:@selector(ConnectMjpeg) withObject:nil afterDelay:3/*秒数*/];	
                    m_bDisconnected=true;
                    
                }
            }
        }
    }
    
    if (nRet<0) {
        nRet=0;
    }
    m_dwDataCul+=nRet;
    
    if (time(NULL)-m_dwDataCulTime>1000) {
        
        //NSLog(@"data m_dwDataCul=%d",m_dwDataCul);
        
        //加载栏设置
        if (m_dwDataCul>0) {
            viLoading.hidden=YES;
            [indLoading stopAnimating];
        }
        else
        {
            viLoading.hidden=NO;
            [indLoading startAnimating];
        }
        
        [lbStatusText2 setText:[NSString stringWithFormat:NSLocalizedString(@"c50fsi_lbStatusText2", nil),
                                (float)(m_dwDataCul/1024.0f)]];
        m_dwDataCulTime=time(NULL);
        m_dwDataCul=0;
    }
    
    UNLOCK_CS(&m_cs);
}

-(void) draw:(unsigned char*)data:(int)len
{
    NSData*nsData=[[NSData alloc]initWithBytesNoCopy:data length:len freeWhenDone:NO];
    UIImage*img=[[UIImage alloc] initWithData:nsData];
    [viImg setImage:img];

    img=nil;
    nsData=nil;
}

-(IBAction) btnScreenshot_click:(id)sender
{
    [m_saveImg SaveImage:self.view :viImg.image];
}

@end
