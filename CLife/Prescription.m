//
//  Prescription.m
//  CLife
//
//  Created by Jasjeet Gill on 8/14/12.
//  Copyright (c) 2012 Blue Label Solutions LLC. All rights reserved.
//

#import "Prescription.h"
#import "AuthenticationManager.h"
#import "User.h"
#import "DateTimeHelper.h"
#import "IDGenerator.h"

@implementation Prescription
@dynamic name;
@dynamic alert;
@dynamic dosageamount;
@dynamic dosageunit;
@dynamic duration;
@dynamic frequency;
@dynamic method;
@dynamic repeat;
@dynamic datestart;
@dynamic notes;
@dynamic userid;



#pragma mark - Static Initializers
+ (Prescription *) createPrescriptionWithName:(NSString *)name 
                                   withMethod:(NSString *)method 
                             withDosageAmount:(NSString *)dosage 
                               withDosageUnit:(NSString *)dosageUnit 
                                    withNotes:(NSString *)notes
{
    
    
    AuthenticationManager* authenticationManager = [AuthenticationManager instance];
    ResourceContext* resourceContext = [ResourceContext instance];
    Prescription* prescription = (Prescription*)[Resource createInstanceOfType:PRESCRIPTION withResourceContext:resourceContext];
    
    User* user = (User*)[resourceContext resourceWithType:USER withID:authenticationManager.m_LoggedInUserID];
    
    IDGenerator* idGenerator = [IDGenerator instance];
    NSNumber* prescriptionID = [idGenerator generateNewId:PRESCRIPTION];
    
    prescription.objectid = prescriptionID;
    prescription.name = name;
    prescription.method = method;
    prescription.dosageamount = dosage;
    prescription.dosageunit = dosageUnit;
    prescription.notes = notes;
    prescription.userid = user.objectid;
    
    prescription.alert = [NSNumber numberWithInt:0];
    
    NSDate* currentDate = [NSDate date];
    double doubleDate = [currentDate timeIntervalSince1970];
    prescription.datestart = [NSNumber numberWithDouble:doubleDate];
    
    prescription.repeat = [NSNumber numberWithInt:0];
    prescription.duration = [NSNumber numberWithInt:0];
    prescription.frequency = [NSNumber numberWithInt:0];
    
    return prescription;
    
}

@end