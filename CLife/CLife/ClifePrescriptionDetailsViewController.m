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
#import "SchedulePeriods.h"
#import "Macros.h"
#import "PrescriptionInstanceManager.h"
#import "ClifeAppDelegate.h"

@interface ClifePrescriptionDetailsViewController ()

@end

@implementation ClifePrescriptionDetailsViewController
@synthesize tbl_prescriptionDetails = m_tbl_prescriptionDetails;

@synthesize av_edit                 = m_av_edit;
@synthesize av_delete               = m_av_delete;

@synthesize sectionsArray           = m_sectionsArray;

@synthesize prescriptionID          = m_prescriptionID;

@synthesize tf_medicationName       = m_tf_medicationName;
@synthesize tf_doctorName           = m_tf_doctorName;
@synthesize tf_method               = m_tf_method;
@synthesize pv_method               = m_pv_method;
@synthesize methodArray             = m_methodArray;
@synthesize tf_dosageAmount         = m_tf_dosageAmount;
@synthesize tf_dosageUnit           = m_tf_dosageUnit;
@synthesize pv_dosageUnit           = m_pv_dosageUnit;
@synthesize dosageUnitArray         = m_dosageUnitArray;
@synthesize tv_reason               = m_tv_reason;

@synthesize dateOnlyFormatter       = m_dateOnlyFormatter;
@synthesize dateAndTimeFormatter    = m_dateAndTimeFormatter;

@synthesize scheduleAmountArray     = m_scheduleAmountArray;

@synthesize tf_scheduleStartDate    = m_tf_scheduleStartDate;
@synthesize pv_scheduleStartDate    = m_pv_scheduleStartDate;

@synthesize tf_scheduleAmount       = m_tf_scheduleAmount;
@synthesize pv_scheduleAmount       = m_pv_scheduleAmount;

@synthesize schedulePeriodSingularArray = m_schedulePeriodSingularArray;
@synthesize schedulePeriodPluralArray = m_schedulePeriodPluralArray;

@synthesize tf_scheduleRepeat       = m_tf_scheduleRepeat;
@synthesize pv_scheduleRepeat       = m_pv_scheduleRepeat;

@synthesize tf_scheduleOccurences   = m_tf_scheduleOccurences;
@synthesize pv_scheduleOccurences   = m_pv_scheduleOccurences;

@synthesize tf_scheduleEndDate      = m_tf_scheduleEndDate;
@synthesize pv_scheduleEndDate      = m_pv_scheduleEndDate;

@synthesize gestureRecognizer       = m_gestureRecognizer;
@synthesize v_disabledBackground    = m_v_disabledBackground;

@synthesize didRequestEdit          = m_didRequestEdit;
@synthesize didRequestDelete        = m_didRequestDelete;
@synthesize isEditing               = m_isEditing;
@synthesize occurancesRowIsShown    = m_occurancesRowIsShown;
@synthesize isEditable              = m_isEditable;

@synthesize medicationName          = m_medicationName;
@synthesize doctorName              = m_doctorName;
@synthesize method                  = m_method;
@synthesize dosageAmount            = m_dosageAmount;
@synthesize dosageUnit              = m_dosageUnit;
@synthesize reason                  = m_reason;

