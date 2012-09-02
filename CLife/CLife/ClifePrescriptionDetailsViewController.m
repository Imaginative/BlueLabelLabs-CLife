//
//  ClifePrescriptionDetailsViewController.m
//  CLife
//
//  Created by Jordan Gurrieri on 8/17/12.
//  Copyright (c) 2012 Blue Label Solutions LLC. All rights reserved.
//

#import "ClifePrescriptionDetailsViewController.h"
#import "Prescription.h"
#import "IDGenerator.h"
#import "DateTimeHelper.h"
#import "PrescriptionInstance.h"
#import "LocalNotificationManager.h"
@interface ClifePrescriptionDetailsViewController ()

@end

@implementation ClifePrescriptionDetailsViewController
@synthesize tbl_prescriptionDetails = m_tbl_prescriptionDetails;
@synthesize sectionsArray           = m_sectionsArray;
@synthesize prescriptionID          = m_prescriptionID;
@synthesize tf_medicationName       = m_tf_medicationName;
@synthesize gestureRecognizer       = m_gestureRecognizer;
@synthesize tf_scheduleStartDate    = m_tf_scheduleStartDate;
@synthesize pv_startDate            = m_pv_startDate;
@synthesize dateFormatter           = m_dateFormatter;
@synthesize numberArray             = m_numberArray;
@synthesize tf_scheduleAmount       = m_tf_scheduleAmount;
@synthesize pv_scheduleAmount       = m_pv_scheduleAmount;
@synthesize tf_scheduleRepeat       = m_tf_scheduleRepeat;
@synthesize pv_scheduleRepeat       = m_pv_scheduleRepeat;
@synthesize tf_scheduleDuration     = m_tf_scheduleDuration;
@synthesize pv_scheduleDuration     = m_pv_scheduleDuration;
@synthesize tf_scheduleReminder     = m_tf_scheduleReminder;
@synthesize pv_scheduleReminder     = m_pv_scheduleReminder;
@synthesize tf_method               = m_tf_method;
@synthesize pv_method               = m_pv_method;
@synthesize methodArray             = m_methodArray;
@synthesize tf_dosageAmount         = m_tf_dosageAmount;
@synthesize tf_dosageUnit           = m_tf_dosageUnit;
@synthesize pv_dosageUnit           = m_pv_dosageUnit;
@synthesize dosageUnitArray         = m_dosageUnitArray;
@synthesize tv_reason               = m_tv_reason;
@synthesize v_disabledBackground    = m_v_disabledBackground;
@synthesize isEditing               = m_isEditing;
@synthesize medicationName          = m_medicationName;
@synthesize sheduleStartDate        = m_scheduleStartDate;
@synthesize method                  = m_method;
@synthesize dosageAmount            = m_dosageAmount;
@synthesize dosageUnit              = m_dosageUnit;
@synthesize reason                  = m_reason;


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
                          NSLocalizedString(@"SCHEDULE", nil),
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
    
    // Setup array for number pickers
    NSMutableArray *mtblNumbersArray = [[NSMutableArray alloc] initWithObjects:[NSString stringWithFormat:@"%d %@", 1, NSLocalizedString(@"DOSE", nil)], nil];
    for (int i = 2; i <= 30; i++) {
        [mtblNumbersArray addObject:[NSString stringWithFormat:@"%d %@", i, NSLocalizedString(@"DOSES", nil)]];
    }
    self.numberArray = [NSArray arrayWithArray:mtblNumbersArray];
    
    self.methodArray = [NSArray arrayWithObjects:
                        NSLocalizedString(@"PILL", nil),
                        NSLocalizedString(@"LIQUID", nil),
                        NSLocalizedString(@"TOPICAL", nil),
                        NSLocalizedString(@"SYRINGE", nil),
                        nil];
    
    // Setup tap gesture recognizer to capture touches on the tableview when the keyboard is visible
    self.gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideInputView)];
    
    // Are we opening an existing prescription or adding a new one?
    if (self.prescriptionID != nil) {
        // Existing prescription
        self.isEditing = NO;
        
        // add the "Edit" button to the nav bar if openning an existing prescription
        UIBarButtonItem* rightButton = [[UIBarButtonItem alloc]
                                        initWithBarButtonSystemItem:UIBarButtonSystemItemEdit
                                        target:self
                                        action:@selector(onEditPrescriptionButtonPressed:)];
        self.navigationItem.rightBarButtonItem = rightButton;
        [rightButton release];
        
        // Get the prescription object
        ResourceContext* resourceContext = [ResourceContext instance];
        Prescription* prescription = (Prescription*)[resourceContext resourceWithType:PRESCRIPTION withID:self.prescriptionID];
        
        self.medicationName = prescription.name;
        self.method = prescription.method;
        self.dosageAmount = prescription.dosageamount;
        self.dosageUnit = prescription.dosageunit;
        self.reason = prescription.notes;
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
        
        self.medicationName = nil;
        self.method = nil;
        self.dosageAmount = nil;
        self.dosageUnit = nil;
        self.reason = nil;
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
    self.tf_scheduleStartDate = nil;
    self.pv_startDate = nil;
    self.dateFormatter = nil;
    self.tf_scheduleAmount = nil;
    self.pv_scheduleAmount = nil;
    self.tf_scheduleRepeat = nil;
    self.pv_scheduleRepeat = nil;
    self.tf_scheduleDuration = nil;
    self.pv_scheduleDuration = nil;
    self.tf_scheduleReminder = nil;
    self.pv_scheduleReminder = nil;
    self.tf_method = nil;
    self.pv_method = nil;
    self.tf_dosageAmount = nil;
    self.tf_dosageUnit = nil;
    self.pv_dosageUnit = nil;
    self.tv_reason = nil;
    self.v_disabledBackground = nil;
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
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
        // Dosage section
        return 2;
    }
    if (section == 3) {
        // Schedule section
        return 5;
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
            
            self.tf_medicationName = [[UITextField alloc] initWithFrame:CGRectMake(8, 11, 282, 21)];
            self.tf_medicationName.font = [UIFont systemFontOfSize:17.0];
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
        
        if (self.medicationName != nil) {
            self.tf_medicationName.text = self.medicationName;
        }
        else {
            self.tf_medicationName.text = nil;
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
            
            [cell setSelectionStyle:UITableViewCellEditingStyleNone];
            
            // Initialize the gender picker view
            if (self.pv_method == nil) {
                UIPickerView* pickerView = [[[UIPickerView alloc] init] autorelease];
                [pickerView sizeToFit];
                pickerView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
                pickerView.dataSource = self;
                pickerView.delegate = self;
                pickerView.showsSelectionIndicator = YES;
                
                self.pv_method = pickerView;
                
                self.tf_method = [[UITextField alloc] initWithFrame:CGRectMake(8, 11, 282, 21)];
                self.tf_method.font = [UIFont systemFontOfSize:17.0];
                self.tf_method.adjustsFontSizeToFitWidth = YES;
                self.tf_method.textColor = [UIColor blackColor];
                self.tf_method.placeholder = NSLocalizedString(@"SELECT METHOD", nil);
                self.tf_method.backgroundColor = [UIColor clearColor];
                self.tf_method.textAlignment = UITextAlignmentLeft;
                self.tf_method.delegate = self;
                [self.tf_method setEnabled:YES];
                
                self.tf_method.inputView = self.pv_method;
                
                [cell.contentView addSubview:self.tf_method];
            }
        }
        
        if (self.method != nil) {
            self.tf_method.text = self.method;
        }
        else {
            self.tf_method.text = nil;
        }
        
        // disable the cell until the "Edit" button is pressed
        if (self.isEditing == YES) {
            [cell setUserInteractionEnabled:YES];
            [self.tf_method setClearButtonMode:UITextFieldViewModeAlways];
        }
        else {
            [cell setUserInteractionEnabled:NO];
            [self.tf_method setClearButtonMode:UITextFieldViewModeNever];
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
                self.tf_dosageAmount.textColor = [UIColor darkGrayColor];
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
            
            if (self.dosageAmount != nil) {
                self.tf_dosageAmount.text = self.dosageAmount;
            }
            else {
                self.tf_dosageAmount.text = nil;
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
                cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
                
                [cell setSelectionStyle:UITableViewCellEditingStyleNone];
                
                cell.textLabel.text = NSLocalizedString(@"UNIT", nil);
                
                // Initialize the dosage unit picker view
                if (self.pv_dosageUnit == nil) {
                    UIPickerView* pickerView = [[[UIPickerView alloc] init] autorelease];
                    [pickerView sizeToFit];
                    pickerView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
                    pickerView.dataSource = self;
                    pickerView.delegate = self;
                    pickerView.showsSelectionIndicator = YES;
                    
                    self.pv_dosageUnit = pickerView;
                    
                    self.tf_dosageUnit = [[UITextField alloc] initWithFrame:CGRectMake(110, 0, 170, 21)];
                    self.tf_dosageUnit.adjustsFontSizeToFitWidth = YES;
                    self.tf_dosageUnit.textColor = [UIColor darkGrayColor];
                    self.tf_dosageUnit.placeholder = NSLocalizedString(@"SELECT UNIT", nil);
                    self.tf_dosageUnit.backgroundColor = [UIColor clearColor];
                    self.tf_dosageUnit.textAlignment = UITextAlignmentRight;
                    self.tf_dosageUnit.delegate = self;
                    [self.tf_dosageUnit setEnabled:YES];
                    
                    self.tf_dosageUnit.inputView = self.pv_dosageUnit;
                    
                    cell.accessoryView = self.tf_dosageUnit;
                }
            }
            
            if (self.dosageUnit != nil) {
                self.tf_dosageUnit.text = self.dosageUnit;
            }
            else {
                self.tf_dosageUnit.text = nil;
            }
            
            // disable the cell until the "Edit" button is pressed
            if (self.isEditing == YES) {
                [cell setUserInteractionEnabled:YES];
                [self.tf_dosageUnit setClearButtonMode:UITextFieldViewModeAlways];
            }
            else {
                [cell setUserInteractionEnabled:NO];
                [self.tf_dosageUnit setClearButtonMode:UITextFieldViewModeNever];
            }
        }
    }
    else if (indexPath.section == 3) {
        // Schedule section
        
        if (indexPath.row == 0) {
            // Schedule start date row
            
            CellIdentifier = @"ScheduleStartDate";
            cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            
            if (cell == nil) {
                cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
                
                [cell setSelectionStyle:UITableViewCellEditingStyleNone];
                
                cell.textLabel.text = NSLocalizedString(@"STARTS", nil);
                
                // Initialize the start date picker view
                if (self.pv_startDate == nil) {
                    UIDatePicker* pickerView = [[[UIDatePicker alloc] init] autorelease];
                    [pickerView sizeToFit];
                    pickerView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
                    [pickerView addTarget:self action:@selector(dateChanged:) forControlEvents:UIControlEventValueChanged];
                    pickerView.datePickerMode = UIDatePickerModeDateAndTime;
                    
                    self.pv_startDate = pickerView;
                    
                    self.tf_scheduleStartDate = [[UITextField alloc] initWithFrame:CGRectMake(110, 0, 170, 21)];
                    self.tf_scheduleStartDate.adjustsFontSizeToFitWidth = YES;
                    self.tf_scheduleStartDate.textColor = [UIColor darkGrayColor];
                    self.tf_scheduleStartDate.backgroundColor = [UIColor clearColor];
                    self.tf_scheduleStartDate.textAlignment = UITextAlignmentRight;
                    self.tf_scheduleStartDate.delegate = self;
                    [self.tf_scheduleStartDate setEnabled:YES];
                    
                    self.tf_scheduleStartDate.inputView = self.pv_startDate;
                    
                    cell.accessoryView = self.tf_scheduleStartDate;
                }
            }
            
            if (self.sheduleStartDate != nil) {
                NSDate *startDate = [DateTimeHelper parseWebServiceDateDouble:self.sheduleStartDate];
                self.tf_scheduleStartDate.text = [self.dateFormatter stringFromDate:startDate];
            }
            else {
                NSDate *startDate = [NSDate date];
                self.tf_scheduleStartDate.text = [self.dateFormatter stringFromDate:startDate];
            }
            
//            // disable the cell until the "Edit" button is pressed
//            if (self.isEditing == YES) {
//                [cell setUserInteractionEnabled:YES];
//                [self.tf_scheduleStartDate setClearButtonMode:UITextFieldViewModeAlways];
//            }
//            else {
                [cell setUserInteractionEnabled:NO];
                [self.tf_scheduleStartDate setClearButtonMode:UITextFieldViewModeNever];
//            }
        }
        else if (indexPath.row == 1) {
            // Schedule amount row
            
            CellIdentifier = @"ScheduleAmount";
            cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            
            if (cell == nil) {
                cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
                
                [cell setSelectionStyle:UITableViewCellEditingStyleNone];
                
                cell.textLabel.text = NSLocalizedString(@"TAKE", nil);
                
                // Initialize the schedule amount picker view
                if (self.pv_scheduleAmount == nil) {
                    UIPickerView* pickerView = [[[UIPickerView alloc] init] autorelease];
                    [pickerView sizeToFit];
                    pickerView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
                    pickerView.dataSource = self;
                    pickerView.delegate = self;
                    pickerView.showsSelectionIndicator = YES;
                    
                    self.pv_scheduleAmount = pickerView;
                    
                    self.tf_scheduleAmount = [[UITextField alloc] initWithFrame:CGRectMake(110, 0, 170, 21)];
                    self.tf_scheduleAmount.adjustsFontSizeToFitWidth = YES;
                    self.tf_scheduleAmount.textColor = [UIColor darkGrayColor];
                    self.tf_scheduleAmount.backgroundColor = [UIColor clearColor];
                    self.tf_scheduleAmount.textAlignment = UITextAlignmentRight;
                    self.tf_scheduleAmount.delegate = self;
                    [self.tf_scheduleAmount setEnabled:YES];
                    
                    self.tf_scheduleAmount.inputView = self.pv_scheduleAmount;
                    
                    cell.accessoryView = self.tf_scheduleAmount;
                }
            }
            
//            if (self. != nil) {
                self.tf_scheduleAmount.text = @"1 dose";
//            }
//            else {
//                self.tf_scheduleAmount.text = nil;
//            }
            
            // disable the cell until the "Edit" button is pressed
//            if (self.isEditing == YES) {
//                [cell setUserInteractionEnabled:YES];
//                [self.tf_dosageUnit setClearButtonMode:UITextFieldViewModeAlways];
//            }
//            else {
                [cell setUserInteractionEnabled:NO];
                [self.tf_scheduleAmount setClearButtonMode:UITextFieldViewModeNever];
//            }
        }
        else if (indexPath.row == 2) {
            // Schedule amount row
            
            CellIdentifier = @"ScheduleRepeat";
            cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            
            if (cell == nil) {
                cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
                
                [cell setSelectionStyle:UITableViewCellEditingStyleNone];
                
                cell.textLabel.text = NSLocalizedString(@"EVERY", nil);
                
                // Initialize the schedule repeat picker view
                if (self.pv_scheduleRepeat == nil) {
                    UIPickerView* pickerView = [[[UIPickerView alloc] init] autorelease];
                    [pickerView sizeToFit];
                    pickerView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
                    pickerView.dataSource = self;
                    pickerView.delegate = self;
                    pickerView.showsSelectionIndicator = YES;
                    
                    self.pv_scheduleRepeat = pickerView;
                    
                    self.tf_scheduleRepeat = [[UITextField alloc] initWithFrame:CGRectMake(110, 0, 170, 21)];
                    self.tf_scheduleRepeat.adjustsFontSizeToFitWidth = YES;
                    self.tf_scheduleRepeat.textColor = [UIColor darkGrayColor];
                    self.tf_scheduleRepeat.backgroundColor = [UIColor clearColor];
                    self.tf_scheduleRepeat.textAlignment = UITextAlignmentRight;
                    self.tf_scheduleRepeat.delegate = self;
                    [self.tf_scheduleRepeat setEnabled:YES];
                    
                    self.tf_scheduleRepeat.inputView = self.pv_scheduleRepeat;
                    
                    cell.accessoryView = self.tf_scheduleRepeat;
                }
            }
            
            //            if (self. != nil) {
            self.tf_scheduleRepeat.text = @"6 hours";
            //            }
            //            else {
            //                self.tf_scheduleAmount.text = nil;
            //            }
            
            // disable the cell until the "Edit" button is pressed
            //            if (self.isEditing == YES) {
            //                [cell setUserInteractionEnabled:YES];
            //                [self.tf_dosageUnit setClearButtonMode:UITextFieldViewModeAlways];
            //            }
            //            else {
            [cell setUserInteractionEnabled:NO];
            [self.tf_scheduleRepeat setClearButtonMode:UITextFieldViewModeNever];
            //            }
        }
        else if (indexPath.row == 3) {
            // Schedule duration row
            
            CellIdentifier = @"ScheduleDuration";
            cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            
            if (cell == nil) {
                cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
                
                [cell setSelectionStyle:UITableViewCellEditingStyleNone];
                
                cell.textLabel.text = NSLocalizedString(@"FOR", nil);
                
                // Initialize the schedule repeat picker view
                if (self.pv_scheduleDuration == nil) {
                    UIPickerView* pickerView = [[[UIPickerView alloc] init] autorelease];
                    [pickerView sizeToFit];
                    pickerView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
                    pickerView.dataSource = self;
                    pickerView.delegate = self;
                    pickerView.showsSelectionIndicator = YES;
                    
                    self.pv_scheduleDuration = pickerView;
                    
                    self.tf_scheduleDuration = [[UITextField alloc] initWithFrame:CGRectMake(110, 0, 170, 21)];
                    self.tf_scheduleDuration.adjustsFontSizeToFitWidth = YES;
                    self.tf_scheduleDuration.textColor = [UIColor darkGrayColor];
                    self.tf_scheduleDuration.backgroundColor = [UIColor clearColor];
                    self.tf_scheduleDuration.textAlignment = UITextAlignmentRight;
                    self.tf_scheduleDuration.delegate = self;
                    [self.tf_scheduleDuration setEnabled:YES];
                    
                    self.tf_scheduleDuration.inputView = self.pv_scheduleDuration;
                    
                    cell.accessoryView = self.tf_scheduleDuration;
                }
            }
            
            //            if (self. != nil) {
            self.tf_scheduleDuration.text = @"1 week";
            //            }
            //            else {
            //                self.tf_scheduleAmount.text = nil;
            //            }
            
            // disable the cell until the "Edit" button is pressed
            //            if (self.isEditing == YES) {
            //                [cell setUserInteractionEnabled:YES];
            //                [self.tf_dosageUnit setClearButtonMode:UITextFieldViewModeAlways];
            //            }
            //            else {
            [cell setUserInteractionEnabled:NO];
            [self.tf_scheduleDuration setClearButtonMode:UITextFieldViewModeNever];
            //            }
        }
        else if (indexPath.row == 4) {
            // Schedule reminder row
            
            CellIdentifier = @"ScheduleReminder";
            cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            
            if (cell == nil) {
                cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
                
                [cell setSelectionStyle:UITableViewCellEditingStyleNone];
                
                cell.textLabel.text = NSLocalizedString(@"REMINDER", nil);
                
                // Initialize the schedule repeat picker view
                if (self.pv_scheduleReminder == nil) {
                    UIPickerView* pickerView = [[[UIPickerView alloc] init] autorelease];
                    [pickerView sizeToFit];
                    pickerView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
                    pickerView.dataSource = self;
                    pickerView.delegate = self;
                    pickerView.showsSelectionIndicator = YES;
                    
                    self.pv_scheduleReminder = pickerView;
                    
                    self.tf_scheduleReminder = [[UITextField alloc] initWithFrame:CGRectMake(110, 0, 170, 21)];
                    self.tf_scheduleReminder.adjustsFontSizeToFitWidth = YES;
                    self.tf_scheduleReminder.textColor = [UIColor darkGrayColor];
                    self.tf_scheduleReminder.backgroundColor = [UIColor clearColor];
                    self.tf_scheduleReminder.textAlignment = UITextAlignmentRight;
                    self.tf_scheduleReminder.delegate = self;
                    [self.tf_scheduleReminder setEnabled:YES];
                    
                    self.tf_scheduleReminder.inputView = self.pv_scheduleReminder;
                    
                    cell.accessoryView = self.tf_scheduleReminder;
                }
            }
            
            //            if (self. != nil) {
            self.tf_scheduleReminder.text = @"5 minutes before";
            //            }
            //            else {
            //                self.tf_scheduleAmount.text = nil;
            //            }
            
            // disable the cell until the "Edit" button is pressed
            //            if (self.isEditing == YES) {
            //                [cell setUserInteractionEnabled:YES];
            //                [self.tf_dosageUnit setClearButtonMode:UITextFieldViewModeAlways];
            //            }
            //            else {
            [cell setUserInteractionEnabled:NO];
            [self.tf_scheduleReminder setClearButtonMode:UITextFieldViewModeNever];
            //            }
        }
    }
    else if (indexPath.section == 4) {
        // Reason section
        
        CellIdentifier = @"Reason";
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        if (cell == nil) {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
            
            cell.textLabel.text = nil;
            [cell setSelectionStyle:UITableViewCellEditingStyleNone];
            
            self.tv_reason = [[UITextView alloc] initWithFrame:CGRectMake(5, 0, 290, 115)];
            self.tv_reason.font = [UIFont systemFontOfSize:16.0f];
            self.tv_reason.textColor = [UIColor lightGrayColor];
            self.tv_reason.text = NSLocalizedString(@"ENTER REASON", nil);
            self.tv_reason.keyboardType = UIKeyboardTypeDefault;
            self.tv_reason.returnKeyType = UIReturnKeyDefault;
            self.tv_reason.backgroundColor = [UIColor clearColor];
            self.tv_reason.autocorrectionType = UITextAutocorrectionTypeNo;
            self.tv_reason.autocapitalizationType = UITextAutocapitalizationTypeSentences;
            self.tv_reason.textAlignment = UITextAlignmentLeft;
            self.tv_reason.delegate = self;
            
            [cell.contentView addSubview:self.tv_reason];
            
        }
        
        if (self.reason != nil) {
            self.tv_reason.textColor = [UIColor blackColor];
            self.tv_reason.text = self.reason;
        }
        else {
            self.tv_reason.textColor = [UIColor lightGrayColor];
            self.tv_reason.text = NSLocalizedString(@"ENTER REASON", nil);
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
    if (indexPath.section == 4) {
        return 115.0f;
    }
    else if (indexPath.section == 2 ||
             indexPath.section == 3)
    {
        return 45.0f;
    }
    else {
        return 46.0f;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        // Medication Name selected
        
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        
        // Set the medication name text field as active
        [self.tf_medicationName becomeFirstResponder];
        
    }
    else if (indexPath.section == 1) {
        // Method selected
        
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        
        // Set the birthday text field as active
        [self.tf_method becomeFirstResponder];
        
    }
    else if (indexPath.section == 2) {
        // Dosage section
        
        if (indexPath.row == 0) {
            // Dosage Amount row
            
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
            
            // Set the dosage amount text field as active
            [self.tf_dosageAmount becomeFirstResponder];
            
        }
        else if (indexPath.row == 1) {
            // Dosage Unit row
            
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
            
            // Set the dosage amount text field as active
            [self.tf_dosageUnit becomeFirstResponder];
        }
    }
    else if (indexPath.section == 4) {
        // Reason selected
        
        [self.tv_reason becomeFirstResponder];
        
    }
}

#pragma mark - UIPickerView Methods
#pragma mark UIDatePickerView Methods
- (void)dateChanged:(id)sender
{
//    self.tf_startDate.text = [self.dateFormatter stringFromDate:self.pv_birthday.date];
    
    NSDate* startDate = self.pv_startDate.date;
    double doubleDate = [startDate timeIntervalSince1970];
    self.sheduleStartDate = [NSNumber numberWithDouble:doubleDate];
}

#pragma mark UIPickerView Data Source
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    if (pickerView == self.pv_method) {
        return [self.methodArray count];
    }
    else if (pickerView == self.pv_dosageUnit) {
        return [self.dosageUnitArray count];
    }
    else {
        return 0;
    }
}

