# TCParallax
**写在前面:**



Parallax scrolling effect on UITableView header view when a tableView is scrolled

## 使用

~~~Pod
platform :ios, ‘8.0’ 
use_frameworks!
target "TCParallaxExample" do
	pod 'TCParallax'
end
~~~



# API

```
 ///  创建一个只有一张图片的headerView
 ///
 ///  - parameter image:     要展示的图片
 ///  - parameter forSize:   view大xiao
 ///  - parameter referView: 依赖view(headerView会依赖于这个view形变)
static func creatParallaxScrollViewWithImage(image:UIImage,forSize:CGSize,referView:UITableView?) -> ParallaxScrollView 

 ///  将一个view改造成ParallaxView
 ///
 ///  - parameter subView:   view
 ///  - parameter referView: 依赖view(headerView会依赖于这个view形变)
static func creatParallaxScrollViewWithSubView(subView:UIView,referView:UITableView) -> ParallaxScrollView 
```



# 使用

## Swift

```swift
let headerView = ParallaxScrollView.creatParallaxScrollViewWithImage(UIImage(named: "imageDemo.jpg")!, forSize: CGSize(width: tableView.bounds.width, height: 300),referView: tableView) 
tableView.tableHeaderView = headerView
```
## Object-C

```Objective-C
- (UITableView *)tableView{
    if (!_tableView) {
        _tableView = [[UITableView alloc]initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
        _tableView.tableHeaderView = [ParallaxScrollView creatParallaxScrollViewWithSubView:self.headerView referView:_tableView];
        _tableView.backgroundColor = [UIColor whiteColor];
        _tableView.rowHeight = 45;
        _tableView.delegate = self;
        _tableView.dataSource = self;
    }
    return _tableView;
}
- (EditeUserHeaderView *)headerView{
    if (!_headerView) {
        _headerView = [[EditeUserHeaderView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, 167)];
        _headerView.backgroundColor = Color(@"#040406");
        _headerView.delegate = self;
         _headerView.user = self.user;
    }
    return _headerView;
}
```

![solarized vim](./演示.gif)

