//
//  ApplicationSettings.h
//  Platform
//
//  Created by Bobby Gill on 10/10/11.
//  Copyright 2011 Blue Label Solutions LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "Resource.h"

@interface ApplicationSettings : Resource {
    
}

//Generic settings
@property (nonatomic, retain) NSString* base_url;
@property (nonatomic, retain) NSString* fb_app_id;
@property (nonatomic, retain) NSNumber* http_timeout_seconds;
@property (nonatomic, retain) NSString* twitter_consumersecret;
@property (nonatomic, retain) NSString* twitter_consumerkey;

//Generic enumeration settings
@property (nonatomic,retain) NSNumber* pagesize;
@property (nonatomic,retain) NSNumber* numberoflinkedobjectstoreturn;

//Feed settings
@property (nonatomic,retain) NSNumber* feed_maxnumtodownload;
@property (nonatomic,retain) NSNumber* feed_enumeration_timegap;



@property (nonatomic,retain) NSNumber* version;

@property (nonatomic,retain) NSNumber* poll_expiry_seconds;


@property (nonatomic,retain) NSNumber* num_users;
@property (nonatomic,retain) NSNumber* progress_maxsecondstodisplay;



//Follow settings
@property (nonatomic,retain) NSNumber* follow_maxnumtodownload;
@property (nonatomic,retain) NSNumber* follow_enumeration_timegap;








@end