#pragma mark UIPickerView Delegate
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    if (pickerView == self.pv_method) {
        return [self.methodArray objectAtIndex:row];
    }
    else if (pickerView == self.pv_dosageUnit) {
        return [self.dosageUnitArray objectAtIndex:row];
    }
    else {
        return nil;
    }
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    if (pickerView == self.pv_method) {
        self.tf_method.text = [self.methodArray objectAtIndex:row];
        
        self.method = [self.methodArray objectAtIndex:row];
    }
    else if (pickerView == self.pv_dosageUnit) {
        self.tf_dosageUnit.text = [self.dosageUnitArray objectAtIndex:row];
        
        self.dosageUnit = [self.dosageUnitArray objectAtIndex:row];
    }
}

#pragma mark - UITextview and TextField Delegate Methods
- (void)textViewDidBeginEditing:(UITextView *)textView
{
    // reason textview editing has begun
    self.tv_reason = textView;
    
    // Scroll tableview to this row
    [self.tbl_prescriptionDetails setContentOffset:CGPointMake(0, 610) animated:YES];
    
    // Mark this row selected
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:3];
    [self.tbl_prescriptionDetails selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
    
    // disable nav bar buttons until text entry complete
    if (self.prescriptionID == nil) {
        // New prescription
        self.navigationItem.rightBarButtonItem.enabled = NO;
        self.navigationItem.leftBarButtonItem.enabled = NO;
    }
    else {
        // Editing existing prescription
        self.navigationItem.rightBarButtonItem.enabled = NO;
    }
    
    // Clear the default text of the caption textview upon startin to edit
    if ([self.tv_reason.text isEqualToString:NSLocalizedString(@"ENTER REASON", nil)]) {
        [self.tv_reason setText:@""];
        self.tv_reason.textColor = [UIColor blackColor];
    }
    
    // Add the tap gesture recognizer to capture background touches which will dismiss the keyboard
    [self.tbl_prescriptionDetails addGestureRecognizer:self.gestureRecognizer];
    
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
    self.tv_reason = textView;
    
    // Scroll tableview to this row
    [self.tbl_prescriptionDetails setContentOffset:CGPointMake(0, 85) animated:YES];
    
    // Deselect this row
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:3];
    [self.tbl_prescriptionDetails deselectRowAtIndexPath:indexPath animated:NO];
    
    // Add default text back if reason was left empty
    if ([self.tv_reason.text isEqualToString:@""] || [self.tv_reason.text isEqualToString:NSLocalizedString(@"ENTER REASON", nil)]) {
        self.tv_reason.textColor = [UIColor lightGrayColor];
        [self.tv_reason setText:NSLocalizedString(@"ENTER REASON", nil)];
    }
    else {
        // caption is acceptable
        
        NSString *trimmedReason = [self.tv_reason.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        
        self.reason = trimmedReason;
        
    }
    
    // Re-enable nav bar buttons until text entry complete
    if (self.prescriptionID == nil) {
        // New prescription
        self.navigationItem.rightBarButtonItem.enabled = YES;
        self.navigationItem.leftBarButtonItem.enabled = YES;
    }
    else {
        // Editing existing prescription
        self.navigationItem.rightBarButtonItem.enabled = YES;
    }
    
    // remove the tap gesture recognizer so it does not interfere with other table view touches
    [self.tbl_prescriptionDetails removeGestureRecognizer:self.gestureRecognizer];
    
}

