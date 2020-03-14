//
//  KZColorWheelView.m
//
//  Created by Alex Restrepo on 5/11/11.
//  Copyright 2011 KZLabs http://kzlabs.me
//  All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "KZColorPicker.h"
#import "KZColorPickerHSWheel.h"
#import "KZColorPickerBrightnessSlider.h"
#import "KZColorPickerAlphaSlider.h"
#import "HSV.h"
#import "UIColor-Expanded.h"
#import "KZColorPickerSwatchView.h"
#import "KZColorCompareView.h"

@interface KZColorPicker()
@property (nonatomic, retain) KZColorPickerHSWheel *colorWheel;
@property (nonatomic, retain) KZColorPickerBrightnessSlider *brightnessSlider;
@property (nonatomic, retain) KZColorPickerAlphaSlider *alphaSlider;
@property (nonatomic, retain) KZColorCompareView *currentColorView;
@property (nonatomic, retain) NSMutableArray *swatches;
- (void) fixLocations;
@end


@implementation KZColorPicker
@synthesize colorWheel;
@synthesize brightnessSlider;
@synthesize selectedColor;
@synthesize alphaSlider;
@synthesize swatches;
@synthesize currentColorView = _currentColorView;

- (void) setup
{
	// set the frame to a fixed 300 x 300
	//self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, 300, 280);
	self.backgroundColor = [UIColor clearColor];
    
    
	// HS wheel
	KZColorPickerHSWheel *wheel = [[KZColorPickerHSWheel alloc] initAtOrigin:CGPointMake(40, 15)];
	[wheel addTarget:self action:@selector(colorWheelColorChanged:) forControlEvents:UIControlEventValueChanged];
	[self addSubview:wheel];
	self.colorWheel = wheel;
	[wheel release];
	
	// brightness slider
	KZColorPickerBrightnessSlider *slider = [[KZColorPickerBrightnessSlider alloc] initWithFrame:CGRectMake(24, 277, 272, 38)];
	[slider addTarget:self action:@selector(brightnessChanged:) forControlEvents:UIControlEventValueChanged];
	[self addSubview:slider];
	self.brightnessSlider = slider;
	[slider release];
    
    // alpha slider,滚动条
    KZColorPickerAlphaSlider *alpha = [[KZColorPickerAlphaSlider alloc] initWithFrame:CGRectMake(24, 321, 272, 38)];
    [alpha addTarget:self action:@selector(alphaChanged:) forControlEvents:UIControlEventValueChanged];
	[self addSubview:alpha];
    self.alphaSlider = alpha;
	[alpha release];
    
    // current color indicator hier.
    KZColorCompareView *colorView = [[KZColorCompareView alloc] initWithFrame:CGRectMake(5, 25, 44, 44)];
    [colorView addTarget:self action:@selector(setDefaultColor:) forControlEvents:UIControlEventTouchUpInside];
    self.currentColorView = colorView;    
    //[self addSubview:colorView];
    [colorView release];
    
	// swatches.颜色选择块里面的颜色
    NSMutableArray *colors = [NSMutableArray array];
#if 0 //是否绘制颜色选择块
    for(float angle = 0; angle < 360; angle += 60)
    {
        CGFloat h = 0;
        h = (M_PI / 180.0 * angle) / (2 * M_PI);            
        [colors addObject:[UIColor colorWithHue:h  saturation:1.0 brightness:1.0 alpha:1.0]];                        
    }
    
    for (int i = 0; i < 6; i++)
    {            
        [colors addObject:[UIColor colorWithRed:i / 5.0 green:i / 5.0 blue:i / 5.0 alpha:1.0]];
    }  
#endif
    
    //显示颜色选择块
    KZColorPickerSwatchView *swatch = nil;	
    self.swatches = [NSMutableArray array];
    for (UIColor *color in colors)
    {
        swatch = [[KZColorPickerSwatchView alloc] initWithFrame:CGRectZero];
        swatch.color = color;
        [swatch addTarget:self action:@selector(swatchAction:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:swatch];
        [swatches addObject:swatch];
        [swatch release];
    }
	
    //当前选择的颜色
	self.selectedColor = [UIColor whiteColor];//[UIColor colorWithRed:0.349 green:0.613 blue:0.378 alpha:1.000];
    [self fixLocations];
}

/*
 
 绘制控制位置
 
 */
- (void) fixLocations
{
    [UIView setAnimationsEnabled:NO];
    //颜色盘中心位置
    [self.colorWheel setCenter:CGPointMake(self.bounds.size.width/2, 262)];
    //当前的颜色块位置
    [self.currentColorView setFrame:CGRectMake(12, 82, 50, 50)];
    
    //选择颜色的块的位置
    CGFloat totalWidth = self.bounds.size.width - 40.0;
    CGFloat swatchCellWidth = totalWidth / self.swatches.count;

    int sx = 0;
    int sy = 370;
    for (KZColorPickerSwatchView *swatch in self.swatches)
    {
        //颜色块的位置
        swatch.frame = CGRectMake(sx + swatchCellWidth * 0.5 ,
        sy, 36.0, 36.0);
        sx += swatchCellWidth;
    }

    //滚动栏位置
    self.brightnessSlider.frame = CGRectMake(0, 0, 272, 38);
    [self.brightnessSlider setCenter:CGPointMake(self.bounds.size.width/2+4, 410)];
    self.alphaSlider.frame = CGRectMake(24, 350, 272, 38);
    [self.alphaSlider setCenter:CGPointMake(self.bounds.size.width/2+4, 465)];
    [UIView setAnimationsEnabled:YES];
    
}

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) 
	{
        // Initialization code
		[self setup];
    }
    return self;
}

