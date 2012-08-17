//
//  ClifePrescriptionDetailsViewController.m
//  CLife
//
//  Created by Jordan Gurrieri on 8/17/12.
//  Copyright (c) 2012 Blue Label Solutions LLC. All rights reserved.
//

#import "ClifePrescriptionDetailsViewController.h"

@interface ClifePrescriptionDetailsViewController ()

@end

@implementation ClifePrescriptionDetailsViewController
@synthesize tbl_prescriptionDetails = m_tbl_prescriptionDetails;
@synthesize sectionsArray           = m_sectionsArray;
@synthesize prescriptionID          = m_prescriptionID;
@synthesize tf_medicationName       = m_tf_medicationName;
@synthesize gestureRecognizer       = m_gestureRecognizer;
@synthesize pv_startDate            = m_pv_startDate;
@synthesize dateFormatter           = m_dateFormatter;
@synthesize pv_method               = m_pv_method;
@synthesize methodArray             = m_methodArray;
@synthesize tf_dosageAmount         = m_tf_dosageAmount;
@synthesize pv_dosageUnit           = m_pv_dosageUnit;
@synthesize dosageUnitArray         = m_dosageUnitArray;
@synthesize tv_reason               = m_tv_reason;
@synthesize v_disabledBackground    = m_v_disabledBackground;
@synthesize isEditing               = m_isEditing;


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
    
    // Setup date formatter for birthday picker
    self.dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
    [self.dateFormatter setDateStyle:NSDateFormatterLongStyle];
    [self.dateFormatter setTimeStyle:NSDateFormatterNoStyle];
    
    // Setup array for section titles
    self.sectionsArray = [NSArray arrayWithObjects:
                          NSLocalizedString(@"MEDICATION", nil),
                          NSLocalizedString(@"METHOD", nil),
                          NSLocalizedString(@"DOSAGE", nil),
                          NSLocalizedString(@"REASON", nil),
                          nil];
    
    // Setup arrays for gender and blood type pickers
    self.methodArray = [NSArray arrayWithObjects:
                        NSLocalizedString(@"PILL", nil),
                        NSLocalizedString(@"LIQUID", nil),
                        NSLocalizedString(@"TOPICAL", nil),
                        NSLocalizedString(@"SYRINGE", nil),
                        nil];
    
    self.dosageUnitArray = [NSArray arrayWithObjects:
                            NSLocalizedString(@"ug", nil),
                            NSLocalizedString(@"mg", nil),
                            NSLocalizedString(@"g", nil),
                            NSLocalizedString(@"ul", nil),
                            NSLocalizedString(@"ml", nil),
                            NSLocalizedString(@"l", nil),
                           nil];
    
    // Setup tap gesture recognizer to capture touches on the tableview when the keyboard is visible
    self.gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
    
    // add the "Edit" button to the nav bar if openning an existing prescription
    if (self.prescriptionID != nil) {
        UIBarButtonItem* rightButton = [[UIBarButtonItem alloc]
                                        initWithBarButtonSystemItem:UIBarButtonSystemItemEdit
                                        target:self
                                        action:@selector(onEditPrescriptionButtonPressed:)];
        self.navigationItem.rightBarButtonItem = rightButton;
        [rightButton release];
    }
    else {
        // We are adding a new prescription
        self.isEditing = YES;
        
        // add the "Done" button to the nav bar
        UIBarButtonItem* rightButton = [[UIBarButtonItem alloc]
                                        initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                        target:self
                                        action:@selector(onDoneAddingPrescriptionButtonPressed:)];
        self.navigationItem.rightBarButtonItem = rightButton;
        [rightButton release];
        
        // add the "Cancel" button to the nav bar
        UIBarButtonItem* leftButton = [[UIBarButtonItem alloc]
                                        initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                        target:self
                                        action:@selector(onCanceledAddingPrescriptionButtonPressed:)];
        self.navigationItem.leftBarButtonItem = leftButton;
        [leftButton release];
    }
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    
    self.tbl_prescriptionDetails = nil;
    self.tf_medicationName = nil;
    self.gestureRecognizer = nil;
    self.pv_startDate = nil;
    self.dateFormatter = nil;
    self.pv_method = nil;
    self.tf_dosageAmount = nil;
    self.pv_dosageUnit = nil;
    self.tv_reason = nil;
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
    if (section == 2) {
        return 2;
    }
    else {
        return 1;
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
        // Medication Name section
        
        CellIdentifier = @"MedicationName";
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        if (cell == nil) {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
            
            [cell setSelectionStyle:UITableViewCellEditingStyleNone];
            
            self.tf_medicationName = [[UITextField alloc] initWithFrame:CGRectMake(10, 12, 280, 21)];
            self.tf_medicationName.font = [UIFont systemFontOfSize:16.0];
            self.tf_medicationName.adjustsFontSizeToFitWidth = YES;
            self.tf_medicationName.textColor = [UIColor blackColor];
            self.tf_medicationName.placeholder = NSLocalizedString(@"ENTER MEDICATION NAME", nil);
            self.tf_medicationName.keyboardType = UIKeyboardTypeDefault;
            self.tf_medicationName.returnKeyType = UIReturnKeyDone;
            self.tf_medicationName.backgroundColor = [UIColor clearColor];
            self.tf_medicationName.autocorrectionType = UITextAutocorrectionTypeNo;
            self.tf_medicationName.autocapitalizationType = UITextAutocapitalizationTypeWords;
            self.tf_medicationName.textAlignment = UITextAlignmentLeft;
            self.tf_medicationName.delegate = self;
            [self.tf_medicationName setEnabled:YES];
            
            [cell.contentView addSubview:self.tf_medicationName];
            
        }
        
        // disable the cell until the "Edit" button is pressed
        if (self.isEditing == YES) {
            [cell setUserInteractionEnabled:YES];
            [self.tf_medicationName setClearButtonMode:UITextFieldViewModeAlways];
        }
        else {
            [cell setUserInteractionEnabled:NO];
            [self.tf_medicationName setClearButtonMode:UITextFieldViewModeNever];
        }
    }
    else if (indexPath.section == 1) {
        // Method section
        
        CellIdentifier = @"Method";
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        if (cell == nil) {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
            
            cell.textLabel.text = NSLocalizedString(@"SELECT METHOD", nil);
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
        // Dosage section
        
        if (indexPath.row == 0) {
            // Dosage Amount row
            
            CellIdentifier = @"DosageAmount";
            cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            
            if (cell == nil) {
                cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
                
                cell.textLabel.text = NSLocalizedString(@"AMOUNT", nil);
                [cell setSelectionStyle:UITableViewCellEditingStyleNone];
                
                self.tf_dosageAmount = [[UITextField alloc] initWithFrame:CGRectMake(110, 0, 170, 21)];
                self.tf_dosageAmount.adjustsFontSizeToFitWidth = YES;
                self.tf_dosageAmount.textColor = [UIColor blackColor];
                self.tf_dosageAmount.placeholder = NSLocalizedString(@"ENTER AMOUNT", nil);
                self.tf_dosageAmount.keyboardType = UIKeyboardTypeNumberPad;
                self.tf_dosageAmount.returnKeyType = UIReturnKeyDone;
                self.tf_dosageAmount.backgroundColor = [UIColor clearColor];
                self.tf_dosageAmount.autocorrectionType = UITextAutocorrectionTypeNo;
                self.tf_dosageAmount.autocapitalizationType = UITextAutocapitalizationTypeWords;
                self.tf_dosageAmount.textAlignment = UITextAlignmentRight;
                self.tf_dosageAmount.delegate = self;
                [self.tf_dosageAmount setEnabled:YES];
                
                cell.accessoryView = self.tf_dosageAmount;
                
            }
            
            // disable the cell until the "Edit" button is pressed
            if (self.isEditing == YES) {
                [cell setUserInteractionEnabled:YES];
                [self.tf_dosageAmount setClearButtonMode:UITextFieldViewModeAlways];
            }
            else {
                [cell setUserInteractionEnabled:NO];
                [self.tf_dosageAmount setClearButtonMode:UITextFieldViewModeWhileEditing];
            }
        }
        else if (indexPath.row == 1) {
            // Dosage Unit row
            
            CellIdentifier = @"DosageUnit";
            cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            
            if (cell == nil) {
                cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];
                
                cell.textLabel.text = NSLocalizedString(@"UNIT", nil);
                cell.detailTextLabel.text = NSLocalizedString(@"SELECT UNIT", nil);
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
    }
    else if (indexPath.section == 3) {
        // Reason section
        
        CellIdentifier = @"Reason";
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        if (cell == nil) {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
            
            cell.textLabel.text = nil;
            [cell setSelectionStyle:UITableViewCellEditingStyleNone];
            
            self.tv_reason = [[UITextView alloc] initWithFrame:CGRectMake(10, 10, 280, 100)];
            self.tv_reason.font = [UIFont systemFontOfSize:16.0f];
            self.tv_reason.textColor = [UIColor lightGrayColor];
            self.tv_reason.text = NSLocalizedString(@"ENTER REASON", nil);
            self.tv_reason.keyboardType = UIKeyboardTypeDefault;
            self.tv_reason.returnKeyType = UIReturnKeyDone;
            self.tv_reason.backgroundColor = [UIColor clearColor];
            self.tv_reason.autocorrectionType = UITextAutocorrectionTypeNo;
            self.tv_reason.autocapitalizationType = UITextAutocapitalizationTypeSentences;
            self.tv_reason.textAlignment = UITextAlignmentLeft;
            self.tv_reason.delegate = self;
            
            [cell.contentView addSubview:self.tv_reason];
            
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
        return 120.0f;
    }
    else if (indexPath.section == 2) {
        return 45.0f;
    }
    else {
        return 46.0f;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     [detailViewController release];
     */
}

#pragma mark - UITextview and TextField Delegate Methods
- (void)textViewDidBeginEditing:(UITextView *)textView
{
    // reason textview editing has begun
    self.tv_reason = textView;
    
    // disable "Done" and "Cancel" buttons until text entry complete
    self.navigationItem.rightBarButtonItem.enabled = NO;
    self.navigationItem.leftBarButtonItem.enabled = NO;
    
    // Clear the default text of the caption textview upon startin to edit
    if ([self.tv_reason.text isEqualToString:NSLocalizedString(@"ENTER REASON", nil)]) {
        [self.tv_reason setText:@""];
        self.tv_reason.textColor = [UIColor blackColor];
    }
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    // reason textview editing has ended
    self.tv_reason = textView;
    
    // Add default text back if reason was left empty
    if ([self.tv_reason.text isEqualToString:@""] || [self.tv_reason.text isEqualToString:NSLocalizedString(@"ENTER REASON", nil)]) {
        self.tv_reason.textColor = [UIColor lightGrayColor];
        [self.tv_reason setText:NSLocalizedString(@"ENTER REASON", nil)];
    }
    else {
        // caption is acceptable
        
        NSString *trimmedReason = [self.tv_reason.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        
    }
    
    // Re-enable "Done" and "Cancel" buttons
    self.navigationItem.rightBarButtonItem.enabled = YES;
    self.navigationItem.leftBarButtonItem.enabled = YES;
    
}

#pragma mark - TextField Delegate
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    // textfield editing has begun
    
    // disable "Done" and "Delete" buttons until text entry complete
    self.navigationItem.rightBarButtonItem.enabled = NO;
    self.navigationItem.leftBarButtonItem.enabled = NO;
    
    // Add the tap gesture recognizer to capture background touches which will dismiss the keyboard
    [self.tbl_prescriptionDetails addGestureRecognizer:self.gestureRecognizer];
    
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    // textfield editing has ended
    
    // Re-enable "Done" and "Delete" buttons
    self.navigationItem.rightBarButtonItem.enabled = YES;
    self.navigationItem.leftBarButtonItem.enabled = YES;
    
    // remove the tap gesture recognizer so it does not interfere with other table view touches
    [self.tbl_prescriptionDetails removeGestureRecognizer:self.gestureRecognizer];
    
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

#pragma mark - UIActionSheet Delegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        // Process delete WITHOUT data export
        [self deletePrescription];
    }
    else if (buttonIndex == 1) {
        // Process delete WITH data export
        
    }
    else {
        // Cancel
        
    }
}

#pragma mark - UI Action Methods
- (void)showDeleteNavBarButton {
    
    
    // add the "Delete" button to the nav bar
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setBackgroundImage:[UIImage imageNamed:@"delete_red.png"] forState:UIControlStateNormal];
    [button setTitle:NSLocalizedString(@"DELETE", nil) forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont boldSystemFontOfSize:12.0f];
    button.titleLabel.shadowColor = [UIColor lightGrayColor];
    button.titleLabel.shadowOffset = CGSizeMake(0.0f, -1.0f);
    [button.layer setCornerRadius:5.0f];
    [button.layer setMasksToBounds:YES];
    [button.layer setBorderWidth:1.0f];
    [button.layer setBorderColor: [[UIColor darkGrayColor] CGColor]];
    button.frame=CGRectMake(0.0, 100.0, 60.0, 30.0);
    
    [button addTarget:self action:@selector(onDeletePrescriptionButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem* leftButton = [[UIBarButtonItem alloc] initWithCustomView:button];
    
    self.navigationItem.leftBarButtonItem = leftButton;
    [leftButton release];
}

- (void)hideKeyboard {
    if ([self.tf_medicationName isFirstResponder] == YES) {
        [self.tf_medicationName resignFirstResponder];
    }
    else if ([self.tf_dosageAmount isFirstResponder] == YES) {
        [self.tf_dosageAmount resignFirstResponder];
    }
}

- (void)editPrescription {
    
    self.isEditing = YES;
    
    // Reload the table view to enable user interaction and accessory views on the tableview cells
    [self.tbl_prescriptionDetails reloadData];
    
    // add the "Done" button to the nav bar
    UIBarButtonItem* rightButton = [[UIBarButtonItem alloc]
                                    initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                    target:self
                                    action:@selector(doneEditingProfile:)];
    self.navigationItem.rightBarButtonItem = rightButton;
    [rightButton release];
    
    // add the "Delete" button to the nav bar
    [self showDeleteNavBarButton];
    
}

- (void)doneEditingProfile:(id)sender {
    self.isEditing = NO;
    
    // Reload the table view to disable user interaction and accessory views on the tableview cells
    [self.tbl_prescriptionDetails reloadData];
    
    // Hide the keyboard if it is shown
    [self hideKeyboard];
    
    // add the "Edit" button back to the nav bar
    UIBarButtonItem* rightButton = [[UIBarButtonItem alloc]
                                    initWithBarButtonSystemItem:UIBarButtonSystemItemEdit
                                    target:self
                                    action:@selector(onEditProfileButtonPressed:)];
    self.navigationItem.rightBarButtonItem = rightButton;
    [rightButton release];
    
    // remove the "Delete" button
    self.navigationItem.leftBarButtonItem = nil;
}

- (void)deletePrescription {
    
}

- (void)onEditPrescriptionButtonPressed:(id)sender {
    //    // Promt user to backup data before editing profile information
    //    UIAlertView* alert = [[UIAlertView alloc]
    //                          initWithTitle:NSLocalizedString(@"EDIT PROFILE", nil)
    //                          message:NSLocalizedString(@"EDIT PROFILE MESSAGE", nil)
    //                          delegate:self
    //                          cancelButtonTitle:NSLocalizedString(@"YES", nil)
    //                          otherButtonTitles:NSLocalizedString(@"NO", nil), nil];
    //    [alert show];
    //    [alert release];
    
    [self editPrescription];
}

- (void)onDeletePrescriptionButtonPressed:(id)sender {
    // Promt user to backup data before editing profile information
    UIActionSheet* actionSheet = [[UIActionSheet alloc]
                                  initWithTitle:NSLocalizedString(@"DELETE PRESCRIPTION MESSAGE", nil)
                                  delegate:self
                                  cancelButtonTitle:NSLocalizedString(@"CANCEL", nil)
                                  destructiveButtonTitle:NSLocalizedString(@"DELETE WITHOUT DATA EXPORT", nil)
                                  otherButtonTitles:NSLocalizedString(@"DELETE WITH DATA EXPORT", nil), nil];
    [actionSheet showInView:self.parentViewController.tabBarController.view];
    [actionSheet release];
}

- (void)onDoneAddingPrescriptionButtonPressed:(id)sender {
    [self.navigationController dismissModalViewControllerAnimated:YES];
}

- (void)onCanceledAddingPrescriptionButtonPressed:(id)sender {
    [self.navigationController dismissModalViewControllerAnimated:YES];
}

//#pragma mark - UIAlertView Delegate
//- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
//    if (buttonIndex == 0) {
//        // Backup data
//        NSLog(@"Backup data");
//    }
//    else {
//        [self editPrescription];
//    }
//}

#pragma mark - Static Initializers
+ (ClifePrescriptionDetailsViewController *)createInstanceForPrescriptionWithID:(NSNumber *)prescriptionID {
    ClifePrescriptionDetailsViewController *instance = [[ClifePrescriptionDetailsViewController alloc] initWithNibName:@"ClifePrescriptionDetailsViewController" bundle:nil];
    [instance autorelease];
    
    instance.prescriptionID = prescriptionID;
    
    return instance;
}

@end
