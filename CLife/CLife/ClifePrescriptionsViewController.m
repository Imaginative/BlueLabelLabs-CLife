//
//  ClifePrescriptionsViewController.m
//  CLife
//
//  Created by Jasjeet Gill on 8/9/12.
//  Copyright (c) 2012 Blue Label Solutions LLC. All rights reserved.
//

#import "ClifePrescriptionsViewController.h"
#import "ClifePrescriptionDetailsViewController.h"
#import "ClifeAppDelegate.h"
#import "Prescription.h"
#import "Attributes.h"
#import "Macros.h"

#define kMAXROWS 1000

@interface ClifePrescriptionsViewController ()

@end

@implementation ClifePrescriptionsViewController
@synthesize frc_prescriptions   = __frc_prescriptions;
@synthesize tbl_prescriptions   = m_tbl_prescriptions;


#pragma mark - Properties
- (NSFetchedResultsController*)frc_prescriptions {
    NSString* activityName = @"ClifePrescriptionsViewController.frc_prescriptions:";
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
    
    [fetchRequest setFetchBatchSize:kMAXROWS];
    
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

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"PRESCRIPTIONS", nil);
        self.tabBarItem.image = [UIImage imageNamed:@"icon-medical.png"];
    }
    return self;
}
							
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    // add the "+" button to the nav bar
    UIBarButtonItem* rightButton = [[UIBarButtonItem alloc]
                                    initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                    target:self
                                    action:@selector(onAddPrescriptionButtonPressed:)];
    self.navigationItem.rightBarButtonItem = rightButton;
    [rightButton release];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    
    self.tbl_prescriptions = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
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
    
    if (rows == 0) {
        rows = 1;   // Show "add prescription row"
    }
    
    return rows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *CellIdentifier;
    
    UITableViewCell *cell;
    
    NSInteger count = [[self.frc_prescriptions fetchedObjects]count];
    
    if (count > 0 && indexPath.row < count) {
        // Set prescription
        CellIdentifier = @"Prescription";
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        if (cell == nil) {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
            
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            
        }
        
        Prescription *prescription = [[self.frc_prescriptions fetchedObjects] objectAtIndex:indexPath.row];
        
        cell.textLabel.text = prescription.name;
        cell.imageView.image = [UIImage imageNamed:@"icon-pill.png"];
        
    }
    else {
        // Set None row
        CellIdentifier = @"NoPrescription";
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        if (cell == nil) {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
            
            cell.textLabel.text = @"Press '+' to add a prescription";
            
            cell.textLabel.textAlignment = UITextAlignmentCenter;
            cell.textLabel.shadowColor = [UIColor whiteColor];
            cell.textLabel.shadowOffset = CGSizeMake(0.0, 1.0);
            cell.textLabel.textColor = [UIColor lightGrayColor];
            
            cell.userInteractionEnabled = NO;
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
 [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
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
    
    Prescription *prescription = [[self.frc_prescriptions fetchedObjects] objectAtIndex:indexPath.row];
    
    ClifePrescriptionDetailsViewController *prescriptionDetailsVC = [ClifePrescriptionDetailsViewController createInstanceForPrescriptionWithID:prescription.objectid];
    
    [prescriptionDetailsVC setHidesBottomBarWhenPushed:YES];
    [self.navigationController pushViewController:prescriptionDetailsVC animated:YES];
}

#pragma mark - UI Action Methods
- (void)onAddPrescriptionButtonPressed:(id)sender {
    ClifePrescriptionDetailsViewController *prescriptionDetailsVC = [ClifePrescriptionDetailsViewController createInstanceForPrescriptionWithID:nil];
    
    UINavigationController *navigationcontroller = [[[UINavigationController alloc] initWithRootViewController:prescriptionDetailsVC] autorelease];
    [self.navigationController presentModalViewController:navigationcontroller animated:YES];
}

#pragma mark - NSFetchedResultsControllerDelegate methods
//- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
//{
//    [self.tbl_prescriptions beginUpdates];
//}
//
//- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
//{
//    [self.tbl_prescriptions endUpdates];
//}

- (void) controller:(NSFetchedResultsController *)controller 
    didChangeObject:(id)anObject
        atIndexPath:(NSIndexPath *)indexPath 
      forChangeType:(NSFetchedResultsChangeType)type 
       newIndexPath:(NSIndexPath *)newIndexPath {
    
    NSString* activityName = @"ClifePrescriptionsViewController.controller.didChangeObject:";
    
    if (type == NSFetchedResultsChangeDelete)
    {
//        LOG_CLIFEPRESCRIPTIONSVIEWCONTROLLER(0,@"%@ Received NSFetechedResultsChangeDelete notification",activityName);
    }
    
    if (controller == self.frc_prescriptions) {
//        LOG_CLIFEPRESCRIPTIONSVIEWCONTROLLER(0, @"%@Received a didChange message from a NSFetchedResultsController. %p", activityName, &controller);
        
        if (indexPath.row < kMAXROWS) {
            [self.tbl_prescriptions reloadData];
        }
    }
    else {
//        LOG_CLIFEPRESCRIPTIONSVIEWCONTROLLER(1, @"%@Received a didChange message from a NSFetchedResultsController that isnt mine. %p", activityName, &controller);
    }
}

#pragma mark - Static Initializers
+ (ClifePrescriptionsViewController *)createInstance {
    ClifePrescriptionsViewController *instance = [[ClifePrescriptionsViewController alloc] initWithNibName:@"ClifePrescriptionsViewController" bundle:nil];
    [instance autorelease];
    return instance;
}

@end
