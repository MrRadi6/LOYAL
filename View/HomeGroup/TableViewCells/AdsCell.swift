//
//  AdsCell.swift
//  Loyal
//
//  Created by Ahmed Samir on 7/17/19.
//  Copyright © 2019 MrRadix. All rights reserved.
//

import UIKit
import FSPagerView
import SkeletonView

class AdsCell: UITableViewCell {
    
    @IBOutlet weak var adsBanner: FSPagerView!
    @IBOutlet weak var pageControl: FSPageControl!
    private var numberOfAds = 0
    
    var ads: [Ads]? {
        didSet{
            if let ads = ads {
                numberOfAds = ads.count
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.adsBanner.reloadData()
                }
                configurePagerControl()
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        configurePagerView()
        configurePagerControl()
        selectionStyle = .none
    }
    
    private func configurePagerView() {
        adsBanner.delegate = self
        adsBanner.dataSource = self
        adsBanner.register(FSPagerViewCell.self, forCellWithReuseIdentifier: "cell")
        adsBanner.isInfinite = true
        adsBanner.automaticSlidingInterval = 3.0
        adsBanner.transformer = FSPagerViewTransformer(type: .linear)
        adsBanner.layer.masksToBounds = true
        adsBanner.layer.cornerRadius = 4
    }
    
    private func configurePagerControl() {
        selectionStyle = .none
        pageControl.setFillColor(#colorLiteral(red: 0.568627451, green: 0.568627451, blue: 0.568627451, alpha: 0.5193172089), for: .normal)
        pageControl.setFillColor(.white, for: .selected)
        pageControl.numberOfPages = numberOfAds
        pageControl.currentPage = 0
        
    }
    
    private func setNumberOfAds(numberOfAds: Int){
        self.numberOfAds = numberOfAds
    }
    
    func setCurrentPageForController(pageNumber: Int) {
        pageControl.currentPage = pageNumber
    }
}

extension AdsCell: FSPagerViewDelegate,FSPagerViewDataSource {
    
    func numberOfItems(in pagerView: FSPagerView) -> Int {
        return numberOfAds
    }
    
    func pagerView(_ pagerView: FSPagerView, cellForItemAt index: Int) -> FSPagerViewCell {
        let cell = pagerView.dequeueReusableCell(withReuseIdentifier: "cell", at: index)
        setCurrentPageForController(pageNumber: index)
        if let ads = ads {
            cell.imageView?.image = ads[index].image
            cell.imageView?.contentMode = .scaleAspectFill
        } else {
            cell.imageView?.image = UIImage(named: "adPlaceholder")
            cell.imageView?.contentMode = .scaleAspectFill
        }
        return cell
    }
    
    
}
