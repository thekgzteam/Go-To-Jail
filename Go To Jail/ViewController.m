//
//  ViewController.m
//  Go To Jail
//
//  Created by Edil Ashimov on 7/29/15.
//  Copyright (c) 2015 Edil Ashimov. All rights reserved.
//

#import "ViewController.h"
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>

@interface ViewController () <CLLocationManagerDelegate>
@property (weak, nonatomic) IBOutlet UITextView *myTextView;
@property CLLocationManager *myLocationManager;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.myLocationManager = [CLLocationManager new];
    [self.myLocationManager requestWhenInUseAuthorization];
    self.myLocationManager.delegate = self;
}
//}delegate method
-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"%@", error);
}
- (IBAction)startUpdationLocation:(id)sender {
    self.myTextView.text = @"locating you son....";
    [self.myLocationManager startUpdatingLocation];
}
//delegate method
-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    for (CLLocation *location in locations) {
        if (location.verticalAccuracy < 1000 && location.horizontalAccuracy < 1000){
            [self.myLocationManager stopUpdatingLocation];
            self.myTextView.text = @"Location found Son, IT IS TOO LATE IF YOU ARE READING THIS ...START PREPARING FOR EVACUATION. HAZARD!!!";

            [self reverseGeoCode:location];
            break;

        }
    }
}
//its  creating a new thread
- (void)reverseGeoCode:(CLLocation *)location {
    CLGeocoder *geocoder = [CLGeocoder new];
    [geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
        CLPlacemark *placemark = placemarks.lastObject;
        NSString *address = [NSString stringWithFormat:@"%@ %@ \n %@",placemark.subThoroughfare,placemark.thoroughfare,placemark.locality];
        [self updateMyTextView: [NSString stringWithFormat:@"We found You; %@", address]];
        [self findStripClubsNearMe:location];
    }];
}
- (void)findStripClubsNearMe:(CLLocation *)location {
    MKLocalSearchRequest *request = [MKLocalSearchRequest new];
    request.naturalLanguageQuery = @"Strip Club";
    request.region = MKCoordinateRegionMake(location.coordinate, MKCoordinateSpanMake(1,1));
    MKLocalSearch *search = [[MKLocalSearch alloc] initWithRequest:request];
    [search startWithCompletionHandler:^(MKLocalSearchResponse *response, NSError *error) {
        NSArray *mapItems = response.mapItems;
        MKMapItem *mapitem = mapItems.firstObject;
        [self updateMyTextView: [NSString stringWithFormat:@"You shoud Visit... \n %@", mapitem.name]];
        [self getDirectionsTo:mapitem];
    }];

}
-(void)getDirectionsTo:(MKMapItem *)destinationItem {
    MKDirectionsRequest *request = [MKDirectionsRequest new];
    request.source = [MKMapItem mapItemForCurrentLocation];
    request.destination = destinationItem;
    MKDirections *directions = [[MKDirections alloc] initWithRequest:request];
    [directions calculateDirectionsWithCompletionHandler:^(MKDirectionsResponse *response, NSError *error) {
        NSArray *routes = response.routes;
        MKRoute *route =routes.firstObject;
        int s=1;
        for (MKRouteStep *step in route.steps){
            [self updateMyTextView: [NSString stringWithFormat:@"%d.\t%@", s, step.instructions]];
            //            NSLog(@"%d.\t%@", s, step.instructions);
            s++;
        }
    }];
}
- (void)updateMyTextView:(NSString*)string  {
    self.myTextView.text = [NSString stringWithFormat:@"%@ \n %@", self.myTextView.text, string];
}
@end
