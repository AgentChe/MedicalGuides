//
//  Fonts.swift
//  Soccer
//
//  Created by Andrey Chernyshev on 16.01.2021.
//

import UIKit

struct Fonts {
    // MARK: Avenir
    struct Avenir {
        static func medium(size: CGFloat) -> UIFont {
            UIFont(name: "Avenir-Medium", size: size)!
        }
        
        static func black(size: CGFloat) -> UIFont {
            UIFont(name: "Avenir-Black", size: size)!
        }
        
        static func bold(size: CGFloat) -> UIFont {
            UIFont(name: "Avenir Next LT Pro", size: size)!
        }
        
        static func regular(size: CGFloat) -> UIFont {
            UIFont(name: "Avenir-Regular", size: size)!
        }
    }
}
