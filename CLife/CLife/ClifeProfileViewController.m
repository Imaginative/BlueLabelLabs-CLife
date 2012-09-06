//
//  ClifeProfileViewController.m
//  CLife
//
//  Created by Jasjeet Gill on 8/9/12.
//  Copyright (c) 2012 Blue Label Solutions LLC. All rights reserved.
//

#import "ClifeProfileViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "DateTimeHelper.h"

@interface ClifeProfileViewController ()

@end

@implementation ClifeProfileViewController
@synthesize tbl_profile         = m_tbl_profile;
@synthesize sectionsArray       = m_sectionsArray;
@synthesize tf_name             = m_tf_name;
@synthesize tf_birthday         = m_tf_birthday;
@synthesize tf_gender           = m_tf_gender;
@synthesize tf_bloodType        = m_tf_bloodType;
@synthesize gestureRecognizer   = m_gestureRecognizer;
@synthesize pv_birthday         = m_pv_birthday;
@synthesize dateFormatter       = m_dateFormatter;
@synthesize pv_gender           = m_pv_gender;
@synthesize pv_bloodType        = m_pv_bloodType;
@synthesize genderArray         = m_genderArray;
@synthesize bloodTypeArray      = m_bloodTypeArray;
@synthesize v_disabledBackground = m_v_disabledBackground;
@synthesize lbl_disableTabBar   = m_lbl_disableTabBar;
@synthesize isEditing           = m_isEditing;
@synthesize isNewUser           = m_isNewUser;
@synthesize name                = m_name;
@synthesize birthday            = m_birthday;
@synthesize gender              = m_gender;
@synthesize bloodType           = m_bloodType;
@synthesize av_edit             = m_av_edit;
@synthesize av_delete           = m_av_delete;


