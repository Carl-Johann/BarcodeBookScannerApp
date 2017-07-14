//
//  AddToBookshelfCVCell
//  BarcodeBookScanner
//
//  Created by CarlJohan on 13/07/2017.
//  Copyright © 2017 Carl-Johan. All rights reserved.
//

import Foundation
import UIKit

class AddToBookshelfCell: UICollectionViewCell {
    
//    let textView = UITextView()
    let titleTextView: UITextView = {
        let textView = UITextView()
        textView.textContainer.maximumNumberOfLines = 0
        textView.font = UIFont(name: "HelveticaNeue", size: 10)
        textView.isUserInteractionEnabled = false
        textView.textContainer.lineBreakMode = .byWordWrapping
        textView.backgroundColor = .green
        
        return textView
    }()

    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupTextView()
    }
    
    func setupTextView() {
        
//        titleTextView.frame = frame
        addSubview(titleTextView)
    }
    
    
    
//    func addViews(){
////        backgroundColor = UIColor.blackColor()
//        
//        addSubview(titleTextView)
//        
////        conss
////        topSeparatorView.widthAnchor.constraintEqualToAnchor(widthAnchor).active = true
////        topSeparatorView.heightAnchor.constraintEqualToConstant(0.5).active = true
//        
//    }
//    
//    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