@synthesize scheduleStartDate        = m_scheduleStartDate;
@synthesize scheduleAmount          = m_scheduleAmount;
@synthesize scheduleRepeatNumber    = m_scheduleRepeatNumber;
@synthesize scheduleRepeatPeriod      = m_scheduleRepeatPeriod;
@synthesize scheduleOccurenceNumber = m_scheduleOccurenceNumber;
@synthesize scheduleEndDate         = m_scheduleEndDate;

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
    
    // Setup date formatters for pickers
    self.dateOnlyFormatter = [[[NSDateFormatter alloc] init] autorelease];
    [self.dateOnlyFormatter setLocale:[NSLocale currentLocale]];
    [self.dateOnlyFormatter setDateStyle:NSDateFormatterLongStyle];
    [self.dateOnlyFormatter setTimeStyle:NSDateFormatterNoStyle];
    
    self.dateAndTimeFormatter = [[[NSDateFormatter alloc] init] autorelease];
    [self.dateAndTimeFormatter setLocale:[NSLocale currentLocale]];
    [self.dateAndTimeFormatter setDateStyle:NSDateFormatterMediumStyle];
    [self.dateAndTimeFormatter setTimeStyle:NSDateFormatterShortStyle];
    
    // Setup array for section titles
    self.sectionsArray = [NSArray arrayWithObjects:
                          NSLocalizedString(@"MEDICATION", nil),
                          NSLocalizedString(@"DOCTOR", nil),
                          NSLocalizedString(@"METHOD", nil),
                          NSLocalizedString(@"DOSAGE", nil),
                          NSLocalizedString(@"REMINDER SCHEDULE", nil),
                          NSLocalizedString(@"REASON AND NOTES", nil),
                          nil];
    
    // Setup arrays for pickers
    self.methodArray = [NSArray arrayWithObjects:
                        NSLocalizedString(@"PILL", nil),
                        NSLocalizedString(@"LIQUID", nil),
                        NSLocalizedString(@"CREAM", nil),
                        NSLocalizedString(@"INJECTION", nil),
                        nil];
    
    self.dosageUnitArray = [NSArray arrayWithObjects:
                            NSLocalizedString(@"mg", nil),
                            NSLocalizedString(@"ug", nil),
                            NSLocalizedString(@"g", nil),
                            NSLocalizedString(@"ml", nil),
                            NSLocalizedString(@"ul", nil),
                            NSLocalizedString(@"l", nil),
                           nil];
    
    self.schedulePeriodSingularArray = [NSArray arrayWithObjects:
                                     NSLocalizedString(@"HOUR", nil),
                                     NSLocalizedString(@"DAY", nil),
                                     NSLocalizedString(@"WEEK", nil),
                                     NSLocalizedString(@"MONTH", nil),
                                     NSLocalizedString(@"YEAR", nil),
                                     nil];
    
    self.schedulePeriodPluralArray = [NSArray arrayWithObjects:
                            NSLocalizedString(@"HOURS", nil),
                            NSLocalizedString(@"DAYS", nil),
                            NSLocalizedString(@"WEEKS", nil),
                            NSLocalizedString(@"MONTHS", nil),
                            NSLocalizedString(@"YEARS", nil),
                            nil];
    
    // Setup tap gesture recognizer to capture touches on the tableview when the keyboard is visible
    self.gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideInputView)];
    
    // Are we opening an existing prescription or adding a new one?
    if (self.prescriptionID != nil) {
        // Existing prescription
        self.isEditing = NO;
        
        if (self.isEditable == YES) {
            // add the "Edit" button to the nav bar if openning an existing prescription
            UIBarButtonItem* rightButton = [[UIBarButtonItem alloc]
                                            initWithBarButtonSystemItem:UIBarButtonSystemItemEdit
                                            target:self
                                            action:@selector(onEditPrescriptionButtonPressed:)];
            self.navigationItem.rightBarButtonItem = rightButton;
            [rightButton release];
        }
        
        // Get the prescription object
        ResourceContext* resourceContext = [ResourceContext instance];
        Prescription* prescription = (Prescription*)[resourceContext resourceWithType:PRESCRIPTION withID:self.prescriptionID];
        
        self.medicationName = prescription.name;
        self.method = prescription.methodconstant;
        
        if (!prescription.doctor) {
            self.doctorName = nil;
        }
        else {
            self.doctorName = prescription.doctor;
        }
        
        self.dosageAmount = prescription.strength;
        self.dosageUnit = prescription.unit;
        
        self.scheduleStartDate = prescription.datestart;
        self.scheduleAmount = prescription.numberofdoses;
        self.scheduleRepeatNumber = prescription.repeatmultiple;
        self.scheduleRepeatPeriod = prescription.repeatperiod;
        self.scheduleOccurenceNumber = prescription.occurmultiple;
        self.scheduleEndDate = prescription.dateend;
        
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
        self.doctorName = nil;
        self.method = nil;
        
        self.dosageAmount = nil;
        self.dosageUnit = nil;
        
        self.scheduleStartDate = nil;
        self.scheduleAmount = nil;
        self.scheduleRepeatNumber = nil;
        self.scheduleRepeatPeriod = nil;
        self.scheduleOccurenceNumber = nil;
        self.scheduleEndDate = nil;
        
        self.reason = nil;
    }
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    
    self.tbl_prescriptionDetails = nil;
    self.av_edit = nil;
    self.av_delete = nil;
    self.tf_medicationName = nil;
    self.tf_doctorName = nil;
    self.gestureRecognizer = nil;
    self.tf_scheduleStartDate = nil;
    self.pv_scheduleStartDate = nil;
    self.dateOnlyFormatter = nil;
    self.dateAndTimeFormatter = nil;
    self.tf_scheduleAmount = nil;
    self.pv_scheduleAmount = nil;
    self.tf_scheduleRepeat = nil;
    self.pv_scheduleRepeat = nil;
    self.tf_scheduleOccurences = nil;
    self.pv_scheduleOccurences = nil;
    self.tf_scheduleEndDate = nil;
    self.pv_scheduleEndDate = nil;
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
    if (section == 3) {
        // Dosage section
        return 3;
    }
    if (section == 4) {
        // Schedule section
        if ([self.scheduleRepeatPeriod intValue] == kHOUR) {
            // Hide the number of daily occurances row
            self.occurancesRowIsShown = NO;
            return 3;
        }
        else {
            self.occurancesRowIsShown = YES;
            return 4;
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
        // Doctor Name section
        
        CellIdentifier = @"DoctorName";
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        if (cell == nil) {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
            
            [cell setSelectionStyle:UITableViewCellEditingStyleNone];
            
            self.tf_doctorName = [[UITextField alloc] initWithFrame:CGRectMake(8, 11, 282, 21)];
            self.tf_doctorName.font = [UIFont systemFontOfSize:17.0];
            self.tf_doctorName.adjustsFontSizeToFitWidth = YES;
            self.tf_doctorName.textColor = [UIColor blackColor];
            self.tf_doctorName.placeholder = NSLocalizedString(@"PRESCRIBED BY", nil);
            self.tf_doctorName.keyboardType = UIKeyboardTypeDefault;
            self.tf_doctorName.returnKeyType = UIReturnKeyDone;
            self.tf_doctorName.backgroundColor = [UIColor clearColor];
            self.tf_doctorName.autocorrectionType = UITextAutocorrectionTypeNo;
            self.tf_doctorName.autocapitalizationType = UITextAutocapitalizationTypeWords;
            self.tf_doctorName.textAlignment = UITextAlignmentLeft;
            self.tf_doctorName.delegate = self;
            [self.tf_doctorName setEnabled:YES];
            
            [cell.contentView addSubview:self.tf_doctorName];
            
        }
        
        if (self.doctorName != nil) {
            self.tf_doctorName.text = self.doctorName;
        }
        else {
            self.tf_doctorName.text = nil;
        }
        
        // disable the cell until the "Edit" button is pressed
        if (self.isEditing == YES) {
            [cell setUserInteractionEnabled:YES];
            [self.tf_doctorName setClearButtonMode:UITextFieldViewModeAlways];
        }
        else {
            [cell setUserInteractionEnabled:NO];
            [self.tf_doctorName setClearButtonMode:UITextFieldViewModeNever];
        }
    }
    else if (indexPath.section == 2) {
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
            self.tf_method.text = [self.methodArray objectAtIndex:[self.method intValue]];
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
    else if (indexPath.section == 3) {
        // Dosage section
        
        if (indexPath.row == 0) {
            // Dosage Strength row
            
            CellIdentifier = @"DosageStrength";
            cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            
            if (cell == nil) {
                cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
                
                cell.textLabel.text = NSLocalizedString(@"STRENGTH", nil);
                [cell setSelectionStyle:UITableViewCellEditingStyleNone];
                
//                self.tf_dosageAmount = [[UITextField alloc] initWithFrame:CGRectMake(100, 0, 180, 21)];
                self.tf_dosageAmount = [[UITextField alloc] initWithFrame:CGRectMake(140, 0, 140, 21)];
                self.tf_dosageAmount.adjustsFontSizeToFitWidth = YES;
                self.tf_dosageAmount.textColor = [UIColor darkGrayColor];
                self.tf_dosageAmount.placeholder = NSLocalizedString(@"ENTER STRENGTH", nil);
                self.tf_dosageAmount.keyboardType = UIKeyboardTypeDecimalPad;
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
                self.tf_dosageAmount.text = [self.dosageAmount stringValue];
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
                    
//                    self.tf_dosageUnit = [[UITextField alloc] initWithFrame:CGRectMake(80, 0, 200, 21)];
                    self.tf_dosageUnit = [[UITextField alloc] initWithFrame:CGRectMake(100, 0, 180, 21)];
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
        else if (indexPath.row == 2) {
            // Schedule amount row
            
            CellIdentifier = @"ScheduleAmount";
            cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            
            if (cell == nil) {
                cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
                
                [cell setSelectionStyle:UITableViewCellEditingStyleNone];
                
                cell.textLabel.text = NSLocalizedString(@"AMOUNT", nil);
                
                // Initialize the schedule amount picker view
                if (self.pv_scheduleAmount == nil) {
                    UIPickerView* pickerView = [[[UIPickerView alloc] init] autorelease];
                    [pickerView sizeToFit];
                    pickerView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
                    pickerView.dataSource = self;
                    pickerView.delegate = self;
                    pickerView.showsSelectionIndicator = YES;
                    
                    self.pv_scheduleAmount = pickerView;
                    
//                    self.tf_scheduleAmount = [[UITextField alloc] initWithFrame:CGRectMake(80, 0, 200, 21)];
                    self.tf_scheduleAmount = [[UITextField alloc] initWithFrame:CGRectMake(100, 0, 180, 21)];
                    self.tf_scheduleAmount.adjustsFontSizeToFitWidth = YES;
                    self.tf_scheduleAmount.placeholder = NSLocalizedString(@"ENTER AMOUNT", nil);
                    self.tf_scheduleAmount.textColor = [UIColor darkGrayColor];
                    self.tf_scheduleAmount.backgroundColor = [UIColor clearColor];
                    self.tf_scheduleAmount.textAlignment = UITextAlignmentRight;
                    self.tf_scheduleAmount.delegate = self;
                    [self.tf_scheduleAmount setEnabled:YES];
                    
                    self.tf_scheduleAmount.inputView = self.pv_scheduleAmount;
                    
                    cell.accessoryView = self.tf_scheduleAmount;
                }
            }
            
            if (self.scheduleAmount != nil) {
                if ([self.scheduleAmount intValue] == 1) {
                    self.tf_scheduleAmount.text = [NSString stringWithFormat:@"%d %@", 1, NSLocalizedString(@"DOSE", nil)];
                }
                else {
                    self.tf_scheduleAmount.text = [NSString stringWithFormat:@"%d %@", [self.scheduleAmount intValue], NSLocalizedString(@"DOSES", nil)];
                }
            }
            else {
                self.tf_scheduleAmount.text = nil;
            }
            
            // disable the cell until the "Edit" button is pressed
            if (self.isEditing == YES) {
                [cell setUserInteractionEnabled:YES];
                [self.tf_scheduleAmount setClearButtonMode:UITextFieldViewModeAlways];
            }
            else {
                [cell setUserInteractionEnabled:NO];
                [self.tf_scheduleAmount setClearButtonMode:UITextFieldViewModeNever];
            }
        }
    }
    else if (indexPath.section == 4) {
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
                if (self.pv_scheduleStartDate == nil) {
                    UIDatePicker* pickerView = [[[UIDatePicker alloc] init] autorelease];
                    [pickerView sizeToFit];
                    pickerView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
                    [pickerView addTarget:self action:@selector(startDateChanged:) forControlEvents:UIControlEventValueChanged];
                    pickerView.datePickerMode = UIDatePickerModeDateAndTime;        
                    pickerView.minimumDate = [NSDate date];
                    
                    self.pv_scheduleStartDate = pickerView;
                    
//                    self.tf_scheduleStartDate = [[UITextField alloc] initWithFrame:CGRectMake(80, 0, 200, 21)];
                    self.tf_scheduleStartDate = [[UITextField alloc] initWithFrame:CGRectMake(100, 0, 180, 21)];
                    self.tf_scheduleStartDate.adjustsFontSizeToFitWidth = YES;
                    self.tf_scheduleStartDate.placeholder = NSLocalizedString(@"EX. TOMORROW 8:00 AM", nil);
                    self.tf_scheduleStartDate.textColor = [UIColor darkGrayColor];
                    self.tf_scheduleStartDate.backgroundColor = [UIColor clearColor];
                    self.tf_scheduleStartDate.textAlignment = UITextAlignmentRight;
                    self.tf_scheduleStartDate.delegate = self;
                    [self.tf_scheduleStartDate setEnabled:YES];
                    
                    self.tf_scheduleStartDate.inputView = self.pv_scheduleStartDate;
                    
                    cell.accessoryView = self.tf_scheduleStartDate;
                }
            }
            
            if (self.scheduleStartDate != nil) {
                NSDate *startDate = [DateTimeHelper parseWebServiceDateDouble:self.scheduleStartDate];
                self.tf_scheduleStartDate.text = [self.dateAndTimeFormatter stringFromDate:startDate];
            }
            else {
//                NSDate *startDate = [NSDate date];
//                self.tf_scheduleStartDate.text = [self.dateAndTimeFormatter stringFromDate:startDate];
//                
//                double doubleDate = [startDate timeIntervalSince1970];
//                self.scheduleStartDate = [NSNumber numberWithDouble:doubleDate];
                
                self.tf_scheduleStartDate.text = nil;
            }
            
            // disable the cell until the "Edit" button is pressed
            if (self.isEditing == YES) {
                [cell setUserInteractionEnabled:YES];
                [self.tf_scheduleStartDate setClearButtonMode:UITextFieldViewModeAlways];
            }
            else {
                [cell setUserInteractionEnabled:NO];
                [self.tf_scheduleStartDate setClearButtonMode:UITextFieldViewModeNever];
            }
        }
        else if (indexPath.row == 1) {
            // Schedule repeat row
            
            CellIdentifier = @"ScheduleRepeat";
            cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            
            if (cell == nil) {
                cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
                
                [cell setSelectionStyle:UITableViewCellEditingStyleNone];
                
                cell.textLabel.text = NSLocalizedString(@"REPEATS", nil);
                
                // Initialize the schedule repeat picker view
                if (self.pv_scheduleRepeat == nil) {
                    UIPickerView* pickerView = [[[UIPickerView alloc] init] autorelease];
                    [pickerView sizeToFit];
                    pickerView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
                    pickerView.dataSource = self;
                    pickerView.delegate = self;
                    pickerView.showsSelectionIndicator = YES;
                    
                    self.pv_scheduleRepeat = pickerView;
                    
//                    self.tf_scheduleRepeat = [[UITextField alloc] initWithFrame:CGRectMake(80, 0, 200, 21)];
                    self.tf_scheduleRepeat = [[UITextField alloc] initWithFrame:CGRectMake(100, 0, 180, 21)];
                    self.tf_scheduleRepeat.adjustsFontSizeToFitWidth = YES;
                    self.tf_scheduleRepeat.placeholder = NSLocalizedString(@"ENTER REPEATS", nil);
                    self.tf_scheduleRepeat.textColor = [UIColor darkGrayColor];
                    self.tf_scheduleRepeat.backgroundColor = [UIColor clearColor];
                    self.tf_scheduleRepeat.textAlignment = UITextAlignmentRight;
                    self.tf_scheduleRepeat.delegate = self;
                    [self.tf_scheduleRepeat setEnabled:YES];
                    
                    self.tf_scheduleRepeat.inputView = self.pv_scheduleRepeat;
                    
                    cell.accessoryView = self.tf_scheduleRepeat;
                }
            }
            
            if (self.scheduleRepeatNumber != nil && self.scheduleRepeatPeriod != nil) {
                if ([self.scheduleRepeatNumber intValue] == 0) {
                    self.tf_scheduleRepeat.text = NSLocalizedString(@"DOES NOT REPEAT", nil);
                }
                else if ([self.scheduleRepeatNumber intValue] == 1) {
                    self.tf_scheduleRepeat.text = [NSString stringWithFormat:@"%@ %@",
                                                   NSLocalizedString(@"EVERY", nil),
                                                   [self.schedulePeriodSingularArray objectAtIndex:[self.scheduleRepeatPeriod intValue]]];
                }
                else {
                    self.tf_scheduleRepeat.text = [NSString stringWithFormat:@"%@ %d %@",
                                                   NSLocalizedString(@"EVERY", nil),
                                                   [self.scheduleRepeatNumber intValue],
                                                   [self.schedulePeriodPluralArray objectAtIndex:[self.scheduleRepeatPeriod intValue]]];
                }
            }
            else {
                self.tf_scheduleRepeat.text = nil;
            }
            
            
            // disable the cell until the "Edit" button is pressed
            if (self.isEditing == YES) {
                [cell setUserInteractionEnabled:YES];
                [self.tf_scheduleRepeat setClearButtonMode:UITextFieldViewModeAlways];
                }
            else {
                [cell setUserInteractionEnabled:NO];
                [self.tf_scheduleRepeat setClearButtonMode:UITextFieldViewModeNever];
            }
        }
        else if (indexPath.row == 2) {
            if ([self.scheduleRepeatPeriod intValue] != kHOUR) {
                // Schedule Occurences row
                
                CellIdentifier = @"ScheduleOccurences";
                cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
                
                if (cell == nil) {
                    cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
                    
                    [cell setSelectionStyle:UITableViewCellEditingStyleNone];
                    
                    cell.textLabel.text = NSLocalizedString(@"OCCURS", nil);
                    
                    // Initialize the schedule repeat picker view
                    if (self.pv_scheduleOccurences == nil) {
                        UIPickerView* pickerView = [[[UIPickerView alloc] init] autorelease];
                        [pickerView sizeToFit];
                        pickerView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
                        pickerView.dataSource = self;
                        pickerView.delegate = self;
                        pickerView.showsSelectionIndicator = YES;
                        
                        self.pv_scheduleOccurences = pickerView;
                        
//                        self.tf_scheduleOccurences = [[UITextField alloc] initWithFrame:CGRectMake(80, 0, 200, 21)];
                        self.tf_scheduleOccurences = [[UITextField alloc] initWithFrame:CGRectMake(100, 0, 180, 21)];
                        self.tf_scheduleOccurences.adjustsFontSizeToFitWidth = YES;
                        self.tf_scheduleOccurences.placeholder = NSLocalizedString(@"ENTER OCCURS", nil);
                        self.tf_scheduleOccurences.textColor = [UIColor darkGrayColor];
                        self.tf_scheduleOccurences.backgroundColor = [UIColor clearColor];
                        self.tf_scheduleOccurences.textAlignment = UITextAlignmentRight;
                        self.tf_scheduleOccurences.delegate = self;
                        [self.tf_scheduleOccurences setEnabled:YES];
                        
                        self.tf_scheduleOccurences.inputView = self.pv_scheduleOccurences;
                        
                        cell.accessoryView = self.tf_scheduleOccurences;
                    }
                }
                
                if (self.scheduleOccurenceNumber != nil) {
                    if ([self.scheduleAmount intValue] == 1) {
                        self.tf_scheduleOccurences.text = [NSString stringWithFormat:@"%d %@", 1, NSLocalizedString(@"TIME THAT DAY", nil)];
                    }
                    else {
                        self.tf_scheduleOccurences.text = [NSString stringWithFormat:@"%d %@", [self.scheduleOccurenceNumber intValue], NSLocalizedString(@"TIMES THAT DAY", nil)];
                    }
                }
                else {
                    self.tf_scheduleOccurences.text = nil;
                }
                
                // disable the cell until the "Edit" button is pressed
                if (self.isEditing == YES) {
                    [cell setUserInteractionEnabled:YES];
                    [self.tf_scheduleOccurences setClearButtonMode:UITextFieldViewModeAlways];
                }
                else {
                    [cell setUserInteractionEnabled:NO];
                    [self.tf_scheduleOccurences setClearButtonMode:UITextFieldViewModeNever];
                }
            }
            else {
                // Schedule End Date row
                
                CellIdentifier = @"ScheduleEndDate";
                cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
                
                if (cell == nil) {
                    cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
                    
                    [cell setSelectionStyle:UITableViewCellEditingStyleNone];
                    
                    cell.textLabel.text = NSLocalizedString(@"ENDS", nil);
                    
                    // Initialize the end date picker view
                    if (self.pv_scheduleEndDate == nil) {
                        UIDatePicker* pickerView = [[[UIDatePicker alloc] init] autorelease];
                        [pickerView sizeToFit];
                        pickerView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
                        [pickerView addTarget:self action:@selector(endDateChanged:) forControlEvents:UIControlEventValueChanged];
                        pickerView.datePickerMode = UIDatePickerModeDate;
                        pickerView.minimumDate = [NSDate date];
                        
                        self.pv_scheduleEndDate = pickerView;
                        
//                        self.tf_scheduleEndDate = [[UITextField alloc] initWithFrame:CGRectMake(80, 0, 200, 21)];
                        self.tf_scheduleEndDate = [[UITextField alloc] initWithFrame:CGRectMake(100, 0, 180, 21)];
                        self.tf_scheduleEndDate.adjustsFontSizeToFitWidth = YES;
                        self.tf_scheduleEndDate.placeholder = NSLocalizedString(@"ENTER ENDS", nil);
                        self.tf_scheduleEndDate.textColor = [UIColor darkGrayColor];
                        self.tf_scheduleEndDate.backgroundColor = [UIColor clearColor];
                        self.tf_scheduleEndDate.textAlignment = UITextAlignmentRight;
                        self.tf_scheduleEndDate.delegate = self;
                        [self.tf_scheduleEndDate setEnabled:YES];
                        
                        self.tf_scheduleEndDate.inputView = self.pv_scheduleEndDate;
                        
                        cell.accessoryView = self.tf_scheduleEndDate;
                    }
                }
                
                if (self.scheduleEndDate != nil) {
                    NSDate *endDate = [DateTimeHelper parseWebServiceDateDouble:self.scheduleEndDate];
                    self.tf_scheduleEndDate.text = [self.dateOnlyFormatter stringFromDate:endDate];
                }
                else {
                    self.tf_scheduleEndDate.text = nil;
                }
                
                // disable the cell until the "Edit" button is pressed
                if (self.isEditing == YES) {
                    [cell setUserInteractionEnabled:YES];
                    [self.tf_scheduleEndDate setClearButtonMode:UITextFieldViewModeAlways];
                }
                else {
                    [cell setUserInteractionEnabled:NO];
                    [self.tf_scheduleEndDate setClearButtonMode:UITextFieldViewModeNever];
                }
            }
        }
        else if (indexPath.row == 3) {
            // Schedule End Date row
            
            CellIdentifier = @"ScheduleEndDate";
            cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            
            if (cell == nil) {
                cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
                
                [cell setSelectionStyle:UITableViewCellEditingStyleNone];
                
                cell.textLabel.text = NSLocalizedString(@"ENDS", nil);
                
                // Initialize the end date picker view
                if (self.pv_scheduleEndDate == nil) {
                    UIDatePicker* pickerView = [[[UIDatePicker alloc] init] autorelease];
                    [pickerView sizeToFit];
                    pickerView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
                    [pickerView addTarget:self action:@selector(endDateChanged:) forControlEvents:UIControlEventValueChanged];
                    pickerView.datePickerMode = UIDatePickerModeDate;
                    
                    self.pv_scheduleEndDate = pickerView;
                    
//                    self.tf_scheduleEndDate = [[UITextField alloc] initWithFrame:CGRectMake(80, 0, 200, 21)];
                    self.tf_scheduleEndDate = [[UITextField alloc] initWithFrame:CGRectMake(100, 0, 180, 21)];
                    self.tf_scheduleEndDate.adjustsFontSizeToFitWidth = YES;
                    self.tf_scheduleEndDate.placeholder = NSLocalizedString(@"ENTER ENDS", nil);
                    self.tf_scheduleEndDate.textColor = [UIColor darkGrayColor];
                    self.tf_scheduleEndDate.backgroundColor = [UIColor clearColor];
                    self.tf_scheduleEndDate.textAlignment = UITextAlignmentRight;
                    self.tf_scheduleEndDate.delegate = self;
                    [self.tf_scheduleEndDate setEnabled:YES];
                    
                    self.tf_scheduleEndDate.inputView = self.pv_scheduleEndDate;
                    
                    cell.accessoryView = self.tf_scheduleEndDate;
                }
            }
            
            if (self.scheduleEndDate != nil) {
                NSDate *endDate = [DateTimeHelper parseWebServiceDateDouble:self.scheduleEndDate];
                self.tf_scheduleEndDate.text = [self.dateOnlyFormatter stringFromDate:endDate];
            }
            else {
                self.tf_scheduleEndDate.text = nil;
            }
            
            // disable the cell until the "Edit" button is pressed
            if (self.isEditing == YES) {
                [cell setUserInteractionEnabled:YES];
                [self.tf_scheduleEndDate setClearButtonMode:UITextFieldViewModeAlways];
            }
            else {
                [cell setUserInteractionEnabled:NO];
                [self.tf_scheduleEndDate setClearButtonMode:UITextFieldViewModeNever];
            }
        }
    }
    else if (indexPath.section == 5) {
        // Reason and Notes section
        
        CellIdentifier = @"ReasonAndNotes";
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
    if (indexPath.section == 5) {
        return 115.0f;
    }
    else if (indexPath.section == 3 ||
             indexPath.section == 4)
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
        // Doctor Name selected
        
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        
        // Set the doctor name text field as active
        [self.tf_doctorName becomeFirstResponder];
        
    }
    else if (indexPath.section == 2) {
        // Method selected
        
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        
        // Set the birthday text field as active
        [self.tf_method becomeFirstResponder];
        
    }
    else if (indexPath.section == 3) {
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
        else if (indexPath.row == 2) {
            // Amount row
            
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
            
            // Set the dosage amount text field as active
            [self.tf_scheduleAmount becomeFirstResponder];
        }
    }
    else if (indexPath.section == 4) {
        // Schedule section
        
        if (indexPath.row == 0) {
            // Start Date row
            
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
            
            // Set the dosage amount text field as active
            [self.tf_scheduleStartDate becomeFirstResponder];
            
        }
        else if (indexPath.row == 1) {
            // Repeats row
            
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
            
            // Set the dosage amount text field as active
            [self.tf_scheduleRepeat becomeFirstResponder];
        }
        else if (indexPath.row == 2) {
            if ([self.scheduleRepeatPeriod intValue] != kHOUR) {
                // Occurances row
                
                [tableView deselectRowAtIndexPath:indexPath animated:YES];
                
                // Set the dosage amount text field as active
                [self.tf_scheduleOccurences becomeFirstResponder];
            }
            else{
                // End Date row
                
                [tableView deselectRowAtIndexPath:indexPath animated:YES];
                
                // Set the dosage amount text field as active
                [self.tf_scheduleEndDate becomeFirstResponder];
            }
            
        }
        else if (indexPath.row == 4) {
            // End Date row
            
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
            
            // Set the dosage amount text field as active
            [self.tf_scheduleEndDate becomeFirstResponder];
        }
    }
    else if (indexPath.section == 5) {
        // Reason selected
        
        [self.tv_reason becomeFirstResponder];
        
    }
}

#pragma mark - UIPickerView Methods
#pragma mark UIDatePickerView Methods
- (void)startDateChanged:(id)sender
{
    self.tf_scheduleStartDate.text = [self.dateAndTimeFormatter stringFromDate:self.pv_scheduleStartDate.date];
    
    NSDate* startDate = self.pv_scheduleStartDate.date;
    double doubleDate = [startDate timeIntervalSince1970];
    self.scheduleStartDate = [NSNumber numberWithDouble:doubleDate];
    
    // We need to reset the occurances everytime this value changes
    self.tf_scheduleOccurences.text = nil;
    self.scheduleOccurenceNumber = nil;
    [self.pv_scheduleOccurences reloadComponent:0];
}

- (void)endDateChanged:(id)sender
{
    self.tf_scheduleEndDate.text = [self.dateOnlyFormatter stringFromDate:self.pv_scheduleEndDate.date];
    
    self.scheduleEndDate = [self processEndDateWithDate:self.pv_scheduleEndDate.date];
}

#pragma mark UIPickerView Data Source
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    if (pickerView == self.pv_scheduleRepeat) {
        return 2;
    }
    else {
        return 1;
    }
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    if (pickerView == self.pv_method) {
        return [self.methodArray count];
    }
    else if (pickerView == self.pv_dosageUnit) {
        return [self.dosageUnitArray count];
    }
    else if (pickerView == self.pv_scheduleAmount) {
        return 30;
    }
    else if (pickerView == self.pv_scheduleRepeat) {
        if (component == 0) {
            int selectedRow = [pickerView selectedRowInComponent:1];
            switch (selectedRow)
            {
                case kHOUR:
                    return 24;
                case kDAY:
                    return 31;
                case kWEEK:
                    return 52;
                case kMONTH:
                    return 12;
                case kYEAR:
                    return 25;
                default:
                    return 24;  // default is hourly
            }
        }
        else {
            return [self.schedulePeriodPluralArray count];
        }
    }
    else if (pickerView == self.pv_scheduleOccurences) {
        NSDate *startDate = [DateTimeHelper parseWebServiceDateDouble:self.scheduleStartDate];
        NSCalendar *calendar = [NSCalendar currentCalendar];
        NSDateComponents *components = [calendar components:(NSHourCalendarUnit) fromDate:startDate];
        NSInteger hours = [components hour];
        
        if ([self.scheduleRepeatPeriod intValue] == kHOUR) {
            int repeats = [self.scheduleRepeatNumber intValue];
            
            return (((24 - hours) + repeats - 1) / repeats) + 1;    // always round up (A+B-1)/B, +1 for blank row
        }
        else {
            return (24 - hours) + 1;    // always round down, +1 for blank row
        }
    }
    else {
        return 0;
    }
}

