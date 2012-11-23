//
//  ClifeReminderDetailsViewController.m
//  CLife
//
//  Created by Jordan Gurrieri on 9/9/12.
//  Copyright (c) 2012 Blue Label Solutions LLC. All rights reserved.
//

#import "ClifeReminderDetailsViewController.h"
#import "PrescriptionInstance.h"
#import "DateTimeHelper.h"
#import "ClifePrescriptionDetailsViewController.h"

@interface ClifeReminderDetailsViewController ()

@end

@implementation ClifeReminderDetailsViewController
@synthesize tbl_reminderDetails     = m_tbl_reminderDetails;
@synthesize prescriptionInstanceID  = m_prescriptionInstanceID;
@synthesize sectionsArray           = m_sectionsArray;
@synthesize dateAndTimeFormatter    = m_dateAndTimeFormatter;
@synthesize isEditing               = m_isEditing;
@synthesize v_disabledBackground    = m_v_disabledBackground;
@synthesize gestureRecognizer       = m_gestureRecognizer;
@synthesize doneButton              = m_doneButton;
@synthesize editButton              = m_editButton;

#pragma mark - Initialization

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.dateAndTimeFormatter = [[[NSDateFormatter alloc] init] autorelease];
    [self.dateAndTimeFormatter setLocale:[NSLocale currentLocale]];
    [self.dateAndTimeFormatter setDateStyle:NSDateFormatterMediumStyle];
    [self.dateAndTimeFormatter setTimeStyle:NSDateFormatterShortStyle];
    
    // Setup array for section titles
    self.sectionsArray = [NSArray arrayWithObjects:
                          NSLocalizedString(@"MEDICATION", nil),
                          NSLocalizedString(@"REMINDER", nil),
                          nil];
    
    // Setup tap gesture recognizer to capture touches on the tableview when the keyboard is visible
    self.gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideInputView)];
    
    // Initalize done and edit nave bar buttons
    self.doneButton = [[UIBarButtonItem alloc]
                                    initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                    target:self
                                    action:@selector(doneEditingPrescriptionInstance:)];

    self.editButton = [[UIBarButtonItem alloc]
                                    initWithBarButtonSystemItem:UIBarButtonSystemItemEdit
                                    target:self
                                    action:@selector(onEditReminderButtonPressed:)];
    
    // Determine if we are in an editing state or not
    if (self.prescriptionInstanceID != nil) {
        // Get the prescription instance object
        ResourceContext *resourceContext = [ResourceContext instance];
        PrescriptionInstance *prescriptionInstance = (PrescriptionInstance *)[resourceContext resourceWithType:PRESCRIPTIONINSTANCE withID:self.prescriptionInstanceID];
        
        self.dateScheduled = prescriptionInstance.datescheduled;
        
        NSDate *dateScheduled = [DateTimeHelper parseWebServiceDateDouble:self.dateScheduled];
        
        if (self.dateScheduled != nil && [dateScheduled compare:[NSDate date]] == NSOrderedDescending) {
            // add the "Edit" button to the nav bar
            self.navigationItem.rightBarButtonItem = self.editButton;
        }
    }
    else {
        self.dateScheduled = nil;
    }
    
    self.isEditing = NO;
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    
    self.tbl_reminderDetails = nil;
    self.dateAndTimeFormatter = nil;
    self.tf_dateScheduled = nil;
    self.pv_dateScheduled = nil;
    self.v_disabledBackground = nil;
    self.gestureRecognizer = nil;
    self.doneButton = nil;
    self.editButton = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
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

