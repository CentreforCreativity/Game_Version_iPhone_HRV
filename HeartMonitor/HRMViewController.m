//
//  HRMViewController.m
//  HeartMonitor
//
//  Created by Steven F. Daniel on 30/11/13.
//  Copyright (c) 2013 GENIESOFT STUDIOS. All rights reserved.
//

#import "HRMViewController.h"
#import "PowerSpectrum.h"
 #import <QuartzCore/QuartzCore.h>

@interface HRMViewController ()
@property (weak, nonatomic) IBOutlet UIView *warmUpView;
@property (weak, nonatomic) IBOutlet UIButton *sessionBtn;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *warmUpViewCenterXConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *squareGameViewCenterXConstrain;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *indicatorCenterYConstrain;





@end

@implementation HRMViewController



- (IBAction)startSession:(id)sender {
   
    for (CALayer* layer in [self.view.layer sublayers]) {
        [layer removeAllAnimations];
    }
    self.i = 2;
    self.indicatorCenterYConstrain.constant = 0;
    [self.view layoutIfNeeded]; // Called on parent view

    
    if (self.isMeteringActive == NO) {
    self.warmUpViewCenterXConstraint.constant = 0;
    [UIView animateWithDuration:0.37
                     animations:^{
                         [self.view layoutIfNeeded]; // Called on parent view
                     }completion:^(BOOL finished) {
                         if (finished) {
                             NSLog(@"int: %d",self.i);
                             [self animateIndicator];
                         }
                     }];
    }
    else {
        [self showSquareGameView];
    }
}


-(void)showSquareGameView{
    self.squareGameViewCenterXConstrain.constant = 0;
    [UIView animateWithDuration:0.37
                     animations:^{
                         [self.view layoutIfNeeded]; // Called on parent view
                     }completion:^(BOOL finished) {
                         if (finished) {
                             NSLog(@"int: %d",self.i);
                             [self animateIndicator];
                         }
                     }];

}





- (IBAction)backToMainView:(id)sender {
    
    
    for (CALayer* layer in [self.view.layer sublayers]) {
        [layer removeAllAnimations];
    }
    self.i =1;
    self.warmUpViewCenterXConstraint.constant = self.view.frame.size.width;
    self.squareGameViewCenterXConstrain.constant = self.view.frame.size.width;
    [UIView animateWithDuration:0.37
                     animations:^{
                         [self.view layoutIfNeeded]; // Called on parent view
                         
                     }completion:^(BOOL finished) {
                         if (finished) {
                     
                         //    [self.warmUpView removeFromSuperview];
                         //    [self.view addSubview:self.warmUpView];
                         }
                     }];
    
}




