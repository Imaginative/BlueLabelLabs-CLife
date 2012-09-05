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




@dynamic alert;
@dynamic datestart;
@dynamic dateend;
@dynamic name;
@dynamic strength;
@dynamic unit;

@dynamic numberofdoses;
@dynamic method;
@dynamic repeatmultiple;
@dynamic repeatperiod;
@dynamic userid;
@dynamic notes;




#pragma mark - Static Initializers
+ (Prescription *) createPrescriptionWithName:(NSString *)name 
                                   withMethod:(NSString *)method 
                                 withStrength:(NSString *)strength 
                                     withUnit:(NSString *)unit 
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
    prescription.strength = strength;
    prescription.unit = unit;
    prescription.notes = notes;
    prescription.userid = user.objectid;
    
    prescription.alert = [NSNumber numberWithInt:0];
    
    NSDate* currentDate = [NSDate date];
    double doubleDate = [currentDate timeIntervalSince1970];
    prescription.datestart = [NSNumber numberWithDouble:doubleDate];
    
    prescription.repeatmultiple = nil;
    prescription.repeatperiod = nil;
    prescription.dateend = nil;
    prescription.numberofdoses = nil;
    
    return prescription;
    
}

@end