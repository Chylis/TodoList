//
//  METodoListViewController.h
//  TodoList
//
//  Created by Magnus Eriksson on 21/08/2015.
//  Copyright (c) 2015 MagnusEriksson. All rights reserved.
//

#import "METodoListViewController.h"
#import "MEAddTodoItemViewController.h"
#import "MEPopoverNavigationController.h"

#import "METodoListItem.h"

#import "NSUserDefaults+METodoListItems.h"

typedef NS_ENUM(NSInteger, METodoListSection)
{
    METodoListSectionIncompleted = 0,
    METodoListSectionCompleted,
    METodoListSectionCount
};

static NSString *const CellIdentifierMETodoListCell = @"CellIdentifierMETodoListCell";

@interface METodoListViewController () <UITableViewDataSource, UITableViewDelegate, MEAddTodoItemViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) NSMutableArray *completedItems; //Array of METodoListItem
@property (strong, nonatomic) NSMutableArray *incompletedItems; //Array of METodoListItem

@property (strong, nonatomic) NSIndexPath *indexPathOfReorderDestination;

@end

@implementation METodoListViewController

#pragma mark - Life cycle / Setup

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self loadStoredDatasource];
    [self setupTableView];
    self.navigationItem.leftBarButtonItem = self.editButtonItem;
}

-(void)loadStoredDatasource
{
    self.completedItems = [[NSMutableArray alloc] initWithArray:[NSUserDefaults completedTodoItems]];
    self.incompletedItems = [[NSMutableArray alloc] initWithArray:[NSUserDefaults incompletedTodoItems]];
}

-(void)setupTableView
{
    //Prepare for self sizing cells
    static const int DefaultRowHeight = 44;
    self.tableView.estimatedRowHeight = DefaultRowHeight;
    
    //Register Cell
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:CellIdentifierMETodoListCell];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self observeTodoItemUpdates];
}

-(void)observeTodoItemUpdates
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(METodoItemWasUpdated:)
                                                 name:NOTIFICATION_METodoListItemDidToggleCompleted
                                               object:nil];;
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Properties

-(void)setEditing:(BOOL)editing animated:(BOOL)animated
{
    [super setEditing:editing animated:animated];
    [self.tableView setEditing:editing animated:animated];
}

#pragma mark - UITableViewDataSource

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return METodoListSectionCount;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case METodoListSectionIncompleted:      return self.incompletedItems.count;
        case METodoListSectionCompleted:        return self.completedItems.count;
        default:                                return 0;
    }
}

-(NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return section == METodoListSectionIncompleted ? @"To do" : @"Completed";
}

#pragma mark - UITableViewDelegate

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifierMETodoListCell
                                                            forIndexPath:indexPath];
    [self configureTodoListItemCell:cell atIndexPath:indexPath];
    return cell;
}

-(void)configureTodoListItemCell:(UITableViewCell*)cell atIndexPath:(NSIndexPath*)indexPath
{
    METodoListItem *item = [self itemAtIndexPath:indexPath];
    cell.textLabel.text = item.content;
    cell.accessoryType = item.completed ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
 
    cell.showsReorderControl = YES;
    cell.textLabel.numberOfLines = 0;
}

-(void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
    NSMutableArray *datasource = [self datasourceFromSection:fromIndexPath.section];
    METodoListItem *item = [datasource objectAtIndex:fromIndexPath.row];
    
    if (fromIndexPath.section == toIndexPath.section){
        //Item dragged within same section - update underlying model location
        [datasource removeObjectAtIndex:fromIndexPath.row];
        [datasource insertObject:item atIndex:toIndexPath.row];
        [self saveState];
    } else {
        //Item dragged to different section - save destination indexpath and toggle completed property
        self.indexPathOfReorderDestination = toIndexPath;
        item.completed = !item.completed;
    }
}

-(NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewRowAction *deleteItemAction = [self actionDeleteItemAtIndexPath:indexPath];
    UITableViewRowAction *editItemAction = [self actionEditItemAtIndexPath:indexPath];
    return @[deleteItemAction, editItemAction];
}

-(UITableViewRowAction*)actionEditItemAtIndexPath:(NSIndexPath*)indexPath
{
    return [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal
                                              title:NSLocalizedString(@"Edit", nil)
                                            handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
                                                [self editItemAtIndexPath:indexPath];
                                            }];
}
-(UITableViewRowAction*)actionDeleteItemAtIndexPath:(NSIndexPath*)indexPath
{
    return [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive
                                              title:NSLocalizedString(@"Delete", nil)
                                            handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
                                                METodoListItem *item = [self itemAtIndexPath:indexPath];
                                                [self deleteItem:item fromSection:indexPath.section];
                                                [self saveState];
                                            }];
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    //Implemented to enable tableviewcell-swiping
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.isEditing){
        [self editItemAtIndexPath:indexPath];
    } else {
        METodoListItem *item = [self itemAtIndexPath:indexPath];
        item.completed = !item.completed;
    }
}