-(void)animateIndicator{
    
        self.i=self.i+0.05;
    self.indicatorCenterYConstrain.constant = 200;
    [UIView animateWithDuration:self.i
                          delay:0
                        options:UIViewAnimationOptionAllowUserInteraction
                     animations:^{
                         NSLog(@"--- -- -: %f",self.i);
                         [self.view layoutIfNeeded];

                     }completion:^(BOOL finished) {
                         if (finished)
                         {
                             self.indicatorCenterYConstrain.constant = -140;

                             [UIView animateWithDuration:self.i
                                              animations:^{
                                                  NSLog(@"--- -- -: %f",self.i);
                                                  [self.view layoutIfNeeded];
                                                  
                                              }completion:^(BOOL finished) {
                                                  if (finished)
                                                  {
                                                      NSLog(@"int: %f",self.i);
                                                      
                                                      if (self.isMeteringActive == NO){
                                                          [self animateIndicator];

                                                      }
                                                 
                                                      
                                                  }
                                              }];

                         }
                     }];
    
    
    
    
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.warmUpViewCenterXConstraint.constant = self.view.frame.size.width;
    self.squareGameViewCenterXConstrain.constant = self.view.frame.size.width;
    [self.view layoutIfNeeded];
    self.i=0;
    
    
	// Do any additional setup after loading the view, typically from a nib.
	self.polarH7DeviceData = nil;
	//[self.view setBackgroundColor:[UIColor groupTableViewBackgroundColor]];
	[self.heartImage setImage:[UIImage imageNamed:@"HeartImage"]];
	
	// Clear out textView
	[self.deviceInfo setText:@""];
	[self.deviceInfo setTextColor:[UIColor blueColor]];
	//[self.deviceInfo setBackgroundColor:[UIColor groupTableViewBackgroundColor]];
	[self.deviceInfo setFont:[UIFont fontWithName:@"Futura-CondensedMedium" size:25]];
	[self.deviceInfo setUserInteractionEnabled:NO];
	
	// Create our Heart Rate BPM Label
	self.heartRateBPM = [[UILabel alloc] initWithFrame:CGRectMake(55, 30, 75, 50)];
	[self.heartRateBPM setTextColor:[UIColor whiteColor]];
	[self.heartRateBPM setText:[NSString stringWithFormat:@"%i", 0]];
	[self.heartRateBPM setFont:[UIFont fontWithName:@"Futura-CondensedMedium" size:28]];
	[self.heartImage addSubview:self.heartRateBPM];
	
	// Scan for all available CoreBluetooth LE devices
	NSArray *services = @[[CBUUID UUIDWithString:POLARH7_HRM_HEART_RATE_SERVICE_UUID], [CBUUID UUIDWithString:POLARH7_HRM_DEVICE_INFO_SERVICE_UUID]];
	CBCentralManager *centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
	[centralManager scanForPeripheralsWithServices:services options:nil];
	self.centralManager = centralManager;
    heartbeatsArray = [[NSMutableArray alloc]init];
    timestampsArray = [[NSMutableArray alloc]init];
}

// method called whenever the device state changes.
- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
	// Determine the state of the peripheral
	if ([central state] == CBCentralManagerStatePoweredOff) {
		NSLog(@"CoreBluetooth BLE hardware is powered off");
	}
	else if ([central state] == CBCentralManagerStatePoweredOn) {
        // corrected for iOS 8 delayed start after CBManager is instantiated
        // Scan for all available CoreBluetooth LE devices
        NSArray *services = @[[CBUUID UUIDWithString:POLARH7_HRM_HEART_RATE_SERVICE_UUID], [CBUUID UUIDWithString:POLARH7_HRM_DEVICE_INFO_SERVICE_UUID]];
        [self.centralManager scanForPeripheralsWithServices:services options:nil];
        NSLog(@"CoreBluetooth BLE hardware is powered on and ready");
	}
	else if ([central state] == CBCentralManagerStateUnauthorized) {
		NSLog(@"CoreBluetooth BLE state is unauthorized");
	}
	else if ([central state] == CBCentralManagerStateUnknown) {
		NSLog(@"CoreBluetooth BLE state is unknown");
	}
	else if ([central state] == CBCentralManagerStateUnsupported) {
		NSLog(@"CoreBluetooth BLE hardware is unsupported on this platform");
	}
}

// method called whenever we have successfully connected to the BLE peripheral
- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
	[peripheral setDelegate:self];
    [peripheral discoverServices:nil];
	self.connected = [NSString stringWithFormat:@"Connected: %@", peripheral.state == CBPeripheralStateConnected ? @"YES" : @"NO"];
}

// CBPeripheralDelegate - Invoked when you discover the peripheral's available services.
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
	for (CBService *service in peripheral.services) {
		[peripheral discoverCharacteristics:nil forService:service];
	}
}

// CBCentralManagerDelegate - This is called with the CBPeripheral class as its main input parameter. This contains most of the information there is to know about a BLE peripheral.
- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{
	NSString *localName = [advertisementData objectForKey:CBAdvertisementDataLocalNameKey];
	if (![localName isEqual:@""]) {
		// We found the Heart Rate Monitor
		[self.centralManager stopScan];
		self.polarH7HRMPeripheral = peripheral;
		peripheral.delegate = self;
		[self.centralManager connectPeripheral:peripheral options:nil];
	}
}

