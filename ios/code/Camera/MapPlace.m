#import "MapPlace.h"
@implementation MapPlace
@synthesize coordinate;

- (NSString *)subtitle{
    return m_sContent;
}
- (NSString *)title{
    return m_sTitle;
}
-(id)init
{
    if ((self=[super init])) {
        m_sTitle=[[NSMutableString alloc] init];
        m_sContent=[[NSMutableString alloc] init];
    }
    return self;
}
- (id)setInfo:(CLLocationCoordinate2D)c :(NSString*)t :(NSString*)str
{
    coordinate=c;
    [m_sTitle setString:t];
    [m_sContent setString:str];
    return self;
}
-(void)dealloc
{
    m_sTitle=nil;
    m_sContent=nil;
    NSLog(@"MapPlace dealloc");
}
@end