#pragma mark - TextField Delegate
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    // textfield editing has begun
    
    // Determine which text field is active and make appropriate changes
    if (textField == self.tf_medicationName) {
        // Disable the table view scrolling
        [self.tbl_prescriptionDetails setScrollEnabled:NO];
        
        // Add the tap gesture recognizer to capture background touches which will dismiss the keyboard
        [self.tbl_prescriptionDetails addGestureRecognizer:self.gestureRecognizer];
        
    }
    else if (textField == self.tf_method) {
        
        [self showDisabledBackgroundView];
        
        // Add the tap gesture recognizer to capture background touches which will dismiss the keyboard
        [self.v_disabledBackground addGestureRecognizer:self.gestureRecognizer];
        
        // Scroll tableview to this row
        [self.tbl_prescriptionDetails setContentOffset:CGPointMake(0, 50) animated:YES];
        
        if ([self.tf_method.text isEqualToString:@""] == NO &&
            [self.tf_method.text isEqualToString:@" "] == NO)
        {
            int row = [self.methodArray indexOfObject:self.tf_method.text];
            [self.pv_method selectRow:row inComponent:0 animated:YES];
            
            self.method = [self.methodArray objectAtIndex:row];
        }
        else {
            self.tf_method.text = [self.methodArray objectAtIndex:0];
            
            self.method = [self.methodArray objectAtIndex:0];
        }
        
    }
    else if (textField == self.tf_dosageAmount) {
        // Disable the table view scrolling
        [self.tbl_prescriptionDetails setScrollEnabled:NO];
        
        // Add the tap gesture recognizer to capture background touches which will dismiss the keyboard
        [self.tbl_prescriptionDetails addGestureRecognizer:self.gestureRecognizer];
        
        [self.tbl_prescriptionDetails setContentOffset:CGPointMake(0, 135) animated:YES];
        
    }
    else if (textField == self.tf_dosageUnit) {
        
        [self showDisabledBackgroundView];
        
        // Add the tap gesture recognizer to capture background touches which will dismiss the keyboard
        [self.v_disabledBackground addGestureRecognizer:self.gestureRecognizer];
        
        // Scroll tableview to this row
        [self.tbl_prescriptionDetails setContentOffset:CGPointMake(0, 170) animated:YES];
        
        if ([self.tf_dosageUnit.text isEqualToString:@""] == NO &&
            [self.tf_dosageUnit.text isEqualToString:@" "] == NO)
        {
            int row = [self.dosageUnitArray indexOfObject:self.tf_dosageUnit.text];
            [self.pv_dosageUnit selectRow:row inComponent:0 animated:YES];
            
            self.dosageUnit = [self.dosageUnitArray objectAtIndex:row];
        }
        else {
            self.tf_dosageUnit.text = [self.dosageUnitArray objectAtIndex:0];
            
            self.method = [self.dosageUnitArray objectAtIndex:0];
        }
        
    }
    
    // disable nav bar buttons until text entry complete
    if (self.prescriptionID == nil) {
        // New prescription
        self.navigationItem.rightBarButtonItem.enabled = NO;
        self.navigationItem.leftBarButtonItem.enabled = NO;
    }
    else {
        // Editing existing prescription
        self.navigationItem.rightBarButtonItem.enabled = NO;
    }
    
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
    
    if (textField == self.tf_medicationName) {
        // Enable the table view scrolling
        [self.tbl_prescriptionDetails setScrollEnabled:YES];
        
        // remove the tap gesture recognizer so it does not interfere with other table view touches
        [self.tbl_prescriptionDetails removeGestureRecognizer:self.gestureRecognizer];
        
        if ([enteredText isEqualToString:@""] == YES ||
            [enteredText isEqualToString:@" "] == YES)
        {
            self.medicationName = nil;
        }
        else {
            self.medicationName = enteredText;
        }
    }
    else if (textField == self.tf_method) {
        [self hideDisabledBackgroundView];
        
        if ([enteredText isEqualToString:@""] == YES ||
            [enteredText isEqualToString:@" "] == YES)
        {
            self.method = nil;
        }
        else {
            self.method = enteredText;
        }
    }
    else if (textField == self.tf_dosageAmount) {
        // Enable the table view scrolling
        [self.tbl_prescriptionDetails setScrollEnabled:YES];
        
        // remove the tap gesture recognizer so it does not interfere with other table view touches
        [self.tbl_prescriptionDetails removeGestureRecognizer:self.gestureRecognizer];
        
        if ([enteredText isEqualToString:@""] == YES ||
            [enteredText isEqualToString:@" "] == YES)
        {
            self.dosageAmount = nil;
        }
        else {
            self.dosageAmount = enteredText;
        }
    }
    else if (textField == self.tf_dosageUnit) {
        [self hideDisabledBackgroundView];
        
        if ([enteredText isEqualToString:@""] == YES ||
            [enteredText isEqualToString:@" "] == YES)
        {
            self.dosageUnit = nil;
        }
        else {
            self.dosageUnit = enteredText;
        }
    }
    
    // Re-enable nav bar buttons until text entry complete
    if (self.prescriptionID == nil) {
        // New prescription
        self.navigationItem.rightBarButtonItem.enabled = YES;
        self.navigationItem.leftBarButtonItem.enabled = YES;
    }
    else {
        // Editing existing prescription
        self.navigationItem.rightBarButtonItem.enabled = YES;
    }
    
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
- (void)scheduleReminders {
    NSCalendar *calendar = [NSCalendar autoupdatingCurrentCalendar];
    
    // Get the current date
    NSDate *pickerDate = [self.pv_startDate date];
    
    // Break the date up into components
    NSDateComponents *dateComponents = [calendar components:( NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit )
												   fromDate:pickerDate];
    NSDateComponents *timeComponents = [calendar components:( NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit )
												   fromDate:pickerDate];
    // Set up the fire time
    NSDateComponents *dateComps = [[NSDateComponents alloc] init];
    [dateComps setDay:[dateComponents day]];
    [dateComps setMonth:[dateComponents month]];
    [dateComps setYear:[dateComponents year]];
    [dateComps setHour:[timeComponents hour]];
    [dateComps setMinute:[timeComponents minute] + 1];
	[dateComps setSecond:[timeComponents second]];
    NSDate *itemDate = [calendar dateFromComponents:dateComps];
    [dateComps release];
    
    UILocalNotification *localNotif = [[UILocalNotification alloc] init];
    if (localNotif == nil)
        return;
    localNotif.fireDate = itemDate;
    localNotif.timeZone = [NSTimeZone defaultTimeZone];
    
	// Notification details
    localNotif.alertBody = @"Take medication";
	// Set the action button
    localNotif.alertAction = @"Confirm";
    
    localNotif.soundName = UILocalNotificationDefaultSoundName;
    localNotif.applicationIconBadgeNumber = 1;
    
	// Specify custom data for the notification
    NSDictionary *infoDict = [NSDictionary dictionaryWithObject:@"someValue" forKey:@"someKey"];
    localNotif.userInfo = infoDict;
    
	// Schedule the notification
    [[UIApplication sharedApplication] scheduleLocalNotification:localNotif];
    [localNotif release];
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
    [button setTitle:NSLocalizedString(@"DELETE PRESCRIPTION", nil) forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont boldSystemFontOfSize:17.0f];
    button.titleLabel.shadowColor = [UIColor lightGrayColor];
    button.titleLabel.shadowOffset = CGSizeMake(0.0f, -1.0f);
    [button.layer setCornerRadius:10.0f];
    [button.layer setMasksToBounds:YES];
    [button.layer setBorderWidth:2.0f];
    [button.layer setBorderColor: [[UIColor darkGrayColor] CGColor]];
    button.frame = CGRectMake(10.0f, 15.0f, 300.0f, 44.0f);
    
    [button addTarget:self action:@selector(onDeletePrescriptionButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    UIView *footer = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 80.0f)];
    [footer addSubview:button];
    
    self.tbl_prescriptionDetails.tableFooterView = footer;
    [footer release];
}

