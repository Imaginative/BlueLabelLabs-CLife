//
//  ClifeRemindersViewController.m
//  CLife
//
//  Created by Jordan Gurrieri on 9/13/12.
//  Copyright (c) 2012 Blue Label Solutions LLC. All rights reserved.
//

#import "ClifeRemindersViewController.h"
#import "ClifeAppDelegate.h"
#import "Attributes.h"
#import "PrescriptionInstance.h"
#import "PrescriptionInstanceState.h"
#import "DateTimeHelper.h"

#define kTABLEVIEWCELLHEIGHT 50.0

@interface ClifeRemindersViewController ()

@end

@implementation ClifeRemindersViewController
@synthesize frc_prescriptionInstances      = __frc_prescriptionInstances;
@synthesize tbl_reminders                  = m_tbl_reminders;

#pragma mark - Properties
- (NSFetchedResultsController*)frc_prescriptionInstances {
    NSString* activityName = @"ClifeRemindersViewController.frc_prescriptionInstances:";
    if (__frc_prescriptionInstances != nil) {
        return __frc_prescriptionInstances;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    ResourceContext* resourceContext = [ResourceContext instance];
    ClifeAppDelegate* app = (ClifeAppDelegate*)[[UIApplication sharedApplication]delegate];
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:PRESCRIPTIONINSTANCE inManagedObjectContext:app.managedObjectContext];
    
    NSSortDescriptor* sortDescriptor = [[NSSortDescriptor alloc] initWithKey:DATESCHEDULED ascending:YES];
    
    double doubleDate = [[NSDate date] timeIntervalSince1970];
    NSNumber *today = [NSNumber numberWithDouble:doubleDate];
    
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"%K>%@", DATESCHEDULED, today];
    
    [fetchRequest setPredicate:predicate];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    [fetchRequest setEntity:entityDescription];
    [fetchRequest setReturnsDistinctResults:YES];
    
    NSFetchedResultsController* controller = [[NSFetchedResultsController alloc]initWithFetchRequest:fetchRequest managedObjectContext:resourceContext.managedObjectContext sectionNameKeyPath:@"scheduleDateString" cacheName:@"Reminders"];
    
    controller.delegate = self;
    self.frc_prescriptionInstances = controller;
    
    NSError* error = nil;
    [controller performFetch:&error];
  	if (error != nil)
    {
        NSLog(@"%@ Could not create instance of NSFetchedResultsController due to %@", activityName, [error userInfo]);
    }
    
    [controller release];
    [fetchRequest release];
    [sortDescriptor release];
    return __frc_prescriptionInstances;
    
}