#pragma mark - Initialization

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"PROFILE", nil);
        self.tabBarItem.image = [UIImage imageNamed:@"icon-profile.png"];
    }
    return self;
}
							
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    // Setup date formatter for birthday picker
    self.dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
    [self.dateFormatter setDateStyle:NSDateFormatterLongStyle];
    [self.dateFormatter setTimeStyle:NSDateFormatterNoStyle];
    
    // Setup array for section titles
    self.sectionsArray = [NSArray arrayWithObjects:
                          NSLocalizedString(@"NAME", nil),
                          NSLocalizedString(@"BIRTHDAY", nil),
                          NSLocalizedString(@"GENDER", nil),
                          NSLocalizedString(@"BLOOD TYPE", nil),
                          nil];
    
    // Setup arrays for gender and blood type pickers
    self.genderArray = [NSArray arrayWithObjects:
                        NSLocalizedString(@"MALE", nil), 
                        NSLocalizedString(@"FEMALE", nil), 
                        nil];
    
    self.bloodTypeArray = [NSArray arrayWithObjects:
                           NSLocalizedString(@"A", nil), 
                           NSLocalizedString(@"B", nil), 
                           NSLocalizedString(@"AB", nil), 
                           NSLocalizedString(@"O", nil), 
                           nil];
    
    // Setup tap gesture recognizer to capture touches on the tableview when the keyboard is visible
    self.gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideInputView)];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];

    // Are we opening an existing prescription or adding a new one?
    if (self.loggedInUser.username != nil &&
        ![self.loggedInUser.displayname isEqualToString:@""])
    {
        // Existing user
        self.isEditing = NO;
        self.isNewUser = NO;
        
        // add the "Edit" button to the nav bar
        UIBarButtonItem* rightButton = [[UIBarButtonItem alloc]
                                        initWithBarButtonSystemItem:UIBarButtonSystemItemEdit
                                        target:self
                                        action:@selector(onEditProfileButtonPressed:)];
        self.navigationItem.rightBarButtonItem = rightButton;
        [rightButton release];
        
        // Set profile values to that of the logged in user
        self.name = self.loggedInUser.username;
        self.birthday = self.loggedInUser.dateborn;
        self.gender = self.loggedInUser.sex;
        self.bloodType = self.loggedInUser.bloodtype;
    }
    else {
        // We are adding a new user
        self.isEditing = YES;
        self.isNewUser = YES;
        
        // add the "Done" button to the nav bar
        UIBarButtonItem* rightButton = [[UIBarButtonItem alloc]
                                        initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                        target:self
                                        action:@selector(doneEditingProfile:)];
        self.navigationItem.rightBarButtonItem = rightButton;
        [rightButton release];
        
        // Set profile values to nil
        self.name = nil;
        self.birthday = nil;
        self.gender = nil;
        self.bloodType = nil;

    }
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (self.isEditing == YES) {
        [self hideTabBar];
    }
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    
    self.tbl_profile = nil;
    self.tf_name = nil;
    self.tf_birthday = nil;
    self.tf_gender = nil;
    self.tf_bloodType = nil;
    self.gestureRecognizer = nil;
    self.pv_birthday = nil;
    self.dateFormatter = nil;
    self.pv_gender = nil;
    self.pv_bloodType = nil;
    self.v_disabledBackground = nil;
    self.lbl_disableTabBar = nil;
    self.av_edit = nil;
    self.av_delete = nil;
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
    // Configure the cell...
    NSString *CellIdentifier;
    UITableViewCell *cell;
    
    if (indexPath.section == 0) {
        // Name section
        
        CellIdentifier = @"Name";
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        if (cell == nil) {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
            
            [cell setSelectionStyle:UITableViewCellEditingStyleNone];
            
            self.tf_name = [[UITextField alloc] initWithFrame:CGRectMake(8, 11, 282, 21)];
            self.tf_name.font = [UIFont systemFontOfSize:17.0];
            self.tf_name.adjustsFontSizeToFitWidth = YES;
            self.tf_name.textColor = [UIColor blackColor];
            self.tf_name.placeholder = NSLocalizedString(@"ENTER FULL NAME", nil);
            self.tf_name.backgroundColor = [UIColor clearColor];
            self.tf_name.textAlignment = UITextAlignmentLeft;
            self.tf_name.delegate = self;
            [self.tf_name setEnabled:YES];
            
            self.tf_name.keyboardType = UIKeyboardTypeDefault;
            self.tf_name.returnKeyType = UIReturnKeyDone;
            self.tf_name.autocorrectionType = UITextAutocorrectionTypeNo;
            self.tf_name.autocapitalizationType = UITextAutocapitalizationTypeWords;
            
            [cell.contentView addSubview:self.tf_name];
            
        }
        
        if (self.name != nil) {
            self.tf_name.text = self.name;
        }
        else {
            self.tf_name.text = nil;
        }
        
        // disable the cell until the "Edit" button is pressed
        if (self.isEditing == YES) {
            [cell setUserInteractionEnabled:YES];
            [self.tf_name setClearButtonMode:UITextFieldViewModeAlways];
        }
        else {
            [cell setUserInteractionEnabled:NO];
            [self.tf_name setClearButtonMode:UITextFieldViewModeNever];
        }
    }
    else if (indexPath.section == 1) {
        // Birthday section
        
        CellIdentifier = @"Birthday";
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        if (cell == nil) {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
            
            [cell setSelectionStyle:UITableViewCellEditingStyleNone];
            
            // Initialize the birthday picker view
            if (self.pv_birthday == nil) {
                UIDatePicker* pickerView = [[[UIDatePicker alloc] init] autorelease];
                [pickerView sizeToFit];
                pickerView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
                [pickerView addTarget:self action:@selector(dateChanged:) forControlEvents:UIControlEventValueChanged];
                pickerView.datePickerMode = UIDatePickerModeDate;
                pickerView.maximumDate = [NSDate date];
                
                self.pv_birthday = pickerView;
                
                self.tf_birthday = [[UITextField alloc] initWithFrame:CGRectMake(8, 11, 282, 21)];
                self.tf_birthday.font = [UIFont systemFontOfSize:17.0];
                self.tf_birthday.adjustsFontSizeToFitWidth = YES;
                self.tf_birthday.textColor = [UIColor blackColor];
                self.tf_birthday.placeholder = NSLocalizedString(@"ENTER BIRTHDAY", nil);
                self.tf_birthday.backgroundColor = [UIColor clearColor];
                self.tf_birthday.textAlignment = UITextAlignmentLeft;
                self.tf_birthday.delegate = self;
                [self.tf_birthday setEnabled:YES];
                
                self.tf_birthday.inputView = self.pv_birthday;
                
                [cell.contentView addSubview:self.tf_birthday];
            }
        }
        
        if (self.birthday != nil) {
            NSDate *birthday = [DateTimeHelper parseWebServiceDateDouble:self.birthday];
            self.tf_birthday.text = [self.dateFormatter stringFromDate:birthday];
        }
        else {
            self.tf_birthday.text = nil;
        }
        
        // disable the cell until the "Edit" button is pressed
        if (self.isEditing == YES) {
            [cell setUserInteractionEnabled:YES];
            [self.tf_birthday setClearButtonMode:UITextFieldViewModeAlways];
        }
        else {
            [cell setUserInteractionEnabled:NO];
            [self.tf_birthday setClearButtonMode:UITextFieldViewModeNever];
        }
    }
    else if (indexPath.section == 2) {
        // Gender section
        
        CellIdentifier = @"Gender";
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        if (cell == nil) {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
            
            [cell setSelectionStyle:UITableViewCellEditingStyleNone];
            
            // Initialize the gender picker view
            if (self.pv_gender == nil) {
                UIPickerView* pickerView = [[[UIPickerView alloc] init] autorelease];
                [pickerView sizeToFit];
                pickerView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
                pickerView.dataSource = self;
                pickerView.delegate = self;
                pickerView.showsSelectionIndicator = YES;
                
                self.pv_gender = pickerView;
                
                self.tf_gender = [[UITextField alloc] initWithFrame:CGRectMake(8, 11, 282, 21)];
                self.tf_gender.font = [UIFont systemFontOfSize:17.0];
                self.tf_gender.adjustsFontSizeToFitWidth = YES;
                self.tf_gender.textColor = [UIColor blackColor];
                self.tf_gender.placeholder = NSLocalizedString(@"SELECT GENDER", nil);
                self.tf_gender.backgroundColor = [UIColor clearColor];
                self.tf_gender.textAlignment = UITextAlignmentLeft;
                self.tf_gender.delegate = self;
                [self.tf_gender setEnabled:YES];
                
                self.tf_gender.inputView = self.pv_gender;
                
                [cell.contentView addSubview:self.tf_gender];
            }
        }
        
        if (self.gender != nil) {
            self.tf_gender.text = self.gender;
        }
        else {
            self.tf_gender.text = nil;
        }
        
        // disable the cell until the "Edit" button is pressed
        if (self.isEditing == YES) {
            [cell setUserInteractionEnabled:YES];
            [self.tf_gender setClearButtonMode:UITextFieldViewModeAlways];
        }
        else {
            [cell setUserInteractionEnabled:NO];
            [self.tf_gender setClearButtonMode:UITextFieldViewModeNever];
        }
    }
    else if (indexPath.section == 3) {
        // Blood Type section
        
        CellIdentifier = @"BloodType";
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        if (cell == nil) {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];

            
            [cell setSelectionStyle:UITableViewCellEditingStyleNone];
            
            // Initialize the blood type picker view
            if (self.pv_bloodType == nil) {
                UIPickerView* pickerView = [[[UIPickerView alloc] init] autorelease];
                [pickerView sizeToFit];
                pickerView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
                pickerView.dataSource = self;
                pickerView.delegate = self;
                pickerView.showsSelectionIndicator = YES;
                
                self.pv_bloodType = pickerView;
                
                self.tf_bloodType = [[UITextField alloc] initWithFrame:CGRectMake(8, 11, 282, 21)];
                self.tf_bloodType.font = [UIFont systemFontOfSize:17.0];
                self.tf_bloodType.adjustsFontSizeToFitWidth = YES;
                self.tf_bloodType.textColor = [UIColor blackColor];
                self.tf_bloodType.placeholder = NSLocalizedString(@"SELECT BLOOD TYPE", nil);
                self.tf_bloodType.backgroundColor = [UIColor clearColor];
                self.tf_bloodType.textAlignment = UITextAlignmentLeft;
                self.tf_bloodType.delegate = self;
                [self.tf_bloodType setEnabled:YES];
                
                self.tf_bloodType.inputView = self.pv_bloodType;
                
                [cell.contentView addSubview:self.tf_bloodType];
            }
        }
        
        if (self.bloodType != nil) {
            self.tf_bloodType.text = self.bloodType;
        }
        else {
            self.tf_bloodType.text = nil;
        }
        
        // disable the cell until the "Edit" button is pressed
        if (self.isEditing == YES) {
            [cell setUserInteractionEnabled:YES];
            [self.tf_bloodType setClearButtonMode:UITextFieldViewModeAlways];
        }
        else {
            [cell setUserInteractionEnabled:NO];
            [self.tf_bloodType setClearButtonMode:UITextFieldViewModeNever];
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        // Name selected
        
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        
        // Set the name text field as active
        [self.tf_name becomeFirstResponder];
        
    }
    else if (indexPath.section == 1) {
        // Birthday selected
        
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        
        // Set the birthday text field as active
        [self.tf_birthday becomeFirstResponder];
        
    }
    else if (indexPath.section == 2) {
        // Gender selected
        
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        
        // Set the gender text field as active
        [self.tf_gender becomeFirstResponder];
        
    }
    else if (indexPath.section == 3) {
        // Blood Type selected
        
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        
        // Set the gender text field as active
        [self.tf_bloodType becomeFirstResponder];
        
    }
}