- (void)hideInputView {
    [[self view] endEditing:YES];
}

- (void)editPrescription {
    
    self.isEditing = YES;
    
    // Reload the table view to enable user interaction and accessory views on the tableview cells
    [self.tbl_prescriptionDetails reloadData];
    
    // Hide the back button
    [self.navigationItem setHidesBackButton:YES animated:YES];
    
    // add the "Done" button to the nav bar
    UIBarButtonItem* rightButton = [[UIBarButtonItem alloc]
                                    initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                    target:self
                                    action:@selector(doneEditingPrescription:)];
    self.navigationItem.rightBarButtonItem = rightButton;
    [rightButton release];
    
    // add the "Delete" button to the table view's footer
//    [self showDeleteNavBarButton];
    [self showDeleteButton];
    
}

- (void)doneEditingPrescription:(id)sender {
    if (self.medicationName == nil ||
        self.method == nil ||
        self.dosageAmount == nil ||
        self.dosageUnit == nil ||
        [self.medicationName isEqualToString:@""] ||
        [self.method isEqualToString:@""] ||
        [self.dosageAmount isEqualToString:@""] ||
        [self.dosageUnit isEqualToString:@""])
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
        
        // Hide the keyboard if it is shown
        [self hideInputView];
        
        // Re-show the back button
        [self.navigationItem setHidesBackButton:NO animated:YES];
        
        // add the "Edit" button back to the nav bar
        UIBarButtonItem* rightButton = [[UIBarButtonItem alloc]
                                        initWithBarButtonSystemItem:UIBarButtonSystemItemEdit
                                        target:self
                                        action:@selector(onEditPrescriptionButtonPressed:)];
        self.navigationItem.rightBarButtonItem = rightButton;
        [rightButton release];
        
        // remove the "Delete" button
        //    self.navigationItem.leftBarButtonItem = nil;
        self.tbl_prescriptionDetails.tableFooterView = nil;
        
        // Update the prescription properties and save
        ResourceContext *resourceContext = [ResourceContext instance];
        Prescription *prescription = (Prescription *)[resourceContext resourceWithType:PRESCRIPTION withID:self.prescriptionID];
        
        prescription.name = self.medicationName;
        prescription.method = self.method;
        prescription.dosageamount = self.dosageAmount;
        prescription.dosageunit = self.dosageUnit;
        prescription.notes = self.reason;
        
        [resourceContext save:NO onFinishCallback:nil trackProgressWith:nil];
        
        // Reload the table view to disable user interaction and accessory views on the tableview cells
        [self.tbl_prescriptionDetails reloadData];
    }
}