#pragma mark UIPickerView Delegate
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    NSString *title;
    
    if (pickerView == self.pv_method) {
        title = [self.methodArray objectAtIndex:row];
    }
    else if (pickerView == self.pv_dosageUnit) {
        title = [self.dosageUnitArray objectAtIndex:row];
    }
    else if (pickerView == self.pv_scheduleAmount) {
        if (row == 0) {
            title = [NSString stringWithFormat:@"%d %@", 1, NSLocalizedString(@"DOSE", nil)];
        }
        else {
            title = [NSString stringWithFormat:@"%d %@", row + 1, NSLocalizedString(@"DOSES", nil)];
        }
    }
    else if (pickerView == self.pv_scheduleRepeat) {
        switch (component) {
            case 0:
                if (row == 0) {
                    title = [NSString stringWithFormat:@"%@", NSLocalizedString(@"EVERY", nil)];
                }
                else {
                    title = [NSString stringWithFormat:@"%@ %d", NSLocalizedString(@"EVERY", nil), row + 1];
                }
                break;
            case 1:
                if ([pickerView selectedRowInComponent:0] == 0) {
                    title = [self.schedulePeriodSingularArray objectAtIndex:row];
                }
                else {
                    title = [self.schedulePeriodPluralArray objectAtIndex:row];
                }
                break;
            default:
                break;
        }
    }
    else if (pickerView == self.pv_scheduleOccurences) {
        if (row == 0) {
            title = nil;
        }
        else if (row == 1) {
            title = [NSString stringWithFormat:@"%d %@", 1, NSLocalizedString(@"TIME THAT DAY", nil)];
        }
        else {
            title = [NSString stringWithFormat:@"%d %@", row, NSLocalizedString(@"TIMES THAT DAY", nil)];
        }
    }
    else {
        title = nil;
    }
    
    return title;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    if (pickerView == self.pv_method) {
        self.tf_method.text = [self.methodArray objectAtIndex:row];
        
        self.method = [NSNumber numberWithInt:row];
    }
    else if (pickerView == self.pv_dosageUnit) {
        self.tf_dosageUnit.text = [self.dosageUnitArray objectAtIndex:row];
        
        self.dosageUnit = [self.dosageUnitArray objectAtIndex:row];
    }
    else if (pickerView == self.pv_scheduleAmount) {
        if (row == 0) {
            self.tf_scheduleAmount.text = [NSString stringWithFormat:@"%d %@", 1, NSLocalizedString(@"DOSE", nil)];
        }
        else {
            self.tf_scheduleAmount.text = [NSString stringWithFormat:@"%d %@", row + 1, NSLocalizedString(@"DOSES", nil)];
        }
        
        self.scheduleAmount = [NSNumber numberWithInt:(row + 1)];
    }
    else if (pickerView == self.pv_scheduleRepeat) {
        switch (component) {
            case 1:
                self.scheduleRepeatPeriod = [NSNumber numberWithInt:row];
                [pickerView reloadComponent:0];
                break;
            case 0:
                self.scheduleRepeatNumber = [NSNumber numberWithInt:(row + 1)];
                [pickerView reloadComponent:1];
                break;
            default:
                break;
        }
        
        if ([pickerView selectedRowInComponent:0] == 0) {
            self.tf_scheduleRepeat.text = [NSString stringWithFormat:@"%@ %@",
                                           NSLocalizedString(@"EVERY", nil),
                                           [self.schedulePeriodSingularArray objectAtIndex:[pickerView selectedRowInComponent:1]]];
        }
        else {
            self.tf_scheduleRepeat.text = [NSString stringWithFormat:@"%@ %d %@",
                                           NSLocalizedString(@"EVERY", nil),
                                           [pickerView selectedRowInComponent:0] + 1,
                                           [self.schedulePeriodPluralArray objectAtIndex:[pickerView selectedRowInComponent:1]]];
        }
        
        // We need to reset the occurances everytime this value changes
        self.tf_scheduleOccurences.text = nil;
        self.scheduleOccurenceNumber = nil;
        [self.pv_scheduleOccurences reloadComponent:0];
    }
    else if (pickerView == self.pv_scheduleOccurences) {
        if (row == 0) {
            self.tf_scheduleOccurences.text = nil;
            self.scheduleOccurenceNumber = nil;
        }
        else if (row == 1) {
            self.tf_scheduleOccurences.text = [NSString stringWithFormat:@"%d %@", 1, NSLocalizedString(@"TIME THAT DAY", nil)];
            self.scheduleOccurenceNumber = [NSNumber numberWithInt:row];
        }
        else {
            self.tf_scheduleOccurences.text = [NSString stringWithFormat:@"%d %@", row, NSLocalizedString(@"TIMES THAT DAY", nil)];
            self.scheduleOccurenceNumber = [NSNumber numberWithInt:(row)];
        }
    }
}