#pragma mark - UIPickerView Methods
#pragma mark UIDatePickerView Methods
- (void)dateChanged:(id)sender
{
    self.tf_birthday.text = [self.dateFormatter stringFromDate:self.pv_birthday.date];
    
    NSDate* birthday = self.pv_birthday.date;
    double doubleDate = [birthday timeIntervalSince1970];
    self.birthday = [NSNumber numberWithDouble:doubleDate];
}

#pragma mark UIPickerView Data Source
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    if (pickerView == self.pv_gender) {
        return [self.genderArray count];
    }
    else if (pickerView == self.pv_bloodType) {
        return [self.bloodTypeArray count];
    }
    else {
        return 0;
    }
}

#pragma mark UIPickerView Delegate
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    if (pickerView == self.pv_gender) {
        return [self.genderArray objectAtIndex:row];
    }
    else if (pickerView == self.pv_bloodType) {
        return [self.bloodTypeArray objectAtIndex:row];
    }
    else {
        return nil;
    }
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    if (pickerView == self.pv_gender) {
        self.tf_gender.text = [self.genderArray objectAtIndex:row];
        
        self.gender = [self.genderArray objectAtIndex:row];
    }
    else if (pickerView == self.pv_bloodType) {
        self.tf_bloodType.text = [self.bloodTypeArray objectAtIndex:row];
        
        self.bloodType = [self.bloodTypeArray objectAtIndex:row];
    }
}

