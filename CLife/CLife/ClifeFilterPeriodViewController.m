//
//  ClifeFilterPeriodViewController.m
//  CLife
//
//  Created by Jordan Gurrieri on 9/24/12.
//  Copyright (c) 2012 Blue Label Solutions LLC. All rights reserved.
//

#import "ClifeFilterPeriodViewController.h"
#import "DateTimeHelper.h"
#import "ClifeFilterViewController.h"

@interface ClifeFilterPeriodViewController ()

@end

@implementation ClifeFilterPeriodViewController
@synthesize sectionsArray           = m_sectionsArray;
@synthesize periodArray             = m_periodArray;
@synthesize dateFormatter           = m_dateFormatter;
@synthesize tf_dateStart            = m_tf_dateStart;
@synthesize pv_dateStart            = m_pv_dateStart;
@synthesize tf_dateEnd              = m_tf_dateEnd;
@synthesize pv_dateEnd              = m_pv_dateEnd;

#pragma mark - Properties
- (id)delegate {
    return m_delegate;
}

- (void)setDelegate:(id<ClifeFilterPeriodViewControllerDelegate>)del
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
    
    self.navigationItem.title = NSLocalizedString(@"PERIOD", nil);
    
    // add the "Clear" button to the nav bar
    UIBarButtonItem* rightButton = [[UIBarButtonItem alloc]
                                   initWithTitle:NSLocalizedString(@"CLEAR", nil)
                                   style:UIBarButtonItemStylePlain
                                   target:self
                                   action:@selector(onClearButtonPressed:)];
    self.navigationItem.rightBarButtonItem = rightButton;
    [rightButton release];
    
    // Setup disabled backgroud view
    UIView *background = [[UIView alloc] initWithFrame:self.tableView.frame];
    background.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    background.backgroundColor = [UIColor blackColor];
    background.alpha = 0.0f;
    
    self.v_disabledBackground = background;
    [background release];
    
    [self.view addSubview:self.v_disabledBackground];
    [self.view sendSubviewToBack:self.v_disabledBackground];
    
    // Setup tap gesture recognizer to capture touches on the tableview when the keyboard is visible
    self.gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideInputView)];
    
    // Setup date formatter
    self.dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
    [self.dateFormatter setDateStyle:NSDateFormatterLongStyle];
    [self.dateFormatter setTimeStyle:NSDateFormatterNoStyle];
    
    // Setup array of values
    self.sectionsArray = [NSArray arrayWithObjects:
                          NSLocalizedString(@"CUSTOM RANGE", nil),
                          NSLocalizedString(@"PERIOD", nil),
                          nil];
    
    self.periodArray = [NSArray arrayWithObjects:
                        NSLocalizedString(@"TODAY", nil),
                        NSLocalizedString(@"YESTERDAY", nil),
                        [NSString stringWithFormat:@"%@ %d %@", NSLocalizedString(@"LAST", nil), 3, NSLocalizedString(@"DAYS", nil)],
                        [NSString stringWithFormat:@"%@ %d %@", NSLocalizedString(@"LAST", nil), 7, NSLocalizedString(@"DAYS", nil)],
                        [NSString stringWithFormat:@"%@ %d %@", NSLocalizedString(@"LAST", nil), 30, NSLocalizedString(@"DAYS", nil)],
                        [NSString stringWithFormat:@"%@ %d %@", NSLocalizedString(@"LAST", nil), 60, NSLocalizedString(@"DAYS", nil)],
                        [NSString stringWithFormat:@"%@ %d %@", NSLocalizedString(@"LAST", nil), 90, NSLocalizedString(@"DAYS", nil)],
                        [NSString stringWithFormat:@"%@ %d %@", NSLocalizedString(@"LAST", nil), 365, NSLocalizedString(@"DAYS", nil)],
                        nil];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.tableView reloadData];
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    
    self.dateFormatter = nil;
    self.tf_dateStart = nil;
    self.pv_dateStart = nil;
    self.tf_dateEnd = nil;
    self.pv_dateEnd = nil;
    self.v_disabledBackground = nil;
    self.gestureRecognizer = nil;
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
    if (section == 0) {
        // Custom Range section
        return 2;
    }
    if (section == 1) {
        // Period section
        return [self.periodArray count];
    }
    else {
        return 0;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [self.sectionsArray objectAtIndex:section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *CellIdentifier;
    UITableViewCell *cell;
    
    if (indexPath.section == 0) {
        // Custom Range section
        
        if (indexPath.row == 0) {
            CellIdentifier = @"StartDate";
            cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            
            if (cell == nil) {
                cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
                
                [cell setSelectionStyle:UITableViewCellEditingStyleNone];
                
                cell.textLabel.text = NSLocalizedString(@"START", nil);
                
                // Initialize the start date picker view
                if (self.pv_dateStart == nil) {
                    UIDatePicker* pickerView = [[[UIDatePicker alloc] init] autorelease];
                    [pickerView sizeToFit];
                    pickerView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
                    [pickerView addTarget:self action:@selector(startDateChanged:) forControlEvents:UIControlEventValueChanged];
                    pickerView.datePickerMode = UIDatePickerModeDate;
                    
                    self.pv_dateStart = pickerView;
                    
                    self.tf_dateStart = [[UITextField alloc] initWithFrame:CGRectMake(80, 0, 200, 21)];
                    self.tf_dateStart.adjustsFontSizeToFitWidth = YES;
                    self.tf_dateStart.placeholder = NSLocalizedString(@"ENTER START DATE", nil);
                    self.tf_dateStart.textColor = [UIColor darkGrayColor];
                    self.tf_dateStart.backgroundColor = [UIColor clearColor];
                    self.tf_dateStart.textAlignment = UITextAlignmentRight;
                    self.tf_dateStart.delegate = self;
                    [self.tf_dateStart setEnabled:YES];
                    
                    self.tf_dateStart.inputView = self.pv_dateStart;
                    
                    cell.accessoryView = self.tf_dateStart;
                }
            }
            
            ClifeFilterViewController *filterViewController = (ClifeFilterViewController *)self.delegate;
            if (filterViewController.filterDateStart != nil && filterViewController.selectedPeriodIndex == 99) {
                self.tf_dateStart.text = [self.dateFormatter stringFromDate:filterViewController.filterDateStart];
            }
            else {            
                self.tf_dateStart.text = nil;
            }
            
            // make sure the start date cannot be set to a date later than the end date
            if (filterViewController.filterDateEnd != nil && filterViewController.selectedPeriodIndex == 99) {
                self.pv_dateStart.maximumDate = filterViewController.filterDateEnd;
            }
            else {
                self.pv_dateStart.maximumDate = [NSDate date];
            }
        }
        else if (indexPath.row == 1) {
            CellIdentifier = @"EndDate";
            cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            
            if (cell == nil) {
                cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
                
                [cell setSelectionStyle:UITableViewCellEditingStyleNone];
                
                cell.textLabel.text = NSLocalizedString(@"END", nil);
                
                // Initialize the start date picker view
                if (self.pv_dateEnd == nil) {
                    UIDatePicker* pickerView = [[[UIDatePicker alloc] init] autorelease];
                    [pickerView sizeToFit];
                    pickerView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
                    [pickerView addTarget:self action:@selector(endDateChanged:) forControlEvents:UIControlEventValueChanged];
                    pickerView.datePickerMode = UIDatePickerModeDate;
                    pickerView.maximumDate = [NSDate date];
                    
                    self.pv_dateEnd = pickerView;
                    
                    self.tf_dateEnd = [[UITextField alloc] initWithFrame:CGRectMake(80, 0, 200, 21)];
                    self.tf_dateEnd.adjustsFontSizeToFitWidth = YES;
                    self.tf_dateEnd.placeholder = NSLocalizedString(@"ENTER END DATE", nil);
                    self.tf_dateEnd.textColor = [UIColor darkGrayColor];
                    self.tf_dateEnd.backgroundColor = [UIColor clearColor];
                    self.tf_dateEnd.textAlignment = UITextAlignmentRight;
                    self.tf_dateEnd.delegate = self;
                    [self.tf_dateEnd setEnabled:YES];
                    
                    self.tf_dateEnd.inputView = self.pv_dateEnd;
                    
                    cell.accessoryView = self.tf_dateEnd;
                }
            }
            
            ClifeFilterViewController *filterViewController = (ClifeFilterViewController *)self.delegate;
            if (filterViewController.filterDateEnd != nil && filterViewController.selectedPeriodIndex == 99) {
                self.tf_dateEnd.text = [self.dateFormatter stringFromDate:filterViewController.filterDateEnd];
            }
            else {
                self.tf_dateEnd.text = nil;
            }
            
            // make sure the end date cannot be set to a date before the start date
            if (filterViewController.filterDateStart != nil && filterViewController.selectedPeriodIndex == 99) {
                self.pv_dateEnd.minimumDate = filterViewController.filterDateStart;
            }
            else {
                self.pv_dateEnd.minimumDate = nil;
            }
        }
    }
    else if (indexPath.section == 1) {
        // Period section
        
        CellIdentifier = @"Period";
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        if (cell == nil) {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        }
        
        cell.textLabel.text = [self.periodArray objectAtIndex:indexPath.row];
        
        ClifeFilterViewController *filterViewController = (ClifeFilterViewController *)self.delegate;
        if (filterViewController.selectedPeriodIndex == indexPath.row) {
            filterViewController.periodTextLabel = [self.periodArray objectAtIndex:indexPath.row];
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
    
    if (indexPath.section == 0) {
        // Custom Range section
        
        if (indexPath.row == 0) {
            // Set the start date text field as active
            [self.tf_dateStart becomeFirstResponder];
        }
        else if (indexPath.row == 1) {
            // Set the end date text field as active
            [self.tf_dateEnd becomeFirstResponder];
        }
    }
    else if (indexPath.section == 1) {
        // Period section
        
        NSInteger count = [self.periodArray count];
        
        if (indexPath.row < count) {
            
            // Clear all items so we can reset the filter values to this selection
            [self onClearButtonPressed:nil];
            
            // Mark this cell selected
            UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
            
            ClifeFilterViewController *filterViewController = (ClifeFilterViewController *)self.delegate;
            
            
            // Now get the start and end date for the chosen period
            NSDate *today = [self.dateFormatter dateFromString:[self.dateFormatter stringFromDate:[NSDate date]]];  //removes time components
            
            NSCalendar *calendar = [NSCalendar currentCalendar];
            NSDateComponents *components = [[[NSDateComponents alloc] init] autorelease];
            
            if (indexPath.row == 0) {
                // Today
                
                filterViewController.filterDateStart = today;
                filterViewController.filterDateEnd = [self processEndDateWithDate:today];
            }
            else if (indexPath.row == 1) {
                // Yesterday
                components.day = -1;
                NSDate *yesterday = [calendar dateByAddingComponents:components toDate:today options:0];
                
                filterViewController.filterDateStart = yesterday;
                filterViewController.filterDateEnd = [self processEndDateWithDate:yesterday];
            }
            else if (indexPath.row == 2) {
                // Last 3 days
                components.day = -2;
                NSDate *start = [calendar dateByAddingComponents:components toDate:today options:0];
                
                filterViewController.filterDateStart = start;
                filterViewController.filterDateEnd = [self processEndDateWithDate:today];
            }
            else if (indexPath.row == 3) {
                // Last 7 days
                components.day = -6;
                NSDate *start = [calendar dateByAddingComponents:components toDate:today options:0];
                
                filterViewController.filterDateStart = start;
                filterViewController.filterDateEnd = [self processEndDateWithDate:today];
            }
            else if (indexPath.row == 4) {
                // Last 30 days
                components.day = -29;
                NSDate *start = [calendar dateByAddingComponents:components toDate:today options:0];
                
                filterViewController.filterDateStart = start;
                filterViewController.filterDateEnd = [self processEndDateWithDate:today];
            }
            else if (indexPath.row == 5) {
                // Last 60 days
                components.day = -59;
                NSDate *start = [calendar dateByAddingComponents:components toDate:today options:0];
                
                filterViewController.filterDateStart = start;
                filterViewController.filterDateEnd = [self processEndDateWithDate:today];
            }
            else if (indexPath.row == 6) {
                // Last 90 days
                components.day = -89;
                NSDate *start = [calendar dateByAddingComponents:components toDate:today options:0];
                
                filterViewController.filterDateStart = start;
                filterViewController.filterDateEnd = [self processEndDateWithDate:today];
            }
            else if (indexPath.row == 7) {
                // Last 365 days
                components.day = -364;
                NSDate *start = [calendar dateByAddingComponents:components toDate:today options:0];
                
                filterViewController.filterDateStart = start;
                filterViewController.filterDateEnd = [self processEndDateWithDate:today];
            }
            
            // Update the period text label to show the range
            filterViewController.periodTextLabel = [self.periodArray objectAtIndex:indexPath.row];
            filterViewController.selectedPeriodIndex = indexPath.row;
            
        }
    }
}

#pragma mark - UIDatePickerView Methods
- (NSDate *)processEndDateWithDate:(NSDate *)date {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents* components = [[[NSDateComponents alloc] init] autorelease];
    components.day = 1;
    components.second = -1; // sets the date to the last second on the desired end day
    NSDate* endDate = [calendar dateByAddingComponents:components toDate:date options:0];
    
    return endDate;
}

- (void)startDateChanged:(id)sender
{
    self.tf_dateStart.text = [self.dateFormatter stringFromDate:self.pv_dateStart.date];
    
    ClifeFilterViewController *filterViewController = (ClifeFilterViewController *)self.delegate;
    filterViewController.filterDateStart = self.pv_dateStart.date;
}

- (void)endDateChanged:(id)sender
{
    self.tf_dateEnd.text = [self.dateFormatter stringFromDate:self.pv_dateEnd.date];
    
    ClifeFilterViewController *filterViewController = (ClifeFilterViewController *)self.delegate;
    filterViewController.filterDateEnd = [self processEndDateWithDate:self.pv_dateEnd.date];
}

#pragma mark - TextField Delegate
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if (textField == self.tf_dateStart) {
        
        [self showDisabledBackgroundView];
        
        // Add the tap gesture recognizer to capture background touches which will dismiss the keyboard
        [self.v_disabledBackground addGestureRecognizer:self.gestureRecognizer];
        
        if ([self.dateFormatter dateFromString:self.tf_dateStart.text]) {
            self.pv_dateStart.date = [self.dateFormatter dateFromString:self.tf_dateStart.text];
            
            ClifeFilterViewController *filterViewController = (ClifeFilterViewController *)self.delegate;
            filterViewController.filterDateStart = self.pv_dateStart.date;
        }
        else {
            self.pv_dateStart.date = [NSDate date];
            
            self.tf_dateStart.text = [self.dateFormatter stringFromDate:self.pv_dateStart.date];
            
            ClifeFilterViewController *filterViewController = (ClifeFilterViewController *)self.delegate;
            filterViewController.filterDateStart = self.pv_dateStart.date;
        }
    }
    else if (textField == self.tf_dateEnd) {
        
        [self showDisabledBackgroundView];
        
        // Add the tap gesture recognizer to capture background touches which will dismiss the keyboard
        [self.v_disabledBackground addGestureRecognizer:self.gestureRecognizer];
                
        if ([self.dateFormatter dateFromString:self.tf_dateEnd.text]) {
            self.pv_dateEnd.date = [self.dateFormatter dateFromString:self.tf_dateEnd.text];
            
            ClifeFilterViewController *filterViewController = (ClifeFilterViewController *)self.delegate;
            filterViewController.filterDateEnd = [self processEndDateWithDate:[self.dateFormatter dateFromString:self.tf_dateEnd.text]];
        }
        else {
            self.tf_dateEnd.text = [self.dateFormatter stringFromDate:self.pv_dateEnd.date];
            
            ClifeFilterViewController *filterViewController = (ClifeFilterViewController *)self.delegate;
            filterViewController.filterDateEnd = [self processEndDateWithDate:self.pv_dateEnd.date];
        }   
    }
    
    // disable nav bar buttons until text entry complete
    self.navigationItem.leftBarButtonItem.enabled = NO;
    self.navigationItem.rightBarButtonItem.enabled = NO;
    
    // create a done view + done button, attach to it a doneClicked action, and place it in a toolbar as an accessory input view.
    // Prepare done button
    UIToolbar* keyboardDoneButtonView = [[UIToolbar alloc] init];
    keyboardDoneButtonView.barStyle = UIBarStyleBlack;
    keyboardDoneButtonView.translucent = YES;
    keyboardDoneButtonView.tintColor = nil;
    [keyboardDoneButtonView sizeToFit];
    
    UIBarButtonItem* doneButton = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                                 target:self
                                                                                 action:@selector(hideInputView)] autorelease];
    
    UIBarButtonItem *flexSpace = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil] autorelease];
    
    [keyboardDoneButtonView setItems:[NSArray arrayWithObjects:flexSpace, doneButton, nil]];
    
    // Plug the keyboardDoneButtonView into the text field.
    textField.inputAccessoryView = keyboardDoneButtonView;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    // textfield editing has ended
    NSString *enteredText = [textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    ClifeFilterViewController *filterViewController = (ClifeFilterViewController *)self.delegate;
    
    if (textField == self.tf_dateStart) {
        
        [self hideDisabledBackgroundView];
        
        if ([self.dateFormatter dateFromString:enteredText]) {
            self.pv_dateStart.date = [self.dateFormatter dateFromString:enteredText];
            
            filterViewController.filterDateStart = [self.dateFormatter dateFromString:enteredText];;
        }
        else {
            self.tf_dateStart.text = [self.dateFormatter stringFromDate:self.pv_dateStart.date];
            
            filterViewController.filterDateStart = self.pv_dateStart.date;
        }
        
        // make sure the end date cannot be set to a date before the start date
        if (filterViewController.filterDateStart != nil) {
            self.pv_dateEnd.minimumDate = filterViewController.filterDateStart;
        }
        else {
            self.pv_dateEnd.minimumDate = nil;
        }
        
    }
    else if (textField == self.tf_dateEnd) {
        
        [self hideDisabledBackgroundView];
        
        if ([self.dateFormatter dateFromString:enteredText]) {
            self.pv_dateEnd.date = [self.dateFormatter dateFromString:enteredText];
            
            filterViewController.filterDateEnd = [self processEndDateWithDate:[self.dateFormatter dateFromString:enteredText]];
        }
        else {
            self.tf_dateEnd.text = [self.dateFormatter stringFromDate:self.pv_dateEnd.date];
            
            filterViewController.filterDateEnd = [self processEndDateWithDate:self.pv_dateEnd.date];
        }
        
        // make sure the start date cannot be set to a date later than the end date
        if (filterViewController.filterDateEnd != nil) {
            self.pv_dateStart.maximumDate = filterViewController.filterDateEnd;
        }
        else {
            self.pv_dateStart.maximumDate = [NSDate date];
        }
    }
    
    // Update the period text label to show the range
    [filterViewController updatePeriodTextLabel];
    
    // Re-enable nav bar buttons
    self.navigationItem.leftBarButtonItem.enabled = YES;
    self.navigationItem.rightBarButtonItem.enabled = YES;
    
    // Deslect all rows in the period
    UITableViewCell *cell;
    NSInteger count = [self.periodArray count];
    for (int i = 0; i < count; i++) {
        cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:1]];
        
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    filterViewController.selectedPeriodIndex = 99;
    
}

