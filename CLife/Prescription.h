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
@property (nonatomic,retain) NSNumber* alert;
@property (nonatomic,retain) NSNumber* datestart;
@property (nonatomic,retain) NSNumber* dateend;
@property (nonatomic,retain) NSString* name;


@property (nonatomic,retain) NSString* strength;
@property (nonatomic,retain) NSString* unit;
@property (nonatomic,retain) NSString* method;
@property (nonatomic,retain) NSNumber* numberofdoses;

@property (nonatomic,retain) NSNumber* repeatmultiple;
@property (nonatomic,retain) NSNumber* repeatperiod;

@property (nonatomic,retain) NSNumber* userid;
@property (nonatomic,retain) NSString* notes;

+ (Prescription*) createPrescriptionWithName:(NSString *)name 
                                  withMethod:(NSString *)method 
                                withStrength:(NSString *)strength 
                                    withUnit:(NSString *)unit 
                                   withNotes:(NSString *)notes;
@end
