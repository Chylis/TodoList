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

@property (weak, nonatomic) IBOutlet UITextField *titleTextField;
@property (weak, nonatomic) IBOutlet UITextView *descriptionTextView;

@end

@implementation MEAddTodoItemViewController

#pragma mark - Life cycle / Setup

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self prefillTextFields];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.titleTextField becomeFirstResponder];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.titleTextField resignFirstResponder];
    [self.descriptionTextView resignFirstResponder];

}

#pragma mark - Properties

-(void)setItem:(METodoListItem *)item
{
    _item = item;
    [self prefillTextFields];
}

#pragma mark - Helpers

-(void)prefillTextFields
{
    self.titleTextField.text = self.item.title;
    self.descriptionTextView.text = self.item.desc;
}

#pragma mark - IBActions/Callbacks
- (IBAction)saveButtonTapped:(id)sender
{
    METodoListItem *item = self.item ? : [METodoListItem new];
    item.title =  item.title = self.titleTextField.text;
    item.created = [NSDate date];
    item.desc = self.descriptionTextView.text;
    
    BOOL isEditingItem = self.item != nil;
    if (isEditingItem){
        [self.delegate MEAddTodoItemViewController:self didEditItem:item];
    } else {
        [self.delegate MEAddTodoItemViewController:self didCreateItem:item];
    }
}

- (IBAction)cancelButtonTapped:(id)sender
{
    [self.delegate MEAddTodoItemViewControllerDidCancelItemCreation:self];
}

@end