#pragma mark - UITextview and TextField Delegate Methods
- (void)textViewDidBeginEditing:(UITextView *)textView
{
    // reason textview editing has begun
    self.tv_reason = textView;
    
    // Scroll tableview to this row
    if (self.scheduleOccurenceNumber == nil) {
        [self.tbl_prescriptionDetails setContentOffset:CGPointMake(0, 660) animated:YES];
    }
    else {
        [self.tbl_prescriptionDetails setContentOffset:CGPointMake(0, 700) animated:YES];
    }
    
    // Disable the table view scrolling
    [self.tbl_prescriptionDetails setScrollEnabled:NO];
    
    // Add the tap gesture recognizer to capture background touches which will dismiss the keyboard
    [self.tbl_prescriptionDetails addGestureRecognizer:self.gestureRecognizer];
    
    // Mark this row selected
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:5];
    [self.tbl_prescriptionDetails selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
    
//    // disable nav bar buttons until text entry complete
//    if (self.prescriptionID == nil) {
//        // New prescription
//        self.navigationItem.rightBarButtonItem.enabled = NO;
//        self.navigationItem.leftBarButtonItem.enabled = NO;
//    }
//    else {
//        // Editing existing prescription
//        self.navigationItem.rightBarButtonItem.enabled = NO;
//    }
    
    // Clear the default text of the caption textview upon startin to edit
    if ([self.tv_reason.text isEqualToString:NSLocalizedString(@"ENTER REASON", nil)]) {
        [self.tv_reason setText:@""];
        self.tv_reason.textColor = [UIColor blackColor];
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
    
    // Plug the keyboardDoneButtonView into the text view.
    textView.inputAccessoryView = keyboardDoneButtonView;
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    // reason textview editing has ended
    self.tv_reason = textView;
    
//    // Scroll tableview to this row
//    [self.tbl_prescriptionDetails setContentOffset:CGPointMake(0, 85) animated:YES];
    
    // Deselect this row
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:5];
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
    
    // Re-enable the table view scrolling
    [self.tbl_prescriptionDetails setScrollEnabled:YES];
    
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
    else if (textField == self.tf_doctorName) {
        // Disable the table view scrolling
        [self.tbl_prescriptionDetails setScrollEnabled:NO];
        
        // Add the tap gesture recognizer to capture background touches which will dismiss the keyboard
        [self.tbl_prescriptionDetails addGestureRecognizer:self.gestureRecognizer];
        
        // Scroll tableview to this row
        [self.tbl_prescriptionDetails setContentOffset:CGPointMake(0, 40) animated:YES];
        
    }
    else if (textField == self.tf_method) {
        
        [self showDisabledBackgroundView];
        
        // Add the tap gesture recognizer to capture background touches which will dismiss the keyboard
        [self.v_disabledBackground addGestureRecognizer:self.gestureRecognizer];
        
        // Scroll tableview to this row
        [self.tbl_prescriptionDetails setContentOffset:CGPointMake(0, 140) animated:YES];
        
        if ([self.tf_method.text isEqualToString:@""] == NO &&
            [self.tf_method.text isEqualToString:@" "] == NO)
        {
            int row = [self.method intValue];
            [self.pv_method selectRow:row inComponent:0 animated:YES];
            
            self.method = [NSNumber numberWithInt:row];
        }
        else {
            self.tf_method.text = [self.methodArray objectAtIndex:0];
            
            self.method = [NSNumber numberWithInt:0];
        }
        
    }
    else if (textField == self.tf_dosageAmount) {
        // Disable the table view scrolling
        [self.tbl_prescriptionDetails setScrollEnabled:NO];
        
        // Add the tap gesture recognizer to capture background touches which will dismiss the keyboard
        [self.tbl_prescriptionDetails addGestureRecognizer:self.gestureRecognizer];
        
        [self.tbl_prescriptionDetails setContentOffset:CGPointMake(0, 230) animated:YES];
        
    }
    else if (textField == self.tf_dosageUnit) {
        
        [self showDisabledBackgroundView];
        
        // Add the tap gesture recognizer to capture background touches which will dismiss the keyboard
        [self.v_disabledBackground addGestureRecognizer:self.gestureRecognizer];
        
        // Scroll tableview to this row
        [self.tbl_prescriptionDetails setContentOffset:CGPointMake(0, 280) animated:YES];
        
        if ([self.tf_dosageUnit.text isEqualToString:@""] == NO &&
            [self.tf_dosageUnit.text isEqualToString:@" "] == NO)
        {
            int row = [self.dosageUnitArray indexOfObject:self.tf_dosageUnit.text];
            [self.pv_dosageUnit selectRow:row inComponent:0 animated:YES];
            
            self.dosageUnit = [self.dosageUnitArray objectAtIndex:row];
        }
        else {
            self.tf_dosageUnit.text = [self.dosageUnitArray objectAtIndex:0];
            
            self.dosageUnit = [self.dosageUnitArray objectAtIndex:0];
        }
        
    }
    else if (textField == self.tf_scheduleAmount) {
        
        [self showDisabledBackgroundView];
        
        // Add the tap gesture recognizer to capture background touches which will dismiss the keyboard
        [self.v_disabledBackground addGestureRecognizer:self.gestureRecognizer];
        
        // Scroll tableview to this row
        [self.tbl_prescriptionDetails setContentOffset:CGPointMake(0, 330) animated:YES];
        
        if ([self.tf_scheduleAmount.text isEqualToString:@""] == NO &&
            [self.tf_scheduleAmount.text isEqualToString:@" "] == NO)
        {
            int row = [self.scheduleAmount intValue] - 1;
            [self.pv_scheduleAmount selectRow:row inComponent:0 animated:YES];
        }
        else {
            self.tf_scheduleAmount.text = [NSString stringWithFormat:@"%d %@", 1, NSLocalizedString(@"DOSE", nil)];
            
            self.scheduleAmount = [NSNumber numberWithInt:1];
        }
        
    }
    else if (textField == self.tf_scheduleStartDate) {
        
        [self showDisabledBackgroundView];
        
        // Add the tap gesture recognizer to capture background touches which will dismiss the keyboard
        [self.v_disabledBackground addGestureRecognizer:self.gestureRecognizer];
        
        // Scroll tableview to this row
        [self.tbl_prescriptionDetails setContentOffset:CGPointMake(0, 425) animated:YES];
        
        if ([self.dateAndTimeFormatter dateFromString:self.tf_scheduleStartDate.text]) {
            self.pv_scheduleStartDate.date = [self.dateAndTimeFormatter dateFromString:self.tf_scheduleStartDate.text];
            
            NSDate* startDate = [self.dateAndTimeFormatter dateFromString:self.tf_scheduleStartDate.text];
            double doubleDate = [startDate timeIntervalSince1970];
            self.scheduleStartDate = [NSNumber numberWithDouble:doubleDate];
        }
        else {
            NSCalendar *calendar = [NSCalendar currentCalendar];
            NSDateComponents* components = [[[NSDateComponents alloc] init] autorelease];
            components.year = [[calendar components:NSYearCalendarUnit fromDate:[NSDate date]] year];
            components.month = [[calendar components:NSMonthCalendarUnit fromDate:[NSDate date]] month];
            components.day = [[calendar components:NSDayCalendarUnit fromDate:[NSDate date]] day] + 1; 
            components.hour = 8;
            components.minute = 0;
            components.second = 0;
            NSDate* defaultStartDate = [calendar dateFromComponents:components];
            self.pv_scheduleStartDate.date = defaultStartDate;
            
            self.tf_scheduleStartDate.text = [self.dateAndTimeFormatter stringFromDate:self.pv_scheduleStartDate.date];
            
            NSDate* startDate = self.pv_scheduleStartDate.date;
            double doubleDate = [startDate timeIntervalSince1970];
            self.scheduleStartDate = [NSNumber numberWithDouble:doubleDate];
        }
        
    }
    else if (textField == self.tf_scheduleRepeat) {
        
        [self showDisabledBackgroundView];
        
        // Add the tap gesture recognizer to capture background touches which will dismiss the keyboard
        [self.v_disabledBackground addGestureRecognizer:self.gestureRecognizer];
        
        // Scroll tableview to this row
        [self.tbl_prescriptionDetails setContentOffset:CGPointMake(0, 470) animated:YES];
        
        if ([self.tf_scheduleRepeat.text isEqualToString:@""] == NO &&
            [self.tf_scheduleRepeat.text isEqualToString:@" "] == NO)
        {
            int repeatNumber = [self.scheduleRepeatNumber intValue];
            if (repeatNumber > 0) {
                [self.pv_scheduleRepeat selectRow:(repeatNumber - 1) inComponent:0 animated:YES];
            }
            else {
                [self.pv_scheduleRepeat selectRow:0 inComponent:0 animated:YES];
            }
            
            int repeatPeriod = [self.scheduleRepeatPeriod intValue];
            if (repeatPeriod >= 0) {
                [self.pv_scheduleRepeat selectRow:repeatPeriod inComponent:1 animated:YES];
            }
            else {
                [self.pv_scheduleRepeat selectRow:0 inComponent:1 animated:YES];
            }
        }
        else {
            self.tf_scheduleRepeat.text = [NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"EVERY", nil),
                                           [self.schedulePeriodSingularArray objectAtIndex:0]];
            
            self.scheduleRepeatNumber = [NSNumber numberWithInt:1];
            self.scheduleRepeatPeriod = [NSNumber numberWithInt:kHOUR];
        }
        
    }
    else if (textField == self.tf_scheduleOccurences) {
        
        [self showDisabledBackgroundView];
        
        // Add the tap gesture recognizer to capture background touches which will dismiss the keyboard
        [self.v_disabledBackground addGestureRecognizer:self.gestureRecognizer];
        
        // Scroll tableview to this row
        [self.tbl_prescriptionDetails setContentOffset:CGPointMake(0, 515) animated:YES];
        
        if ([self.tf_scheduleOccurences.text isEqualToString:@""] == NO &&
            [self.tf_scheduleOccurences.text isEqualToString:@" "] == NO)
        {
            int occurences = [self.scheduleOccurenceNumber intValue];
            [self.pv_scheduleOccurences selectRow:occurences inComponent:0 animated:YES];
        }
        else {
//            self.tf_scheduleOccurences.text = nil;
            
//            self.scheduleOccurenceNumber = [NSNumber numberWithInt:1];
        }
        
    }
    else if (textField == self.tf_scheduleEndDate) {
        
        [self showDisabledBackgroundView];
        
        // Add the tap gesture recognizer to capture background touches which will dismiss the keyboard
        [self.v_disabledBackground addGestureRecognizer:self.gestureRecognizer];
        
        // Scroll tableview to this row
        if (self.scheduleOccurenceNumber == nil) {
            [self.tbl_prescriptionDetails setContentOffset:CGPointMake(0, 515) animated:YES];
        }
        else {
            [self.tbl_prescriptionDetails setContentOffset:CGPointMake(0, 560) animated:YES];
        }
        
        if ([self.dateOnlyFormatter dateFromString:self.tf_scheduleEndDate.text]) {
            self.pv_scheduleEndDate.date = [self.dateOnlyFormatter dateFromString:self.tf_scheduleEndDate.text];
            
//            NSDate* endDate = [self.dateOnlyFormatter dateFromString:self.tf_scheduleEndDate.text];
//            double doubleDate = [endDate timeIntervalSince1970];
//            self.scheduleEndDate = [NSNumber numberWithDouble:doubleDate];
            
            self.scheduleEndDate = [self processEndDateWithDate:[self.dateOnlyFormatter dateFromString:self.tf_scheduleEndDate.text]];
        }
        else {
            self.tf_scheduleEndDate.text = [self.dateOnlyFormatter stringFromDate:self.pv_scheduleEndDate.date];
            
//            NSDate* endDate = self.pv_scheduleEndDate.date;
//            double doubleDate = [endDate timeIntervalSince1970];
//            self.scheduleEndDate = [NSNumber numberWithDouble:doubleDate];
            
            self.scheduleEndDate = [self processEndDateWithDate:self.pv_scheduleEndDate.date];
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
    
    if (textField == self.tf_scheduleEndDate) {
//        // Add a button for no end date
//        UIBarButtonItem* neverButton = [[[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"NO END DATE", nil)
//                                                                         style:UIBarButtonItemStyleBordered
//                                                                        target:self
//                                                                        action:@selector(onNoEndDateButtonPressed)] autorelease];
//        
//        [keyboardDoneButtonView setItems:[NSArray arrayWithObjects:neverButton, flexSpace, doneButton, nil]];
        
        [keyboardDoneButtonView setItems:[NSArray arrayWithObjects:flexSpace, doneButton, nil]];
    }
    else if (textField == self.tf_scheduleRepeat) {
        // Add a button for does not repeat
        UIBarButtonItem* noRepeatButton = [[[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"DOES NOT REPEAT", nil)
                                                                         style:UIBarButtonItemStyleBordered
                                                                        target:self
                                                                        action:@selector(onNoRepeatButtonPressed)] autorelease];
        
        [keyboardDoneButtonView setItems:[NSArray arrayWithObjects:noRepeatButton, flexSpace, doneButton, nil]];
    }
    else {
        [keyboardDoneButtonView setItems:[NSArray arrayWithObjects:flexSpace, doneButton, nil]];
    }
    
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
    else if (textField == self.tf_doctorName) {
        // Enable the table view scrolling
        [self.tbl_prescriptionDetails setScrollEnabled:YES];
        
        // remove the tap gesture recognizer so it does not interfere with other table view touches
        [self.tbl_prescriptionDetails removeGestureRecognizer:self.gestureRecognizer];
        
        if ([enteredText isEqualToString:@""] == YES ||
            [enteredText isEqualToString:@" "] == YES)
        {
            self.doctorName = nil;
        }
        else {
            self.doctorName = enteredText;
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
            self.method = [NSNumber numberWithInt:[self.methodArray indexOfObject:enteredText]];
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
            self.dosageAmount = [NSNumber numberWithDouble:[enteredText doubleValue]];
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
    else if (textField == self.tf_scheduleStartDate) {
        
        [self hideDisabledBackgroundView];
        
        NSDate* startDate;
        
        if ([self.dateAndTimeFormatter dateFromString:enteredText]) {
            self.pv_scheduleStartDate.date = [self.dateAndTimeFormatter dateFromString:enteredText];
            
            startDate = [self.dateAndTimeFormatter dateFromString:enteredText];
        }
        else {
            self.tf_scheduleStartDate.text = [self.dateAndTimeFormatter stringFromDate:self.pv_scheduleStartDate.date];
            
            startDate = self.pv_scheduleStartDate.date;
        }
        
        double doubleDate = [startDate timeIntervalSince1970];
        self.scheduleStartDate = [NSNumber numberWithDouble:doubleDate];
        
        // We need to rest the end date if it is earlier than the start date
        NSDate *endDate = [DateTimeHelper parseWebServiceDateDouble:self.scheduleEndDate];
        if ([endDate compare:startDate] == NSOrderedAscending || [endDate compare:startDate] == NSOrderedSame) {
            self.tf_scheduleEndDate.text = nil;
            self.scheduleEndDate = nil;
        }
        
        // Make sure the end date cannot be set to a date before the start date
        self.pv_scheduleEndDate.minimumDate = startDate;
    }
    else if (textField == self.tf_scheduleAmount) {
        
        [self hideDisabledBackgroundView];
        
        if ([enteredText isEqualToString:@""] == YES ||
            [enteredText isEqualToString:@" "] == YES)
        {
            self.scheduleAmount = nil;
        }
        else {
            int amount = [self.pv_scheduleAmount selectedRowInComponent:0] + 1;
            
            self.scheduleAmount = [NSNumber numberWithInt:amount];
        }
    }
    else if (textField == self.tf_scheduleRepeat) {
        
        [self hideDisabledBackgroundView];
        
        if ([enteredText isEqualToString:@""] == YES ||
            [enteredText isEqualToString:@" "] == YES)
        {
            self.scheduleRepeatNumber = nil;
            self.scheduleRepeatPeriod = nil;
        }
        else {
            int repeats = [self.pv_scheduleRepeat selectedRowInComponent:0] + 1;
            
            self.scheduleRepeatNumber = [NSNumber numberWithInt:repeats];
            
            int row = [self.pv_scheduleRepeat selectedRowInComponent:1];
            self.scheduleRepeatPeriod = [NSNumber numberWithInt:row];
        }
        
        if ([self.scheduleRepeatPeriod intValue] != kHOUR &&
            self.occurancesRowIsShown == NO)
        {
            // We need to add the occurances row
            [self.tbl_prescriptionDetails insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:2 inSection:4]] withRowAnimation:UITableViewRowAnimationAutomatic];
            self.occurancesRowIsShown = YES;
        }
        else if ([self.scheduleRepeatPeriod intValue] == kHOUR && 
                 self.occurancesRowIsShown == YES)
        {
            // We need to remove the occurances row
            [self.tbl_prescriptionDetails deleteRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:2 inSection:4]] withRowAnimation:UITableViewRowAnimationAutomatic];
            self.occurancesRowIsShown = NO;
            self.scheduleOccurenceNumber = nil;
        }
    }
    else if (textField == self.tf_scheduleOccurences) {
        
        [self hideDisabledBackgroundView];
        
        if ([enteredText isEqualToString:@""] == YES ||
            [enteredText isEqualToString:@" "] == YES)
        {
            self.scheduleOccurenceNumber = nil;
        }
        else {
            int occurences = [self.pv_scheduleOccurences selectedRowInComponent:0];
            
            self.scheduleOccurenceNumber = [NSNumber numberWithInt:occurences];
        }
    }
    else if (textField == self.tf_scheduleEndDate) {
        
        [self hideDisabledBackgroundView];
        
        if ([self.dateOnlyFormatter dateFromString:enteredText]) {
            self.pv_scheduleEndDate.date = [self.dateOnlyFormatter dateFromString:enteredText];
            
//            NSDate* endDate = [self.dateOnlyFormatter dateFromString:enteredText];
//            double doubleDate = [endDate timeIntervalSince1970];
//            self.scheduleEndDate = [NSNumber numberWithDouble:doubleDate];
            
            self.scheduleEndDate = [self processEndDateWithDate:[self.dateOnlyFormatter dateFromString:enteredText]];
        }
        else {
            self.tf_scheduleEndDate.text = [self.dateOnlyFormatter stringFromDate:self.pv_scheduleEndDate.date];
            
//            NSDate* endDate = self.pv_scheduleEndDate.date;
//            double doubleDate = [endDate timeIntervalSince1970];
//            self.scheduleEndDate = [NSNumber numberWithDouble:doubleDate];
            
            self.scheduleEndDate = [self processEndDateWithDate:self.pv_scheduleEndDate.date];
        }
    }
    
    // Re-enable nav bar buttons
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
    NSDate *pickerDate = [self.pv_scheduleStartDate date];
    
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

