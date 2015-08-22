//
//  METodoListViewController.h
//  TodoList
//
//  Created by Magnus Eriksson on 21/08/2015.
//  Copyright (c) 2015 MagnusEriksson. All rights reserved.
//

#import "METodoListViewController.h"
#import "MEAddTodoItemViewController.h"

#import "METodoListItem.h"

#import "METodoListItemTableViewCell.h"

#import "NSUserDefaults+METodoListItems.h"

typedef NS_ENUM(NSInteger, METodoListSection)
{
    METodoListSectionIncompleted = 0,
    METodoListSectionCompleted,
    METodoListSectionCount
};

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
    NSString *cellId = NSStringFromClass([METodoListItemTableViewCell class]);
    UINib *nib = [UINib nibWithNibName:cellId bundle:nil];
    [self.tableView registerNib:nib forCellReuseIdentifier:cellId];
    
    self.tableView.allowsSelectionDuringEditing = YES;
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
    METodoListItemTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([METodoListItemTableViewCell class]) forIndexPath:indexPath];
    cell.showsReorderControl = YES;
    
    switch (indexPath.section) {
        case METodoListSectionIncompleted:
            [self configureIncompleteTodoListItemCell:cell atIndexPath:indexPath];
            break;
        case METodoListSectionCompleted:
            [self configureCompletedTodoListItemCell:cell atIndexPath:indexPath];
            break;
        default:
            break;
    }
    
    return cell;
}

-(void)configureIncompleteTodoListItemCell:(METodoListItemTableViewCell*)cell atIndexPath:(NSIndexPath*)indexPath
{
    METodoListItem *item = [self itemAtIndexPath:indexPath];
    cell.titleLabel.text = item.title;
    cell.createdLabel.text = [item.created description];
    cell.descLabel.text = item.desc;
    cell.accessoryType = UITableViewCellAccessoryNone;
}

-(void)configureCompletedTodoListItemCell:(METodoListItemTableViewCell*)cell atIndexPath:(NSIndexPath*)indexPath
{
    METodoListItem *item = [self itemAtIndexPath:indexPath];
    cell.titleLabel.text = item.title;
    cell.createdLabel.text = [item.created description];
    cell.descLabel.text = item.desc;
    cell.accessoryType = UITableViewCellAccessoryCheckmark;
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
                                                METodoListItem *item = [self itemAtIndexPath:indexPath];
                                                [self editItem:item];
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
    METodoListItem *item = [self itemAtIndexPath:indexPath];
    if (self.isEditing){
        [self editItem:item];
    } else {
        item.completed = !item.completed;
    }
}

#pragma mark - Navigation

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:NSStringFromClass([MEAddTodoItemViewController class])]){
        UINavigationController *destVc = segue.destinationViewController;
        MEAddTodoItemViewController *addItemVc = (MEAddTodoItemViewController*)destVc.topViewController;
        [self configureAddItemViewController:addItemVc sender:sender];
    }
}

-(void)configureAddItemViewController:(MEAddTodoItemViewController*)vc sender:(id)sender
{
    vc.delegate = self;
    
    if ([sender isMemberOfClass:[METodoListItem class]]){
        vc.item = sender;
    }
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

-(void)MEAddTodoItemViewControllerDidCancelItemCreation:(MEAddTodoItemViewController *)vc
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [vc.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    });
}

#pragma mark - Helpers

-(void)editItem:(METodoListItem*)item
{
    [self performSegueWithIdentifier:NSStringFromClass([MEAddTodoItemViewController class]) sender:item];
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
