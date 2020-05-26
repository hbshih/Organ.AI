//
//  MyCustomMessagesFlowLayout.swift
//  ChatExample
//
//  Created by Ben on 2020/5/18.
//  Copyright © 2020 MessageKit. All rights reserved.
//

import Foundation
import MessageKit

open class CustomMessagesFlowLayout: MessagesCollectionViewFlowLayout {
    open lazy var customMessageSizeCalculator = CustomMessageSizeCalculator(layout: self)
    open lazy var customMessageSizeCalculator_2 = CustomMessageSizeCalculator_2(layout: self)
    
    open override func cellSizeCalculatorForItem(at indexPath: IndexPath) -> CellSizeCalculator {
        if isSectionReservedForTypingIndicator(indexPath.section) {
            return typingIndicatorSizeCalculator
        }
        let message = messagesDataSource.messageForItem(at: indexPath, in: messagesCollectionView)
        if case .custom = message.kind  {
            if message.sender.senderId == "Time"
            {
                return customMessageSizeCalculator
            }else
            {
                return customMessageSizeCalculator_2
            }
        }
        return super.cellSizeCalculatorForItem(at: indexPath)
    }
    
    open override func messageSizeCalculators() -> [MessageSizeCalculator] {
        var superCalculators = super.messageSizeCalculators()
        // Append any of your custom `MessageSizeCalculator` if you wish for the convenience
        // functions to work such as `setMessageIncoming...` or `setMessageOutgoing...`
        superCalculators.append(customMessageSizeCalculator)
        return superCalculators
    }
}