- (NSNumber *)processEndDateWithDate:(NSDate *)date {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents* components = [[[NSDateComponents alloc] init] autorelease];
    components.day = 1;
    components.second = -1; // sets the date to the last second on the desired end day
    NSDate* endDate = [calendar dateByAddingComponents:components toDate:date options:0];
    
    double doubleDate = [endDate timeIntervalSince1970];
    return [NSNumber numberWithDouble:doubleDate];
}

- (void)onNoEndDateButtonPressed {
    [self.tf_scheduleEndDate resignFirstResponder];
    
    self.tf_scheduleEndDate.text = NSLocalizedString(@"NO END DATE", nil);
    
    self.scheduleEndDate = nil;
}

- (void)onNoRepeatButtonPressed {
    [self.tf_scheduleRepeat resignFirstResponder];
    
    self.tf_scheduleRepeat.text = NSLocalizedString(@"DOES NOT REPEAT", nil);
    
    self.scheduleRepeatNumber = [NSNumber numberWithInt:0];
    self.scheduleRepeatPeriod = [NSNumber numberWithInt:0];
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

- (void)doneEditingPrescription:(id)sender 
{
    NSString* activityName = @"PrescriptionDetailsViewController.doneEditingPrescription:";
    
    // Exit any text fields or text views being edited
    [self hideInputView];
    
    if (self.medicationName == nil ||
        self.method == nil ||
        self.dosageAmount == nil ||
        self.dosageUnit == nil ||
        self.scheduleStartDate == nil ||
        self.scheduleAmount == nil ||
        self.scheduleRepeatNumber == nil ||
        self.scheduleRepeatPeriod == nil ||
        self.scheduleEndDate == nil ||
        [self.medicationName isEqualToString:@""] ||
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
        self.tbl_prescriptionDetails.tableFooterView = nil;
        
        //we need to save the changes to the prescription object to the local database 
        NSString* newMedicationName = self.medicationName;
        NSString* newDoctorName = self.doctorName;
        NSNumber* newMethod = self.method;
        NSNumber* newStrength = self.dosageAmount;
        NSString* newUnit = self.dosageUnit;
        NSNumber* newScheduledStartDate = self.scheduleStartDate;
        NSNumber* newScheduledAmount = self.scheduleAmount;
        NSNumber* newScheduledRepeatNumber = self.scheduleRepeatNumber;
        NSNumber* newRepeatPeriod = self.scheduleRepeatPeriod;
        NSNumber* newOccurenceMultiple = self.scheduleOccurenceNumber;
        NSNumber* newScheduledEndDate = self.scheduleEndDate;
        NSString* newNotes = self.reason;
        
        ResourceContext* resourceContext = [ResourceContext instance];
        Prescription* prescription = (Prescription*)[resourceContext resourceWithType:PRESCRIPTION withID:self.prescriptionID];
        
        BOOL shouldRecreatePrescriptionInstances = NO;
        
        //now we have the current prescription object we then need to compare new and old
        //values and change them accordingly
        if (newMedicationName != nil &&
            ![newMedicationName isEqualToString:prescription.name])
        {
            //the medication name changed
            prescription.name = newMedicationName;
        }
        
        if (newDoctorName != nil &&
            ![newDoctorName isEqualToString:prescription.doctor])
        {
            //the doctor name changed
            prescription.doctor = newDoctorName;
        }
        
        if (newMethod != nil &&
            ![newMethod isEqualToNumber:prescription.methodconstant])
        {
            //the method has changed
            prescription.methodconstant = newMethod;
        }
        
        if (newStrength != nil &&
            ![newStrength isEqualToNumber:prescription.strength])
        {
            prescription.strength = newStrength;
        }
        
        if (newUnit != nil &&
            ![newUnit isEqualToString:prescription.unit])
        {
            prescription.unit = newUnit;
        }
        
        if (newScheduledStartDate != nil &&
            ![newScheduledStartDate isEqualToNumber:prescription.datestart])
        {
            prescription.datestart = newScheduledStartDate;
            shouldRecreatePrescriptionInstances = YES;
        }
        
        if (newScheduledAmount != nil &&
            ![newScheduledAmount isEqualToNumber:prescription.numberofdoses])
        {
            prescription.numberofdoses = newScheduledAmount;
        }
        
        if ( newScheduledRepeatNumber != nil
            && ![newScheduledRepeatNumber isEqualToNumber:prescription.repeatmultiple])
        {
            prescription.repeatmultiple = newScheduledRepeatNumber;
            shouldRecreatePrescriptionInstances = YES;
        }
        
        if (newRepeatPeriod != nil &&
            ![newRepeatPeriod isEqualToNumber:prescription.repeatperiod])
        {
            prescription.repeatperiod = newRepeatPeriod;
            shouldRecreatePrescriptionInstances = YES;
            
        }
        
        if (newOccurenceMultiple != nil &&
            ![newOccurenceMultiple isEqualToNumber:prescription.occurmultiple])
        {
            prescription.occurmultiple = newOccurenceMultiple;
            shouldRecreatePrescriptionInstances = YES;
        }
        
        if (newScheduledEndDate != nil &&
            ![newScheduledEndDate isEqualToNumber:prescription.dateend])
        {
            prescription.dateend = newScheduledEndDate;
            shouldRecreatePrescriptionInstances = YES;
        }
        
        if (newNotes != nil &&
            ![newNotes isEqualToString:prescription.notes])
        {
            prescription.notes = newNotes;
        }
        
        if (shouldRecreatePrescriptionInstances)
        {
            //if we fall into here, we need to delete all outstanding, unconfirmed prescription instance objects
            PrescriptionInstanceManager* pim = [PrescriptionInstanceManager instance];
            
            //delete them
            [pim deleteUnconfirmedPrescriptionInstanceObjectsFor:prescription shouldSave:NO];
            
            //and then recreate a new set of prescription instance objects
            NSArray* prescriptionInstances = [PrescriptionInstance createPrescriptionInstancesFor:prescription];
//            LOG_PRESCRIPTIONDETAILVIEWCONTROLLER(0,@"%@Created %d new PrescriptionInstance objects for Prescription:%@ (%@)",activityName, [prescriptionInstances count], prescription.objectid,prescription.name);
        }
        
        //we save the changes to the database
        [resourceContext save:NO onFinishCallback:nil trackProgressWith:nil];
//        LOG_PRESCRIPTIONDETAILVIEWCONTROLLER(0,@"%@Committed all changes to Prescription: %@ (@%) to the local store",activityName,prescription.objectid,prescription.name);
        
        //now we need to call the notification manager to reschedule all the new notifications
        LocalNotificationManager* lim = [LocalNotificationManager instance];
        [lim scheduleNotifications];
        
//        LOG_PRESCRIPTIONDETAILVIEWCONTROLLER(0,@"%@Rescheduled new local notifications due to changes made to Prescription: %@ (%@)",activityName,prescription.objectid,prescription.name);
        
        // Reload the table view to disable user interaction and accessory views on the tableview cells
        [self.tbl_prescriptionDetails reloadData];
    }
}

- (void)deletePrescription {
    // Delete the prescription object
    [Prescription deletePrescriptionWithID:self.prescriptionID];
    
    self.prescriptionID = nil;
    self.medicationName = nil;
    self.doctorName = nil;
    self.method = nil;
    self.dosageAmount = nil;
    self.dosageUnit = nil;
    self.reason = nil;
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)onEditPrescriptionButtonPressed:(id)sender 
{
    NSString* activityName = @"CLifePrescriptionDetailsViewController.onEditPrescriptionButtonPressed:";
    
    // Promt user to backup data before editing profile information
    self.av_edit = [[UIAlertView alloc]
                          initWithTitle:NSLocalizedString(@"EDIT PRESCRIPTION", nil)
                          message:NSLocalizedString(@"EDIT PRESCRIPTION MESSAGE", nil)
                          delegate:self
                          cancelButtonTitle:NSLocalizedString(@"YES", nil)
                          otherButtonTitles:NSLocalizedString(@"NO", nil), nil];
    [self.av_edit show];
    [self.av_edit release];
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
    
    // Exit any text fields or text views being edited
    [self hideInputView];
    
    if (self.medicationName == nil ||
        self.method == nil ||
        self.dosageAmount == nil ||
        self.dosageUnit == nil ||
        self.scheduleStartDate == nil ||
        self.scheduleAmount == nil ||
        self.scheduleRepeatNumber == nil ||
        self.scheduleRepeatPeriod == nil ||
        self.scheduleEndDate == nil ||
        [self.medicationName isEqualToString:@""] ||
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
        ResourceContext* resourceContext = [ResourceContext instance];
               
        Prescription* prescription = [Prescription createPrescriptionWithName:self.medicationName
                                                               withDoctorName:self.doctorName
                                                           withMethodConstant:self.method
                                                                 withStrength:self.dosageAmount
                                                                     withUnit:self.dosageUnit
                                                                withDateStart:self.scheduleStartDate
                                                            withNumberOfDoses:self.scheduleAmount
                                                           withRepeatMultiple:self.scheduleRepeatNumber
                                                             withRepeatPeriod:self.scheduleRepeatPeriod
                                                            withOccurMultiple:self.scheduleOccurenceNumber
                                                                  withDateEnd:self.scheduleEndDate
                                                                    withNotes:self.reason];
        
//        // We will show a HUD since it may take a long time to generate all prescription instances
//        ClifeAppDelegate* appDelegate =(ClifeAppDelegate *)[[UIApplication sharedApplication] delegate];
//        UIProgressHUDView* progressView = appDelegate.progressView;
//        ApplicationSettings* settings = [[ApplicationSettingsManager instance] settings];
//        progressView.delegate = self;
//        
//        NSString* message = @"Creating reminders...";
//        [self showProgressBar:message withCustomView:nil withMaximumDisplayTime:settings.http_timeout_seconds];
        
//        [self performSelector:@selector(createPrescriptionInstancesForPrescription:) withObject:prescription];
        
        //we need to then create an array of prescription objects corresponding to this
        //particular prescription
        NSArray* prescriptionInstances = [PrescriptionInstance createPrescriptionInstancesFor:prescription];
        //now we have an array of prescription instances corresponding to the prescription
        
        [resourceContext save:NO onFinishCallback:nil trackProgressWith:nil];
        
        //we pass this to the local notification manager which will schedule them for
        //notifications as appropriate
        LocalNotificationManager* localNotificationManager = [LocalNotificationManager instance];
        [localNotificationManager scheduleNotifications];
        
        self.prescriptionID = prescription.objectid;
        
        [self.navigationController dismissModalViewControllerAnimated:YES];
    }
}

- (void)onCanceledAddingPrescriptionButtonPressed:(id)sender {
    [self.navigationController dismissModalViewControllerAnimated:YES];
}

#pragma mark MailComposeController Delegate
// The mail compose view controller delegate method
- (void)mailComposeController:(MFMailComposeViewController *)controller
          didFinishWithResult:(MFMailComposeResult)result
                        error:(NSError *)error
{
    if (result == MFMailComposeResultSent) {
        if (self.didRequestDelete == YES) {
            // Prompt user to enter their full name as verification before continuing
            self.av_delete = [[UIPromptAlertView alloc]
                              initWithTitle:NSLocalizedString(@"CONFIRM DELETE", nil)
                              message:[NSString stringWithFormat:@"\n\n%@", NSLocalizedString(@"CONFIRM DELETE MESSAGE", nil)]
                              delegate:self
                              cancelButtonTitle:NSLocalizedString(@"CANCEL", nil)
                              otherButtonTitles:NSLocalizedString(@"CONFIRM", nil), nil];
            self.av_delete.verificationText = self.loggedInUser.username;
            [self.av_delete performSelector:@selector(show) withObject:nil afterDelay:1];
            [self.av_delete release];
        }
        else if (self.didRequestEdit == YES) {
            // Allow editing
            [self editPrescription];
        }
    }
    
    [self dismissModalViewControllerAnimated:YES];
}

#pragma mark -  MBProgressHUD Delegate
-(void)hudWasHidden:(MBProgressHUD *)hud {
    NSString* activityName = @"CLifePrescriptionDetailsViewController.hudWasHidden";
    [self hideProgressBar];
    
    [self.navigationController dismissModalViewControllerAnimated:YES];
    
//    UIProgressHUDView* progressView = (UIProgressHUDView*)hud;
    
//    for (Request* request in progressView.requests) {
//        NSArray* changedAttributes = request.changedAttributesList;
//        //list of all changed attributes
//        
//        if ([changedAttributes containsObject:]) {
//            
//        }
//    }
}

#pragma mark - UIAlertView Delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView == self.av_edit) {
        self.didRequestDelete = NO;
        
        if (buttonIndex == 0) {
            self.didRequestEdit = YES;
            
            // Export data
            ExportManager *exportManager = [ExportManager instanceWithDelegate:self forPrescriptions:nil withStartDate:nil withEndDate:nil];
            [exportManager exportData];
        }
        else {
            // Skip export
            [self editPrescription];
        }
    }
    else if (alertView == self.av_delete) {
        if (buttonIndex == 0) {
            // Cancel
            self.didRequestDelete = NO;
            
            NSLog(@"Canceled delete");
        }
        else {
            [self deletePrescription];
        }
    }
}