- (UITableViewCell *)tableView:(UITableView *)tableView configureCellWithIdentifier:(NSString *)CellIdentifier {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if ([CellIdentifier isEqualToString:@"DayAndTimeScheduled"]) {
        if (cell == nil) {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
            
            [cell setSelectionStyle:UITableViewCellEditingStyleNone];
            
            cell.textLabel.text = NSLocalizedString(@"SCHEDULED", nil);
            
            // Initialize the date taken picker view
            if (self.pv_dateScheduled == nil) {
                UIDatePicker* pickerView = [[[UIDatePicker alloc] init] autorelease];
                [pickerView sizeToFit];
                pickerView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
                [pickerView addTarget:self action:@selector(dateScheduledChanged:) forControlEvents:UIControlEventValueChanged];
                pickerView.datePickerMode = UIDatePickerModeDateAndTime;        
                pickerView.minimumDate = [NSDate date];
                
                self.pv_dateScheduled = pickerView;
            }
            
            self.tf_dateScheduled = [[UITextField alloc] initWithFrame:CGRectMake(100, 0, 180, 21)];
            self.tf_dateScheduled.adjustsFontSizeToFitWidth = YES;
            self.tf_dateScheduled.placeholder = NSLocalizedString(@"ENTER DATE AND TIME", nil);
            self.tf_dateScheduled.backgroundColor = [UIColor clearColor];
            self.tf_dateScheduled.textAlignment = UITextAlignmentRight;
            self.tf_dateScheduled.delegate = self;
            [self.tf_dateScheduled setEnabled:YES];
            
            self.tf_dateScheduled.inputView = self.pv_dateScheduled;
            
            cell.accessoryView = self.tf_dateScheduled;
        }
        
        if (self.dateScheduled != nil) {
            NSDate *dateScheduled = [DateTimeHelper parseWebServiceDateDouble:self.dateScheduled];
            self.tf_dateScheduled.backgroundColor = [UIColor clearColor];
            self.tf_dateScheduled.text = [self.dateAndTimeFormatter stringFromDate:dateScheduled];
            
            self.pv_dateScheduled.date = dateScheduled;
        }
        else {            
            self.tf_dateScheduled.text = nil;
            
            self.pv_dateScheduled.date = [NSDate date];
        }
        
        // disable the cell until the "Edit" button is pressed
        if (self.isEditing == YES) {
            [cell setUserInteractionEnabled:YES];
            [self.tf_dateScheduled setClearButtonMode:UITextFieldViewModeAlways];
        }
        else {
            [cell setUserInteractionEnabled:NO];
            [self.tf_dateScheduled setClearButtonMode:UITextFieldViewModeNever];
        }
    }
    
    return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Get the prescription instance object
    ResourceContext *resourceContext = [ResourceContext instance];
    PrescriptionInstance *prescriptionInstance = (PrescriptionInstance *)[resourceContext resourceWithType:PRESCRIPTIONINSTANCE withID:self.prescriptionInstanceID];
    
    // Configure the cell...
    NSString *CellIdentifier;
    UITableViewCell *cell;
    
    if (indexPath.section == 0) {
        // Prescription Name section
        
        CellIdentifier = @"PrescriptionName";
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        if (cell == nil) {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
            
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            
        }
        
        cell.textLabel.text = prescriptionInstance.prescriptionname;
    }
    else if (indexPath.section == 1) {
        // Reminder section
        
        // Day and Time Scheduled
        CellIdentifier = @"DayAndTimeScheduled";
        
        cell = [self tableView:tableView configureCellWithIdentifier:CellIdentifier];
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
//- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
//    
//}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section == 0 && indexPath.row == 0) {
        ResourceContext *resourceContext = [ResourceContext instance];
        PrescriptionInstance *prescriptionInstance = (PrescriptionInstance *)[resourceContext resourceWithType:PRESCRIPTIONINSTANCE withID:self.prescriptionInstanceID];
        
        ClifePrescriptionDetailsViewController *prescriptionDetailsVC = [ClifePrescriptionDetailsViewController createInstanceForPrescriptionWithID:prescriptionInstance.prescriptionid];
        
        [prescriptionDetailsVC setHidesBottomBarWhenPushed:YES];
        [self.navigationController pushViewController:prescriptionDetailsVC animated:YES];
    }
    else if (indexPath.section == 1 && indexPath.row == 0) {
        // Date Scheduled selected
        
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        
        // Set the date taken text field as active
        [self.tf_dateScheduled becomeFirstResponder];
    }
}

#pragma mark - UITextField Delegate Methods
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    // textfield editing has begun
    
    if (textField == self.tf_dateScheduled) {
        
        [self showDisabledBackgroundView];
        
//        // Add the tap gesture recognizer to capture background touches which will dismiss the keyboard
//        [self.v_disabledBackground addGestureRecognizer:self.gestureRecognizer];
//
//        // Scroll tableview to this row
//        [self.tbl_reminderDetails setContentOffset:CGPointMake(0, 40) animated:YES];
        
        if ([self.dateAndTimeFormatter dateFromString:self.tf_dateScheduled.text]) {
            self.pv_dateScheduled.date = [self.dateAndTimeFormatter dateFromString:self.tf_dateScheduled.text];
            
            NSDate* dateScheduled = [self.dateAndTimeFormatter dateFromString:self.tf_dateScheduled.text];
            double doubleDate = [dateScheduled timeIntervalSince1970];
            self.dateScheduled = [NSNumber numberWithDouble:doubleDate];
        }
        else {
            self.tf_dateScheduled.text = [self.dateAndTimeFormatter stringFromDate:self.pv_dateScheduled.date];
            
            NSDate* dateScheduled = self.pv_dateScheduled.date;
            double doubleDate = [dateScheduled timeIntervalSince1970];
            self.dateScheduled = [NSNumber numberWithDouble:doubleDate];
        }
        
    }
  
//    // Hide the back button until user is done editing
//    self.navigationItem.hidesBackButton = YES;
    
