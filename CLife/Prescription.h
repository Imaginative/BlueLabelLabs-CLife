//
//  Prescription.h
//  CLife
//
//  Created by Jasjeet Gill on 8/14/12.
//  Copyright (c) 2012 Blue Label Solutions LLC. All rights reserved.
//

#import "Resource.h"

@interface Prescription : Resource
{
    
}

@property (nonatomic,retain) NSNumber* userid;

@property (nonatomic,retain) NSString* name;
@property (nonatomic,retain) NSString* method;

@property (nonatomic,retain) NSNumber* strength;
@property (nonatomic,retain) NSString* unit;

@property (nonatomic,retain) NSNumber* datestart;
@property (nonatomic,retain) NSNumber* numberofdoses;
@property (nonatomic,retain) NSNumber* repeatmultiple;
@property (nonatomic,retain) NSNumber* repeatperiod;
@property (nonatomic,retain) NSNumber* occurmultiple;
@property (nonatomic,retain) NSNumber* dateend;

@property (nonatomic,retain) NSString* notes;

- (NSArray*) unconfirmedPrescriptionInstancesAfter:(NSDate*)date;
- (NSArray*) prescriptionInstances;

+ (void) deletePrescriptionWithID:(NSNumber *)prescriptionID;

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
                                    withNotes:(NSString *)notes;
@end