// Invoked when you discover the characteristics of a specified service.
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
	if ([service.UUID isEqual:[CBUUID UUIDWithString:POLARH7_HRM_HEART_RATE_SERVICE_UUID]])  {  // 1
		for (CBCharacteristic *aChar in service.characteristics)
		{
			// Request heart rate notifications
			if ([aChar.UUID isEqual:[CBUUID UUIDWithString:POLARH7_HRM_NOTIFICATIONS_SERVICE_UUID]]) { // 2
				[self.polarH7HRMPeripheral setNotifyValue:YES forCharacteristic:aChar];
			}
			// Request body sensor location
			else if ([aChar.UUID isEqual:[CBUUID UUIDWithString:POLARH7_HRM_BODY_LOCATION_UUID]]) { // 3
				[self.polarH7HRMPeripheral readValueForCharacteristic:aChar];
			}
//			else if ([aChar.UUID isEqual:[CBUUID UUIDWithString:POLARH7_HRM_ENABLE_SERVICE_UUID]]) { // 4
//				// Read the value of the heart rate sensor
//				UInt8 value = 0x01;
//				NSData *data = [NSData dataWithBytes:&value length:sizeof(value)];
//				[peripheral writeValue:data forCharacteristic:aChar type:CBCharacteristicWriteWithResponse];
//			}
		}
	}
	// Retrieve Device Information Services for the Manufacturer Name
	if ([service.UUID isEqual:[CBUUID UUIDWithString:POLARH7_HRM_DEVICE_INFO_SERVICE_UUID]])  { // 5
        for (CBCharacteristic *aChar in service.characteristics)
        {
            if ([aChar.UUID isEqual:[CBUUID UUIDWithString:POLARH7_HRM_MANUFACTURER_NAME_UUID]]) {
                [self.polarH7HRMPeripheral readValueForCharacteristic:aChar];
                NSLog(@"Found a Device Manufacturer Name Characteristic");
            }
        }
	}
}

// Invoked when you retrieve a specified characteristic's value, or when the peripheral device notifies your app that the characteristic's value has changed.
- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
	// Updated value for heart rate measurement received
	if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:POLARH7_HRM_NOTIFICATIONS_SERVICE_UUID]]) { // 1
		// Get the Heart Rate Monitor BPM
		[self getHeartBPMData:characteristic error:error];
	}
	// Retrieve the characteristic value for manufacturer name received
    if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:POLARH7_HRM_MANUFACTURER_NAME_UUID]]) {  // 2
		[self getManufacturerName:characteristic];
    }
	// Retrieve the characteristic value for the body sensor location received
	else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:POLARH7_HRM_BODY_LOCATION_UUID]]) {  // 3
		[self getBodyLocation:characteristic];
    }
	
	// Add our constructed device information to our UITextView
	self.deviceInfo.text = [NSString stringWithFormat:@"%@\n%@\n%@\n", self.connected, self.bodyData, self.manufacturer];  // 4
    
    
    
    

    
    
    
    
    
}

