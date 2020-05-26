//
//  CustomMessageSizeCalculator.swift
//  ChatExample
//
//  Created by Ben on 2020/5/18.
//  Copyright © 2020 MessageKit. All rights reserved.
//

import Foundation
import MessageKit

open class CustomMessageSizeCalculator: MessageSizeCalculator {
     
      public override init(layout: MessagesCollectionViewFlowLayout? = nil) {
          super.init()
          self.layout = layout
      }

      open override func sizeForItem(at indexPath: IndexPath) -> CGSize {
          guard let layout = layout else { return .zero }
          let collectionViewWidth = layout.collectionView?.bounds.width ?? 0
          let contentInset = layout.collectionView?.contentInset ?? .zero
          let inset = layout.sectionInset.left + layout.sectionInset.right + contentInset.left + contentInset.right
          return CGSize(width: ((collectionViewWidth) - inset), height: ((collectionViewWidth / 2) - inset))
      }
    

    
}