- (void)deletePrescription {
    // Delete the prescription object
    ResourceContext *resourceContext = [ResourceContext instance];
    [resourceContext delete:self.prescriptionID withType:PRESCRIPTION];
    
    self.prescriptionID = nil;
    self.medicationName = nil;
    self.method = nil;
    self.dosageAmount = nil;
    self.dosageUnit = nil;
    self.reason = nil;
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)onEditPrescriptionButtonPressed:(id)sender {
    // Promt user to backup data before editing profile information
    UIAlertView* alert = [[UIAlertView alloc]
                          initWithTitle:NSLocalizedString(@"EDIT PRESCRIPTION", nil)
                          message:NSLocalizedString(@"EDIT PRESCRIPTION MESSAGE", nil)
                          delegate:self
                          cancelButtonTitle:NSLocalizedString(@"YES", nil)
                          otherButtonTitles:NSLocalizedString(@"NO", nil), nil];
    [alert show];
    [alert release];
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
    if (self.medicationName == nil ||
        self.method == nil ||
        self.dosageAmount == nil ||
        self.dosageUnit == nil ||
        [self.medicationName isEqualToString:@""] ||
        [self.method isEqualToString:@""] ||
        [self.dosageAmount isEqualToString:@""] ||
        [self.dosageUnit isEqualToString:@""])
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
        // Schedule the reminders
        // We dont need this method in the final version, you can uncomment it for now
        // since the real method doesn work
        //[self scheduleReminders];
        
        // Exit editing and save changes
        ResourceContext* resourceContext = [ResourceContext instance];
        
        Prescription *prescription = [Prescription createPrescriptionWithName:self.medicationName withMethod:self.method withDosageAmount:self.dosageAmount withDosageUnit:self.dosageUnit withNotes:self.reason];   
        
        //we need to then create an array of prescription objects corresponding to this
        //particular prescription
        NSArray* prescriptionInstances = [PrescriptionInstance createPrescriptionInstancesFor:prescription];
        //now we have an array of prescription instances corresponding to the prescription
        
        //we pass this to the local notification manager which will schedule them for
        //notifications as appropriate
        LocalNotificationManager* localNotificationManager = [LocalNotificationManager instance];
        [localNotificationManager scheduleNotificationsFor:prescriptionInstances];
        
        
        
        
        
        [resourceContext save:NO onFinishCallback:nil trackProgressWith:nil];
        
        self.prescriptionID = prescription.objectid;
        
        [self.navigationController dismissModalViewControllerAnimated:YES];
    }
}

- (void)onCanceledAddingPrescriptionButtonPressed:(id)sender {
    [self.navigationController dismissModalViewControllerAnimated:YES];
}

#pragma mark - UIAlertView Delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        // Backup data
        NSLog(@"Backup data");
    }
    else {
        [self editPrescription];
    }
}

#pragma mark - UIActionSheet Delegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        // Process delete WITHOUT data export
        [self deletePrescription];
    }
    else if (buttonIndex == 1) {
        // Process delete WITH data export
        [self deletePrescription];
    }
    else {
        // Cancel
        
    }
}

#pragma mark - Static Initializers
+ (ClifePrescriptionDetailsViewController *)createInstanceForPrescriptionWithID:(NSNumber *)prescriptionID {
    ClifePrescriptionDetailsViewController *instance = [[ClifePrescriptionDetailsViewController alloc] initWithNibName:@"ClifePrescriptionDetailsViewController" bundle:nil];
    [instance autorelease];
    
    instance.prescriptionID = prescriptionID;
    
    return instance;
}

@end
