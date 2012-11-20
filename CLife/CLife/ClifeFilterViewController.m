//
//  ClifeFilterViewController.m
//  CLife
//
//  Created by Jordan Gurrieri on 9/21/12.
//  Copyright (c) 2012 Blue Label Solutions LLC. All rights reserved.
//

#import "ClifeFilterViewController.h"
#import "Prescription.h"
#import "ClifeHistoryViewController.h"

@interface ClifeFilterViewController ()

@end

@implementation ClifeFilterViewController
@synthesize sectionsArray               = m_sectionsArray;
@synthesize filteredPrescriptions       = m_filteredPrescriptions;
@synthesize filterDateStart             = m_filterDateStart;
@synthesize filterDateEnd               = m_filterDateEnd;
@synthesize periodTextLabel             = m_periodTextLabel;
@synthesize selectedPeriodIndex         = m_selectedPeriodIndex;

#pragma mark - Properties
- (id)delegate {
    return m_delegate;
}

- (void)setDelegate:(id<ClifeFilterViewControllerDelegate>)del
{
    m_delegate = del;
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
    
    self.navigationItem.title = NSLocalizedString(@"FILTER", nil);
    
    // Setup array of values
    self.sectionsArray = [NSArray arrayWithObjects:
                          NSLocalizedString(@"PRESCRIPTIONS", nil),
                          NSLocalizedString(@"PERIOD", nil),
                          nil];
    
    if (self.filteredPrescriptions == nil) {
        // Initialize the array of filtered prescriptions
        self.filteredPrescriptions = [[NSMutableArray alloc] init];
    }
    
    // add the "Done" button to the nav bar
    UIBarButtonItem* rightButton = [[UIBarButtonItem alloc]
                                    initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                    target:self
                                    action:@selector(onDoneButtonPressed:)];
    self.navigationItem.rightBarButtonItem = rightButton;
    [rightButton release];
    
    // add the "Clear" button to the nav bar
    UIBarButtonItem* leftButton = [[UIBarButtonItem alloc]
                                    initWithTitle:NSLocalizedString(@"CLEAR", nil)
                                    style:UIBarButtonItemStylePlain
                                    target:self
                                    action:@selector(onClearButtonPressed:)];
    self.navigationItem.leftBarButtonItem = leftButton;
    [leftButton release];
    
    // Setup date formatter
    self.dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
    [self.dateFormatter setLocale:[NSLocale currentLocale]];
    [self.dateFormatter setDateStyle:NSDateFormatterShortStyle];
    [self.dateFormatter setTimeStyle:NSDateFormatterNoStyle];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.tableView reloadData];
    
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
    return [self.sectionsArray count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [self.sectionsArray objectAtIndex:section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    if (indexPath.section == 0) {
        // Prescriptions section
        if ([self.filteredPrescriptions count] > 0) {
            cell.textLabel.textColor = [UIColor blackColor];
            cell.textLabel.minimumFontSize = 10.0f;
            cell.textLabel.adjustsFontSizeToFitWidth = YES;
            
            int count = [self.filteredPrescriptions count];
            
            // Add the first prescription
            Prescription *prescription = [self.filteredPrescriptions objectAtIndex:0];
            cell.textLabel.text = prescription.name;
            
            // Now, if more than 1 exist, add the rest ot the string
            for (int i = 1; i < count; i++) {
                prescription = [self.filteredPrescriptions objectAtIndex:i];
                cell.textLabel.text = [NSString stringWithFormat:@"%@, %@", cell.textLabel.text, prescription.name];
            }
        }
        else {
            cell.textLabel.textColor = [UIColor lightGrayColor];
            cell.textLabel.text = NSLocalizedString(@"CHOOSE PRESCRIPTIONS", nil);
        }
    }
    else if (indexPath.section == 1) {
        // Period section
        if (self.filterDateStart != nil && self.filterDateEnd != nil) {            
            cell.textLabel.textColor = [UIColor blackColor];
            cell.textLabel.text = self.periodTextLabel;
        }
        else {
            cell.textLabel.textColor = [UIColor lightGrayColor];
            cell.textLabel.text = NSLocalizedString(@"CHOOSE PERIOD", nil);
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
    
    if (indexPath.section == 0) {
        // Prescriptions selected
        ClifeFilterPrescriptionsViewController *filterPrescriptionsViewController = [ClifeFilterPrescriptionsViewController createInstance];
        filterPrescriptionsViewController.delegate = self;
        
        [self.navigationController pushViewController:filterPrescriptionsViewController animated:YES];
    }
    else if (indexPath.section == 1) {
        // Period selected
        ClifeFilterPeriodViewController *filterPeriodViewController = [ClifeFilterPeriodViewController createInstance];
        filterPeriodViewController.delegate = self;
        
        [self.navigationController pushViewController:filterPeriodViewController animated:YES];
    }
}

#pragma mark - Helper Methods
- (void)updatePeriodTextLabel {
    NSString *startStr = [self.dateFormatter stringFromDate:self.filterDateStart];
    NSString *endStr = [self.dateFormatter stringFromDate:self.filterDateEnd];
    
    self.periodTextLabel = [NSString stringWithFormat:@"%@ %@ %@", startStr, NSLocalizedString(@"TO", nil), endStr];
}

#pragma mark - UI Action Methods
- (void)onDoneButtonPressed:(id)sender {
    // Pass the filtered prescriptions to the History view controller
    BOOL isFiltered = NO;
    
    ClifeHistoryViewController *historyViewController = (ClifeHistoryViewController *)self.delegate;
    if ([self.filteredPrescriptions count] > 0) {
        historyViewController.filteredPrescriptions = self.filteredPrescriptions;
        
        isFiltered = YES;
    }
    else {
        historyViewController.filteredPrescriptions = nil;
    }
    
    // Now pass the filtered period
    if (self.filterDateStart != nil || self.filterDateEnd != nil) {
        historyViewController.filterDateStart = self.filterDateStart;
        historyViewController.filterDateEnd = self.filterDateEnd;
        
        isFiltered = YES;
    }
    else {
        historyViewController.filterDateStart = nil;
        historyViewController.filterDateEnd = nil;
    }
    
    // Now put the History view controller in the filtered state if a filter is applied
    if (isFiltered == YES) {
        historyViewController.isFiltered = YES;
    }
    else {
        historyViewController.isFiltered = NO;
    }
    
    // Finally update the period text label and selected index
    historyViewController.periodTextLabel = self.periodTextLabel;
    historyViewController.selectedPeriodIndex = self.selectedPeriodIndex;
    
    [self.navigationController dismissModalViewControllerAnimated:YES];
}

- (void)onClearButtonPressed:(id)sender {
    // clear the filtered items
    [self.filteredPrescriptions removeAllObjects];
    self.filterDateStart = nil;
    self.filterDateEnd = nil;
    self.periodTextLabel = nil;
    self.selectedPeriodIndex = 99;
    
    
    // Make sure the history view controller is not marked as having any filters
    ClifeHistoryViewController *historyViewController = (ClifeHistoryViewController *)self.delegate;
    historyViewController.isFiltered = NO;
    
    [self.tableView reloadData];
}

#pragma mark - Static Initializers
+ (ClifeFilterViewController *)createInstance {
    ClifeFilterViewController *instance = [[ClifeFilterViewController alloc] initWithNibName:@"ClifeFilterViewController" bundle:nil];
    [instance autorelease];
    return instance;
}

@end