#pragma mark - Navigation

- (IBAction)addItemButtonTapped:(UIBarButtonItem *)sender
{
    [self navigateToAddTodoItemViewController:sender];
}

-(void)navigateToAddTodoItemViewController:(id)sender
{
    //Create AddItemVC
    MEAddTodoItemViewController *addItemVc = [self.storyboard instantiateViewControllerWithIdentifier:NSStringFromClass([MEAddTodoItemViewController class])];
    addItemVc.delegate = self;
    
    //Create PopoverNavCtrl
    MEPopoverNavigationController *navCtlr = [self.storyboard instantiateViewControllerWithIdentifier:NSStringFromClass([MEPopoverNavigationController class])];
    [navCtlr setViewControllers:@[addItemVc]];
    
    if ([sender isKindOfClass:[UIBarButtonItem class]]){
        navCtlr.popoverPresentationController.barButtonItem = sender;
    } else {
        NSIndexPath *indexPathOfSender = (NSIndexPath*)sender;
        METodoListItem *item = [self itemAtIndexPath:indexPathOfSender];
        addItemVc.item = item;
        
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPathOfSender];
        navCtlr.popoverPresentationController.sourceView = cell;
        navCtlr.popoverPresentationController.permittedArrowDirections = UIPopoverArrowDirectionDown | UIPopoverArrowDirectionUp;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self presentViewController:navCtlr animated:YES completion:nil];
    });
}

#pragma mark - MEAddTodoItemViewControllerDelegate

-(void)MEAddTodoItemViewController:(MEAddTodoItemViewController *)vc didCreateItem:(METodoListItem *)item
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [vc.presentingViewController dismissViewControllerAnimated:YES completion:^{
            [self addItem:item toSection:METodoListSectionIncompleted];
            [self saveState];
        }];
    });
}

-(void)MEAddTodoItemViewController:(MEAddTodoItemViewController *)vc didEditItem:(METodoListItem *)item
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
        [vc.presentingViewController dismissViewControllerAnimated:YES completion:^{
            [self saveState];
        }];
    });
}

#pragma mark - Helpers

-(void)editItemAtIndexPath:(NSIndexPath*)indexPath
{
    [self navigateToAddTodoItemViewController:indexPath];
}

-(void)deleteItem:(METodoListItem*)item fromSection:(NSInteger)section
{
    //Update data source
    NSMutableArray *datasource = [self datasourceFromSection:section];
    NSUInteger row = [datasource indexOfObject:item];
    [datasource removeObject:item];
    
    if ([self.tableView numberOfRowsInSection:section] != datasource.count){
        //Model-view mismatch - update view
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:section];
        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}

-(void)addItem:(METodoListItem*)item toSection:(NSInteger)section
{
    [self insertItem:item intoIndexPath:[NSIndexPath indexPathForRow:0 inSection:section]];
}

-(void)insertItem:(METodoListItem*)item intoIndexPath:(NSIndexPath*)indexPath
{
    //Update data source
    NSMutableArray *datasource = [self datasourceFromSection:indexPath.section];
    [datasource insertObject:item atIndex:indexPath.row];
    
    if ([self.tableView numberOfRowsInSection:indexPath.section] != datasource.count){
        //Model-view mismatch - update view
        [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else {
        [self.tableView reloadData];
    }
}

-(METodoListItem*)itemAtIndexPath:(NSIndexPath*)indexPath
{
    NSArray *datasource = [self datasourceFromSection:indexPath.section];
    return [datasource objectAtIndex:indexPath.item];
}

-(NSMutableArray*)datasourceFromSection:(NSInteger)section
{
    return section == METodoListSectionIncompleted ? self.incompletedItems : self.completedItems;
}

-(void)saveState
{
    [NSUserDefaults updateIncompetedTodoItems:self.incompletedItems];
    [NSUserDefaults updateCompletedTodoItems:self.completedItems];
}


/*
 - Triggered when the 'METodoItem.completed' property is updated
 - Updates data source and UI: moves the cell from one section to the other, depending on the 'item.completed' value
 - Updates local storage
 */
-(void)METodoItemWasUpdated:(NSNotification*)notification
{
    METodoListItem *item = notification.object;
    NSInteger sourceSection = item.completed ? METodoListSectionIncompleted : METodoListSectionCompleted;
    NSInteger destinationSection = item.completed ? METodoListSectionCompleted : METodoListSectionIncompleted;
    
    [CATransaction begin];
    
    [CATransaction setCompletionBlock:^{
        if (self.indexPathOfReorderDestination){
            //User dragged item to new section - Insert item in specified indexpath
            [self insertItem:item intoIndexPath:self.indexPathOfReorderDestination];
            self.indexPathOfReorderDestination = nil;
        } else {
            //User toggled item.complete - append item to destination section
            [self addItem:item toSection:destinationSection];
        }

        [self saveState];
    }];
    
    //Remove item from source section
    [self deleteItem:item fromSection:sourceSection];
    
    
    [CATransaction commit];
}


@end
