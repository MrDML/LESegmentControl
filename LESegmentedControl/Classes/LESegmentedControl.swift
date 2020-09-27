//
//  LESegmentedControl.swift
//  LESegmentControl
//
//  Created by leon on 2020/9/24.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

 @objc public protocol LESegmentedControlDelegate {
    
    
    /// 数据源
    /// - Parameter segmentedControl: segmentedControl description
    func numberOfTitles(in segmentedControl:LESegmentedControl) -> [Any];
    
    /// 扩展响应区域
    /// - Parameters:
    ///   - segmentedControl: segmentedControl description
    ///   - inset: inset description
    @objc optional func enlargeEdgeInset(segmentedControl: LESegmentedControl) -> UIEdgeInsets
    
    /// segment内间距扩展
    /// - Parameters:
    ///   - segmentedControl: segmentedControl description
    ///   - inset: inset description
    @objc optional  func segmentEdgeInset(segmentedControl: LESegmentedControl)->UIEdgeInsets
    
    /// 指示器:box
    /// - Parameter segmentedControl: segmentedControl description
    @objc optional  func selectionBoxIndicatorEdgeInset(segmentedControl: LESegmentedControl)->UIEdgeInsets
    
    
    /// 指示器:条纹
    /// - Parameter segmentedControl: segmentedControl description
    @objc optional  func  selectionStripeIndicatorEdgeInset(segmentedControl: LESegmentedControl)->UIEdgeInsets

    /// 设置选中Segment标题背景色和字体大小
    /// - Parameter segmentedControl: segmentedControl description
    @objc optional func selectSegmentAttributes(segmentedControl: LESegmentedControl) -> [NSAttributedString.Key:Any]?

    /// 设置未选中Segment标题背景色和字体大小
    /// - Parameter segmentedControl: segmentedControl description
    @objc optional func noSelectSegmentAttributes(segmentedControl: LESegmentedControl) -> [NSAttributedString.Key:Any]?

    ///  选中
    /// - Parameters:
    ///   - segment: segment description
    ///   - didSelectRowAtIndex: didSelectRowAtIndex description
    @objc optional func segmented(segment:LESegmentedControl,didSelectRowAtIndex index:Int);
    
}

import UIKit
@objc public class LESegmentedControl: UIControl,UIScrollViewDelegate {

