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
@synthesize sectionsArray  = m_sectionsArray;
@synthesize tf_name             = m_tf_name;
@synthesize gestureRecognizer   = m_gestureRecognizer;
@synthesize pv_birthday         = m_pv_birthday;
@synthesize dateFormatter       = m_dateFormatter;
@synthesize pv_gender           = m_pv_gender;
@synthesize pv_bloodType        = m_pv_bloodType;
@synthesize genderArray         = m_genderArray;
@synthesize bloodTypeArray      = m_bloodTypeArray;
@synthesize v_disabledBackground = m_v_disabledBackground;
@synthesize isEditing           = m_isEditing;
@synthesize isNewUser           = m_isNewUser;
@synthesize name                = m_name;
@synthesize birthday            = m_birthday;
@synthesize gender              = m_gender;
@synthesize bloodType           = m_bloodType;


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
    self.gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    
//    //we load up saved user information
//    AuthenticationManager* authenticationManager = [AuthenticationManager instance];
//    ResourceContext* resourceContext = [ResourceContext instance];
//    NSNumber* loggedInUserID = [authenticationManager m_LoggedInUserID];
//    
//    User* loggedInUser = (User*)[resourceContext resourceWithType:USER withID:loggedInUserID];
//    
//    //now lets load up the fields
//    if (loggedInUser.displayname != nil &&
//        ![loggedInUser.displayname isEqualToString:@""])
//    {
//        self.tf_name.text = loggedInUser.displayname;
//    }
//    
//    if (loggedInUser.bloodtype != nil &&
//        ![loggedInUser.bloodtype isEqualToString:@""])
//    {
//        //lets find the index of the user's blood type
//        int indexOfBloodType = [self.bloodTypeArray indexOfObject:loggedInUser.bloodtype];
//        [self.pv_bloodType selectRow:indexOfBloodType inComponent:0 animated:NO];
//        
//    }
//    
//    if (loggedInUser.sex != nil &&
//        ![loggedInUser.sex isEqualToString:@""])
//    {
//        //lets find the index of the user's sex
//        int indexOfGender = [self.genderArray indexOfObject:loggedInUser.sex];
//        [self.pv_gender selectRow:indexOfGender inComponent:0 animated:NO];
//        
//    }

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

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    
    self.tbl_profile = nil;
    self.tf_name = nil;
    self.gestureRecognizer = nil;
    self.pv_birthday = nil;
    self.dateFormatter = nil;
    self.pv_gender = nil;
    self.pv_bloodType = nil;
    self.v_disabledBackground = nil;
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
            self.tf_name.keyboardType = UIKeyboardTypeDefault;
            self.tf_name.returnKeyType = UIReturnKeyDone;
            self.tf_name.backgroundColor = [UIColor clearColor];
            self.tf_name.autocorrectionType = UITextAutocorrectionTypeNo;
            self.tf_name.autocapitalizationType = UITextAutocapitalizationTypeWords;
            self.tf_name.textAlignment = UITextAlignmentLeft;
            self.tf_name.delegate = self;
            [self.tf_name setEnabled:YES];
            
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
            
            cell.textLabel.text = NSLocalizedString(@"ENTER BIRTHDAY", nil);
            cell.textLabel.font = [UIFont systemFontOfSize:16.0];
            cell.textLabel.textColor = [UIColor lightGrayColor];
        }
        
        if (self.birthday != nil) {
            cell.textLabel.textColor = [UIColor blackColor];
            cell.textLabel.font = [UIFont systemFontOfSize:17.0];
            
            NSDate *birthday = [DateTimeHelper parseWebServiceDateDouble:self.birthday];
            cell.textLabel.text = [self.dateFormatter stringFromDate:birthday];;
        }
        else {
            cell.textLabel.text = NSLocalizedString(@"SELECT GENDER", nil);
            cell.textLabel.font = [UIFont systemFontOfSize:16.0];
            cell.textLabel.textColor = [UIColor lightGrayColor];
        }
        
        // disable the cell until the "Edit" button is pressed
        if (self.isEditing == YES) {
            [cell setUserInteractionEnabled:YES];
            [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
        }
        else {
            [cell setUserInteractionEnabled:NO];
            [cell setAccessoryType:UITableViewCellAccessoryNone];
        }
    }
    else if (indexPath.section == 2) {
        // Gender section
        
        CellIdentifier = @"Gender";
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        if (cell == nil) {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
            
            cell.textLabel.text = NSLocalizedString(@"SELECT GENDER", nil);
            cell.textLabel.font = [UIFont systemFontOfSize:16.0];
            cell.textLabel.textColor = [UIColor lightGrayColor];
        }
        
        if (self.gender != nil) {
            cell.textLabel.textColor = [UIColor blackColor];
            cell.textLabel.font = [UIFont systemFontOfSize:17.0];
            cell.textLabel.text = self.gender;
        }
        else {
            cell.textLabel.text = NSLocalizedString(@"SELECT GENDER", nil);
            cell.textLabel.font = [UIFont systemFontOfSize:16.0];
            cell.textLabel.textColor = [UIColor lightGrayColor];
        }
        
        // disable the cell until the "Edit" button is pressed
        if (self.isEditing == YES) {
            [cell setUserInteractionEnabled:YES];
            [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
        }
        else {
            [cell setUserInteractionEnabled:NO];
            [cell setAccessoryType:UITableViewCellAccessoryNone];
        }
    }
    else if (indexPath.section == 3) {
        // Blood Type section
        
        CellIdentifier = @"BloodType";
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        if (cell == nil) {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
            
            cell.textLabel.text = NSLocalizedString(@"SELECT BLOOD TYPE", nil);
            cell.textLabel.font = [UIFont systemFontOfSize:16.0];
            cell.textLabel.textColor = [UIColor lightGrayColor];
        }
        
        if (self.bloodType != nil) {
            cell.textLabel.textColor = [UIColor blackColor];
            cell.textLabel.font = [UIFont systemFontOfSize:17.0];
            cell.textLabel.text = self.bloodType;
        }
        else {
            cell.textLabel.text = NSLocalizedString(@"SELECT BLOOD TYPE", nil);
            cell.textLabel.font = [UIFont systemFontOfSize:16.0];
            cell.textLabel.textColor = [UIColor lightGrayColor];
        }
        
        // disable the cell until the "Edit" button is pressed
        if (self.isEditing == YES) {
            [cell setUserInteractionEnabled:YES];
            [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
        }
        else {
            [cell setUserInteractionEnabled:NO];
            [cell setAccessoryType:UITableViewCellAccessoryNone];
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
    UITableViewCell *targetCell = [tableView cellForRowAtIndexPath:indexPath];
    
    if (indexPath.section == 0) {
        // Name selected
        
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        
        // Scroll tableview to this row
        [self.tbl_profile setContentOffset:CGPointMake(0, 0) animated:YES];
        
        // Set the name text field as active
        [self.tf_name becomeFirstResponder];
        
    }
    else if (indexPath.section == 1) {
        // Birthday selected
        
        // Scroll tableview to this row
        [self.tbl_profile setContentOffset:CGPointMake(0, 0) animated:YES];
        
        // Show the date picker
        if (self.pv_birthday == nil) {
            self.pv_birthday = [[UIDatePicker alloc] init];
            [self.pv_birthday addTarget:self action:@selector(dateChanged:) forControlEvents:UIControlEventValueChanged];
            self.pv_birthday.datePickerMode = UIDatePickerModeDate;
            self.pv_birthday.maximumDate = [NSDate date];
        }
        
        if ([self.dateFormatter dateFromString:targetCell.textLabel.text]) {
            self.pv_birthday.date = [self.dateFormatter dateFromString:targetCell.textLabel.text];
            
            NSDate* birthday = [self.dateFormatter dateFromString:targetCell.textLabel.text];
            double doubleDate = [birthday timeIntervalSince1970];
            self.birthday = [NSNumber numberWithDouble:doubleDate];
        }
        else {
            targetCell.textLabel.text = [self.dateFormatter stringFromDate:self.pv_birthday.date];
            targetCell.textLabel.font = [UIFont systemFontOfSize:17.0];
            targetCell.textLabel.textColor = [UIColor blackColor];
            
            NSDate* birthday = self.pv_birthday.date;
            double doubleDate = [birthday timeIntervalSince1970];
            self.birthday = [NSNumber numberWithDouble:doubleDate];
        }
        
        [self showPicker:(UIPickerView *)self.pv_birthday];
        
    }
    else if (indexPath.section == 2) {
        // Gender selected
        
        // Scroll tableview to this row
        [self.tbl_profile setContentOffset:CGPointMake(0, 85) animated:YES];
        
        if (self.pv_gender == nil) {
            self.pv_gender = [[UIPickerView alloc] init];
            self.pv_gender.dataSource = self;
            self.pv_gender.delegate = self;
            
            self.pv_gender.showsSelectionIndicator = YES;
        }
        
        if ([targetCell.textLabel.text isEqualToString:NSLocalizedString(@"SELECT GENDER", nil)] == NO) {
            int row = [self.genderArray indexOfObject:targetCell.textLabel.text];
            [self.pv_gender selectRow:row inComponent:0 animated:YES];
            
            self.gender = [self.genderArray objectAtIndex:row];
        }
        else {
            targetCell.textLabel.text = [self.genderArray objectAtIndex:0];
            targetCell.textLabel.font = [UIFont systemFontOfSize:17.0];
            targetCell.textLabel.textColor = [UIColor blackColor];
            
            self.gender = [self.genderArray objectAtIndex:0];
        }
        
        [self showPicker:self.pv_gender];
        
    }
    else if (indexPath.section == 3) {
        // Blood Type selected
        
        // Scroll tableview to this row
        [self.tbl_profile setContentOffset:CGPointMake(0, 177) animated:YES];
        
        if (self.pv_bloodType == nil) {
            self.pv_bloodType = [[UIPickerView alloc] init];
            self.pv_bloodType.dataSource = self;
            self.pv_bloodType.delegate = self;
            
            self.pv_bloodType.showsSelectionIndicator = YES;
        }
        
        if ([targetCell.textLabel.text isEqualToString:NSLocalizedString(@"SELECT BLOOD TYPE", nil)] == NO) {
            int row = [self.bloodTypeArray indexOfObject:targetCell.textLabel.text];
            [self.pv_bloodType selectRow:row inComponent:0 animated:YES];
            
            self.bloodType = [self.bloodTypeArray objectAtIndex:row];
        }
        else {
            targetCell.textLabel.text = [self.bloodTypeArray objectAtIndex:0];
            targetCell.textLabel.font = [UIFont systemFontOfSize:17.0];
            targetCell.textLabel.textColor = [UIColor blackColor];
            
            self.bloodType = [self.bloodTypeArray objectAtIndex:0];
        }
        
        [self showPicker:self.pv_bloodType];
        
    }
}

#pragma mark - UIPickerView Methods
- (void)showPicker:(UIPickerView *)pickerView {
    if (pickerView.superview == nil)
    {
        // Show the disabled background so user cannot touch into the tableview while picker is shown
        [self.v_disabledBackground setAlpha:0.0];
        [self.view bringSubviewToFront:self.v_disabledBackground];
        
        [self.view.window addSubview:pickerView];
        
        // size up the picker view to our screen and compute the start/end frame origin for our slide up animation
        //
        // compute the start frame
        CGRect screenRect = [[UIScreen mainScreen] applicationFrame];
        CGSize pickerSize = [pickerView sizeThatFits:CGSizeZero];
        CGRect startRect = CGRectMake(0.0,
                                      screenRect.origin.y + screenRect.size.height,
                                      pickerSize.width, pickerSize.height);
        pickerView.frame = startRect;
        
        // compute the end frame
        CGRect pickerRect = CGRectMake(0.0,
                                       screenRect.origin.y + screenRect.size.height - pickerSize.height,
                                       pickerSize.width,
                                       pickerSize.height);
        // start the slide up animation
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.3];
        
        // we need to perform some post operations after the animation is complete
        [UIView setAnimationDelegate:self];
        
        pickerView.frame = pickerRect;
        
        // animate the showing of the disabled background so user cannot touch into the tableview while picker is shown
        [self.v_disabledBackground setAlpha:0.4];
        
        [UIView commitAnimations];
        
        // add the "Done" button to the nav bar
        UIBarButtonItem* rightButton = [[UIBarButtonItem alloc]
                                        initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                        target:self
                                        action:@selector(pickerDoneAction:)];
        self.navigationItem.rightBarButtonItem = rightButton;
        [rightButton release];
        
//        // remove the "Delete" button
//        self.navigationItem.leftBarButtonItem = nil;
    }
}

- (void)pickerDoneAction:(id)sender
{
    // Determine which picker to hide
    BOOL pickerInSuperView = NO;
    UIPickerView *pickerView;
    if (self.pv_birthday.superview != nil) {
        pickerInSuperView = YES;
        pickerView = (UIPickerView *)self.pv_birthday;
    }
    else if (self.pv_gender.superview != nil) {
        pickerInSuperView = YES;
        pickerView = self.pv_gender;
    }
    else if (self.pv_bloodType.superview != nil) {
        pickerInSuperView = YES;
        pickerView = self.pv_bloodType;
    }
    
    if (pickerInSuperView == YES) {
        CGRect screenRect = [[UIScreen mainScreen] applicationFrame];
        CGRect endFrame = pickerView.frame;
        endFrame.origin.y = screenRect.origin.y + screenRect.size.height;
        
        // start the slide down animation
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.3];
        
        // we need to perform some post operations after the animation is complete
        [UIView setAnimationDelegate:self];
        [UIView setAnimationDidStopSelector:@selector(slideDownDidStop)];
        
        pickerView.frame = endFrame;
        
        // Hide the disabled background
        [self.v_disabledBackground setAlpha:0.0];
        
        [UIView commitAnimations];
        
        // remove the "Done" button in the nav bar
        self.navigationItem.rightBarButtonItem = nil;
        
        // deselect the current table row
        NSIndexPath *indexPath = [self.tbl_profile indexPathForSelectedRow];
        [self.tbl_profile deselectRowAtIndexPath:indexPath animated:YES];
    }
}

- (void)slideDownDidStop
{
    // the picker has finished sliding downwards, so remove it
    
    [self.view sendSubviewToBack:self.v_disabledBackground];
    
    // Determine which picker to remove
    BOOL pickerInSuperView = NO;
    UIPickerView *pickerView;
    if (self.pv_birthday.superview != nil) {
        pickerInSuperView = YES;
        pickerView = (UIPickerView *)self.pv_birthday;
    }
    else if (self.pv_gender.superview != nil) {
        pickerInSuperView = YES;
        pickerView = self.pv_gender;
    }
    else if (self.pv_bloodType.superview != nil) {
        pickerInSuperView = YES;
        pickerView = self.pv_bloodType;
    }
    
    if (pickerInSuperView == YES) {
        [pickerView removeFromSuperview];
    }
    
    // add the "Done" button to the nav bar
    UIBarButtonItem* rightButton = [[UIBarButtonItem alloc]
                                    initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                    target:self
                                    action:@selector(doneEditingProfile:)];
    self.navigationItem.rightBarButtonItem = rightButton;
    [rightButton release];
    
//    // add the "Delete" button to the nav bar
//    [self showDeleteNavBarButton];
}

#pragma mark UIDatePickerView Methods
- (void)dateChanged:(id)sender
{
    NSIndexPath *indexPath = [self.tbl_profile indexPathForSelectedRow];
    UITableViewCell *cell = [self.tbl_profile cellForRowAtIndexPath:indexPath];
    cell.textLabel.text = [self.dateFormatter stringFromDate:self.pv_birthday.date];
    cell.textLabel.font = [UIFont systemFontOfSize:17.0];
    cell.textLabel.textColor = [UIColor blackColor];
    
    NSDate* currentDate = [NSDate date];
    double doubleDate = [currentDate timeIntervalSince1970];
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
    NSIndexPath *indexPath = [self.tbl_profile indexPathForSelectedRow];
    UITableViewCell *cell = [self.tbl_profile cellForRowAtIndexPath:indexPath];
    cell.textLabel.font = [UIFont systemFontOfSize:17.0];
    cell.textLabel.textColor = [UIColor blackColor];
    
    if (pickerView == self.pv_gender) {
        cell.textLabel.text = [self.genderArray objectAtIndex:row];
        
        self.gender = [self.genderArray objectAtIndex:row];
    }
    else if (pickerView == self.pv_bloodType) {
        cell.textLabel.text = [self.bloodTypeArray objectAtIndex:row];
        
        self.bloodType = [self.bloodTypeArray objectAtIndex:row];
    }
    else {
        cell.textLabel.text = nil;
    }
}

#pragma mark - TextField Delegate
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    // textfield editing has begun
    
    // disable "Done" and "Delete" buttons until text entry complete
    self.navigationItem.rightBarButtonItem.enabled = NO;
//    self.navigationItem.leftBarButtonItem.enabled = NO;
    
    // Add the tap gesture recognizer to capture background touches which will dismiss the keyboard
    [self.tbl_profile addGestureRecognizer:self.gestureRecognizer];
    
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    // textfield editing has ended
    self.tf_name = textField;
    
    NSString *enteredText = [textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    if ([enteredText isEqualToString:@""] == YES ||
        [enteredText isEqualToString:@" "] == YES)
    {
        self.name = nil;
    }
    else {
        self.name = enteredText;
    }
    
    // Re-enable "Done" and "Delete" buttons
    self.navigationItem.rightBarButtonItem.enabled = YES;
//    self.navigationItem.leftBarButtonItem.enabled = YES;
    
    // remove the tap gesture recognizer so it does not interfere with other table view touches
    [self.tbl_profile removeGestureRecognizer:self.gestureRecognizer];
    
    self.name = self.tf_name.text;
    
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
//- (void)showDeleteNavBarButton {
//    // add the "Delete" button to the nav bar
//    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
//    [button setBackgroundImage:[UIImage imageNamed:@"delete_red.png"] forState:UIControlStateNormal];
//    [button setTitle:NSLocalizedString(@"DELETE", nil) forState:UIControlStateNormal];
//    button.titleLabel.font = [UIFont boldSystemFontOfSize:12.0f];
//    button.titleLabel.shadowColor = [UIColor lightGrayColor];
//    button.titleLabel.shadowOffset = CGSizeMake(0.0f, -1.0f);
//    [button.layer setCornerRadius:5.0f];
//    [button.layer setMasksToBounds:YES];
//    [button.layer setBorderWidth:1.0f];
//    [button.layer setBorderColor: [[UIColor darkGrayColor] CGColor]];
//    button.frame=CGRectMake(0.0, 100.0, 60.0, 30.0);
//    
//    [button addTarget:self action:@selector(onDeleteProfileButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
//    
//    UIBarButtonItem* leftButton = [[UIBarButtonItem alloc] initWithCustomView:button];
//    
//    self.navigationItem.leftBarButtonItem = leftButton;
//    [leftButton release];
//}

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

- (void)hideKeyboard {
    if ([self.tf_name isFirstResponder] == YES) {
        [self.tf_name resignFirstResponder];
    }
}

- (void)editProfile {
    self.isEditing = YES;
    
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
//    [self showDeleteNavBarButton];
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
        
        // Reload the table view to disable user interaction and accessory views on the tableview cells
        [self.tbl_profile reloadData];
        
        // Hide the keyboard if it is shown
        [self hideKeyboard];
        
        // add the "Edit" button back to the nav bar
        UIBarButtonItem* rightButton = [[UIBarButtonItem alloc]
                                        initWithBarButtonSystemItem:UIBarButtonSystemItemEdit
                                        target:self
                                        action:@selector(onEditProfileButtonPressed:)];
        self.navigationItem.rightBarButtonItem = rightButton;
        [rightButton release];
        
        //now we update the user object iwth the changed properties
        self.loggedInUser.username = self.name;
        self.loggedInUser.dateborn = self.birthday;
        self.loggedInUser.sex = self.gender;
        self.loggedInUser.bloodtype = self.bloodType;
        
        //now we save the changes
        ResourceContext* resourceContext = [ResourceContext instance];
        [resourceContext save:NO onFinishCallback:nil trackProgressWith:nil];
        
        // remove the "Delete" button
        //    self.navigationItem.leftBarButtonItem = nil;
        self.tbl_profile.tableFooterView = nil;
    }
}

- (void)deleteProfile {
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
}

- (void)onEditProfileButtonPressed:(id)sender {
    // Promt user to backup data before editing profile information
    UIAlertView* alert = [[UIAlertView alloc]
                          initWithTitle:NSLocalizedString(@"EDIT PROFILE", nil)
                          message:NSLocalizedString(@"EDIT PROFILE MESSAGE", nil)
                          delegate:self
                          cancelButtonTitle:NSLocalizedString(@"YES", nil)
                          otherButtonTitles:NSLocalizedString(@"NO", nil), nil];
    [alert show];
    [alert release];
}

- (void)onDeleteProfileButtonPressed:(id)sender {
    // Promt user to backup data before editing profile information
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
    if (buttonIndex == 0) {
        // Backup data
        NSLog(@"Backup data");
    }
    else {
        [self editProfile];
    }
}

#pragma mark - UIActionSheet Delegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        // Process delete WITHOUT data export
        [self deleteProfile];
    }
    else if (buttonIndex == 1) {
        // Process delete WITH data export
        [self deleteProfile];
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