#pragma mark - UIActionSheet Delegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        // Process delete WITHOUT data export
        self.didRequestDelete = YES;
        
        // Prompt user to enter their full name as verification before continuing
        self.av_delete = [[UIPromptAlertView alloc]
                          initWithTitle:NSLocalizedString(@"CONFIRM DELETE", nil)
                          message:[NSString stringWithFormat:@"\n\n%@", NSLocalizedString(@"CONFIRM DELETE MESSAGE", nil)]
                          delegate:self
                          cancelButtonTitle:NSLocalizedString(@"CANCEL", nil)
                          otherButtonTitles:NSLocalizedString(@"CONFIRM", nil), nil];
        self.av_delete.verificationText = self.loggedInUser.username;
        [self.av_delete show];
        [self.av_delete release];
    }
    else if (buttonIndex == 1) {
        // Process delete WITH data export
        self.didRequestDelete = YES;
        
        // Export data
        ExportManager *exportManager = [ExportManager instanceWithDelegate:self forPrescriptions:nil withStartDate:nil withEndDate:nil];
        exportManager.delegate = self;
        [exportManager exportData];
        
//        // Prompt user to enter their full name as verification before continuing
//        self.av_delete = [[UIPromptAlertView alloc]
//                          initWithTitle:NSLocalizedString(@"CONFIRM DELETE", nil)
//                          message:[NSString stringWithFormat:@"\n\n%@", NSLocalizedString(@"CONFIRM DELETE MESSAGE", nil)]
//                          delegate:self
//                          cancelButtonTitle:NSLocalizedString(@"CANCEL", nil)
//                          otherButtonTitles:NSLocalizedString(@"CONFIRM", nil), nil];
//        self.av_delete.verificationText = self.loggedInUser.username;
//        [self.av_delete show];
//        [self.av_delete release];
    }
    else {
        // Cancel
        
    }
}

#pragma mark - Static Initializers
+ (ClifePrescriptionDetailsViewController *)createInstanceForPrescriptionWithID:(NSNumber *)prescriptionID isEditable:(BOOL)isEditable {
    ClifePrescriptionDetailsViewController *instance = [[ClifePrescriptionDetailsViewController alloc] initWithNibName:@"ClifePrescriptionDetailsViewController" bundle:nil];
    [instance autorelease];
    
    instance.prescriptionID = prescriptionID;
    instance.isEditable = isEditable;
    
    return instance;
}

@end