#pragma mark - Initialization

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = NSLocalizedString(@"REMINDERS", nil);
        self.tabBarItem.image = [UIImage imageNamed:@"icon-calendar.png"];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    
    self.tbl_reminders = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    
    NSInteger sections = [[self.frc_prescriptionInstances sections] count];
    
    return sections;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    
    NSInteger rows = 0;
    
    if ([[self.frc_prescriptionInstances sections] count] > 0) {
        id <NSFetchedResultsSectionInfo> sectionInfo = [[self.frc_prescriptionInstances sections] objectAtIndex:section];
        rows = [sectionInfo numberOfObjects];
    }
    
    return rows;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSInteger sections = [[self.frc_prescriptionInstances sections] count];
    
    if (sections == 0) {
        return nil;
    }
    else if (section == 0) {
        // Determine if the section header matches today's date
        
        id <NSFetchedResultsSectionInfo> sectionInfo = [[self.frc_prescriptionInstances sections] objectAtIndex:section];
        NSString* date = [sectionInfo name];
        
        // Setup date formatter
        NSDateFormatter *dateOnlyFormatter = [[[NSDateFormatter alloc] init] autorelease];
        [dateOnlyFormatter setDateStyle:NSDateFormatterLongStyle];
        [dateOnlyFormatter setTimeStyle:NSDateFormatterNoStyle];
        
        NSString* today = [dateOnlyFormatter stringFromDate:[NSDate date]];
        
        if ([today isEqualToString:[sectionInfo name]]) {
            return NSLocalizedString(@"TODAY", nil);
        }
        else {
            return date;
        }
    }
    else {
        id <NSFetchedResultsSectionInfo> sectionInfo = [[self.frc_prescriptionInstances sections] objectAtIndex:section];
        NSString* date = [sectionInfo name];
        return date;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *CellIdentifier;
    UITableViewCell *cell;
    
    NSInteger sections = [[self.frc_prescriptionInstances sections] count];
    
    NSInteger rows = 0;
    if (sections > 0) {
        id <NSFetchedResultsSectionInfo> sectionInfo = [[self.frc_prescriptionInstances sections] objectAtIndex:indexPath.section];
        rows = [sectionInfo numberOfObjects];
    }
    
    if (sections > 0 && rows > 0 && indexPath.section < sections && indexPath.row < rows) {
        // Set prescriptionInstance
        
        CellIdentifier = @"PrescriptionInstance";
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        if (cell == nil) {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
            
            cell.accessoryType = UITableViewCellAccessoryNone;
            
            [cell setSelectionStyle:UITableViewCellEditingStyleNone];
            
        }
        
        PrescriptionInstance *prescriptionInstance = [self.frc_prescriptionInstances objectAtIndexPath:indexPath];
        
        cell.textLabel.text = prescriptionInstance.prescriptionname;
        
        // Setup date formatter
        NSDateFormatter *dateAndTimeFormatter = [[[NSDateFormatter alloc] init] autorelease];
        [dateAndTimeFormatter setDateStyle:NSDateFormatterMediumStyle];
        [dateAndTimeFormatter setTimeStyle:NSDateFormatterShortStyle];
        
        NSDate *scheduleDate = [DateTimeHelper parseWebServiceDateDouble:prescriptionInstance.datescheduled];
        cell.detailTextLabel.text = [dateAndTimeFormatter stringFromDate:scheduleDate];
        
        cell.imageView.image = [UIImage imageNamed:@"icon-pill.png"];
    }
    else {
        // Set None row
        CellIdentifier = @"NoPrescriptionInstance";
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        if (cell == nil) {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
            
            cell.textLabel.text = @"No reminders";
            
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
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return kTABLEVIEWCELLHEIGHT;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
//    PrescriptionInstance *prescriptionInstance = [self.frc_prescriptionInstances objectAtIndexPath:indexPath];
//    
//    ClifeHistoryDetailsViewController *historyDetailsVC = [ClifeHistoryDetailsViewController createInstanceForPrescriptionInstanceWithID:prescriptionInstance.objectid];
//    
//    [historyDetailsVC setHidesBottomBarWhenPushed:YES];
//    [self.navigationController pushViewController:historyDetailsVC animated:YES];
}

#pragma mark - NSFetchedResultsControllerDelegate methods
//- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
//{
//    [self.tbl_reminders beginUpdates];
//}
//
//- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
//{
//    [self.tbl_reminders endUpdates];
//}

- (void) controller:(NSFetchedResultsController *)controller 
    didChangeObject:(id)anObject
        atIndexPath:(NSIndexPath *)indexPath 
      forChangeType:(NSFetchedResultsChangeType)type 
       newIndexPath:(NSIndexPath *)newIndexPath {
    
    NSString* activityName = @"ClifeRemindersViewController.controller.didChangeObject:";
    
    if (controller == self.frc_prescriptionInstances) {
        [self.tbl_reminders reloadData];
    }
    else {
        NSLog(@"%@Received a didChange message from a NSFetchedResultsController that isnt mine. %p", activityName, &controller);
    }
}

#pragma mark - Static Initializers
+ (ClifeRemindersViewController *)createInstance {
    ClifeRemindersViewController *instance = [[ClifeRemindersViewController alloc] initWithNibName:@"ClifeRemindersViewController" bundle:nil];
    [instance autorelease];
    return instance;
}

@end