// Instance method to get the heart rate BPM information
- (void) getHeartBPMData:(CBCharacteristic *)characteristic error:(NSError *)error
{
	// Get the Heart Rate Monitor BPM
	NSData *data = [characteristic value];      // 1
	//const uint8_t *reportData = [data bytes];
    const uint8_t * reportData =  (uint8_t *)[data bytes];

    
    
	uint16_t bpm = 0;
	
	if ((reportData[0] & 0x01) == 0) {          // 2
		// Retrieve the BPM value for the Heart Rate Monitor
		bpm = reportData[1];
	}
	else {
		bpm = CFSwapInt16LittleToHost(*(uint16_t *)(&reportData[1]));  // 3
	}
	// Display the heart rate value to the UI if no error occurred
	if( (characteristic.value)  || !error ) {   // 4
		self.heartRate = bpm;
		self.bpmLabel.text = [NSString stringWithFormat:@"%i", bpm];
		self.heartRateBPM.font = [UIFont fontWithName:@"Futura-CondensedMedium" size:28];
		[self doHeartBeat];
		self.pulseTimer = [NSTimer scheduledTimerWithTimeInterval:(60. / self.heartRate) target:self selector:@selector(doHeartBeat) userInfo:nil repeats:NO];
        
        NSTimeInterval timePassed_ms;
        timePassed_ms = 0;
        
        if ( self.timeStarted == nil){
            self.timeStarted = [NSDate date];
        }
        
        NSDate *methodFinish = [NSDate date];
        self.executionTime = [methodFinish timeIntervalSinceDate:self.timeStarted];
        NSLog(@"executionTime = %.5f", self.executionTime);
        self.executionTimeLabel.text = [NSString stringWithFormat:(@"%.0f"), self.executionTime];
        
        
        [heartbeatsArray addObject:[NSString stringWithFormat:@"%d",bpm]];
        [timestampsArray addObject:[NSNumber numberWithFloat: self.executionTime]];
        
 
        
        [self analyseData];

	}
	return;
}

// Instance method to get the manufacturer name of the device
- (void) getManufacturerName:(CBCharacteristic *)characteristic
{
	NSString *manufacturerName = [[NSString alloc] initWithData:characteristic.value encoding:NSUTF8StringEncoding];
	self.manufacturer = [NSString stringWithFormat:@"Manufacturer: %@", manufacturerName];
	return;
}

// Instance method to get the body location of the device
- (void) getBodyLocation:(CBCharacteristic *)characteristic
{
	NSData *sensorData = [characteristic value];
	uint8_t *bodyData = (uint8_t *)[sensorData bytes];
	if (bodyData ) {
		uint8_t bodyLocation = bodyData[0];
		self.bodyData = [NSString stringWithFormat:@"Body Location: %@", bodyLocation == 1 ? @"Chest" : @"Undefined"];
	}
	else {
		self.bodyData = [NSString stringWithFormat:@"Body Location: N/A"];
	}
	return;
}

// instance method to stop the device from rotating - only support the Portrait orientation
- (NSUInteger) supportedInterfaceOrientations {
    // Return a bitmask of supported orientations. If you need more,
    // use bitwise or (see the commented return).
    return UIInterfaceOrientationMaskPortrait;
}

// instance method to simulate our pulsating Heart Beat
- (void) doHeartBeat
{
	CALayer *layer = [self heartImage].layer;
	CABasicAnimation *pulseAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
	pulseAnimation.toValue = [NSNumber numberWithFloat:1.1];
	pulseAnimation.fromValue = [NSNumber numberWithFloat:1.0];
	
	pulseAnimation.duration = 60. / self.heartRate / 2.;
	pulseAnimation.repeatCount = 1;
	pulseAnimation.autoreverses = YES;
	pulseAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
	[layer addAnimation:pulseAnimation forKey:@"scale"];
	
	self.pulseTimer = [NSTimer scheduledTimerWithTimeInterval:(60. / self.heartRate) target:self selector:@selector(doHeartBeat) userInfo:nil repeats:NO];
}

// handle memory warning errors
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)analyseData{
    int calmingLevel;
    NSNumber *myNumber = [timestampsArray  lastObject];
  //  NSLog(@"::::::::: = %.5f", [myNumber floatValue]);
    
    if (heartbeatsArray.count >=1){

     //  typedef struct attentionLevel =    analyseData([myNumber floatValue], [[heartbeatsArray lastObject]integerValue], &calmingLevel);
        
        
        //   struct ClassABC cabc;
        //   initClassABC(&cabc);
        //   HRVData heartRateValues = getHeartData();

          HRVData heartRateValues =    analyseData([myNumber floatValue], [[heartbeatsArray lastObject]integerValue], &calmingLevel);
        [self.attenrionMeter setValue:heartRateValues.attentionLevel animateWithDuration:0.4];
        [self.relaxationMeter setValue:heartRateValues.calmingLevel animateWithDuration:0.4];

        
        [self setSquareGameIndicatorPositionforAttention:heartRateValues.attentionLevel andRelaxation:heartRateValues.calmingLevel];
        
        
        
        //  NSLog(@"subtract: %f", heartRateValues.averagePower[0] );
        //  self.deviceInfo.text = [NSString stringWithFormat:@"Attention: %d", attentionLevel];
    }
}


