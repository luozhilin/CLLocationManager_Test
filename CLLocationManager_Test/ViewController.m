//
//  ViewController.m
//  CLLocationManager_Test
//
//  Created by Luozhilin on 16/6/22.
//  Copyright © 2016年 Luozhilin. All rights reserved.
//

#import "ViewController.h"

#import <CoreLocation/CoreLocation.h>

@interface ViewController ()<CLLocationManagerDelegate, UITableViewDelegate, UITableViewDataSource>
{
    UITableView *myTableView;
    NSMutableArray *dataArr;
}
@property (weak, nonatomic) IBOutlet UILabel *curLocatinLabel;

// 1.设置位置管理者属性
@property (nonatomic, strong) CLLocationManager *lcManager;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    myTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
    dataArr = [NSMutableArray array];

    myTableView.delegate = self;
    myTableView.dataSource = self;
    [self.view addSubview:myTableView];
    
    // 2.判断是否打开了位置服务
    if ([CLLocationManager locationServicesEnabled]) {
        // 创建位置管理者对象
        self.lcManager = [[CLLocationManager alloc] init];
        
        if ([[UIDevice currentDevice].systemVersion floatValue] >=8.0 ) {
            [_lcManager requestAlwaysAuthorization];
        }
        
        if ([_lcManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
            [_lcManager requestWhenInUseAuthorization];
        }
        
        self.lcManager.delegate = self; // 设置代理
        // 设置定位距离过滤参数 (当本次定位和上次定位之间的距离大于或等于这个值时，调用代理方法)
        self.lcManager.distanceFilter = 20;
//        self.lcManager.desiredAccuracy = kCLLocationAccuracyBest; // 设置定位精度(精度越高越耗电)
        self.lcManager.desiredAccuracy = kCLLocationAccuracyBest;
        [self.lcManager startUpdatingLocation]; // 开始更新位置
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/** 获取到新的位置信息时调用*/
-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
//    1.coordinate : 当前位置的坐标
//    latitude : 纬度
//    longitude : 经度
//    2.altitude : 海拔，高度
//    3.horizontalAccuracy : 纬度和经度的精度
//    4.verticalAccuracy : 垂直精度(获取不到海拔时为负数)
//    5.course : 行进方向(真北)
//    6.speed : 以米/秒为单位的速度
//    7.description : 位置描述信息
    
    CLLocation *location = [locations firstObject];
    NSString *str = [NSString stringWithFormat:@"经度%lf,维度%lf,speed%lf",location.coordinate.longitude, location.coordinate.latitude,location.speed];
//    self.curLocatinLabel.text = str;
    NSLog(@"定位到了");
    

    [dataArr addObject:str];

    [myTableView reloadData];
    
}
/** 不能获取位置信息时调用*/
-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"获取定位失败");
}
/** 定位服务状态改变时调用*/
-(void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    switch (status) {
        case kCLAuthorizationStatusNotDetermined:
        {
            NSLog(@"用户还未决定授权");
            break;
        }
        case kCLAuthorizationStatusRestricted:
        {
            NSLog(@"访问受限");
            break;
        }
        case kCLAuthorizationStatusDenied:
        {
            // 类方法，判断是否开启定位服务
            if ([CLLocationManager locationServicesEnabled]) {
                NSLog(@"定位服务开启，被拒绝");
            } else {
                NSLog(@"定位服务关闭，不可用");
            }
            break;
        }
        case kCLAuthorizationStatusAuthorizedAlways:
        {
            NSLog(@"获得前后台授权");
            break;
        }
        case kCLAuthorizationStatusAuthorizedWhenInUse:
        {
            NSLog(@"获得前台授权");
            break;
        }
        default:
            break;
    }
}

#pragma mark - UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return dataArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //    声明静态字符串型对象，用来标记重用单元格
    static NSString *TableSampleIdentifier = @"TableSampleIdentifier";
    //    用TableSampleIdentifier表示需要重用的单元
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:TableSampleIdentifier];
    //    如果如果没有多余单元，则需要创建新的单元
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:TableSampleIdentifier];
    }
    
    //    获取当前行信息值
    NSUInteger row = [indexPath row];
    
    //    把数组中的值赋给单元格显示出来
    cell.textLabel.text=[dataArr objectAtIndex:row];
    
    return cell;
}



@end
