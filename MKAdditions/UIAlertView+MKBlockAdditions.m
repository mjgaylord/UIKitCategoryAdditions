//
//  UIAlertView+MKBlockAdditions.m
//  UIKitCategoryAdditions
//
//  Created by Mugunth on 21/03/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "UIAlertView+MKBlockAdditions.h"

static DismissBlock _dismissBlock;
static CancelBlock _cancelBlock;

@implementation UIAlertView (Block)

+ (UIAlertView*) alertViewWithTitle:(NSString*) title
							message:(NSString*) message
				  cancelButtonTitle:(NSString*) cancelButtonTitle
				  otherButtonTitles:(NSArray*) otherButtons
						  onDismiss:(DismissBlock) dismissed
						   onCancel:(CancelBlock) cancelled {
    
    [_cancelBlock release];
    _cancelBlock  = [cancelled copy];
	
    [_dismissBlock release];
    _dismissBlock  = [dismissed copy];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                    message:message
                                                   delegate:[self class]
                                          cancelButtonTitle:cancelButtonTitle
                                          otherButtonTitles:nil];
    
    for(NSString *buttonTitle in otherButtons)
        [alert addButtonWithTitle:buttonTitle];
    
    [alert show];
    return [alert autorelease];
}

+ (UIAlertView*) alertViewWithTitle:(NSString*) title
							message:(NSString*) message {
    
    return [UIAlertView alertViewWithTitle:title
                                   message:message
                         cancelButtonTitle:NSLocalizedString(@"Dismiss", @"")];
}

+ (UIAlertView*) alertViewWithTitle:(NSString*) title
							message:(NSString*) message
				  cancelButtonTitle:(NSString*) cancelButtonTitle {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                    message:message
                                                   delegate:nil
                                          cancelButtonTitle:cancelButtonTitle
                                          otherButtonTitles: nil];
    [alert show];
    return [alert autorelease];
}


+ (void)alertView:(UIAlertView*) alertView didDismissWithButtonIndex:(NSInteger) buttonIndex {
    
	if(buttonIndex == [alertView cancelButtonIndex] && _cancelBlock) {
		_cancelBlock();
	} else if (_dismissBlock) {
        _dismissBlock(buttonIndex - 1); // cancel button is button 0
	}
    Block_release(_cancelBlock);
    Block_release(_dismissBlock);
	_cancelBlock = _dismissBlock = nil;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	if(buttonIndex == [alertView cancelButtonIndex] && _cancelBlock){
		_cancelBlock();
	} else if (_dismissBlock) {
        _dismissBlock(buttonIndex - 1); // cancel button is button 0
    }
    
    Block_release(_cancelBlock);
    Block_release(_dismissBlock);
	_cancelBlock = _dismissBlock = nil;
	
}

- (void) show:(CancelBlock) cancelBlock onDismiss:(DismissBlock) dismissedBlock {
	self.delegate = self;
	Block_release(_cancelBlock);
	_cancelBlock = Block_copy(cancelBlock);
	Block_release(_dismissBlock);
	_dismissBlock = Block_copy(dismissedBlock);
	[self show];
}

@end
