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
#import "PrescriptionInstanceState.h"

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
@synthesize prescriptionInstanceState = m_prescriptionInstanceState;
@synthesize dateTakenIsShown        = m_dateTakenIsShown;
@synthesize av_edit                 = m_av_edit;
@synthesize presentedAsModal        = m_presentedAsModal;
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
                          NSLocalizedString(@"CONFIRMATION", nil),
                          NSLocalizedString(@"DAY AND TIME", nil),
                          NSLocalizedString(@"NOTES", nil),
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
                                    action:@selector(onEditPrescriptionInstanceButtonPressed:)];
    
    // Determine if we are in an editing state or not
    if (self.prescriptionInstanceID != nil) {
        // Existing prescription instance
        
        // get the prescription instance
        ResourceContext *resourceContext = [ResourceContext instance];
        PrescriptionInstance *prescriptionInstance = (PrescriptionInstance *)[resourceContext resourceWithType:PRESCRIPTIONINSTANCE withID:self.prescriptionInstanceID];
        
        self.dateTaken = prescriptionInstance.datetaken;
        self.prescriptionInstanceState = [prescriptionInstance.state intValue];
        self.notes = prescriptionInstance.notes;
        
        if (self.prescriptionInstanceState == kUNCONFIRMED ||
            self.presentedAsModal == YES)
        {
            // We have an unconfirmed instance, or we've opened from a notification
            
            // we load up the date picker since it will likely be shown when the user confirms the state
            UIDatePicker* pickerView = [[[UIDatePicker alloc] init] autorelease];
            [pickerView sizeToFit];
            pickerView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
            [pickerView addTarget:self action:@selector(dateTakenChanged:) forControlEvents:UIControlEventValueChanged];
            pickerView.datePickerMode = UIDatePickerModeDateAndTime;        
            pickerView.maximumDate = [NSDate date];
            pickerView.date = [NSDate date];
            
            self.pv_dateTaken = pickerView;
            
            if (self.presentedAsModal == YES) {
                self.isEditing = YES;
                
                // add the "Done" button to the nav bar
                self.navigationItem.rightBarButtonItem = self.doneButton;
            }

        }
        else {
            self.isEditing = NO;
            
            // add the "Edit" button to the nav bar
            self.navigationItem.rightBarButtonItem = self.editButton;

        }
        
        if (self.prescriptionInstanceState == kTAKEN) {
            self.dateTakenIsShown = YES;
        }
    }
    else {
        self.dateTaken = nil;
        self.prescriptionInstanceState = kUNCONFIRMED;
        self.notes = nil;
        
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
    self.av_edit = nil;
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
    if (section == 2) {
        if (self.prescriptionInstanceState == kTAKEN) {
            // Taken state
            return 2;
        }
        else {
            // Not Taken state
            return 1;
        }
    }
    else {
        return 1;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [self.sectionsArray objectAtIndex:section];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section == 1 &&
        (self.prescriptionInstanceState == kUNCONFIRMED))
    {
        UIView *v_header = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 47)];
        v_header.backgroundColor = [UIColor clearColor];
        
        UIImageView *iv_badge = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 53, 45)];
        iv_badge.image = [UIImage imageNamed:@"warningLarge.png"];
        
        // Show confirmation warning label
        UILabel *lbl_warning = [[UILabel alloc] initWithFrame:CGRectMake(53, 0, 267, 45)];
        lbl_warning.text = NSLocalizedString(@"WARNING", nil);
        lbl_warning.textColor = [UIColor darkGrayColor];
        lbl_warning.shadowColor = [UIColor whiteColor];
        lbl_warning.shadowOffset = CGSizeMake(0, 1);
        lbl_warning.numberOfLines = 0;
        lbl_warning.lineBreakMode = UILineBreakModeWordWrap;
        lbl_warning.backgroundColor = [UIColor yellowColor];
        lbl_warning.textAlignment = UITextAlignmentCenter;
        lbl_warning.adjustsFontSizeToFitWidth = YES;
        lbl_warning.backgroundColor = [UIColor yellowColor];
        
        [v_header addSubview:iv_badge];
        [v_header addSubview:lbl_warning];
        
        return v_header;
    }
    else {
        return nil;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 1 &&
        (self.prescriptionInstanceState == kUNCONFIRMED))
    {        
        return 47.0f;
    }
    else {
        return 34.0f;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView configureCellWithIdentifier:(NSString *)CellIdentifier {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    // Get the prescription instance object
    ResourceContext *resourceContext = [ResourceContext instance];
    PrescriptionInstance *prescriptionInstance = (PrescriptionInstance *)[resourceContext resourceWithType:PRESCRIPTIONINSTANCE withID:self.prescriptionInstanceID];
    
    if ([CellIdentifier isEqualToString:@"ConfirmationButton"]) {
        if (cell == nil) {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
            
            [cell setSelectionStyle:UITableViewCellEditingStyleNone];
            
            NSArray *segmentTitles = [NSArray arrayWithObjects:NSLocalizedString(@"TAKEN", nil), NSLocalizedString(@"NOT TAKEN", nil), nil];
            
            self.sc_confirmation = [[UISegmentedControl alloc] initWithItems:segmentTitles];
            self.sc_confirmation.frame = CGRectMake(-1, -1, 302, 47);
            [self.sc_confirmation addTarget:self action:@selector(stateDidChange:) forControlEvents:UIControlEventValueChanged];
            
            cell.contentView.backgroundColor = [UIColor clearColor];
            
            [cell.contentView addSubview:self.sc_confirmation];
        }
        
        switch (self.prescriptionInstanceState) {
            case kTAKEN:
                self.sc_confirmation.selectedSegmentIndex = 0;
                break;
                
            case kNOTTAKEN:
                self.sc_confirmation.selectedSegmentIndex = 1;
                break;
                
            default:
                break;
        }
        
        if (self.prescriptionInstanceState == kUNCONFIRMED)
        {
            // We have an unconfirmed instance
            self.sc_confirmation.enabled = YES;
        }
        else if (self.isEditing == YES) {
            self.sc_confirmation.enabled = YES;
        }
        else {
            self.sc_confirmation.enabled = NO;
        }
    }
    else if ([CellIdentifier isEqualToString:@"DayAndTimeScheduled"]) {
        if (cell == nil) {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];
            cell.textLabel.text = NSLocalizedString(@"SCHEDULED", nil);
            cell.detailTextLabel.textColor = [UIColor darkGrayColor];
            
            [cell setSelectionStyle:UITableViewCellEditingStyleNone];
        }
        
        NSDate *dateScheduled = [DateTimeHelper parseWebServiceDateDouble:prescriptionInstance.datescheduled];
        cell.detailTextLabel.text = [self.dateAndTimeFormatter stringFromDate:dateScheduled];
    }
    else if ([CellIdentifier isEqualToString:@"DayAndTimeTaken"]) {
        if (cell == nil) {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
            
            [cell setSelectionStyle:UITableViewCellEditingStyleNone];
            
            cell.textLabel.text = NSLocalizedString(@"TAKEN", nil);
            
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
            }
            
            self.tf_dateTaken = [[UITextField alloc] initWithFrame:CGRectMake(80, 0, 200, 21)];
            self.tf_dateTaken.adjustsFontSizeToFitWidth = YES;
            self.tf_dateTaken.placeholder = NSLocalizedString(@"ENTER DATE AND TIME", nil);
            self.tf_dateTaken.backgroundColor = [UIColor clearColor];
            self.tf_dateTaken.textAlignment = UITextAlignmentRight;
            self.tf_dateTaken.delegate = self;
            [self.tf_dateTaken setEnabled:YES];
            
            self.tf_dateTaken.inputView = self.pv_dateTaken;
            
            cell.accessoryView = self.tf_dateTaken;
        }
        
        if (self.dateTaken != nil) {
            NSDate *dateTaken = [DateTimeHelper parseWebServiceDateDouble:self.dateTaken];
            self.tf_dateTaken.backgroundColor = [UIColor clearColor];
            self.tf_dateTaken.text = [self.dateAndTimeFormatter stringFromDate:dateTaken];
        }
        else {            
            self.tf_dateTaken.text = nil;
        }
        
        // disable the cell until the "Edit" button is pressed
        if (self.isEditing == YES) {
            [cell setUserInteractionEnabled:YES];
            [self.tf_dateTaken setClearButtonMode:UITextFieldViewModeAlways];
        }
        else {
            [cell setUserInteractionEnabled:NO];
            [self.tf_dateTaken setClearButtonMode:UITextFieldViewModeNever];
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
        // Confirmation section
        
        // Confirmation Button
        CellIdentifier = @"ConfirmationButton";
        
        cell = [self tableView:tableView configureCellWithIdentifier:CellIdentifier];
    }
    else if (indexPath.section == 2) {
        if (self.prescriptionInstanceState == kTAKEN) {
            if (indexPath.row == 0) {
                // Day and Time Scheduled
                CellIdentifier = @"DayAndTimeScheduled";
            }
            else if (indexPath.row == 1) {
                // Day and Time Taken
                CellIdentifier = @"DayAndTimeTaken";
            }
        }
        else {
            // Day and Time Scheduled
            CellIdentifier = @"DayAndTimeScheduled";
        }
        
        cell = [self tableView:tableView configureCellWithIdentifier:CellIdentifier];
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
    else if (indexPath.section == 1) {
        return 45.0f;
    }
    else {
        return 46.0f;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section == 0 && indexPath.row == 0) {
        ResourceContext *resourceContext = [ResourceContext instance];
        PrescriptionInstance *prescriptionInstance = (PrescriptionInstance *)[resourceContext resourceWithType:PRESCRIPTIONINSTANCE withID:self.prescriptionInstanceID];
        
        ClifePrescriptionDetailsViewController *prescriptionDetailsVC = [ClifePrescriptionDetailsViewController createInstanceForPrescriptionWithID:prescriptionInstance.prescriptionid isEditable:NO];
        
        [prescriptionDetailsVC setHidesBottomBarWhenPushed:YES];
        [self.navigationController pushViewController:prescriptionDetailsVC animated:YES];
    }
    else if (indexPath.section == 2 && indexPath.row == 1) {
        // Date Taken selected
        
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        
        // Set the date taken text field as active
        [self.tf_dateTaken becomeFirstResponder];
    }
    else if (indexPath.section == 3 && indexPath.row == 0) {
        // Notes selected
        
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        
        // Set the notes text view as active
        [self.tv_notes becomeFirstResponder];
    }
}

#pragma mark - UITextview and TextField Delegate Methods
- (void)textViewDidBeginEditing:(UITextView *)textView
{
    // notes textview editing has begun
    self.tv_notes = textView;
    
    // Scroll tableview to this row
    [self.tbl_historyDetails setContentOffset:CGPointMake(0, 320) animated:YES];
    
    // Disable the table view scrolling
    [self.tbl_historyDetails setScrollEnabled:NO];
    
    // Add the tap gesture recognizer to capture background touches which will dismiss the keyboard
    [self.tbl_historyDetails addGestureRecognizer:self.gestureRecognizer];
    
    // Mark this row selected
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:3];
    [self.tbl_historyDetails selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
    
//    // disable nav bar buttons until text entry complete
//    self.navigationItem.rightBarButtonItem.enabled = NO;
    
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
    
    // Plug the keyboardDoneButtonView into the text view.
    textView.inputAccessoryView = keyboardDoneButtonView;
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    // reason textview editing has ended
    self.tv_notes = textView;
    
    // Scroll tableview to this row
    [self.tbl_historyDetails setContentOffset:CGPointMake(0, 85) animated:YES];
    
    // Deselect this row
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:3];
    [self.tbl_historyDetails deselectRowAtIndexPath:indexPath animated:NO];
    
    NSString *trimmedReason = [self.tv_notes.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if (![trimmedReason isEqualToString:@""] ||
        trimmedReason != nil)
    {
        // note is acceptable
        self.notes = trimmedReason;
    }
    else {
        self.notes = nil;
        
    }
    
    self.navigationItem.rightBarButtonItem.enabled = YES;
    
    // remove the tap gesture recognizer so it does not interfere with other table view touches
    [self.tbl_historyDetails removeGestureRecognizer:self.gestureRecognizer];
    
    // Re-enable the table view scrolling
    [self.tbl_historyDetails setScrollEnabled:YES];
    
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
        [self.tbl_historyDetails setContentOffset:CGPointMake(0, 155) animated:YES];
        
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
        
        self.tf_dateTaken.backgroundColor = [UIColor clearColor];
        
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
    
    // Scroll tableview back to the top
    [self.tbl_historyDetails setContentOffset:CGPointMake(0, 0) animated:YES];
    
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
- (void)stateDidChange:(id)sender {
    
    // Update the prescription instance state
    self.isEditing = YES;
    
    // Hide the back button
    [self.navigationItem setHidesBackButton:YES animated:YES];
    
    // add the "Done" button to the nav bar
    self.navigationItem.rightBarButtonItem = self.doneButton;
    
    switch (self.sc_confirmation.selectedSegmentIndex) {
        case 0:
            self.prescriptionInstanceState = kTAKEN;
            break;
            
        case 1:
            self.prescriptionInstanceState = kNOTTAKEN;
            break;
            
        default:
            self.prescriptionInstanceState = kUNCONFIRMED;
            break;
    }
    
    if (self.sc_confirmation.selectedSegmentIndex == 0 &&
        self.dateTakenIsShown == NO)
    {
        // We need to add the date taken row
        [self.tbl_historyDetails insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:1 inSection:2]] withRowAnimation:UITableViewRowAnimationTop];
        self.dateTakenIsShown = YES;
    }
    else if (self.sc_confirmation.selectedSegmentIndex == 1 && 
             self.dateTakenIsShown == YES)
    {
        // We need to remove the date taken row
        [self.tbl_historyDetails deleteRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:1 inSection:2]] withRowAnimation:UITableViewRowAnimationTop];
        self.dateTakenIsShown = NO;
    }
    else if (self.sc_confirmation.selectedSegmentIndex == 1 && 
             self.dateTakenIsShown == NO)
    {
        [self.tbl_historyDetails reloadData];
    }
    
    if (self.sc_confirmation.selectedSegmentIndex == 0) {
        // force user to update the day and time taken
        NSDate *dateTaken;
        if (self.dateTaken != nil) {
            dateTaken = [DateTimeHelper parseWebServiceDateDouble:self.dateTaken];
        }
        else {
            dateTaken = [NSDate date];
            double doubleDate = [dateTaken timeIntervalSince1970];
            self.dateTaken = [NSNumber numberWithDouble:doubleDate];
        }
        self.pv_dateTaken.date = dateTaken;
        [self.tf_dateTaken performSelector:@selector(becomeFirstResponder) withObject:nil afterDelay:0.2];
//        [self.tf_dateTaken becomeFirstResponder];
    }
}

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