#pragma mark - TextField Delegate
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    // textfield editing has begun
    
    // Determine which text field is active and make appropriate changes
    if (textField == self.tf_name) {
        // Disable the table view scrolling
        [self.tbl_profile setScrollEnabled:NO];
        
        // Add the tap gesture recognizer to capture background touches which will dismiss the keyboard
        [self.tbl_profile addGestureRecognizer:self.gestureRecognizer];
        
    }
    else if (textField == self.tf_birthday) {
        
        [self showDisabledBackgroundView];
        
        // Add the tap gesture recognizer to capture background touches which will dismiss the keyboard
        [self.v_disabledBackground addGestureRecognizer:self.gestureRecognizer];
        
        // Scroll tableview to this row
        [self.tbl_profile setContentOffset:CGPointMake(0, 45) animated:YES];
        
        if ([self.dateFormatter dateFromString:self.tf_birthday.text]) {
            self.pv_birthday.date = [self.dateFormatter dateFromString:self.tf_birthday.text];
            
            NSDate* birthday = [self.dateFormatter dateFromString:self.tf_birthday.text];
            double doubleDate = [birthday timeIntervalSince1970];
            self.birthday = [NSNumber numberWithDouble:doubleDate];
        }
        else {
            self.tf_birthday.text = [self.dateFormatter stringFromDate:self.pv_birthday.date];
            
            NSDate* birthday = self.pv_birthday.date;
            double doubleDate = [birthday timeIntervalSince1970];
            self.birthday = [NSNumber numberWithDouble:doubleDate];
        }
        
    }
    else if (textField == self.tf_gender) {
        
        [self showDisabledBackgroundView];
        
        // Add the tap gesture recognizer to capture background touches which will dismiss the keyboard
        [self.v_disabledBackground addGestureRecognizer:self.gestureRecognizer];
        
        // Scroll tableview to this row
        [self.tbl_profile setContentOffset:CGPointMake(0, 125) animated:YES];
        
        if ([self.tf_gender.text isEqualToString:@""] == NO &&
            [self.tf_gender.text isEqualToString:@" "] == NO)
        {
            int row = [self.genderArray indexOfObject:self.tf_gender.text];
            [self.pv_gender selectRow:row inComponent:0 animated:YES];
            
            self.gender = [self.genderArray objectAtIndex:row];
        }
        else {
            self.tf_gender.text = [self.genderArray objectAtIndex:0];
            
            self.gender = [self.genderArray objectAtIndex:0];
        }
        
    }
    else if (textField == self.tf_bloodType) {
        
        [self showDisabledBackgroundView];
        
        // Add the tap gesture recognizer to capture background touches which will dismiss the keyboard
        [self.v_disabledBackground addGestureRecognizer:self.gestureRecognizer];
        
        // Scroll tableview to this row
        [self.tbl_profile setContentOffset:CGPointMake(0, 215) animated:YES];
        
        if ([self.tf_bloodType.text isEqualToString:@""] == NO &&
            [self.tf_bloodType.text isEqualToString:@" "] == NO)
        {
            int row = [self.bloodTypeArray indexOfObject:self.tf_bloodType.text];
            [self.pv_bloodType selectRow:row inComponent:0 animated:YES];
            
            self.bloodType = [self.bloodTypeArray objectAtIndex:row];
        }
        else {
            self.tf_bloodType.text = [self.bloodTypeArray objectAtIndex:0];
            
            self.bloodType = [self.bloodTypeArray objectAtIndex:0];
        }
        
    }
    
    // disable "Done" and "Delete" buttons until text entry complete
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
    
    // Determine which text field is active and make appropriate changes
    if (textField == self.tf_name) {
        // Enable the table view scrolling
        [self.tbl_profile setScrollEnabled:YES];
        
        // remove the tap gesture recognizer so it does not interfere with other table view touches
        [self.tbl_profile removeGestureRecognizer:self.gestureRecognizer];
        
        if ([enteredText isEqualToString:@""] == YES ||
            [enteredText isEqualToString:@" "] == YES)
        {
            self.name = nil;
        }
        else {
            self.name = enteredText;
        }
        
    }
    else if (textField == self.tf_birthday) {
        
        [self hideDisabledBackgroundView];
        
        if ([self.dateFormatter dateFromString:enteredText]) {
            self.pv_birthday.date = [self.dateFormatter dateFromString:enteredText];
            
            NSDate* birthday = [self.dateFormatter dateFromString:enteredText];
            double doubleDate = [birthday timeIntervalSince1970];
            self.birthday = [NSNumber numberWithDouble:doubleDate];
        }
        else {
            self.tf_birthday.text = [self.dateFormatter stringFromDate:self.pv_birthday.date];
            
            NSDate* birthday = self.pv_birthday.date;
            double doubleDate = [birthday timeIntervalSince1970];
            self.birthday = [NSNumber numberWithDouble:doubleDate];
        }
    }
    else if (textField == self.tf_gender) {
        
        [self hideDisabledBackgroundView];
        
        if ([enteredText isEqualToString:@""] == YES ||
            [enteredText isEqualToString:@" "] == YES)
        {
            self.gender = nil;
        }
        else {
            self.gender = enteredText;
        }
    }
    else if (textField == self.tf_bloodType) {
        
        [self hideDisabledBackgroundView];
        
        if ([enteredText isEqualToString:@""] == YES ||
            [enteredText isEqualToString:@" "] == YES)
        {
            self.bloodType = nil;
        }
        else {
            self.bloodType = enteredText;
        }
    }
    
    // Re-enable "Done" and "Delete" buttons
    self.navigationItem.rightBarButtonItem.enabled = YES;
    
}

//- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)text {
//    
//    return YES;
//}

// Handles keyboard Return button pressed while editing the textfield
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    [textField resignFirstResponder];
    
    return YES;
}

#pragma mark - UI Action Methods
- (void)showTabBar {
    if (self.lbl_disableTabBar.superview != nil) {
        // Now hide the covering view if it is visible
        
        [UIView animateWithDuration:0.4
                         animations:^ {
                             [self.lbl_disableTabBar setAlpha:0.0f];
                         }
                         completion:^(BOOL finished) {
                             [self.lbl_disableTabBar removeFromSuperview];
                         }];
    }
}

- (void)hideTabBar {
    CGRect tabBarFrame = self.tabBarController.tabBar.frame;
    
    // Add a view behind the tabbar that tells the user they
    // cannot move forward unitl editing is complete.
    if (self.lbl_disableTabBar == nil) {
        UILabel *label = [[[UILabel alloc]initWithFrame:CGRectMake(0.0f, 0.0f, tabBarFrame.size.width, tabBarFrame.size.height)] autorelease];
        label.text = NSLocalizedString(@"COMPLETE PROFILE WARNING", nil);
        label.numberOfLines = 0;
        label.textAlignment = UITextAlignmentCenter;
        label.backgroundColor = [UIColor redColor];
        label.textColor = [UIColor whiteColor];
        label.shadowColor = [UIColor darkGrayColor];
        label.shadowOffset = CGSizeMake(0.0f, -1.0f);
        
        // Add a border to the top of the label
        CALayer *topBorder = [CALayer layer];
        topBorder.borderColor = [UIColor darkGrayColor].CGColor;
        topBorder.borderWidth = 1;
        topBorder.frame = CGRectMake(-1, 0, label.frame.size.width+2, label.frame.size.height+2);
        [label.layer addSublayer:topBorder];
        
        label.userInteractionEnabled = YES; // This will prevent touches from being passed through to the tab bar buttons beneath
        
        self.lbl_disableTabBar = label;
    }
    
    if (self.lbl_disableTabBar.superview == nil) {
        // Now animate the showing of the label that will prevent
        // touches on the tab bar until the user is done editing.
        
        [self.lbl_disableTabBar setAlpha:0.0f];
        [self.tabBarController.tabBar addSubview:self.lbl_disableTabBar];
        
        [UIView animateWithDuration:0.3 animations:^ {
            [self.lbl_disableTabBar setAlpha:1.0f];
        }];
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

- (void)showDeleteButton {
    // add the "Delete" button to the footer of the tableview
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setBackgroundImage:[UIImage imageNamed:@"delete_red.png"] forState:UIControlStateNormal];
    [button setTitle:NSLocalizedString(@"DELETE PROFILE", nil) forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont boldSystemFontOfSize:17.0f];
    button.titleLabel.shadowColor = [UIColor lightGrayColor];
    button.titleLabel.shadowOffset = CGSizeMake(0.0f, -1.0f);
    [button.layer setCornerRadius:10.0f];
    [button.layer setMasksToBounds:YES];
    [button.layer setBorderWidth:2.0f];
    [button.layer setBorderColor: [[UIColor darkGrayColor] CGColor]];
    button.frame = CGRectMake(10.0f, 15.0f, 300.0f, 44.0f);
    
    [button addTarget:self action:@selector(onDeleteProfileButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    UIView *footer = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 80.0f)];
    [footer addSubview:button];
    
    self.tbl_profile.tableFooterView = footer;
    [footer release];
}

- (void)hideInputView {
    [[self view] endEditing:YES];
}

- (void)editProfile {
    self.isEditing = YES;
    
    // Hide the tab bar so the user cannot move forward until edit is complete
    [self hideTabBar];
    
    // Reload the table view to enable user interaction and accessory views on the tableview cells
    [self.tbl_profile reloadData];
        
    // add the "Done" button to the nav bar
    UIBarButtonItem* rightButton = [[UIBarButtonItem alloc]
                                    initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                    target:self
                                    action:@selector(doneEditingProfile:)];
    self.navigationItem.rightBarButtonItem = rightButton;
    [rightButton release];
    
    // add the "Delete" button to the table view's footer
    [self showDeleteButton];
    
}

- (void)doneEditingProfile:(id)sender {
    if (self.name == nil ||
        self.birthday == nil ||
        self.gender == nil ||
        self.bloodType == nil ||
        [self.name isEqualToString:@""] ||
        [self.gender isEqualToString:@""] ||
        [self.bloodType isEqualToString:@""])
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
        
        self.isEditing = NO;
        
        // Editing is complete, show the tab bar
        [self showTabBar];
        
        // Reload the table view to disable user interaction and accessory views on the tableview cells
        [self.tbl_profile reloadData];
        
        // Hide the keyboard if it is shown
        [self hideInputView];
        
        // add the "Edit" button back to the nav bar
        UIBarButtonItem* rightButton = [[UIBarButtonItem alloc]
                                        initWithBarButtonSystemItem:UIBarButtonSystemItemEdit
                                        target:self
                                        action:@selector(onEditProfileButtonPressed:)];
        self.navigationItem.rightBarButtonItem = rightButton;
        [rightButton release];
        
        //lets check if a user is currently logged in
        AuthenticationManager* authenticationManager = [AuthenticationManager instance];
        if (![authenticationManager isUserAuthenticated])
        {   
            //there is no user object currently logged in,
            //we instruct the authenticatoin manager to create a new user object and log that in
            User* newUser = [authenticationManager createNewUserAndLogin];
            if (newUser != nil)
            {
                //success everything workedJordan
                
            }
            else {
                //error condition
                
            }
        }
        
        //now we update the user object iwth the changed properties
        self.loggedInUser.username = self.name;
        self.loggedInUser.dateborn = self.birthday;
        self.loggedInUser.sex = self.gender;
        self.loggedInUser.bloodtype = self.bloodType;
        
        //now we save the changes
        ResourceContext* resourceContext = [ResourceContext instance];
        [resourceContext save:NO onFinishCallback:nil trackProgressWith:nil];
        
        // remove the "Delete" button
        self.tbl_profile.tableFooterView = nil;
        
        // Scroll tableview back to the top
        [self.tbl_profile setContentOffset:CGPointMake(0, 0) animated:YES];
    }
}