-(void)setSquareGameIndicatorPositionforAttention: (int)attentionLevel andRelaxation: (int)calmingLevel{
    if(attentionLevel>0 && calmingLevel>0 && self.isMeteringActive==NO){
        self.isMeteringActive = YES;
        self.indicatorImageView.alpha=1;
        [self showSquareGameView];

    }
    
    if (    self.isMeteringActive == YES){

 //   NSLog(@"Width: %f",self.squareGameContainerView.frame.size.width);
 //   NSLog(@"Height: %f",self.squareGameContainerView.frame.size.height);
    float distanceX = 1;
    if (attentionLevel<4){
        
        distanceX = (self.squareGameContainerView.frame.size.width/8)*attentionLevel;
    
    }
    else{
        
        distanceX = (self.squareGameContainerView.frame.size.width/8)*(attentionLevel+1);
        
    }
        
        /*
        if (distanceX == self.squareGameContainerView.frame.size.width){
            distanceX -=10;
        }
        else if (distanceX == self.squareGameContainerView.frame.size.width/6){
            distanceX +=10;
        }
         
         */
    
    float distanceY = 1;
     if (calmingLevel<4){
         
      distanceY =   (self.squareGameContainerView.frame.size.height/8) * calmingLevel;

     }
     else{
         
         distanceY =   (self.squareGameContainerView.frame.size.height/8) * (calmingLevel+1);
         
     }
        
        /*
        if (distanceY == self.squareGameContainerView.frame.size.height){
            distanceY -=10;
        }
        else if (distanceY == self.squareGameContainerView.frame.size.height/6){
            distanceY +=10;
        }
         */
        
  //  NSLog(@"Distance Width: %f",distanceX);
  //  NSLog(@"Distance Height: %f",distanceY);
    NSLog(@"---> %d",attentionLevel);
    NSLog(@"---> %d",calmingLevel);
    self.indicatorYConstrain.constant = -distanceX;
    self.indicatorXConstrain.constant = distanceY;
    [UIView animateWithDuration:0.60
                     animations:^{
                         [self.view layoutIfNeeded];
                     }];
    
    
    
    CGPoint indicatorPoint = CGPointMake(self.indicatorImageView.frame.origin.x + (self.indicatorImageView.frame.size.width/2) ,self.indicatorImageView.frame.origin.y + (self.indicatorImageView.frame.size.height/2));
    
    if (CGRectContainsPoint (self.topLeftImageView.frame, indicatorPoint)){
        self.topLeftScoreLabel.text = [NSString stringWithFormat:@"%d", [self.topLeftScoreLabel.text intValue]+1];
    }
    else if (CGRectContainsPoint (self.topRightImageView.frame, indicatorPoint)){
        self.topRightScoreLabel.text = [NSString stringWithFormat:@"%d", [self.topRightScoreLabel.text intValue]+1];
    }
    else if (CGRectContainsPoint (self.bottomLeftImageView.frame, indicatorPoint)){
        self.bottomLeftScoreLabel.text = [NSString stringWithFormat:@"%d", [self.bottomLeftScoreLabel.text intValue]+1];
    }
    else if (CGRectContainsPoint (self.nbottomRightImageView.frame, indicatorPoint)){
        self.bottomRightScoreLabel.text = [NSString stringWithFormat:@"%d", [self.bottomRightScoreLabel.text intValue]+1];
    }

    }
}





@end
