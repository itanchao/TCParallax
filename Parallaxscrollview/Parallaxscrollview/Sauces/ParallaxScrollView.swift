//
//  ParallaxScrollView.swift
//  Parallaxscrollview
//
//  Created by tanchao on 16/4/20.
//  Copyright © 2016年 谈超. All rights reserved.
//
import UIKit
class ParallaxScrollView: UIView {
    var headerImage:UIImage = UIImage()
    @IBOutlet weak var headerTitleLabel: UILabel?
    ///  创建一个只有一张图片的headerView
    ///
    ///  - parameter image:     要展示的图片
    ///  - parameter forSize:   view大xiao
    ///  - parameter referView: 依赖view(headerView会依赖于这个view形变)
    static func creatParallaxScrollViewWithImage(image:UIImage,forSize:CGSize,referView:UITableView?) -> ParallaxScrollView {
        let paraScrollView = ParallaxScrollView(frame: CGRect(origin: CGPointZero, size: forSize))
        paraScrollView.dependTableView = referView
        paraScrollView.headerImage = image
        paraScrollView.initialSetupForDefaultHeader()
        return paraScrollView
    }
    ///  将一个view改造成ParallaxView
    ///
    ///  - parameter subView:   view
    ///  - parameter referView: 依赖view(headerView会依赖于这个view形变)
    static func creatParallaxScrollViewWithSubView(subView:UIView,referView:UITableView) -> ParallaxScrollView {
       let paraScrollView = ParallaxScrollView(frame: CGRect(origin: CGPointZero, size: subView.bounds.size))
        paraScrollView.dependTableView = referView
        paraScrollView.initialSetupForCustomSubView(subView)
        return paraScrollView
    }
    ///  刷新
    func refreshBlurViewForNewImage() {
        var screenShot = screenShotOfView(self)
        screenShot = screenShot.applyBlurWithblurRadius(5, tintColor: UIColor(white: 0.6, alpha: 0.2), saturationDeltaFactor: 1.0, maskImage: nil)!
        bluredImageView?.image = screenShot
    }
    internal override func awakeFromNib() {
        if (subView != nil) {
            initialSetupForCustomSubView(subView!)
        }
        else{
            initialSetupForDefaultHeader()
        }
        refreshBlurViewForNewImage()
    }
    // MARK:- 私有函数
    ///  滑动时添加效果
    private func layoutHeaderViewForScrollViewOffset(offset:CGPoint) {
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
            var rect = CGRect(origin: CGPointZero, size: bounds.size)
            delta = fabs(min(0.0, offset.y))
            rect.origin.y -= delta
            rect.size.height += delta
            imageScrollView?.frame = rect
            clipsToBounds = false
            headerTitleLabel?.alpha = 1 - (delta) * 1 / kMaxTitleAlphaOffset
        }
    }
   private func initialSetupForCustomSubView(subV:UIView) {
        imageScrollView = UIScrollView(frame: bounds)
        subView = subV
        subV.autoresizingMask = [.FlexibleLeftMargin,.FlexibleRightMargin,.FlexibleTopMargin,.FlexibleBottomMargin,.FlexibleHeight,.FlexibleWidth]
        imageScrollView?.addSubview(subV)
        bluredImageView = UIImageView(frame: subV.frame)
        bluredImageView?.autoresizingMask = subV.autoresizingMask
        bluredImageView?.alpha = 0
        imageScrollView?.addSubview(bluredImageView!)
        refreshBlurViewForNewImage()
    }
    private func initialSetupForDefaultHeader() {
        let imageS = UIScrollView(frame: bounds)
        imageScrollView = imageS
        let imageV = UIImageView(frame: imageS.bounds)
        imageView = imageV
        imageView?.image = headerImage
        imageView?.autoresizingMask = [.FlexibleLeftMargin,.FlexibleRightMargin,.FlexibleTopMargin,.FlexibleBottomMargin,.FlexibleHeight,.FlexibleWidth]
        imageScrollView!.addSubview(imageView!)
        var labelRect = imageScrollView!.bounds
        labelRect.origin.x = kLabelPaddingDist
        labelRect.origin.y = kLabelPaddingDist
        labelRect.size.width = labelRect.size.width - 2 * kLabelPaddingDist
        labelRect.size.height = labelRect.size.height - 2 * kLabelPaddingDist
        let headerl = UILabel(frame: labelRect)
        headerTitleLabel = headerl
        headerTitleLabel!.textColor = UIColor.whiteColor()
        headerTitleLabel!.font = UIFont(name: "AvenirNextCondensed-Regular", size: 23)
        headerTitleLabel!.autoresizingMask = [.FlexibleLeftMargin,.FlexibleRightMargin,.FlexibleTopMargin,.FlexibleBottomMargin,.FlexibleHeight,.FlexibleWidth]
        headerTitleLabel!.textAlignment = .Center
        headerTitleLabel!.numberOfLines = 0
        headerTitleLabel!.lineBreakMode = .ByWordWrapping
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
        drawViewHierarchyInRect(bounds, afterScreenUpdates: false)
        let icon = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return icon
    }
    ///  监听依赖View的滚动
    private func watchDependViewScrolled() {
        dependTableView!.addObserver(self, forKeyPath: "contentOffset", options: [.New,.Old], context: UnsafeMutablePointer<Void>.alloc(0))
    }
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        if keyPath == "contentOffset" {
            layoutHeaderViewForScrollViewOffset(dependTableView!.contentOffset)
        }
    }
    private var dependTableView : UITableView?{
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