    public weak var delefate:LESegmentedControlDelegate? = nil;
    // 扩大点击区域
    private var enlargeEdgeInset:UIEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    // 对segment内间距的扩展
    private var segmentEdgeInset:UIEdgeInsets = UIEdgeInsets(top: 0, left: 30, bottom: 0, right:30)
    /// box外边距
    private var selectionBoxIndicatorEdgeInset:UIEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right:10)
    
    private var selectionStripeIndicatorEdgeInset:UIEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    // 选中索引
    private var selectSegmentIndex:Int = 0
    // 数据源
    private var sectionTitles:[Any] = [Any]();
    
    private var sectionBoxLayers:[CAShapeLayer] = [CAShapeLayer]();
    
    /// box 透明度
    private var selectionIndicatorBoxOpacity: CGFloat = 1
    
    /// box 背景颜色
    private var selectionIndicatorBoxColor:UIColor? = UIColor.black
    
    /// box 透明度
    private var selectionIndicatorStripeOpacity: CGFloat = 1
    
    /// box 背景颜色
    private var selectionIndicatorStripeColor:UIColor? = UIColor.black
    
    
    /// 设置透明度
   @objc public var selectionIndicatorOpacity: CGFloat{
        get{
            var val:CGFloat = 0
            switch selectionStyle {
            case .box:
                val = selectionIndicatorBoxOpacity
                break
            case .stripe:
                val = selectionIndicatorStripeOpacity
                break
            }
            return val
        }
        set{
            switch selectionStyle {
            case .box:
                selectionIndicatorBoxOpacity = newValue
                break
            case .stripe:
                selectionIndicatorStripeOpacity = newValue
                break

            }
        }
    }
    
    /// 设置背景色
    public var selectionIndicatorBackgroundColor: UIColor? {
    
        get{
            var val:UIColor? = UIColor.black
            switch selectionStyle {
            case .box:
                val = selectionIndicatorBoxColor
                break
            case .stripe:
                val = selectionIndicatorStripeColor
                break
            }
            return val
        }
        
        set{
            switch selectionStyle {
            case .box:
                selectionIndicatorBoxColor = newValue
                break
            case .stripe:
                selectionIndicatorStripeColor = newValue
                break
            }
        }
    }

    // segment 宽度
    private var segmentWidth:CGFloat = 0;
    // segment总数
    private var sectionCount:Int {
        return self.sectionTitles.count
    }
    
    /// 设置segment 类型是固定宽度/动态宽度 默认是固定宽度
    public var style:Style = .fix
    
    /// 选中指示器样式
    public var selectionStyle:SelectionStyle = .box
    
    /// 是否允许选中动画
    public var shouldAnimateUserSelection:Bool = true
    
    /// 保存segment动态宽度
    private var segmentWidthsArray:[CGFloat] = [CGFloat]()
    
    /// 是否允许拖拽滚动
    public var isScrollEnabled:Bool = false;
    
   private lazy var scrollView: UIScrollView = {
        let scrollView = LEScrollView()
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        return scrollView
    }()
    
    /// 是否允许拖拽 默认 true
    public var isUserDraggable:Bool = false
    
    /// 是否允许伸展到屏幕 默认 true
    public var shouldStretchSegmentsToScreenSize = true
    
    /// boxt指示器
    lazy var selectionIndicatorBoxLayer:CALayer = {
        let layer = CALayer()
        return layer
    }()
    
    /// Stripe指示器
    lazy var selectionIndicatorStripeLayer:CALayer = {
        let layer = CALayer()
        return layer
    }()
    
    /// 横条指示器默认高度
    public var selectionIndicatorStripeLayerHeight:CGFloat = 1
    
    
    public override init(frame: CGRect) {
        super.init(frame: frame)

        initDefaltValue()

    }
    
    public init(frame: CGRect,style: Style) {
        super.init(frame: frame)
        self.style = style
        initDefaltValue()
    }

    private init() {
        super.init(frame: CGRect.zero)
        initDefaltValue()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    private func initDefaltValue(){
        self.backgroundColor = UIColor.white
        self.scrollView.delegate = self
        self.addSubview(self.scrollView)
    }

    public override func layoutSubviews() {
        super.layoutSubviews()
        // 更新
        updateSegmentsRects()
    }

    /// 更新segment位置
    func updateSegmentsRects(){
        
        // 设置ScrollView
        setScrollViewContentInsetAndFrame()
        // 计算segment默认宽度
        if self.sectionCount > 0 {
            self.segmentWidth = self.frame.size.width / CGFloat(self.sectionCount)
        }
        // 更新
        switch style {
        case .fix:
            updateSegmentFixStyleWidth()
            break
        case .dynamic:
            updateSegmentDynamicStyleWidth()
            break
        }
        // 更新ScrollView内容size以及是否允许拖拽
        setScrollViewEnabledAndSize()
    }
    
    
    /// 更新固定Width
    private func updateSegmentFixStyleWidth(){
        
        for (i,_) in self.sectionTitles.enumerated() {
            let  titleWidth = self.calculateSectionTitleSizeAtIndex(index: i).width + self.segmentEdgeInset.left + self.segmentEdgeInset.right
            // 以最大标题宽度为准座位固定宽度
            self.segmentWidth = max(titleWidth, self.segmentWidth);
        }
    }
    
    /// 更新动态Width
    private func updateSegmentDynamicStyleWidth(){
        
        var totalWidth: CGFloat = 0
        var mutableTitleWidths:[CGFloat] = [CGFloat]()
        segmentWidthsArray.removeAll()
        for (i,_) in self.sectionTitles.enumerated() {
            let titleWidth = self.calculateSectionTitleSizeAtIndex(index: i).width + self.segmentEdgeInset.left + self.segmentEdgeInset.right
            totalWidth += titleWidth
            // 将标题动态宽度存入可变数组
            mutableTitleWidths.append(titleWidth)
        }
        // 根据 totalWidth 和  self.bounds.size.width 对标题进行伸展调整 扩展到整个屏幕
        if self.shouldStretchSegmentsToScreenSize == true {
            mutableTitleWidths =  stretchFixSegmentDynamicWidthToScreenSzie(totalWidth: totalWidth,titleWidths: mutableTitleWidths)
        }
        segmentWidthsArray = mutableTitleWidths
        
    }
    
    /// 伸展修改动态segment的宽度 达到整个屏幕的宽度
    func stretchFixSegmentDynamicWidthToScreenSzie(totalWidth:CGFloat,titleWidths:[CGFloat])->[CGFloat]{
        
        if self.bounds.size.width <= totalWidth {
            return titleWidths
        }
        let whiteSpace = (self.bounds.size.width - totalWidth) / CGFloat(titleWidths.count)
        let whitespaceForSegment = whiteSpace / CGFloat(titleWidths.count)
        let res = titleWidths.map { width -> CGFloat in
           return width + whitespaceForSegment
        }
        return res
    }
    
    
    /// 更新ScrollView ContentInset 和 frame
    func setScrollViewContentInsetAndFrame(){
        self.scrollView.contentInset = UIEdgeInsets.zero;
        self.scrollView.frame = CGRect(x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.height);
    }
    
    func setScrollViewEnabledAndSize(){
        self.scrollView.isScrollEnabled = isScrollEnabled
        // 更新内容视图
        self.scrollView.contentSize = CGSize(width: totalSegmentControlWidth(), height: self.frame.size.height);
    }
    
    
    func totalSegmentControlWidth()->CGFloat{
        
        var totalWidth:CGFloat = 0
        switch style {
        case .fix:
            totalWidth = CGFloat(self.sectionTitles.count) * self.segmentWidth
            break
        case .dynamic:
            totalWidth = self.segmentWidthsArray.reduce(0, +)
//            self.segmentWidthsArray.reduce(0) { (a, b) -> CGFloat in
//                return a + b
//            }
//            self.segmentWidthsArray.reduce(0) {
//                return $0 + $1
//            }
            break
        }
        return totalWidth
    }
    
    // MARK: -刷新数据源
   public func reloadData(){
    self.sectionTitles = self.delefate?.numberOfTitles(in: self) ?? []
    self.segmentEdgeInset = self.delefate?.segmentEdgeInset?(segmentedControl: self) ?? UIEdgeInsets(top: 0, left: 30, bottom: 0, right:30)
    self.enlargeEdgeInset = self.delefate?.enlargeEdgeInset?(segmentedControl: self) ?? UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    self.selectionBoxIndicatorEdgeInset = self.delefate?.selectionBoxIndicatorEdgeInset?(segmentedControl: self) ?? UIEdgeInsets(top: 10, left: 10, bottom: 10, right:10)
    self.selectionStripeIndicatorEdgeInset = self.delefate?.selectionStripeIndicatorEdgeInset?(segmentedControl: self) ?? UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    setNeedsLayout()
    setNeedsDisplay()
    }
    
    
    public override func draw(_ rect: CGRect) {
        // 绘制父视图背景色
        drawSuperViewBackground()
       // 移除父视图已存在的所有视图  Remove all sublayers to avoid drawing images over existing ones
        removeSubViewLayers()
        // 绘制标题
        drawText(oldRect: rect)
        // 绘制指示器
        drawSectionIndicator()
    }
    
    
    /// 绘制指示器
    func drawSectionIndicator(){
        if  self.selectSegmentIndex >= 0 {
            switch selectionStyle {
            case .box:
                addSectionBoxLayerAndSetFrame()
                self.scrollView.layer.insertSublayer(self.selectionIndicatorBoxLayer, at: 0)
                break
            case .stripe:
                self.selectionIndicatorStripeLayer.frame = frameIndicatorStripeLayer()
                self.selectionIndicatorStripeLayer.backgroundColor = self.selectionIndicatorStripeColor?.cgColor
                self.scrollView.layer.insertSublayer(self.selectionIndicatorStripeLayer, at: 0)
                break
            }
        }
    }
    
    
    func frameIndicatorStripeLayer() -> CGRect{
        
        var rect: CGRect = CGRect.zero
        switch style {
        case .fix:
            
            let titleSize = self.calculateSectionTitleSizeAtIndex(index: self.selectSegmentIndex)
            let stringWidth = titleSize.width;
            let startX = self.segmentWidth * CGFloat(self.selectSegmentIndex)
            let endX = self.segmentWidth * CGFloat(self.selectSegmentIndex) + self.segmentWidth
            let middle = (endX - startX) * 0.5
            let x = startX + middle - stringWidth * 0.5
            let y = self.frame.size.height - selectionIndicatorStripeLayerHeight
            rect = CGRect(x: x + selectionStripeIndicatorEdgeInset.left, y:y , width: stringWidth - selectionStripeIndicatorEdgeInset.right - selectionStripeIndicatorEdgeInset.left, height: selectionIndicatorStripeLayerHeight);

            break
            
        case .dynamic:
            
            var selectedSegmentOffset:CGFloat = 0
            var i = 0
            for width in self.segmentWidthsArray {
                if i == self.selectSegmentIndex {
                    break
                }
                selectedSegmentOffset = selectedSegmentOffset + width
                i += 1
            }
            let y = self.frame.size.height - selectionIndicatorStripeLayerHeight
            let x = selectedSegmentOffset + self.segmentEdgeInset.left
            let width  = self.segmentWidthsArray[self.selectSegmentIndex] - segmentEdgeInset.left - segmentEdgeInset.right
            rect = CGRect(x: x + selectionStripeIndicatorEdgeInset.left , y:y , width: width - selectionStripeIndicatorEdgeInset.right - selectionStripeIndicatorEdgeInset.left, height: selectionIndicatorStripeLayerHeight);
            break
        }
        
        return rect
    }
    
    
    /// 绘制标题
    private func drawText(oldRect:CGRect){
        removeSectionBoxLayerFromSuperViewLayer()
        for (i,_) in self.sectionTitles.enumerated() {
            // 计算标题size
            let titleSize = calculateSectionTitleSizeAtIndex(index: i);
            
            var resultRect: (textRect: CGRect, rectDiv: CGRect, fullRect: CGRect) = (CGRect.zero,CGRect.zero,CGRect.zero)
            // 计算每一个Segment具体的rect
            switch style {
            case .fix:
                resultRect = getFixSegmentSubLayersRect(index: i, titleSize: titleSize, oldRect: oldRect)
                break
            case .dynamic:
                resultRect = getDynamicSegmentSubLayersRect(index: i, titleSize: titleSize, oldRect: oldRect)
                break
            }

            // 创建标题
            let textLayer =  createTextLayer(index: i, rect:  resultRect.textRect)
            // 添加到父视图
            self.scrollView.layer.addSublayer(textLayer)
        
        }
    }

    /// 移除boxlayer指示器
    func removeSectionBoxLayerFromSuperViewLayer(){
        for layer  in sectionBoxLayers  {
            layer.removeFromSuperlayer()
        }
        sectionBoxLayers.removeAll()
    }

    /// 添加指示器设置frame
    func addSectionBoxLayerAndSetFrame(){
        self.selectionIndicatorBoxLayer.frame = frameForBoxSelectionIndicator()
        self.selectionIndicatorBoxLayer.backgroundColor = UIColor.clear.cgColor
        let cirnerRadi:CGSize = CGSize(width: self.selectionIndicatorBoxLayer.frame.size.height * 0.5, height:  self.selectionIndicatorBoxLayer.frame.size.height * 0.5)
        let path = UIBezierPath(roundedRect: self.selectionIndicatorBoxLayer.bounds, byRoundingCorners: .allCorners, cornerRadii: cirnerRadi)
        let maskLayer = CAShapeLayer()
        maskLayer.frame = self.selectionIndicatorBoxLayer.bounds
        maskLayer.path = path.cgPath;
        maskLayer.fillColor = selectionIndicatorBoxColor?.cgColor
        maskLayer.backgroundColor = UIColor.clear.cgColor
        maskLayer.actions = ["position":NSNull()]
        maskLayer.opacity = Float(self.selectionIndicatorBoxOpacity)
  
        sectionBoxLayers.append(maskLayer)
        self.selectionIndicatorBoxLayer.addSublayer(maskLayer)
    }
    

    /// box 背景frame
    /// - Returns: description
    func frameForBoxSelectionIndicator() -> CGRect{
        var rect:CGRect = CGRect.zero
        switch style {
        case .fix:
//            rect = CGRect(x: self.segmentWidth * CGFloat(self.selectSegmentIndex) , y: 0, width: self.segmentWidth , height:self.frame.size.height)
            rect = CGRect(x: self.segmentWidth * CGFloat(self.selectSegmentIndex) + selectionBoxIndicatorEdgeInset.left , y: selectionBoxIndicatorEdgeInset.top, width: self.segmentWidth - selectionBoxIndicatorEdgeInset.left - selectionBoxIndicatorEdgeInset.right, height:self.frame.size.height - selectionBoxIndicatorEdgeInset.top - selectionBoxIndicatorEdgeInset.bottom)
            break
        case .dynamic:
            var index:Int = 0
            var selectedSegmentOffset:CGFloat = 0
            for width in self.segmentWidthsArray {
                if self.selectSegmentIndex == index {
                    break
                }
                selectedSegmentOffset += width;
                index += 1
            }
            // 获取对应的宽度
            let widthForIndex = self.segmentWidthsArray[self.selectSegmentIndex]
            
//            rect = CGRect(x: selectedSegmentOffset, y: 0, width: widthForIndex, height: self.frame.size.height)
            
            rect = CGRect(x: selectedSegmentOffset + selectionBoxIndicatorEdgeInset.left , y: selectionBoxIndicatorEdgeInset.top, width: widthForIndex  - selectionBoxIndicatorEdgeInset.left - selectionBoxIndicatorEdgeInset.right, height: self.frame.size.height - selectionBoxIndicatorEdgeInset.top - selectionBoxIndicatorEdgeInset.bottom)
            
            break

        }
        return rect
    }
    
    
    
    /// 动态宽度下 单个section相关视图的rect
    /// - Parameters:
    ///   - index: index description
    ///   - titleSize: titleSize description
    ///   - oldRect: oldRect description
    /// - Returns: description
    func getDynamicSegmentSubLayersRect(index:Int,titleSize:CGSize,oldRect:CGRect) -> (textRect:CGRect,rectDiv:CGRect,fullRect:CGRect){
        // 创建元祖
        var rects = (textRect:CGRect.zero,rectDiv:CGRect.zero,fullRect:CGRect.zero)
        
        let titleHeight = titleSize.height
        
        let y = (self.frame.size.height * 0.5) - (titleHeight * 0.5)
        
        var xOffset:CGFloat = 0
        
        var i = 0
        
        for width in self.segmentWidthsArray {
            if index == i {//  标题索引和宽度索引对应，找到break
                break
            }
            xOffset = xOffset + width
            i = i + 1
        }
        
        // 获取对应的宽度
        let widthForIndex = self.segmentWidthsArray[index]
        
        rects.textRect = CGRect(x: xOffset, y: y, width: widthForIndex, height: titleHeight)

        rects.fullRect = CGRect(x: xOffset, y: 0, width: widthForIndex, height: oldRect.height)
        rects.rectDiv = CGRect.zero
        return rects
        
    }
    
    
    /// 固定宽度下 单个section相关视图的rect
    /// - Parameters:
    ///   - index: index description
    ///   - titleSize: titleSize description
    ///   - oldRect: oldRect description
    /// - Returns: description
    func getFixSegmentSubLayersRect(index:Int,titleSize:CGSize,oldRect:CGRect) -> (textRect:CGRect,rectDiv:CGRect,fullRect:CGRect){
        
        // 创建元祖
        var rects = (textRect:CGRect.zero,rectDiv:CGRect.zero,fullRect:CGRect.zero)
        
        let titleWidth = titleSize.width
        
        let titleHeight = titleSize.height

        // 计算x位置 self.segmentWidth = 标题的实际宽度 + 扩展宽度
        // self.segmentWidth * CGFloat(index) + (self.segmentWidth - titleWidth) * 0.5
        let x = self.segmentWidth * CGFloat(index) + (self.segmentWidth - titleWidth) * 0.5
        
        let y = (self.frame.size.height * 0.5) - (titleHeight * 0.5)

        // 计算标题rect
        rects.textRect = CGRect(x: x, y: y, width: titleWidth, height: titleHeight)

        // 计算分割rect
        rects.rectDiv = CGRect.zero
        // 计算整个外围的边框
        rects.fullRect = CGRect(x: self.segmentWidth * CGFloat(index), y: 0, width: self.segmentWidth, height:oldRect.height)
        //rects.fullRect = CGRect(x: x, y: 0, width: titleWidth, height:oldRect.height)
        
        return rects
        
    }
    
    
    
    /// 创建单个文本视图
    /// - Parameters:
    ///   - index: 索引位置
    ///   - rect: 视图位置
    /// - Returns: description
    private func createTextLayer(index:Int,rect:CGRect) -> CATextLayer{
        let textLayer = CATextLayer()
        textLayer.alignmentMode = kCAAlignmentCenter
        textLayer.contentsScale = UIScreen.main.scale
        let systemVersion = (UIDevice.current.systemVersion as NSString).floatValue
        if systemVersion < 10.0 {
            textLayer.truncationMode = kCATruncationEnd
        }
        textLayer.frame = rect
        textLayer.string = attributedTitleAtIndex(index: index)
        return textLayer
        
    }
    
    private func addBoxLayerAndBackground(fullRect:CGRect){
        let backgroundLayer = CALayer()
        backgroundLayer.frame = fullRect
        self.layer.insertSublayer(backgroundLayer, at: 0)
    }
   
    
    /// 绘制背景
   private func drawSuperViewBackground() {
        self.backgroundColor?.setFill()
        UIRectFill(self.bounds)
    }
    
    
    /// 移除子视图
    private func removeSubViewLayers(){
       self.scrollView.layer.sublayers = nil
    }
    
    
    
    /// 获取对应位置的标题
    /// - Parameter index: index description
    private func attributedTitleAtIndex(index:Int) -> NSAttributedString{
    
        // 获取标题
        let title = self.sectionTitles[index];
        // 判断是否是 NSAttributedString 类型，如果是直接返回
        if ((title as? NSAttributedString) != nil) {
            return title as! NSAttributedString
        }
        // 判断当前segment 是否选中
        let selected = (self.selectSegmentIndex == index) ? true : false
        // 获取文本属性
        let attributeds = selected == true ? selectSegmentAttributes() : noSelectSegmentAttributes()
        // 创建可变字符串
        let string = NSAttributedString.init(string: title as! String, attributes: attributeds)
        
        return string
    }
    
    
    /// 计算Title Size
    /// - Parameter index: 标题索引
    private func calculateSectionTitleSizeAtIndex(index:Int) -> CGSize{
        
        if index >= self.sectionTitles.count {  return CGSize.zero}
        // 获取标题
        let title = self.sectionTitles[index];
        // 标题size
        var size = CGSize.zero
        // 是否选中
        let select:Bool = index == self.selectSegmentIndex ? true : false
        // 对标题判空处理
        if (title as! String).isEmpty{return CGSize.zero}
        // 计算尺寸
        size = (title as! NSString) .boundingRect(with: CGSize(width: CGFloat(MAXFLOAT), height: CGFloat(MAXFLOAT)), options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: select == true ? selectSegmentAttributes():noSelectSegmentAttributes(), context: nil).size;
        return size
    }
    
    
    /// 选中Segment 样式
    /// - Returns: description
    private func selectSegmentAttributes() -> [NSAttributedString.Key:Any]{
        var res:[NSAttributedString.Key:Any]
        if let attributed = self.delefate?.selectSegmentAttributes?(segmentedControl: self) {
           res = attributed
        }else{
            res = [NSAttributedString.Key.foregroundColor:UIColor.white,NSAttributedString.Key.font:UIFont.systemFont(ofSize: 18)]
        }
        return res
    }
    
    
    /// 未选中Segment样式
    /// - Returns: description
    private func noSelectSegmentAttributes()-> [NSAttributedString.Key:Any]{
        
        var res:[NSAttributedString.Key:Any]
        
        if let attributed = self.delefate?.noSelectSegmentAttributes?(segmentedControl: self) {
            res = attributed
        }else{
            res = [NSAttributedString.Key.foregroundColor:UIColor.black,NSAttributedString.Key.font:UIFont.systemFont(ofSize: 18)]
        }
        return res;
    }

    
    public override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {

        super.touchesEnded(touches, with: event)
        // 获取点击位置
        guard let touchLocation =  touches.first?.location(in: self) else {return}
        // 扩大点击区域
        // 扩展区域
        let enlargeRect = CGRect(x: self.bounds.origin.x - enlargeEdgeInset.left,
                                 y: self.bounds.origin.y - enlargeEdgeInset.top,
                                 width: self.bounds.size.width + enlargeEdgeInset.left + enlargeEdgeInset.right,
                                 height: self.bounds.size.height + enlargeEdgeInset.top + enlargeEdgeInset.bottom)

        // 当前点击位置是否在响应区内
        if enlargeRect.contains(touchLocation) {
            // TODO: -计算点击位置以及动画
            var segment:NSInteger = 0

            switch style {
            case .fix:
                segment = NSInteger((touchLocation.x + self.scrollView.contentOffset.x) / self.segmentWidth)
                break
            case .dynamic:
                
                var widthLeft = touchLocation.x + self.scrollView.contentOffset.x
                
                for width in self.segmentWidthsArray {
                    //逐层递减
                    widthLeft = widthLeft - width
                    
                    if widthLeft <= 0 {
                        break
                    }
                    segment += 1
                }
                break
            }
            let sectionsCount:NSInteger = self.sectionTitles.count
            if segment < sectionsCount {
                setSelectSegmentIndex(index: segment, animated: shouldAnimateUserSelection, notify: true)
            }
        }
        
       

    }
    
    
    /// 设置选中segment 触发效果
    /// - Parameters:
    ///   - index: <#index description#>
    ///   - animated: <#animated description#>
    ///   - notify: <#notify description#>
    func setSelectSegmentIndex(index:Int,animated:Bool, notify:Bool){
        self.selectSegmentIndex = index
        // 重绘
        setNeedsDisplay()
        
        if index < 0 {
            self.selectionIndicatorBoxLayer.removeFromSuperlayer()
        }else{
            scrollToSelectedSegmentIndex(animated: animated)
            
            if animated == true {
                
                switch selectionStyle {
                case .box:
                    if self.selectionIndicatorBoxLayer.superlayer == nil {
                        self.scrollView.layer.insertSublayer(self.selectionIndicatorBoxLayer, at: 0)
                        setSelectSegmentIndex(index: index, animated: false, notify: true)
                        return
                    }
                    break
                case .stripe:
                    if self.selectionIndicatorStripeLayer.superlayer == nil {
                        self.scrollView.layer.insertSublayer(self.selectionIndicatorStripeLayer, at: 0)
                        setSelectSegmentIndex(index: index, animated: false, notify: true)
                        return
                    }
                    break
                }
                
                
                if notify == true {
                    notifyForSegmentChangeToIndex(index: index)
                }
                
                // Restore CALayer animations
                self.selectionIndicatorBoxLayer.actions = nil
                
                // Animate to new position
                CATransaction.begin()
                CATransaction.setAnimationDuration(0.15)
                CATransaction.setAnimationTimingFunction(CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear))
                
                switch selectionStyle {
                case .box:
                    self.selectionIndicatorBoxLayer.frame = frameForBoxSelectionIndicator()
                    break
                case .stripe:
                    self.selectionIndicatorStripeLayer.frame = frameForBoxSelectionIndicator()
                    break
                }

                CATransaction.commit()
                
            }else{
                
                // Disable CALayer animations
                let newActions = ["position":NSNull(),"bounds":NSNull()]
                self.selectionIndicatorBoxLayer.actions = newActions
                self.selectionIndicatorBoxLayer.frame = frameForBoxSelectionIndicator()
                if notify == true {
                    notifyForSegmentChangeToIndex(index: index)
                }
                
                
            }
        }
        
    }
    
    
    func scrollToSelectedSegmentIndex(animated:Bool){
        
        scrollTo(index: self.selectSegmentIndex, animated: animated)
    }
    
    func scrollTo(index:Int,animated:Bool){
        
        var rectForSelectedIndex:CGRect = CGRect.zero
        
        var selectedSegmentOffset:CGFloat = 0
        
        switch style {
        case .fix:
            rectForSelectedIndex = CGRect(x: self.segmentWidth * CGFloat(index), y: 0, width: self.segmentWidth, height: self.frame.size.height)
            selectedSegmentOffset = (self.frame.size.width - self.segmentWidth ) * 0.5
            break
        case .dynamic:
            var i = 0
            var xOffset:CGFloat = 0
            for width in self.segmentWidthsArray {
                if index == i {//  标题索引和宽度索引对应，找到break
                    break
                }
                xOffset = xOffset + width
                i = i + 1
            }
            // 获取对应的宽度
            let widthForIndex = self.segmentWidthsArray[index]
            
            rectForSelectedIndex = CGRect(x: xOffset, y: 0, width: widthForIndex, height: self.frame.size.height)
            selectedSegmentOffset = (self.frame.size.width - widthForIndex ) * 0.5
            
            break

        }
        var rectToScrollTo = rectForSelectedIndex
        rectToScrollTo.origin.x -= selectedSegmentOffset
        rectToScrollTo.size.width += selectedSegmentOffset * 2
        self.scrollView .scrollRectToVisible(rectToScrollTo, animated: animated)
    }

}


extension LESegmentedControl{
    
    func notifyForSegmentChangeToIndex(index:Int){
        if self.superview != nil {
            sendActions(for: .valueChanged)
        }
        // 回调
        self.delefate?.segmented?(segment: self, didSelectRowAtIndex: index)
    }
    
}



extension LESegmentedControl{
    
    public enum Style: Int{
        case fix = 0
        case dynamic = 1
    }
    
    public enum SelectionStyle: Int{
        case box = 0
        case stripe = 1
    }
}
