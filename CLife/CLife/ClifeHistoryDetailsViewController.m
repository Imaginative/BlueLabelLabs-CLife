//
//  ClifeHistoryDetailsViewController.m
//  CLife
//
//  Created by Jordan Gurrieri on 9/9/12.
//  Copyright (c) 2012 Blue Label Solutions LLC. All rights reserved.
//

#import "ClifeHistoryDetailsViewController.h"
#import "PrescriptionInstance.h"
#import "DateTimeHelper.h"
#import "ClifePrescriptionDetailsViewController.h"

@interface ClifeHistoryDetailsViewController ()

@end

@implementation ClifeHistoryDetailsViewController
@synthesize tbl_historyDetails      = m_tbl_historyDetails;
@synthesize prescriptionInstanceID  = m_prescriptionInstanceID;
@synthesize sectionsArray           = m_sectionsArray;
@synthesize dateAndTimeFormatter    = m_dateAndTimeFormatter;
@synthesize isEditing               = m_isEditing;
@synthesize sc_confirmation         = m_sc_confirmation;
@synthesize tf_dateTaken            = m_tf_dateTaken;
@synthesize pv_dateTaken            = m_pv_dateTaken;
@synthesize tv_notes                = m_tv_notes;
@synthesize v_disabledBackground    = m_v_disabledBackground;
@synthesize gestureRecognizer       = m_gestureRecognizer;
@synthesize dateTaken               = m_dateTaken;
@synthesize notes                   = m_notes;

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
    [self.dateAndTimeFormatter setDateStyle:NSDateFormatterMediumStyle];
    [self.dateAndTimeFormatter setTimeStyle:NSDateFormatterShortStyle];
    
    // Setup array for section titles
    self.sectionsArray = [NSArray arrayWithObjects:
                          NSLocalizedString(@"MEDICATION", nil),
                          NSLocalizedString(@"CONFIRMATION", nil),
                          NSLocalizedString(@"DAY AND TIME TAKEN", nil),
                          NSLocalizedString(@"NOTES", nil),
                          nil];
    
    // Setup tap gesture recognizer to capture touches on the tableview when the keyboard is visible
    self.gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideInputView)];
    
    if (self.prescriptionInstanceID != nil) {
        ResourceContext *resourceContext = [ResourceContext instance];
        PrescriptionInstance *prescriptionInstance = (PrescriptionInstance *)[resourceContext resourceWithType:PRESCRIPTIONINSTANCE withID:self.prescriptionInstanceID];
        
        self.dateTaken = prescriptionInstance.datetaken;
    }
    else {
        self.dateTaken = nil;
    }
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    
    self.tbl_historyDetails = nil;
    self.dateAndTimeFormatter = nil;
    self.tf_dateTaken = nil;
    self.pv_dateTaken = nil;
    self.tv_notes = nil;
    self.v_disabledBackground = nil;
    self.gestureRecognizer = nil;
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
        // Confirmation section
        
        CellIdentifier = @"Confirmation";
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        if (cell == nil) {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
            
            [cell setSelectionStyle:UITableViewCellEditingStyleNone];
            
            NSArray *segmentTitles = [NSArray arrayWithObjects:NSLocalizedString(@"TAKEN", nil), NSLocalizedString(@"NOT TAKEN", nil), nil];
            
            self.sc_confirmation = [[UISegmentedControl alloc] initWithItems:segmentTitles];
            self.sc_confirmation.frame = CGRectMake(0, 0, 300, 45);
            
            [cell.contentView addSubview:self.sc_confirmation];
        }
    }
    else if (indexPath.section == 2) {
        // Day and Time section
        
        CellIdentifier = @"DayAndTime";
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        if (cell == nil) {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
            
            [cell setSelectionStyle:UITableViewCellEditingStyleNone];
            
            // Initialize the date taken picker view
            if (self.pv_dateTaken == nil) {
                UIDatePicker* pickerView = [[[UIDatePicker alloc] init] autorelease];
                [pickerView sizeToFit];
                pickerView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
                [pickerView addTarget:self action:@selector(dateTakenChanged:) forControlEvents:UIControlEventValueChanged];
                pickerView.datePickerMode = UIDatePickerModeDateAndTime;        
                pickerView.maximumDate = [NSDate date];
                pickerView.date = [NSDate date];
                
                self.pv_dateTaken = pickerView;
                
                self.tf_dateTaken = [[UITextField alloc] initWithFrame:CGRectMake(8, 11, 282, 21)];
                self.tf_dateTaken.adjustsFontSizeToFitWidth = YES;
                self.tf_dateTaken.placeholder = NSLocalizedString(@"UNCONFIRMED", nil);
                self.tf_dateTaken.backgroundColor = [UIColor clearColor];
                self.tf_dateTaken.textAlignment = UITextAlignmentLeft;
                self.tf_dateTaken.delegate = self;
                [self.tf_dateTaken setEnabled:YES];
                
                self.tf_dateTaken.inputView = self.pv_dateTaken;
                
                [cell.contentView addSubview:self.tf_dateTaken];
            }
        }
        
        if (self.dateTaken != nil) {
            NSDate *dateTaken = [DateTimeHelper parseWebServiceDateDouble:self.dateTaken];
            self.tf_dateTaken.text = [self.dateAndTimeFormatter stringFromDate:dateTaken];
        }
        else {            
            self.tf_dateTaken.text = nil;
        }
        
        // disable the cell until the "Edit" button is pressed
//        if (self.isEditing == YES) {
            [cell setUserInteractionEnabled:YES];
            [self.tf_dateTaken setClearButtonMode:UITextFieldViewModeAlways];
//        }
//        else {
//            [cell setUserInteractionEnabled:NO];
//            [self.tf_dateTaken setClearButtonMode:UITextFieldViewModeNever];
//        }
    }
    else if (indexPath.section == 3) {
        // Notes section
        
        CellIdentifier = @"Notes";
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        if (cell == nil) {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
            
            cell.textLabel.text = nil;
            [cell setSelectionStyle:UITableViewCellEditingStyleNone];
            
            self.tv_notes = [[UITextView alloc] initWithFrame:CGRectMake(5, 0, 290, 115)];
            self.tv_notes.font = [UIFont systemFontOfSize:16.0f];
            self.tv_notes.keyboardType = UIKeyboardTypeDefault;
            self.tv_notes.returnKeyType = UIReturnKeyDefault;
            self.tv_notes.backgroundColor = [UIColor clearColor];
            self.tv_notes.autocorrectionType = UITextAutocorrectionTypeDefault;
            self.tv_notes.autocapitalizationType = UITextAutocapitalizationTypeSentences;
            self.tv_notes.textAlignment = UITextAlignmentLeft;
            self.tv_notes.delegate = self;
            
            [cell.contentView addSubview:self.tv_notes];
            
        }
        
        if (self.notes != nil) {
            self.tv_notes.text = self.notes;
        }
        else {
            self.tv_notes.text = nil;
        }
        
        // disable the cell until the "Edit" button is pressed
        if (self.isEditing == YES) {
            [cell setUserInteractionEnabled:YES];
        }
        else {
            [cell setUserInteractionEnabled:NO];
        }
    }
    else {
        CellIdentifier = @"Default";
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        if (cell == nil) {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        }
        
        // disable the cell until the "Edit" button is pressed
        if (self.isEditing == YES) {
            [cell setUserInteractionEnabled:YES];
        }
        else {
            [cell setUserInteractionEnabled:NO];
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
    if (indexPath.section == 3) {
        return 115.0f;
    }
    else {
        return 45.0f;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    ResourceContext *resourceContext = [ResourceContext instance];
    PrescriptionInstance *prescriptionInstance = (PrescriptionInstance *)[resourceContext resourceWithType:PRESCRIPTIONINSTANCE withID:self.prescriptionInstanceID];
    
    ClifePrescriptionDetailsViewController *prescriptionDetailsVC = [ClifePrescriptionDetailsViewController createInstanceForPrescriptionWithID:prescriptionInstance.prescriptionid];
    
    [prescriptionDetailsVC setHidesBottomBarWhenPushed:YES];
    [self.navigationController pushViewController:prescriptionDetailsVC animated:YES];
}

#pragma mark - TextField Delegate
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    // textfield editing has begun
    
    if (textField == self.tf_dateTaken) {
        
        [self showDisabledBackgroundView];
        
        // Add the tap gesture recognizer to capture background touches which will dismiss the keyboard
        [self.v_disabledBackground addGestureRecognizer:self.gestureRecognizer];
        
        // Scroll tableview to this row
        [self.tbl_historyDetails setContentOffset:CGPointMake(0, 142) animated:YES];
        
        if ([self.dateAndTimeFormatter dateFromString:self.tf_dateTaken.text]) {
            self.pv_dateTaken.date = [self.dateAndTimeFormatter dateFromString:self.tf_dateTaken.text];
            
            NSDate* dateTaken = [self.dateAndTimeFormatter dateFromString:self.tf_dateTaken.text];
            double doubleDate = [dateTaken timeIntervalSince1970];
            self.dateTaken = [NSNumber numberWithDouble:doubleDate];
        }
        else {
            self.tf_dateTaken.text = [self.dateAndTimeFormatter stringFromDate:self.pv_dateTaken.date];
            
            NSDate* dateTaken = self.pv_dateTaken.date;
            double doubleDate = [dateTaken timeIntervalSince1970];
            self.dateTaken = [NSNumber numberWithDouble:doubleDate];
        }
        
    }
    
    // disable nav bar buttons until text entry complete
    self.navigationItem.rightBarButtonItem.enabled = NO;
    self.navigationItem.leftBarButtonItem.enabled = NO;
    
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
    
    if (textField == self.tf_dateTaken) {
        
        [self hideDisabledBackgroundView];
        
        if ([self.dateAndTimeFormatter dateFromString:enteredText]) {
            self.pv_dateTaken.date = [self.dateAndTimeFormatter dateFromString:enteredText];
            
            NSDate* dateTaken = [self.dateAndTimeFormatter dateFromString:enteredText];
            double doubleDate = [dateTaken timeIntervalSince1970];
            self.dateTaken = [NSNumber numberWithDouble:doubleDate];
        }
        else {
            self.tf_dateTaken.text = [self.dateAndTimeFormatter stringFromDate:self.pv_dateTaken.date];
            
            NSDate* dateTaken = self.pv_dateTaken.date;
            double doubleDate = [dateTaken timeIntervalSince1970];
            self.dateTaken = [NSNumber numberWithDouble:doubleDate];
        }
    }
    
    // Re-enable nav bar buttons
   self.navigationItem.rightBarButtonItem.enabled = YES;
    
}

#pragma mark - UIDatePickerView Methods
- (void)dateTakenChanged:(id)sender
{
    self.tf_dateTaken.text = [self.dateAndTimeFormatter stringFromDate:self.pv_dateTaken.date];
    
    NSDate* dateTaken = self.pv_dateTaken.date;
    double doubleDate = [dateTaken timeIntervalSince1970];
    self.dateTaken = [NSNumber numberWithDouble:doubleDate];
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

#pragma mark - Static Initializers
+ (ClifeHistoryDetailsViewController *)createInstanceForPrescriptionInstanceWithID:(NSNumber *)prescriptionInstanceID {
    ClifeHistoryDetailsViewController *instance = [[ClifeHistoryDetailsViewController alloc] initWithNibName:@"ClifeHistoryDetailsViewController" bundle:nil];
    [instance autorelease];
    
    instance.prescriptionInstanceID = prescriptionInstanceID;
    
    return instance;
}

@end
