//
//  JKMapView.m
//  Maptest
//
//  Created by Mac on 2018/3/30.
//  Copyright © 2018年 Mac. All rights reserved.
//

#import "JKMapView.h"
#import <MapKit/MapKit.h>
#import "JKAnnotation.h"
#import "JKAnnotationView.h"

@interface JKMapView()<MKMapViewDelegate,CLLocationManagerDelegate,UITableViewDelegate,UITableViewDataSource>
@property (strong, nonatomic) CLLocationManager* locationManager;
@property (nonatomic, strong)CLGeocoder *geoCoder;
@property (nonatomic, strong)MKMapView *map;
@property (nonatomic, strong)UILabel *addressLabel;
@property (nonatomic, strong)UITableView *placetab;
@property (nonatomic, strong)NSMutableArray *dataArray;
@end

@implementation JKMapView

- (NSMutableArray *)dataArray{
    if (!_dataArray){
        _dataArray = [NSMutableArray array];
    }
    
    return _dataArray;
}

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]){
        [self creatMap];
    }
    
    return self;
}

- (void)creatMap{
    _map = [[MKMapView alloc]initWithFrame:self.bounds];
    _map.delegate = self;
    _map.userTrackingMode = MKUserTrackingModeFollow;
    //显示指南针
    _map.showsCompass = YES;
    //显示比例尺
    _map.showsScale = YES;
    //显示交通状况
    _map.showsTraffic = YES;
    //显示建筑物
    _map.showsBuildings = YES;
    //显示用户所在的位置
    _map.showsUserLocation = YES;
    //显示感兴趣的东西
    _map.showsPointsOfInterest = YES;
    [self addSubview:_map];
    
    
    
    
    _addressLabel = [[UILabel alloc]init];
    _addressLabel.bounds = CGRectMake(0, 0, 200, 40);
    _addressLabel.backgroundColor = [UIColor blackColor];
    _addressLabel.textColor = [UIColor whiteColor];
    _addressLabel.center = self.center;
    [self addSubview:_addressLabel];
    
    
    UITextField *keywordSearchButton = [[UITextField alloc]init];
    keywordSearchButton.backgroundColor = [UIColor lightGrayColor];
    keywordSearchButton.frame = CGRectMake(100, 64, 100, 40);
    [keywordSearchButton addTarget:self action:@selector(keywordSearch:) forControlEvents:UIControlEventEditingChanged];
    [self addSubview:keywordSearchButton];
    
    UIButton *hotSearchButton = [UIButton buttonWithType:UIButtonTypeCustom];
    hotSearchButton.frame = CGRectMake(0, 64, 100, 40);
    [hotSearchButton setTitle:@"热点搜索" forState:UIControlStateNormal];
    [hotSearchButton addTarget:self action:@selector(hotSeatch) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:hotSearchButton];
    
    
    _placetab = [[UITableView alloc]initWithFrame:CGRectMake(0, 100, self.frame.size.width, 300)];
    _placetab.delegate = self;
    _placetab.dataSource = self;
    _placetab.hidden = YES;
    [self addSubview:_placetab];
    
    _geoCoder = [[CLGeocoder alloc]init];
}


- (void)hotSeatch {
    //创建本地搜索请求
    MKLocalSearchRequest *request = [[MKLocalSearchRequest alloc] init];
    //设置搜索热点词（自然语言）
    request.naturalLanguageQuery = @"学校";
    //设置搜索范围，以某个原点为中心，向外扩展一段经纬度距离范围
    CLLocationCoordinate2D origionpoint = CLLocationCoordinate2DMake(36.08397, 120.37126);
    //设置经纬度跨越范围
    MKCoordinateSpan span = MKCoordinateSpanMake(0.3, 0.3);
    //设置经纬度搜索区域
    MKCoordinateRegion region = MKCoordinateRegionMake(origionpoint, span);
    //将区域赋值给搜索请求对象中的region属性中
    request.region = region;
    //将地图移动到该区域
    [_map setRegion:region];
    
    //创建本地搜索对象
    MKLocalSearch *search = [[MKLocalSearch alloc] initWithRequest:request];
    //开启搜索
    [search startWithCompletionHandler:^(MKLocalSearchResponse * _Nullable response, NSError * _Nullable error) {
        
        if (error == nil) {
            
            //搜索成功
            //获取搜索结果
            NSArray *arrResult = response.mapItems;
            
            for (MKMapItem *item in arrResult) {
                
                //先取出地图目的坐标对象(标记)
                MKPlacemark *placeMark = item.placemark;
                /*
                 96                  地标里存放的经纬度，以及位置的地理信息说明，如名字、街道等等
                 97                  */
                //创建大头针
                JKAnnotation *anno = [[JKAnnotation alloc] init];
                anno.title = @"我是一个大头针";
                anno.subtitle = @"我有一个小弟叫小头";
                anno.coordinate = placeMark.location.coordinate;
                [_map addAnnotation:anno];
                
            }
            
            
        }else {
            NSLog(@"搜索失败");
            
        }
        
    }];
    
}


