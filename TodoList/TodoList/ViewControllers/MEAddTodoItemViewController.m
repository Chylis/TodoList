//
//  MEAddTodoItemViewController.m
//  TodoList
//
//  Created by Magnus Eriksson on 21/08/2015.
//  Copyright (c) 2015 MagnusEriksson. All rights reserved.
//

#import "MEAddTodoItemViewController.h"

#import "METodoListItem.h"

@interface MEAddTodoItemViewController () <UITextViewDelegate>

@property (weak, nonatomic) IBOutlet UITextView *descriptionTextView;

@end

@implementation MEAddTodoItemViewController


#pragma mark - Life cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self updateUI];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.descriptionTextView becomeFirstResponder];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.descriptionTextView resignFirstResponder];
}

#pragma mark - Properties

-(void)setItem:(METodoListItem *)item
{
    _item = item;
    [self updateUI];
}

#pragma mark - Helpers

-(void)updateUI
{
    dispatch_async(dispatch_get_main_queue(), ^{
        self.title = self.item ? @"Edit item" : @"New item";
        self.descriptionTextView.text = self.item.content;
        [self updateSaveButtonEnabledState];
    });
}

-(void)updateSaveButtonEnabledState
{
    self.navigationItem.rightBarButtonItem.enabled = self.descriptionTextView.text.length > 0;
}

#pragma mark - UITextViewDelegate

-(void)textViewDidChange:(UITextView *)textView
{
    [self updateSaveButtonEnabledState];
}

#pragma mark - IBActions/Callbacks

- (IBAction)saveButtonTapped:(id)sender
{
    METodoListItem *item = self.item ? : [METodoListItem new];
    item.content = self.descriptionTextView.text;
    
    BOOL isEditingItem = self.item != nil;
    if (isEditingItem){
        [self.delegate MEAddTodoItemViewController:self didEditItem:item];
    } else {
        [self.delegate MEAddTodoItemViewController:self didCreateItem:item];
    }
}

- (IBAction)cancelButtonTapped:(id)sender
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    });
}

@end