- (void)dealloc 
{
	[selectedColor release];
	[colorWheel release];
	[brightnessSlider release];
    [alphaSlider release];
    [currentColorIndicator release];
    [swatches release];
    [_currentColorView release];
    [super dealloc];
}

- (void) awakeFromNib
{
    [super awakeFromNib];
	[self setup];
}

/*
  点击当前颜色的框,
 */
- (void) setDefaultColor:(KZColorCompareView *)view
{
    [self setSelectedColor:[UIColor whiteColor] animated:YES];
}

RGBType rgbWithUIColor(UIColor *color)
{
	const CGFloat *components = CGColorGetComponents(color.CGColor);
	
	CGFloat r,g,b;
	
	switch (CGColorSpaceGetModel(CGColorGetColorSpace(color.CGColor))) 
	{
		case kCGColorSpaceModelMonochrome:
			r = g = b = components[0];
			break;
		case kCGColorSpaceModelRGB:
			r = components[0];
			g = components[1];
			b = components[2];
			break;
		default:	// We don't know how to handle this model
			return RGBTypeMake(0, 0, 0);
	}
	
	return RGBTypeMake(r, g, b);
}

- (void) setSelectedColor:(UIColor *)color animated:(BOOL)animated
{
	if (animated) 
	{
		[UIView beginAnimations:nil context:nil];
		self.selectedColor = color;
		[UIView commitAnimations];
	}
	else 
	{
		self.selectedColor = color;
	}
}

- (void) setSelectedColorNoEvent:(UIColor *)c 
{
    [c retain];
    [selectedColor release];
    selectedColor = c;
    
    RGBType rgb = rgbWithUIColor(c);
    HSVType hsv = RGB_to_HSV(rgb);
    
    self.colorWheel.currentHSV = hsv;
    self.brightnessSlider.value = hsv.v;
    self.alphaSlider.value = [c alpha];
    
    UIColor *keyColor = [UIColor colorWithHue:hsv.h
                                   saturation:hsv.s
                                   brightness:1.0
                                        alpha:1.0];
    [self.brightnessSlider setKeyColor:keyColor];
    
    keyColor = [UIColor colorWithHue:hsv.h
                          saturation:hsv.s
                          brightness:hsv.v
                               alpha:1.0];
    [self.alphaSlider setKeyColor:keyColor];
    
    self.currentColorView.currentColor = c;
}

- (void) setSelectedColor:(UIColor *)c
{
	[c retain];
	[selectedColor release];
	selectedColor = c;
	
	RGBType rgb = rgbWithUIColor(c);
	HSVType hsv = RGB_to_HSV(rgb);
	
	self.colorWheel.currentHSV = hsv;
	self.brightnessSlider.value = hsv.v;
    self.alphaSlider.value = [c alpha];
	
    UIColor *keyColor = [UIColor colorWithHue:hsv.h 
                                   saturation:hsv.s
                                   brightness:1.0
                                        alpha:1.0];
	[self.brightnessSlider setKeyColor:keyColor];
    
    keyColor = [UIColor colorWithHue:hsv.h 
                          saturation:hsv.s
                          brightness:hsv.v
                               alpha:1.0];
    [self.alphaSlider setKeyColor:keyColor];
	
	self.currentColorView.currentColor = c;
    [self sendActionsForControlEvents:UIControlEventValueChanged];
}

- (void) colorWheelColorChanged:(KZColorPickerHSWheel *)wheel
{
	HSVType hsv = wheel.currentHSV;
    
    if(0==self.brightnessSlider.value)
    {
        self.brightnessSlider.value=0.1f;
    }
	self.selectedColor = [UIColor colorWithHue:hsv.h
									saturation:hsv.s
									brightness:self.brightnessSlider.value
										 alpha:self.alphaSlider.value];		
	
	//[self sendActionsForControlEvents:UIControlEventValueChanged];
}

- (void) brightnessChanged:(KZColorPickerBrightnessSlider *)slider
{
	HSVType hsv = self.colorWheel.currentHSV;
	
	self.selectedColor = [UIColor colorWithHue:hsv.h
									saturation:hsv.s
									brightness:self.brightnessSlider.value
										 alpha:self.alphaSlider.value];
	
	//[self sendActionsForControlEvents:UIControlEventValueChanged];
}

- (void) alphaChanged:(KZColorPickerAlphaSlider *)slider
{
	HSVType hsv = self.colorWheel.currentHSV;
	
	self.selectedColor = [UIColor colorWithHue:hsv.h
									saturation:hsv.s
									brightness:self.brightnessSlider.value
										 alpha:self.alphaSlider.value];
	
	//[self sendActionsForControlEvents:UIControlEventValueChanged];
}

- (void) swatchAction:(KZColorPickerSwatchView *)sender
{
	[self setSelectedColor:sender.color animated:YES];
	//[self sendActionsForControlEvents:UIControlEventValueChanged];
}



- (void) layoutSubviews
{
    [UIView beginAnimations:nil context:nil];
    
    [self fixLocations];
    
    [UIView commitAnimations];
}

@end
