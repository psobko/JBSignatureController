//
//  JBSignatureController.m
//  JBSignatureController
//
//  Created by Jesse Bunch on 12/10/11.
//  Copyright (c) 2011 Jesse Bunch. All rights reserved.
//

#import "JBSignatureController.h"
#import "JBSignatureView.h"




@interface JBSignatureController()

@property (nonatomic, strong) JBSignatureView *signatureView;
@property (nonatomic, strong) UIImageView *signaturePanelBackgroundImageView;
@property (nonatomic, strong) UIImage *portraitBackgroundImage, *landscapeBackgroundImage;
@property (nonatomic, strong) UIToolbar *toolbar;
@property(nonatomic,strong) UIBarButtonItem *confirmButton, *cancelButton, *flexibleItem;

-(void)pressConfirm;
-(void)pressCancel;

@end

@implementation JBSignatureController

@synthesize
signaturePanelBackgroundImageView,
signatureView,
portraitBackgroundImage,
landscapeBackgroundImage,
confirmButton,
cancelButton,
flexibleItem,
toolbar,
delegate;

#pragma mark - init methods
-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
	if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]))
    {
        
	}
	return self;
}
-(id)init
{
	return [self initWithNibName:nil bundle:nil];
}


#pragma mark - view methods
-(void)loadView
{
	self.view = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]];
	
	self.portraitBackgroundImage = [UIImage imageNamed:@"bg-signature-portrait"];
	self.landscapeBackgroundImage = [UIImage imageNamed:@"bg-signature-landscape"];
	self.signaturePanelBackgroundImageView = [[UIImageView alloc] initWithImage:self.portraitBackgroundImage];
    
	self.signatureView = [[JBSignatureView alloc] init];
	
    self.flexibleItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    self.confirmButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(pressConfirm) ];
	self.cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(pressCancel) ];
    
    self.toolbar = [[UIToolbar alloc] init];
    self.toolbar.frame = CGRectMake(0, 0, self.view.frame.size.width, 44);
    NSArray *toolbarItems = [[NSArray alloc] initWithObjects:self.cancelButton, flexibleItem, self.confirmButton, nil];
    [self.toolbar setItems:toolbarItems animated:NO];
}
-(void)viewDidLoad
{
	[self.signaturePanelBackgroundImageView setFrame:self.view.bounds];
	[self.signaturePanelBackgroundImageView setContentMode:UIViewContentModeTopLeft];
    [self.view addSubview:self.signaturePanelBackgroundImageView];
	
    [self.signatureView setFrame:self.view.bounds];
	[self.view addSubview:self.signatureView];
	
    [self.view addSubview:toolbar];
}
-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}
-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [self.signaturePanelBackgroundImageView setImage:self.portraitBackgroundImage];
    
	if (toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft ||
		toInterfaceOrientation == UIInterfaceOrientationLandscapeRight)
    {
		[self.signaturePanelBackgroundImageView setImage:self.landscapeBackgroundImage];
    }
}
-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
	[self.signatureView setFrame:self.view.bounds];
	[self.signatureView setNeedsDisplay];
}

#pragma mark - private methods
-(void)pressConfirm
{	
	if (self.delegate && [self.delegate respondsToSelector:@selector(signatureConfirmed:signatureController:)]) {
		UIImage *signatureImage = [self.signatureView getSignatureImage];
		[self.delegate signatureConfirmed:signatureImage signatureController:self];
	}
	
}
-(void)pressCancel
{
	if (self.delegate && [self.delegate respondsToSelector:@selector(signatureCancelled:)])
    {
		[self.delegate signatureCancelled:self];
	}
	
}

#pragma mark - public methods
-(void)clearSignature
{
	if (self.delegate && [self.delegate respondsToSelector:@selector(signatureCleared:signatureController:)])
    {
		UIImage *signatureImage = [self.signatureView getSignatureImage];
		[self.delegate signatureCleared:signatureImage signatureController:self];
	}
	[self.signatureView clearSignature];
}
@end