//    // disable nav bar buttons until text entry complete
//    self.navigationItem.rightBarButtonItem.enabled = NO;
//    self.navigationItem.leftBarButtonItem.enabled = NO;
//    
//    // create a done view + done button, attach to it a doneClicked action, and place it in a toolbar as an accessory input view.
//    // Prepare done button
//    UIToolbar* keyboardDoneButtonView = [[UIToolbar alloc] init];
//    keyboardDoneButtonView.barStyle = UIBarStyleBlack;
//    keyboardDoneButtonView.translucent = YES;
//    keyboardDoneButtonView.tintColor = nil;
//    [keyboardDoneButtonView sizeToFit];
//    
//    UIBarButtonItem* doneButton = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
//                                                                                 target:self
//                                                                                 action:@selector(hideInputView)] autorelease];
//    
//    UIBarButtonItem *flexSpace = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil] autorelease];
//    
//    [keyboardDoneButtonView setItems:[NSArray arrayWithObjects:flexSpace, doneButton, nil]];
//    
//    // Plug the keyboardDoneButtonView into the text field.
//    textField.inputAccessoryView = keyboardDoneButtonView;
    
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    // textfield editing has ended
    NSString *enteredText = [textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    if (textField == self.tf_dateScheduled) {
        
        [self hideDisabledBackgroundView];
        
        self.tf_dateScheduled.backgroundColor = [UIColor clearColor];
        
        if ([self.dateAndTimeFormatter dateFromString:enteredText]) {
            self.pv_dateScheduled.date = [self.dateAndTimeFormatter dateFromString:enteredText];
            
            NSDate* dateScheduled = [self.dateAndTimeFormatter dateFromString:enteredText];
            double doubleDate = [dateScheduled timeIntervalSince1970];
            self.dateScheduled = [NSNumber numberWithDouble:doubleDate];
        }
        else {
            self.tf_dateScheduled.text = [self.dateAndTimeFormatter stringFromDate:self.pv_dateScheduled.date];
            
            NSDate* dateScheduled = self.pv_dateScheduled.date;
            double doubleDate = [dateScheduled timeIntervalSince1970];
            self.dateScheduled = [NSNumber numberWithDouble:doubleDate];
        }
    }
    
    // Scroll tableview back to the top
    [self.tbl_reminderDetails setContentOffset:CGPointMake(0, 0) animated:YES];
    
    // Re-enable nav bar buttons
   self.navigationItem.rightBarButtonItem.enabled = YES;
    
}

#pragma mark - UIDatePickerView Methods
- (void)dateScheduledChanged:(id)sender
{
    self.tf_dateScheduled.text = [self.dateAndTimeFormatter stringFromDate:self.pv_dateScheduled.date];
    
    NSDate* dateScheduled = self.pv_dateScheduled.date;
    double doubleDate = [dateScheduled timeIntervalSince1970];
    self.dateScheduled = [NSNumber numberWithDouble:doubleDate];
}

#pragma mark - UIAlertView Delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
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
                     }];
}

- (void)hideInputView {
    [[self view] endEditing:YES];
}

- (void)editReminder {
    self.isEditing = YES;
    
    // Reload the table view to enable user interaction and accessory views on the tableview cells
    [self.tbl_reminderDetails reloadData];
    
    // add the "Done" button to the nav bar
    self.navigationItem.rightBarButtonItem = self.doneButton;
    
    // Show the date picker
    [self.tf_dateScheduled becomeFirstResponder];
    
}

- (void)doneEditingPrescriptionInstance:(id)sender {
    NSDate *dateScheduled = [DateTimeHelper parseWebServiceDateDouble:self.dateScheduled];
    
    if (self.dateScheduled == nil || [dateScheduled compare:[NSDate date]] == NSOrderedAscending)
    {
        // Promt user that date must be in the future
        UIAlertView* alert = [[UIAlertView alloc]
                              initWithTitle:NSLocalizedString(@"INVALID DATE", nil)
                              message:NSLocalizedString(@"INVALID DATE MESSAGE", nil)
                              delegate:self
                              cancelButtonTitle:NSLocalizedString(@"OK", nil)
                              otherButtonTitles:nil];
        [alert show];
        [alert release];
    }
    else {
        // Exit editing and save changes
        
        // Hide the keyboard if it is shown
        [self hideInputView];
        
        self.isEditing = NO;
        
        // Show the back button
        [self.navigationItem setHidesBackButton:NO animated:YES];
        
        // add the "Edit" button back to the nav bar
        self.navigationItem.rightBarButtonItem = self.editButton;
        
//        // Update the prescription instance properties and save
//        ResourceContext *resourceContext = [ResourceContext instance];
//        PrescriptionInstance *prescriptionInstance = (PrescriptionInstance *)[resourceContext resourceWithType:PRESCRIPTIONINSTANCE withID:self.prescriptionInstanceID];
//        
//        prescriptionInstance.datescheduled = self.dateScheduled;
//        
//        [resourceContext save:NO onFinishCallback:nil trackProgressWith:nil];
        
        // Reload the table view to disable user interaction and accessory views on the tableview cells
        [self.tbl_reminderDetails reloadData];
        
        // Scroll tableview back to the top
        [self.tbl_reminderDetails setContentOffset:CGPointMake(0, 0) animated:YES];
    }
}

- (void)onEditReminderButtonPressed:(id)sender {
    [self editReminder];
}

#pragma mark - Static Initializers
+ (ClifeReminderDetailsViewController *)createInstanceForPrescriptionInstanceWithID:(NSNumber *)prescriptionInstanceID {
    ClifeReminderDetailsViewController *instance = [[ClifeReminderDetailsViewController alloc] initWithNibName:@"ClifeReminderDetailsViewController" bundle:nil];
    [instance autorelease];
    
    instance.prescriptionInstanceID = prescriptionInstanceID;
    
    return instance;
}

@end
