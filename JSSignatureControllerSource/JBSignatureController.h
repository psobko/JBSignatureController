//
//  JBSignatureController.h
//  JBSignatureController
//
//  Created by Jesse Bunch on 12/10/11.
//  Copyright (c) 2011 Jesse Bunch. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol JBSignatureControllerDelegate;

@interface JBSignatureController : UIViewController

@property(nonatomic,weak) id<JBSignatureControllerDelegate> delegate;
-(void)clearSignature;
@end

@protocol JBSignatureControllerDelegate <NSObject>

@required
-(void)signatureConfirmed:(UIImage *)signatureImage signatureController:(JBSignatureController *)sender;

@optional
-(void)signatureCancelled:(JBSignatureController *)sender;
-(void)signatureCleared:(UIImage *)clearedSignatureImage signatureController:(JBSignatureController *)sender;

@end