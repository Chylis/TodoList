//
//  MEAddTodoItemViewController.m
//  TodoList
//
//  Created by Magnus Eriksson on 21/08/2015.
//  Copyright (c) 2015 MagnusEriksson. All rights reserved.
//

#import "MEAddTodoItemViewController.h"

#import "METodoListItem.h"

@interface MEAddTodoItemViewController ()

@end

@implementation MEAddTodoItemViewController

#pragma mark - Life cycle / Setup

- (void)viewDidLoad
{
    [super viewDidLoad];
}


#pragma mark - Properties

#pragma mark - IBActions/Callbacks
- (IBAction)saveButtonTapped:(id)sender
{
#warning - Create factory method
    METodoListItem *item = [METodoListItem new];
    item.title =  [NSString stringWithFormat:@"TestTitle %i", arc4random()%19];
    item.created = [NSDate date];
    item.desc = @"TestDescJapp many rows";
    [self.delegate MEAddTodoItemViewController:self didCreateItem:item];
}

- (IBAction)cancelButtonTapped:(id)sender
{
    [self.delegate MEAddTodoItemViewControllerDidCancelItemCreation:self];
}

@end