// Handles keyboard Return button pressed while editing the textfield
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    [textField resignFirstResponder];
    
    return YES;
}

#pragma mark - UI Action Methods
- (void)showDisabledBackgroundView {
    // Show the disabled background so user cannot touch into the tableview while picker is shown
    [self.v_disabledBackground setAlpha:0.0];
    [self.view bringSubviewToFront:self.v_disabledBackground];
    
    // start the show disabled view animation
    [self.v_disabledBackground setAlpha:0.0];
    [self.view bringSubviewToFront:self.v_disabledBackground];
    
    [UIView animateWithDuration:0.3
                          delay:0.0
                        options:UIViewAnimationCurveEaseInOut
                     animations:^{
                         [self.v_disabledBackground setAlpha:0.4];
                     }
                     completion:^(BOOL finished){
                         
                     }];
}

- (void)hideDisabledBackgroundView {
    // start the hide disabled view animation
    [UIView animateWithDuration:0.3
                          delay:0.0
                        options:UIViewAnimationCurveEaseInOut
                     animations:^{
                         [self.v_disabledBackground setAlpha:0.0];
                     }
                     completion:^(BOOL finished){
                         [self.view sendSubviewToBack:self.v_disabledBackground];
                         
                         // Make sure the user enters a start date and end date
                         ClifeFilterViewController *filterViewController = (ClifeFilterViewController *)self.delegate;
                         if (filterViewController.filterDateEnd == nil) {
                             [self.tf_dateEnd becomeFirstResponder];
                         }
                         else if (filterViewController.filterDateStart == nil) {
                             [self.tf_dateStart becomeFirstResponder];
                         }
                     }];
}

- (void)hideInputView {
    [[self view] endEditing:YES];
}

- (void)onClearButtonPressed:(id)sender {
    // clear all items
    ClifeFilterViewController *filterViewController = (ClifeFilterViewController *)self.delegate;
    filterViewController.filterDateStart = nil;
    self.tf_dateStart.text = nil;
    
    filterViewController.filterDateEnd = nil;
    self.tf_dateEnd.text = nil;
    
    filterViewController.periodTextLabel = nil;
    filterViewController.selectedPeriodIndex = 99;
    
    // Deslect all rows in the period
    UITableViewCell *cell;
    NSInteger count = [self.periodArray count];
    for (int i = 0; i < count; i++) {
        cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:1]];
        
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
}

#pragma mark - Static Initializers
+ (ClifeFilterPeriodViewController *)createInstance {
    ClifeFilterPeriodViewController *instance = [[ClifeFilterPeriodViewController alloc] initWithNibName:@"ClifeFilterPeriodViewController" bundle:nil];
    [instance autorelease];
    
    return instance;
}

@end
