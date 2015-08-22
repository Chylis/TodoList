//
//  MEPopoverNavigationController.m
//  TodoList
//
//  Created by Magnus Eriksson on 22/08/2015.
//  Copyright (c) 2015 MagnusEriksson. All rights reserved.
//

#import "MEPopoverNavigationController.h"

#define MEPopoverNavigationControllerWidth [UIScreen mainScreen].applicationFrame.size.width
#define MEPopoverNavigationControllerWidthHidden 50
#define MEPopoverNavigationControllerHeight 200
#define MEPopoverNavigationControllerHeightHidden 50

@implementation MEPopoverNavigationController

#pragma mark - Init

-(instancetype)init
{
    self = [super init];
    if (self){
        [self commonInit];
    }
    return self;
}

-(instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self){
        [self commonInit];
    }
    return self;
}

-(instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self){
        [self commonInit];
    }
    return self;
}

-(void)commonInit
{
    self.modalInPopover = YES;
    self.modalPresentationStyle = UIModalPresentationPopover;
    self.popoverPresentationController.delegate = self;
}

#pragma mark - Life cycle

-(void)viewDidLoad
{
    [super viewDidLoad];
    self.preferredContentSize = CGSizeMake(MEPopoverNavigationControllerWidthHidden, MEPopoverNavigationControllerHeightHidden);
}

-(void)viewDidAppear:(BOOL)animated
{
    [self animatePresentation:^{
        [super viewDidAppear:animated];
    }];
}

#pragma mark - Private

-(void)animatePresentation:(void (^)(void))completion
{
    [self animateWidth:MEPopoverNavigationControllerWidth
                height:MEPopoverNavigationControllerHeight
              duration:0.1
            completion:completion];
}

-(void)animateWidth:(CGFloat)width height:(CGFloat)height duration:(CGFloat)duration completion:(void (^)(void))completion
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [CATransaction begin];
        if (completion){ [CATransaction setCompletionBlock:completion]; }
        [CATransaction setAnimationDuration:duration];
        self.preferredContentSize = CGSizeMake(width, height);
        [CATransaction commit];
    });
}

#pragma mark - UIPopoverPresentationControllerDelegate

- (UIModalPresentationStyle)adaptivePresentationStyleForPresentationController:(UIPresentationController *)controller
{
    return UIModalPresentationNone;
}

@end