//关键字搜索
- (void)keywordSearch:(UITextField*)field {
    if (field.text.length == 0){
        _placetab.hidden = YES;
    }
    //创建地理编码
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    //正向地理编码
    [geocoder geocodeAddressString:field.text completionHandler:^(NSArray * _Nullable placemarks, NSError * _Nullable error) {
        
        if (error == nil) {
            //解析地理位置成功
            //成功后遍历数组
            for (CLPlacemark *place in placemarks) {
                
                //创建大头针
                
                //                                 MyPointAnnotation *annotation = [[MyPointAnnotation alloc] initWithCoorDinate:place.location.coordinate title:place.name subTitle:place.locality information:place.locality];
                //                                 //将大头针加入到地图
                //                                 [_map addAnnotation:annotation];
                [self.dataArray removeAllObjects];
                [self.dataArray addObject:place];
                _placetab.hidden = NO;
                [_placetab reloadData];
               
                
                
                
            }
            
        }else {
            
            NSLog(@"正向地理编码解析失败");
        }
        
    }];
    
}
-(void)startLocation{
    
    if ([CLLocationManager locationServicesEnabled]) {//判断定位操作是否被允许
        
        self.locationManager = [[CLLocationManager alloc] init];
        
        self.locationManager.delegate = self;//遵循代理
        
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        
        self.locationManager.distanceFilter = 10.0f;
        
        [_locationManager requestWhenInUseAuthorization];//使用程序其间允许访问位置数据（iOS8以上版本定位需要）
        
        [self.locationManager startUpdatingLocation];//开始定位
        
    }else{//不能定位用户的位置的情况再次进行判断，并给与用户提示
        
        //1.提醒用户检查当前的网络状况
        
        //2.提醒用户打开定位开关
        
    }
    
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations{
    
    //当前所在城市的坐标值
    CLLocation *currLocation = [locations lastObject];
    NSLog(@"经度=%f 纬度=%f 高度=%f", currLocation.coordinate.latitude, currLocation.coordinate.longitude, currLocation.altitude);
    
    //根据经纬度反向地理编译出地址信息
    CLGeocoder * geoCoder = [[CLGeocoder alloc] init];
    
    [geoCoder reverseGeocodeLocation:currLocation completionHandler:^(NSArray *placemarks, NSError *error) {
        
        for (CLPlacemark * placemark in placemarks) {
            
            NSDictionary *address = [placemark addressDictionary];
            
            //  Country(国家)  State(省)  City（市）
            NSLog(@"#####%@",address);
            
            NSLog(@"%@", [address objectForKey:@"Country"]);
            
            NSLog(@"%@", [address objectForKey:@"State"]);
            
            NSLog(@"%@", [address objectForKey:@"City"]);
            
            
        }
        
    }];
    
}

-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error{
    
    if ([error code] == kCLErrorDenied){
        //访问被拒绝
    }
    if ([error code] == kCLErrorLocationUnknown) {
        //无法获取位置信息
    }
}
- (IBAction)jumpMap:(UIButton *)sender {
    //这个判断其实是不需要的
    
    if ( [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"http://maps.apple.com/"]]){
        
        //MKMapItem 使用场景: 1. 跳转原生地图 2.计算线路
        
        MKMapItem *currentLocation = [MKMapItem mapItemForCurrentLocation];
        
        
        
        //地理编码器
        
        CLGeocoder *geocoder = [[CLGeocoder alloc] init];
        
        //我们假定一个终点坐标，上海嘉定伊宁路2000号报名大厅:121.229296,31.336956
        
        [geocoder geocodeAddressString:@"北京市清华科技园" completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
            
            CLPlacemark *endPlacemark  = placemarks.lastObject;
            
            
            
            //创建一个地图的地标对象
            
            MKPlacemark *endMKPlacemark = [[MKPlacemark alloc] initWithPlacemark:endPlacemark];
            
            //在地图上标注一个点(终点)
            
            MKMapItem *endMapItem = [[MKMapItem alloc] initWithPlacemark:endMKPlacemark];
            
            
            
            //MKLaunchOptionsDirectionsModeKey 指定导航模式
            
            //NSString * const MKLaunchOptionsDirectionsModeDriving; 驾车
            
            //NSString * const MKLaunchOptionsDirectionsModeWalking; 步行
            
            //NSString * const MKLaunchOptionsDirectionsModeTransit; 公交
            
            [MKMapItem openMapsWithItems:@[currentLocation, endMapItem]
             
                           launchOptions:@{MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving,MKLaunchOptionsShowsTrafficKey: [NSNumber numberWithBool:YES]}];
            
            
            
        }];
        
    }
}