- (void)editPrescriptionInstance {
    self.isEditing = YES;
    
    // Reload the table view to enable user interaction and accessory views on the tableview cells
    [self.tbl_historyDetails reloadData];
    
    // add the "Done" button to the nav bar
    self.navigationItem.rightBarButtonItem = self.doneButton;
    
}

- (void)doneEditingPrescriptionInstance:(id)sender {
    if (self.prescriptionInstanceState == kTAKEN && self.dateTaken == nil)
    {
        // Promt user to complete all fields
        UIAlertView* alert = [[UIAlertView alloc]
                              initWithTitle:NSLocalizedString(@"INCOMPLETE", nil)
                              message:NSLocalizedString(@"INCOMPLETE MESSAGE", nil)
                              delegate:self
                              cancelButtonTitle:NSLocalizedString(@"CANCEL", nil)
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
        
        // Update the prescription instance properties and save
        ResourceContext *resourceContext = [ResourceContext instance];
        PrescriptionInstance *prescriptionInstance = (PrescriptionInstance *)[resourceContext resourceWithType:PRESCRIPTIONINSTANCE withID:self.prescriptionInstanceID];
        
        // Set the date taken to nil if this prescription has not been confirmed as taken
        if (self.prescriptionInstanceState != kTAKEN) {
            self.dateTaken = nil;
        }
        
        prescriptionInstance.datetaken = self.dateTaken;
        prescriptionInstance.state = [NSNumber numberWithInt:self.prescriptionInstanceState];
        prescriptionInstance.notes = self.notes;
        
        [resourceContext save:NO onFinishCallback:nil trackProgressWith:nil];
        
        // Reload the table view to disable user interaction and accessory views on the tableview cells
        [self.tbl_historyDetails reloadData];
        
        // Scroll tableview back to the top
        [self.tbl_historyDetails setContentOffset:CGPointMake(0, 0) animated:YES];
        
        if (self.presentedAsModal == YES) {
            // This is the case that we have launched the History Details View Controller from a notification
            [self dismissModalViewControllerAnimated:YES];
        }
    }
}

- (void)onEditPrescriptionInstanceButtonPressed:(id)sender {
    // Promt user to backup data before editing profile information
    self.av_edit = [[UIAlertView alloc]
                    initWithTitle:NSLocalizedString(@"EDIT HISTORY", nil)
                    message:NSLocalizedString(@"EDIT HISTORY MESSAGE", nil)
                    delegate:self
                    cancelButtonTitle:NSLocalizedString(@"YES", nil)
                    otherButtonTitles:NSLocalizedString(@"NO", nil), nil];
    [self.av_edit show];
    [self.av_edit release];
}

#pragma mark - UIAlertView Delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView == self.av_edit) {
        if (buttonIndex == 0) {
            // Backup data
            NSLog(@"Backup data");
        }
        else {
            [self editPrescriptionInstance];
        }
    }
}

#pragma mark - Static Initializers
+ (ClifeHistoryDetailsViewController *)createInstanceForPrescriptionInstanceWithID:(NSNumber *)prescriptionInstanceID {
    ClifeHistoryDetailsViewController *instance = [[ClifeHistoryDetailsViewController alloc] initWithNibName:@"ClifeHistoryDetailsViewController" bundle:nil];
    [instance autorelease];
    
    instance.prescriptionInstanceID = prescriptionInstanceID;
    
    return instance;
}

@end
