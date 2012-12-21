//
//  SignatureView.m
//  JBSignatureControl
//
//  Created by Jesse Bunch on 12/10/11.
//  Copyright (c) 2011 Jesse Bunch. All rights reserved.
//

#import "JBSignatureView.h"

@interface JBSignatureView()

@property (nonatomic, strong) NSMutableArray *handwritingCoords;
@property (nonatomic, weak) UIImage *currentSignatureImage;
@property (nonatomic) float lineWidth;
@property (nonatomic,strong) UIColor *foreColor;
@property (nonatomic) float signatureImageMargin;
@property (nonatomic) BOOL shouldCropSignatureImage;
@property (nonatomic) CGPoint lastTapPoint;

-(void)processPoint:(CGPoint)touchLocation;

@end

@implementation JBSignatureView

@synthesize 
handwritingCoords,
currentSignatureImage,
lineWidth,
foreColor,
signatureImageMargin,
shouldCropSignatureImage,
lastTapPoint;

#pragma mark - init methods

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
		self.handwritingCoords = [[NSMutableArray alloc] init];
		self.lineWidth = 5.0f;
		self.signatureImageMargin = 10.0f;
		self.shouldCropSignatureImage = YES;
		self.foreColor = [UIColor blackColor];
		self.backgroundColor = [UIColor clearColor];
		lastTapPoint = CGPointZero;
    }
    return self;
}

#pragma mark - draw methods

- (void)drawRect:(CGRect)rect {
	
	CGContextRef context = UIGraphicsGetCurrentContext();
	
	CGContextSetLineWidth(context, self.lineWidth);
	CGContextSetStrokeColorWithColor(context, [self.foreColor CGColor]);
	CGContextSetLineCap(context, kCGLineCapButt);
	CGContextSetLineJoin(context, kCGLineJoinRound);
	CGContextBeginPath(context);

	BOOL isFirstPoint = YES;
	
	for (NSString *touchString in self.handwritingCoords)
    {
		
		CGPoint tapLocation = CGPointFromString(touchString);
		
		if (CGPointEqualToPoint(tapLocation, CGPointZero))
        {
			isFirstPoint = YES;
			continue;
		}
		
		if (isFirstPoint)
        {
			CGContextMoveToPoint(context, tapLocation.x, tapLocation.y);
			isFirstPoint = NO;
		} else {
			CGPoint startPoint = CGContextGetPathCurrentPoint(context);
			CGContextAddQuadCurveToPoint(context, startPoint.x, startPoint.y, tapLocation.x, tapLocation.y);
			CGContextAddLineToPoint(context, tapLocation.x, tapLocation.y);
		}
		
	}	

	CGContextStrokePath(context);

}

#pragma mark - touch methods

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {}
-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
	UITouch *touch = [touches anyObject];
	CGPoint touchLocation = [touch locationInView:self];
	
	[self processPoint:touchLocation];
}
-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	[self.handwritingCoords addObject:NSStringFromCGPoint(CGPointZero)];	
}
-(void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
	[self.handwritingCoords addObject:NSStringFromCGPoint(CGPointZero)];
}

#pragma mark - private methods

-(void)processPoint:(CGPoint)touchLocation
{
	if (CGPointEqualToPoint(CGPointZero, lastTapPoint) || 
		fabs(touchLocation.x - lastTapPoint.x) > 2.0f ||
		fabs(touchLocation.y - lastTapPoint.y) > 2.0f) {
		
		[self.handwritingCoords addObject:NSStringFromCGPoint(touchLocation)];
		[self setNeedsDisplay];
		lastTapPoint = touchLocation;
		
	}
	
}


#pragma mark - public methods

-(UIImage *)getSignatureImage
{
	UIGraphicsBeginImageContext(self.bounds.size);
	[self drawRect: self.bounds];
	UIImage *signatureImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();

	if (!self.shouldCropSignatureImage)
    {
		return signatureImage;
	}
	
	float minX = 99999999.0f, minY = 999999999.0f, maxX = 0.0f, maxY = 0.0f;
	
	for (NSString *touchString in self.handwritingCoords)
    {
		CGPoint tapLocation = CGPointFromString(touchString);
		
		if (CGPointEqualToPoint(tapLocation, CGPointZero))
        {
			continue;
		}
		
		if (tapLocation.x < minX) minX = tapLocation.x;
		if (tapLocation.x > maxX) maxX = tapLocation.x;
		if (tapLocation.y < minY) minY = tapLocation.y;
		if (tapLocation.y > maxY) maxY = tapLocation.y;
		
	}
	
	CGRect cropRect = CGRectMake(minX - lineWidth - self.signatureImageMargin,
								 minY - lineWidth - self.signatureImageMargin,
								 maxX - minX + (lineWidth * 2.0f) + (self.signatureImageMargin * 2.0f), 
								 maxY - minY + (lineWidth * 2.0f) + (self.signatureImageMargin * 2.0f));

	CGImageRef imageRef = CGImageCreateWithImageInRect([signatureImage CGImage], cropRect);
	
	UIImage *signatureImageCropped = [UIImage imageWithCGImage:imageRef];

	CFRelease(imageRef);
	return signatureImageCropped;	
}
-(void)clearSignature
{
	[self.handwritingCoords removeAllObjects];
	[self setNeedsDisplay];
}


@end
