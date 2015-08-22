//
//  MEAddTodoItemViewController.h
//  TodoList
//
//  Created by Magnus Eriksson on 21/08/2015.
//  Copyright (c) 2015 MagnusEriksson. All rights reserved.
//

#import <UIKit/UIKit.h>
@class METodoListItem;
@class MEAddTodoItemViewController;

@protocol MEAddTodoItemViewControllerDelegate <NSObject>
@required
-(void)MEAddTodoItemViewController:(MEAddTodoItemViewController*)vc didCreateItem:(METodoListItem*)item;
-(void)MEAddTodoItemViewController:(MEAddTodoItemViewController*)vc didEditItem:(METodoListItem*)item;
@end

@interface MEAddTodoItemViewController : UIViewController

@property (strong, nonatomic) METodoListItem *item;
@property (weak, nonatomic) id<MEAddTodoItemViewControllerDelegate> delegate;

@end