- (void)deleteProfile {
    // Log the user off
    AuthenticationManager* authenticationManager = [AuthenticationManager instance];
    [authenticationManager logoff];
    
    // Delete the profile object
    ResourceContext *resourceContext = [ResourceContext instance];
    [resourceContext delete:self.loggedInUser.objectid withType:USER];
    
    self.loggedInUser.objectid = nil;
    self.name = nil;
    self.birthday = nil;
    self.gender = nil;
    self.bloodType = nil;
    
    self.isEditing = YES;
    self.isNewUser = YES;
    
    [self.tbl_profile reloadData];
    
    [self editProfile];
    
    // remove the "Delete" button
    self.tbl_profile.tableFooterView = nil;
}

- (void)onEditProfileButtonPressed:(id)sender {
    // Promt user to backup data before editing profile information
    self.av_edit = [[UIAlertView alloc]
                          initWithTitle:NSLocalizedString(@"EDIT PROFILE", nil)
                          message:NSLocalizedString(@"EDIT PROFILE MESSAGE", nil)
                          delegate:self
                          cancelButtonTitle:NSLocalizedString(@"YES", nil)
                          otherButtonTitles:NSLocalizedString(@"NO", nil), nil];
    [self.av_edit show];
    [self.av_edit release];
}

- (void)onDeleteProfileButtonPressed:(id)sender {    
    // Prompt user to backup data before editing profile information
    UIActionSheet* actionSheet = [[UIActionSheet alloc]
                                  initWithTitle:NSLocalizedString(@"DELETE PROFILE MESSAGE", nil)
                                  delegate:self
                                  cancelButtonTitle:NSLocalizedString(@"CANCEL", nil)
                                  destructiveButtonTitle:NSLocalizedString(@"DELETE WITHOUT DATA EXPORT", nil)
                                  otherButtonTitles:NSLocalizedString(@"DELETE WITH DATA EXPORT", nil), nil];
    [actionSheet showInView:self.parentViewController.tabBarController.view];
    [actionSheet release];
}

