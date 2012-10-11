//
//  ClifeFilterPrescriptionsViewController.m
//  CLife
//
//  Created by Jordan Gurrieri on 9/23/12.
//  Copyright (c) 2012 Blue Label Solutions LLC. All rights reserved.
//

#import "ClifeFilterPrescriptionsViewController.h"
#import "ClifeAppDelegate.h"
#import "Prescription.h"
#import "Attributes.h"
#import "Macros.h"
#import "ClifeFilterViewController.h"
#import "UIImage+UIImageCategory.h"

@interface ClifeFilterPrescriptionsViewController ()

@end

@implementation ClifeFilterPrescriptionsViewController
@synthesize frc_prescriptions   = __frc_prescriptions;
@synthesize allSelected         = m_allSelected;


#pragma mark - Properties
- (id)delegate {
    return m_delegate;
}

- (void)setDelegate:(id<ClifeFilterPrescriptionsViewControllerDelegate>)del
{
    m_delegate = del;
}

- (NSFetchedResultsController*)frc_prescriptions {
//    NSString* activityName = @"ClifePrescriptionsViewController.frc_prescriptions:";
    if (__frc_prescriptions != nil) {
        return __frc_prescriptions;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    ResourceContext* resourceContext = [ResourceContext instance];
    ClifeAppDelegate* app = (ClifeAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    NSEntityDescription *entityDescription  = [NSEntityDescription entityForName:PRESCRIPTION inManagedObjectContext:app.managedObjectContext];
    
    NSSortDescriptor* sortDescriptor = [[NSSortDescriptor alloc] initWithKey:NAME ascending:YES];
    
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    [fetchRequest setEntity:entityDescription];
    
//    [fetchRequest setFetchBatchSize:kMAXROWS];
    
    NSFetchedResultsController* controller = [[NSFetchedResultsController alloc]initWithFetchRequest:fetchRequest managedObjectContext:resourceContext.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    
    controller.delegate = self;
    self.frc_prescriptions = controller;
    
    NSError* error = nil;
    [controller performFetch:&error];
  	if (error != nil)
    {
//        LOG_CLIFEPRESCRIPTIONSVIEWCONTROLLER(1, @"%@Could not create instance of NSFetchedResultsController due to %@", activityName, [error userInfo]);
    }
    
    [controller release];
    [fetchRequest release];
    [sortDescriptor release];
    return __frc_prescriptions;
    
}

#pragma mark - Initialization

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.title = NSLocalizedString(@"PRESCRIPTIONS", nil);
    
    // add the "Select/Deselect All" button to the nav bar
    UIBarButtonItem* rightButton = [[UIBarButtonItem alloc]
                                    initWithTitle:NSLocalizedString(@"ALL", nil)
                                    style:UIBarButtonItemStylePlain
                                    target:self
                                    action:@selector(onSelectAllButtonPressed:)];
    self.navigationItem.rightBarButtonItem = rightButton;
    [rightButton release];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    NSInteger rows = [[self.frc_prescriptions fetchedObjects] count];
    
    return rows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        
    }
    
    NSInteger count = [[self.frc_prescriptions fetchedObjects]count];
    
    if (count > 0 && indexPath.row < count) {
        // Set prescription
        Prescription *prescription = [[self.frc_prescriptions fetchedObjects] objectAtIndex:indexPath.row];
        
        cell.textLabel.text = prescription.name;
        
        if ([prescription.method isEqualToString:NSLocalizedString(@"PILL", nil)]) {
            cell.imageView.image = [[UIImage imageNamed:@"icon-pill.png"] imageScaledToSize:CGSizeMake(34.0f, 34.0f)];
        }
        else if ([prescription.method isEqualToString:NSLocalizedString(@"LIQUID", nil)]) {
            cell.imageView.image = [[UIImage imageNamed:@"icon-liquid.png"] imageScaledToSize:CGSizeMake(34.0f, 34.0f)];
        }
        else if ([prescription.method isEqualToString:NSLocalizedString(@"CREAM", nil)]) {
            cell.imageView.image = [[UIImage imageNamed:@"icon-paste.png"] imageScaledToSize:CGSizeMake(34.0f, 34.0f)];
        }
        else if ([prescription.method isEqualToString:NSLocalizedString(@"SYRINGE", nil)]) {
            cell.imageView.image = [[UIImage imageNamed:@"icon-syringe.png"] imageScaledToSize:CGSizeMake(34.0f, 34.0f)];
        }
        else {
            cell.imageView.image = [[UIImage imageNamed:@"icon-pill.png"] imageScaledToSize:CGSizeMake(34.0f, 34.0f)];
        }
        
        // Mark the row as selected if this prescription is already in the list of selected prescriptions
        ClifeFilterViewController *filterViewController = (ClifeFilterViewController *)self.delegate;
        if ([filterViewController.filteredPrescriptions indexOfObject:prescription] != NSNotFound) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
        else {
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
        
    }
    
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSInteger count = [[self.frc_prescriptions fetchedObjects] count];
    
    if (indexPath.row < count) {
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        
        // Toggle the checkmark accessory on the cell
        cell.accessoryType = cell.accessoryType==UITableViewCellAccessoryCheckmark ? UITableViewCellAccessoryNone : UITableViewCellAccessoryCheckmark;
        
        // Add or remove the prescription from the list of selected prescriptions
        Prescription *prescription = [[self.frc_prescriptions fetchedObjects] objectAtIndex:indexPath.row];
        
        ClifeFilterViewController *filterViewController = (ClifeFilterViewController *)self.delegate;
        if (cell.accessoryType == UITableViewCellAccessoryCheckmark) {
            [filterViewController.filteredPrescriptions addObject:prescription];
        }
        else {
            [filterViewController.filteredPrescriptions removeObject:prescription];
        }
        
    }
}

#pragma mark - UI Action Methods
- (void)onSelectAllButtonPressed:(id)sender {
    // reset the filtered items
    ClifeFilterViewController *filterViewController = (ClifeFilterViewController *)self.delegate;
    [filterViewController.filteredPrescriptions removeAllObjects];
    
    NSInteger count = [[self.frc_prescriptions fetchedObjects] count];
    
    self.allSelected = !self.allSelected;
    
    for (int i = 0; i < count; i++) {
        // Toggle selection of each row in the table view
        UITableViewCell *cell = [(UITableView *)self.view cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
        
        if (self.allSelected == YES) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
            
            // Add the prescription to the list of selected prescriptions
            Prescription *prescription = [[self.frc_prescriptions fetchedObjects] objectAtIndex:i];
            [filterViewController.filteredPrescriptions addObject:prescription];
        }
        else {
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
    }
}

#pragma mark - Static Initializers
+ (ClifeFilterPrescriptionsViewController *)createInstance {
    ClifeFilterPrescriptionsViewController *instance = [[ClifeFilterPrescriptionsViewController alloc] initWithNibName:@"ClifeFilterPrescriptionsViewController" bundle:nil];
    [instance autorelease];
    
    return instance;
}

@end