//每次调用，都会把用户的最新位置（userLocation参数）传进来
- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation{
    
}
- (void)mapView:(MKMapView *)mapView regionWillChangeAnimated:(BOOL)animated{
    
    //    JKAnnotation *anno = [[JKAnnotation alloc] init];
    //    anno.title = @"我是一个大头针";
    //    anno.subtitle = @"我有一个小弟叫小头";
    //    anno.coordinate = CLLocationCoordinate2DMake(mapView.centerCoordinate.latitude, mapView.centerCoordinate.longitude);
    //    [mapView addAnnotation:anno];
    
    CLLocation *currLocation = [[CLLocation alloc]initWithLatitude:mapView.centerCoordinate.latitude longitude:mapView.centerCoordinate.longitude];
    [_geoCoder reverseGeocodeLocation:currLocation completionHandler:^(NSArray *placemarks, NSError *error) {
        
        for (CLPlacemark * placemark in placemarks) {
            
            NSDictionary *address = [placemark addressDictionary];
            _addressLabel.text = [address objectForKey:@"Name"];
            NSLog(@"%@", [address objectForKey:@"Name"]);
        }
        
    }];
    
    NSLog(@"------%f",mapView.centerCoordinate.latitude);
}


// 已经添加了大头针模型,还没有完全渲染出来之前(mapView的代理)
- (void)mapView:(MKMapView *)mapView didAddAnnotationViews:(NSArray<MKAnnotationView *> *)views{
    for (MKAnnotationView *annotationView in views) {
        //目标位置
        CGRect targetRect = annotationView.frame;
        //先让其在最顶上
        annotationView.frame = CGRectMake(targetRect.origin.x, 0, targetRect.size.width, targetRect.size.height);
        //最后通过动画展示到最终的目标地方
        [UIView animateWithDuration:0.3 animations:^{
            annotationView.frame = targetRect;
        }];
    }
}//如果不要这种效果这段代码也可以不需要


// 大头针视图的重用,大头针也存在着重用的机制,方便优化内存
// 每次添加大头针都会调用此方法  可以设置大头针的样式
- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation{
    // 判断大头针位置是否在原点,如果是则不加大头针或者添加属于自己特殊图标
    if ([annotation isKindOfClass:[MKUserLocation class]]) { return nil; }
    //1.定义一个可重用标识符
    static NSString *reuseIdentifier = @"mapView";
    MKAnnotationView *annotationView = (MKAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:reuseIdentifier];
    if (annotationView == nil) {
        annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
    }
    
    //设置可重用标识符的相关属性
    // 显示标题和副标题
    annotationView.canShowCallout = YES;
    // 设置图片(用户头像,或者商品/超市/汽车/单车等等图片)
    annotationView.image = [UIImage imageNamed:@"header_new"];
    //须导入#import "UIImageView+WebCache.h"头文件
    // [annotationView.image sd_setImageWithURL:[NSURL URLWithString:[dict valueForKey:@"icon"]] placeholderImage:[UIImage imageNamed:@"默认图片"]];
    
    
    return annotationView;
    
    // 判断大头针位置是否在原点,如果是则不加大头针
    //    if([annotation isKindOfClass:[mapView.userLocation class]]){
    //        return nil;
    //    }
    //    //设置自定义大头针
    //    JKAnnotationView *annotationView = (JKAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:@"otherAnnotationView"];
    //    if (annotationView == nil) {
    //        annotationView = [[JKAnnotationView alloc]initWithAnnotation:annotation reuseIdentifier:@"otherAnnotationView"];
    //    }
    //    annotationView.image = [UIImage imageNamed:@"header_new"];
    
    //  return annotationView;
}


#pragma mark----------UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataArray.count;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    CLPlacemark *place = self.dataArray[indexPath.row];
    cell.textLabel.text = place.name;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    tableView.hidden = YES;
    CLPlacemark *place = self.dataArray[indexPath.row];
    JKAnnotation *anno = [[JKAnnotation alloc] init];
    anno.title = place.name;
    anno.coordinate = place.location.coordinate;
    [_map addAnnotation:anno];
    [_map setCenterCoordinate:place.location.coordinate];
}
@end
