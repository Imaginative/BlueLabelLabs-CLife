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

@dynamic userid;

@dynamic name;
@dynamic strength;
@dynamic unit;

@dynamic datestart;
@dynamic numberofdoses;
@dynamic method;
@dynamic repeatmultiple;
@dynamic repeatperiod;
@dynamic occurmultiple;
@dynamic dateend;

@dynamic notes;


#pragma mark - Static Initializers
+ (Prescription *) createPrescriptionWithName:(NSString *)name 
                                   withMethod:(NSString *)method 
                                 withStrength:(NSNumber *)strength 
                                     withUnit:(NSString *)unit
                                withDateStart:(NSNumber *)dateStart
                            withNumberOfDoses:(NSNumber *)numberOfDoses
                           withRepeatMultiple:(NSNumber *)repeatMultiple
                             withRepeatPeriod:(NSNumber *)repeatPeriod
                            withOccurMultiple:(NSNumber *)occurMultiple
                                  withDateEnd:(NSNumber *)dateEnd
                                    withNotes:(NSString *)notes
{
    
    
    AuthenticationManager* authenticationManager = [AuthenticationManager instance];
    ResourceContext* resourceContext = [ResourceContext instance];
    Prescription* prescription = (Prescription*)[Resource createInstanceOfType:PRESCRIPTION withResourceContext:resourceContext];
    
    User* user = (User*)[resourceContext resourceWithType:USER withID:authenticationManager.m_LoggedInUserID];
    
    IDGenerator* idGenerator = [IDGenerator instance];
    NSNumber* prescriptionID = [idGenerator generateNewId:PRESCRIPTION];
    
    prescription.objectid = prescriptionID;
    
    prescription.userid = user.objectid;
    
    prescription.name = name;
    prescription.method = method;
    
    prescription.strength = strength;
    prescription.unit = unit;
    
    prescription.datestart = dateStart;
    prescription.numberofdoses = numberOfDoses;
    prescription.repeatmultiple = repeatMultiple;
    prescription.repeatperiod = repeatPeriod;
    prescription.occurmultiple = occurMultiple;
    prescription.dateend = dateEnd;
    
    prescription.notes = notes;
    
    return prescription;
    
}

@end