#pragma mark - UIAlertView Delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView == self.av_edit) {
        if (buttonIndex == 0) {
            // Backup data
            NSLog(@"Backup data");
        }
        else {
            [self editProfile];
        }
    }
    else if (alertView == self.av_delete) {
        if (buttonIndex == 0) {
            // Cancel
            NSLog(@"Canceled delete");
        }
        else {
            [self deleteProfile];
        }
    }
}

#pragma mark - UIActionSheet Delegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        // Process delete WITHOUT data export 
        
        // Prompt user to enter their full name as verification before continuing
        self.av_delete = [[UIPromptAlertView alloc]
                          initWithTitle:NSLocalizedString(@"CONFIRM DELETE", nil)
                          message:[NSString stringWithFormat:@"\n\n%@", NSLocalizedString(@"CONFIRM DELETE MESSAGE", nil)]
                          delegate:self
                          cancelButtonTitle:NSLocalizedString(@"CANCEL", nil)
                          otherButtonTitles:NSLocalizedString(@"CONFIRM", nil), nil];
        self.av_delete.verificationText = self.name;
        [self.av_delete show];
        [self.av_delete release];
        
    }
    else if (buttonIndex == 1) {
        // Process delete WITH data export
        
        // Prompt user to enter their full name as verification before continuing
        self.av_delete = [[UIPromptAlertView alloc]
                          initWithTitle:NSLocalizedString(@"CONFIRM DELETE", nil)
                          message:[NSString stringWithFormat:@"\n\n%@", NSLocalizedString(@"CONFIRM DELETE MESSAGE", nil)]
                          delegate:self
                          cancelButtonTitle:NSLocalizedString(@"CANCEL", nil)
                          otherButtonTitles:NSLocalizedString(@"CONFIRM", nil), nil];
        self.av_delete.verificationText = self.name;
        [self.av_delete show];
        [self.av_delete release];
        
    }
    else {
        // Cancel
        
    }
}

#pragma mark - Static Initializers
+ (ClifeProfileViewController *)createInstance {
    ClifeProfileViewController *instance = [[ClifeProfileViewController alloc] initWithNibName:@"ClifeProfileViewController" bundle:nil];
    [instance autorelease];
    return instance;
}

@end
