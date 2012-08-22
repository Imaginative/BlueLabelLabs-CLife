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

@property (nonatomic,retain) NSString* name;
@property (nonatomic,retain) NSNumber* alert;
@property (nonatomic,retain) NSNumber* datestart;
@property (nonatomic,retain) NSString* dosageamount;
@property (nonatomic,retain) NSString* dosageunit;
@property (nonatomic,retain) NSNumber* duration;
@property (nonatomic,retain) NSNumber* frequency;
@property (nonatomic,retain) NSString* method;
@property (nonatomic,retain) NSNumber* repeat;
@property (nonatomic,retain) NSNumber* userid;
@property (nonatomic,retain) NSString* notes;

+ (Prescription*) createPrescriptionWithName:(NSString *)name 
                                  withMethod:(NSString *)method 
                            withDosageAmount:(NSString *)dosage 
                              withDosageUnit:(NSString *)dosageUnit 
                                   withNotes:(NSString *)notes;
@end
