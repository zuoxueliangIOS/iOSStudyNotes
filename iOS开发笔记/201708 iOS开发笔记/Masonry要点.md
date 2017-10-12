#iOS Masonry 更新要点

##1.更新方法

AutoLayout方法 | 方法说明
---------- | -------------
setNeedsLayout | 告知页面需要更新，不会立即更新，执行后会调用，loyoutSubviews
layoutIfNeeded | 告知页面布局立即更新，一般会和setNeedsLayout一起使用
layoutSubviews | 系统重写布局
setNeedsUpdateConstraints | 告知需要更新约束，不会立即执行
updateConstraintsIfNeeded | 告知立刻更新约束
updateConstraints | 系统更新约束

##2.设置全局 宏
* #define MAS_SHORTHAND_GLOBALS  使用全局宏定义，可以使equalTo等效于mas_equalTo
* #define MAS_SHORTHAND  使用全局宏定义, 可以在调用masonry方法的时候不使用mas_前缀

##3.基本使用
* mas_makeConstraints:添加约束
* mas_updateConstraints：更新约束、亦可添加新约束
* mas_remakeConstraints：重置之前的约束

##4.重要属性
 * multipler属性表示约束值为约束对象的乘因数
 * dividedBy属性表示约束值为约束对象的除因数，可用于设置view的宽高比
 * priorityLow()设置约束优先级
 
 ```
[self.topView addSubview:self.topInnerView];
    [self.topInnerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(self.topView.mas_height).dividedBy(3);
        make.width.and.height.lessThanOrEqualTo(self.topView);
        make.width.and.height.equalTo(self.topView).with.priorityLow();
        make.center.equalTo(self.topView);
    }];
 ```
##5.新方法：2个或2个以上的控件等间隔排序
```
/**
 *  多个控件固定间隔的等间隔排列，变化的是控件的长度或者宽度值
 *
 *  @param axisType        轴线方向
 *  @param fixedSpacing    间隔大小
 *  @param leadSpacing     头部间隔
 *  @param tailSpacing     尾部间隔
 */
 ```
 ```
- (void)mas_distributeViewsAlongAxis:(MASAxisType)axisType 
                    withFixedSpacing:(CGFloat)fixedSpacing l
                          eadSpacing:(CGFloat)leadSpacing 
                         tailSpacing:(CGFloat)tailSpacing;
```
```
/**
 *  多个固定大小的控件的等间隔排列,变化的是间隔的空隙
 *
 *  @param axisType        轴线方向
 *  @param fixedItemLength 每个控件的固定长度或者宽度值
 *  @param leadSpacing     头部间隔
 *  @param tailSpacing     尾部间隔
 */
 ```
 ```
- (void)mas_distributeViewsAlongAxis:(MASAxisType)axisType 
                 withFixedItemLength:(CGFloat)fixedItemLength 
                         leadSpacing:(CGFloat)leadSpacing 
                         tailSpacing:(CGFloat)tailSpacing;
                         ```
                         ```
使用方法很简单，因为它是NSArray的类扩展：
//  创建水平排列图标 arr中放置了2个或连个以上的初始化后的控件
//  alongAxis 轴线方向   固定间隔     头部间隔      尾部间隔
[arr mas_distributeViewsAlongAxis:MASAxisTypeHorizontal withFixedSpacing:20 leadSpacing:5 tailSpacing:5];
[arr makeConstraints:^(MASConstraintMaker *make) {
       make.top.equalTo(@60);
       make.height.equalTo(@60);
}];
```
##6.使用动画更新约束
```
如果想要约束变换之后实现动画效果，则需要执行如下操作
// 通知需要更新约束，但是不立即执行
[self setNeedsUpdateConstraints];
// 立即更新约束，以执行动态变换
// update constraints now so we can animate the change
[self updateConstraintsIfNeeded];
// 执行动画效果, 设置动画时间
[UIView animateWithDuration:0.4 animations:^{
     [self layoutIfNeeded];
}];
```
##7.多行Label 适配
```
preferredMaxLayoutWidth: 多行label的约束问题
// 已经确认好了位置
// 在layoutSubviews中确认label的preferredMaxLayoutWidth值
- (void)layoutSubviews {
    [super layoutSubviews];
    // 你必须在 [super layoutSubviews] 调用之后，longLabel的frame有值之后设置preferredMaxLayoutWidth
    self.longLabel.preferredMaxLayoutWidth = self.frame.size.width-100;
    // 设置preferredLayoutWidth后，需要重新布局
    [super layoutSubviews];
}
```
##8.scrollview适配
```
scrollView使用约束的问题：原理通过一个contentView来约束scrollView的contentSize大小，也就是说以子控件的约束条件，来控制父视图的大小
// 1. 控制scrollView大小（显示区域）
[self.scrollView makeConstraints:^(MASConstraintMaker *make) {
     make.edges.equalTo(self.view);
}];
// 2. 添加一个contentView到scrollView，并且添加好约束条件
[contentView makeConstraints:^(MASConstraintMaker *make) {
     make.edges.equalTo(self.scrollView);
     // 注意到此处的宽度约束条件，这个宽度的约束条件是比添加项
     make.width.equalTo(self.scrollView);
}];
// 3. 对contentView的子控件做好约束，达到可以控制contentView的大小
```

##9.自动计算UITableviewCell高度

```
推荐使用一个库UITableView-FDTemplateLayoutCell
想法：动态高度的cell, 主要关注的点是什么？
viewController本身不需要知道cell的类型
cell的高度与viewController没有相关性，cell的高度由cell本身来决定
viewController真正做到的是一个
以下是摘抄过来的
主要是UILabel的高度会有变化，所以这里主要是说说label变化时如何处理，设置UILabel的时候注意要设置 preferredMaxLayoutWidth这个宽度，还有ContentHuggingPriority为 UILayoutPriorityRequried

CGFloat maxWidth = [UIScreen mainScreen].bounds.size.width - 10 * 2;

textLabel = [UILabel new];
textLabel.numberOfLines = 0;
textLabel.preferredMaxLayoutWidth = maxWidth;
[self.contentView addSubview:textLabel];

[textLabel mas_makeConstraints:^(MASConstraintMaker *make) {
    make.top.equalTo(statusView.mas_bottom).with.offset(10);
    make.left.equalTo(self.contentView).with.offset(10);
    make.right.equalTo(self.contentView).with.offset(-10);
    make.bottom.equalTo(self.contentView).with.offset(-10);
}];

[_contentLabel setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
如果版本支持最低版本为iOS 8以上的话可以直接利用UITableViewAutomaticDimension在tableview的heightForRowAtIndexPath直接返回即可。

tableView.rowHeight = UITableViewAutomaticDimension;
tableView.estimatedRowHeight = 80; //减少第一次计算量，iOS7后支持

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    // 只用返回这个！
    return UITableViewAutomaticDimension;
}
```

