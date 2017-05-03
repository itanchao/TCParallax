//
//  ParallaxScrollView.swift
//  Parallaxscrollview
//
//  Created by tanchao on 16/4/20.
//  Copyright © 2016年 谈超. All rights reserved.
//
import UIKit
public class ParallaxScrollView: UIView {
    var headerImage:UIImage = UIImage()
    @IBOutlet weak var headerTitleLabel: UILabel?
    ///  创建一个只有一张图片的headerView
    ///
    ///  - parameter image:     要展示的图片
    ///  - parameter forSize:   view大xiao
    ///  - parameter referView: 依赖view(headerView会依赖于这个view形变)
    open class func creatParallaxScrollViewWithImage(image:UIImage,forSize:CGSize,referView:UIScrollView?) -> ParallaxScrollView {
        let paraScrollView = ParallaxScrollView(frame: CGRect(origin: CGPoint(x: 0, y: 0), size: forSize))
        paraScrollView.dependTableView = referView
        paraScrollView.headerImage = image
        paraScrollView.initialSetupForDefaultHeader()
        return paraScrollView
    }
    ///  将一个view改造成ParallaxView
    ///
    ///  - parameter subView:   view
    ///  - parameter referView: 依赖view(headerView会依赖于这个view形变)
    open class func creatParallaxScrollViewWithSubView(subView:UIView,referView:UIScrollView) -> ParallaxScrollView {
        let paraScrollView = ParallaxScrollView(frame: CGRect(origin:  CGPoint(x: 0, y: 0), size: subView.bounds.size))
        paraScrollView.dependTableView = referView
        paraScrollView.initialSetupForCustomSubView(subV: subView)
        return paraScrollView
    }
    ///  刷新
    open func refreshBlurViewForNewImage() {
        var screenShot = screenShotOfView(view: self)
        screenShot = screenShot.applyBlurWithblurRadius(blurRadius: 5, tintColor: UIColor(white: 0.6, alpha: 0.2), saturationDeltaFactor: 1.0, maskImage: nil)!
        bluredImageView?.image = screenShot
    }
    override public func awakeFromNib() {
        if (subView != nil) {
            initialSetupForCustomSubView(subV: subView!)
        }
        else{
            initialSetupForDefaultHeader()
        }
        refreshBlurViewForNewImage()
    }
    // MARK:- 私有函数
    ///  滑动时添加效果
    fileprivate func layoutHeaderViewForScrollViewOffset(offset:CGPoint) {
        var frametemp = imageScrollView!.frame
        if offset.y > 0 {
            frametemp.origin.y = max(offset.y * kParallaxDeltaFactor, 0)
            imageScrollView?.frame = frametemp
            bluredImageView?.alpha = 1 / bounds.size.height * offset.y * 2
            clipsToBounds = true
        }
        else{
            bluredImageView?.alpha = 0
            var delta : CGFloat = 0.0
            var rect = CGRect(origin:  CGPoint(x: 0, y: 0), size: bounds.size)
            delta = fabs(min(0.0, offset.y))
            rect.origin.y -= delta
            rect.size.height += delta
            imageScrollView?.frame = rect
            clipsToBounds = false
            headerTitleLabel?.alpha = 1 - (delta) * 1 / kMaxTitleAlphaOffset
        }
    }
    
    fileprivate func initialSetupForCustomSubView(subV:UIView) {
        let images =  UIScrollView(frame: bounds)
        imageScrollView = images
        subView = subV
        subView?.contentMode = .scaleAspectFill
        subV.autoresizingMask = [.flexibleLeftMargin,.flexibleRightMargin,.flexibleTopMargin,.flexibleBottomMargin,.flexibleHeight,.flexibleWidth]
        imageScrollView?.addSubview(subV)
        bluredImageView = UIImageView(frame: subV.frame)
        bluredImageView?.autoresizingMask = subV.autoresizingMask
        bluredImageView?.alpha = 0
        imageScrollView?.addSubview(bluredImageView!)
        addSubview(imageScrollView!)
        refreshBlurViewForNewImage()
    }
    private func initialSetupForDefaultHeader() {
        let imageS = UIScrollView(frame: bounds)
        imageScrollView = imageS
        let imageV = UIImageView(frame: imageS.bounds)
        imageView = imageV
        imageView?.contentMode = .scaleAspectFill
        imageView?.image = headerImage
        imageView?.autoresizingMask = [.flexibleLeftMargin,.flexibleRightMargin,.flexibleTopMargin,.flexibleBottomMargin,.flexibleHeight,.flexibleWidth]
        imageScrollView!.addSubview(imageView!)
        var labelRect = imageScrollView!.bounds
        labelRect.origin.x = kLabelPaddingDist
        labelRect.origin.y = kLabelPaddingDist
        labelRect.size.width = labelRect.size.width - 2 * kLabelPaddingDist
        labelRect.size.height = labelRect.size.height - 2 * kLabelPaddingDist
        let headerl = UILabel(frame: labelRect)
        headerTitleLabel = headerl
        headerTitleLabel!.textColor = UIColor.white
        headerTitleLabel!.font = UIFont(name: "AvenirNextCondensed-Regular", size: 23)
        headerTitleLabel!.autoresizingMask = [.flexibleLeftMargin,.flexibleRightMargin,.flexibleTopMargin,.flexibleBottomMargin,.flexibleHeight,.flexibleWidth]
        headerTitleLabel!.textAlignment = .center
        headerTitleLabel!.numberOfLines = 0
        headerTitleLabel!.lineBreakMode = .byWordWrapping
        imageScrollView!.addSubview(headerTitleLabel!)
        let bluredImageV = UIImageView(frame: imageView!.frame)
        bluredImageView = bluredImageV
        bluredImageView!.alpha = 0.0
        imageScrollView!.addSubview(bluredImageView!)
        addSubview(imageScrollView!)
        refreshBlurViewForNewImage()
    }
    private func screenShotOfView(view:UIView) ->UIImage{
        UIGraphicsBeginImageContextWithOptions(bounds.size, true, 0)
        drawHierarchy(in: bounds, afterScreenUpdates: false)
        let icon = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return icon!
    }
    ///  监听依赖View的滚动
     fileprivate func watchDependViewScrolled() {
        var myContext = 0
        dependTableView?.addObserver(self, forKeyPath: "contentOffset", options: [.new,.old], context: &myContext);
    }
     override public func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "contentOffset" {
            layoutHeaderViewForScrollViewOffset(offset: dependTableView!.contentOffset)
        }
    }
    private var dependTableView : UIScrollView?{
        didSet{
            watchDependViewScrolled()
        }
    }
    @IBOutlet  private weak var  imageScrollView: UIScrollView?
    @IBOutlet  private weak var imageView: UIImageView?
    @IBOutlet  private weak var subView: UIView?
    @IBOutlet  private var bluredImageView: UIImageView?
}
private let kLabelPaddingDist : CGFloat = 8.0
private let kParallaxDeltaFactor : CGFloat = 0.5
private let kMaxTitleAlphaOffset : CGFloat = 100
