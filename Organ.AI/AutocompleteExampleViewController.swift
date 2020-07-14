//
//  AutocompleteExampleViewController.swift
//  ChatExample
//
//  Created by Nathan Tannar on 2019-04-05.
//  Copyright © 2019 MessageKit. All rights reserved.
//

import UIKit
import MessageKit
import InputBarAccessoryView

final class AutocompleteExampleViewController: ChatViewController {
    
    lazy var joinChatButton: UIButton = {
        let button = UIButton()
        button.layer.cornerRadius = 16
        button.backgroundColor = .primaryColor
        button.setTitle("Talk With Assistant", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.setTitleColor(UIColor(white: 1, alpha: 0.3), for: .highlighted)
        button.addTarget(self, action: #selector(joinChat), for: .touchUpInside)
        return button
    }()
    
    /// The object that manages autocomplete, from InputBarAccessoryView
    lazy var autocompleteManager: AutocompleteManager = { [unowned self] in
        let manager = AutocompleteManager(for: self.messageInputBar.inputTextView)
        manager.delegate = self
        manager.dataSource = self
        manager.keepPrefixOnCompletion = false
        return manager
        }()
    
    
    var a_suggestion: [AutocompleteCompletion] = [AutocompleteCompletion(text: "At 4pm"), AutocompleteCompletion(text: "At 6pm"), AutocompleteCompletion(text: "At 10pm"), AutocompleteCompletion(text: "At the Office"), AutocompleteCompletion(text: "At Room A")]
    
    var b_suggestion: [AutocompleteCompletion] = [AutocompleteCompletion(text: "Book a meeting with Ather"), AutocompleteCompletion(text: "Book a meeting with Ben"), AutocompleteCompletion(text: "Between")]
    
    var s_suggestion: [AutocompleteCompletion] = [AutocompleteCompletion(text: "Schedule a meeting with Frank"), AutocompleteCompletion(text: "Schedule a meeting with Ben")]
    
    var f_suggestion: [AutocompleteCompletion] = [AutocompleteCompletion(text: "From 2 pm to 4 pm "), AutocompleteCompletion(text: "From 1 pm")]
    
    var i_suggestion: [AutocompleteCompletion] = [AutocompleteCompletion(text: "In the Office"), AutocompleteCompletion(text: "In Room A")]
    
    var users: [AutocompleteCompletion] = [AutocompleteCompletion(text: "Ben Shih,", context: ["id": "00001"]), AutocompleteCompletion(text: "Amanda", context: ["id": "00002"]), AutocompleteCompletion(text: "Mandy", context: ["id": "00003"]), AutocompleteCompletion(text: "Marketing Team", context: ["id": "00004"]),  AutocompleteCompletion(text: "Zack Wilson,", context: ["id": "00005"]), AutocompleteCompletion(text: "Erik Flores,", context: ["id": "00006"])]
    
    var r_suggestion: [AutocompleteCompletion] = []
    var hashtag_suggestion: [AutocompleteCompletion] = []
    
    // Completions loaded async that get appeneded to local cached completions
    var asyncCompletions: [AutocompleteCompletion] = []
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // ### 有Message傳回來的時候display在這裡
        
        //  self.setTypingIndicatorViewHidden(false)
        let button1 = UIBarButtonItem(image: UIImage(named: "icons8-synchronize-24"), style: .plain, target: self, action: #selector(handleEditBtn)) // action:#selector(Class.MethodName) for swift 3
        self.navigationItem.rightBarButtonItem  = button1
    }
    
    @objc private func handleEditBtn() {
        print("clicked on Edit btn")
        
        time.removeAll()
        person.removeAll()
        duration = Int()
        activity.removeAll()
        placeholder.removeAll()
        missingVariables = ["time": true, "duration": true, "activity": true, "person": true, "placeholder": true]
        first_message_sent = false
        done = false
        
        self.insertMessage(MockMessage(text: "I am your virtual assistant. You can ask me to book any meeting for you 😃", user: MockUser(senderId: "asdf", displayName: "Booking Assistant"), messageId: "ajskflj", date: Date()))
        messageInputBar.becomeFirstResponder()
        
    }
    
    override func viewDidLoad() {
        
        messagesCollectionView = MessagesCollectionView(frame: .zero, collectionViewLayout: CustomMessagesFlowLayout())
        // incoming text nib register
        let incomingTextNib = UINib(nibName: "IncomingTextCell", bundle: nil)
        messagesCollectionView.register(incomingTextNib, forCellWithReuseIdentifier: "incomingTextCellID")
        
        super.viewDidLoad()
        
        if #available(iOS 13.0, *) {
            self.overrideUserInterfaceStyle = .light
        } else {
            // Fallback on earlier versions
        }

        messageInputBar.inputTextView.keyboardType = .twitter
        
        autocompleteManager.register(prefix: "@", with: [.font: UIFont.preferredFont(forTextStyle: .body), .foregroundColor: UIColor.primaryColor, .backgroundColor: UIColor.primaryColor.withAlphaComponent(0.3)])
        
        // autocompleteManager.register(prefix: "#")
        autocompleteManager.register(prefix: "A")
        autocompleteManager.register(prefix: "a")
        autocompleteManager.register(prefix: "B")
        autocompleteManager.register(prefix: "b")
        autocompleteManager.register(prefix: "S")
        autocompleteManager.register(prefix: "s")
        autocompleteManager.register(prefix: "F")
        autocompleteManager.register(prefix: "f")
        autocompleteManager.register(prefix: "I")
        autocompleteManager.register(prefix: "i")
        autocompleteManager.register(prefix: "N")
        autocompleteManager.register(prefix: "n")
        autocompleteManager.register(prefix: "O")
        autocompleteManager.register(prefix: "o")
        autocompleteManager.register(prefix: "R")
        autocompleteManager.register(prefix: "r")
        autocompleteManager.register(prefix: "T")
        autocompleteManager.register(prefix: "t")
        autocompleteManager.register(prefix: "#")
        autocompleteManager.register(prefix: "1")
        autocompleteManager.register(prefix: "2")
        autocompleteManager.maxSpaceCountDuringCompletion = 1 // Allow for autocompletes with a space
        
        // Set plugins
        messageInputBar.inputPlugins = [autocompleteManager]
    }
    
    
    override func configureMessageCollectionView() {
        super.configureMessageCollectionView()
        
        let layout = messagesCollectionView.collectionViewLayout as? MessagesCollectionViewFlowLayout
        
        layout?.sectionInset = UIEdgeInsets(top: 1, left: 8, bottom: 1, right: 8)
        layout?.setMessageOutgoingCellBottomLabelAlignment(.init(textAlignment: .right, textInsets: .zero))
        layout?.setMessageOutgoingAvatarSize(.zero)
        layout?.setMessageOutgoingMessageTopLabelAlignment(LabelAlignment(textAlignment: .right, textInsets: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 30)))
        layout?.setMessageOutgoingMessageBottomLabelAlignment(LabelAlignment(textAlignment: .right, textInsets: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 12)))
        
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        
        additionalBottomInset = 30
    }
    
    override func configureMessageInputBar() {
        super.configureMessageInputBar()
        messageInputBar.layer.shadowColor = UIColor.black.cgColor
        messageInputBar.layer.shadowRadius = 4
        messageInputBar.layer.shadowOpacity = 0.3
        messageInputBar.layer.shadowOffset = CGSize(width: 0, height: 0)
        messageInputBar.separatorLine.isHidden = true
        messageInputBar.becomeFirstResponder()
        messageInputBar.setRightStackViewWidthConstant(to: 0, animated: false)
        messageInputBar.setMiddleContentView(joinChatButton, animated: false)
    }
    
    private func configureMessageInputBarForChat() {
        messageInputBar.setMiddleContentView(messageInputBar.inputTextView, animated: false)
        messageInputBar.setRightStackViewWidthConstant(to: 52, animated: false)
        //    let bottomItems = [makeButton(named: "ic_at"), makeButton(named: "ic_hashtag"), .flexibleSpace]
        //messageInputBar.setStackViewItems(bottomItems, forStack: .bottom, animated: false)
        
        messageInputBar.sendButton.activityViewColor = .white
        messageInputBar.sendButton.backgroundColor = .primaryColor
        messageInputBar.sendButton.layer.cornerRadius = 10
        messageInputBar.sendButton.setTitleColor(.white, for: .normal)
        messageInputBar.sendButton.setTitleColor(UIColor(white: 1, alpha: 0.3), for: .highlighted)
        messageInputBar.sendButton.setTitleColor(UIColor(white: 1, alpha: 0.3), for: .disabled)
        messageInputBar.sendButton
            .onSelected { item in
                item.transform = CGAffineTransform(scaleX: 1.05, y: 1.05)
        }.onDeselected { item in
            item.transform = .identity
        }
    }
    
    @objc
    func joinChat() {
        configureMessageInputBarForChat()
        self.insertMessage(MockMessage(text: "Tip: Type '#' to look for your recent requests.", user: MockUser(senderId: "asdf", displayName: "Booking Assistant"), messageId: "ajskflj", date: Date()))
        messageInputBar.becomeFirstResponder()
    }
    
    // MARK: - Helpers
    
    func isTimeLabelVisible(at indexPath: IndexPath) -> Bool {
        return indexPath.section % 3 == 0 && !isPreviousMessageSameSender(at: indexPath)
    }
    
    func isPreviousMessageSameSender(at indexPath: IndexPath) -> Bool {
        guard indexPath.section - 1 >= 0 else { return false }
        return messageList[indexPath.section].user == messageList[indexPath.section - 1].user
    }
    
    func isNextMessageSameSender(at indexPath: IndexPath) -> Bool {
        guard indexPath.section + 1 < messageList.count else { return false }
        return messageList[indexPath.section].user == messageList[indexPath.section + 1].user
    }
    
    func setTypingIndicatorViewHidden(_ isHidden: Bool, performUpdates updates: (() -> Void)? = nil) {
        setTypingIndicatorViewHidden(isHidden, animated: true, whilePerforming: updates) { [weak self] success in
            if success, self?.isLastSectionVisible() == true {
                self?.messagesCollectionView.scrollToBottom(animated: true)
            }
        }
    }
    
    private func makeButton(named: String) -> InputBarButtonItem {
        return InputBarButtonItem()
            .configure {
                $0.spacing = .fixed(10)
                $0.image = UIImage(named: named)?.withRenderingMode(.alwaysTemplate)
                $0.setSize(CGSize(width: 25, height: 25), animated: false)
                $0.tintColor = UIColor(white: 0.8, alpha: 1)
        }.onSelected {
            $0.tintColor = .primaryColor
        }.onDeselected {
            $0.tintColor = UIColor(white: 0.8, alpha: 1)
        }.onTouchUpInside { _ in
        }
    }
    
    // MARK: - MessagesDataSource
    
    override func cellTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        if isTimeLabelVisible(at: indexPath) {
            return NSAttributedString(string: MessageKitDateFormatter.shared.string(from: message.sentDate), attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 10), NSAttributedString.Key.foregroundColor: UIColor.darkGray])
        }
        return nil
    }
    
    override func messageTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        if !isPreviousMessageSameSender(at: indexPath) {
            let name = message.sender.displayName
            return NSAttributedString(string: name, attributes: [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .caption1)])
        }
        return nil
    }
    
    override func messageBottomLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        
        if !isNextMessageSameSender(at: indexPath) && isFromCurrentSender(message: message) {
            return NSAttributedString(string: "Delivered", attributes: [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .caption1)])
        }
        return nil
    }
    
    // Async autocomplete requires the manager to reload
    func inputBar(_ inputBar: InputBarAccessoryView, textViewTextDidChangeTo text: String) {
        
        
        
        guard autocompleteManager.currentSession != nil, autocompleteManager.currentSession?.prefix == "#" else { return }
        // Load some data asyncronously for the given session.prefix
        /*DispatchQueue.global(qos: .default).async {
            // fake background loading task
            var array: [AutocompleteCompletion] = []
            for _ in 1...10 {
                array.append(AutocompleteCompletion(text: Lorem.word()))
            }
            sleep(1)
            DispatchQueue.main.async { [weak self] in
                self?.asyncCompletions = array
                self?.autocompleteManager.reloadData()
            }
        }*/
    }
}

extension AutocompleteExampleViewController: AutocompleteManagerDelegate, AutocompleteManagerDataSource {
    
    // MARK: - AutocompleteManagerDataSource
    
    func autocompleteManager(_ manager: AutocompleteManager, autocompleteSourceFor prefix: String) -> [AutocompleteCompletion] {
        
        manager.keepPrefixOnCompletion = false
        
        if prefix == "@" {
            return users
          /*  return SampleData.shared.senders
                .map { user in
                    return AutocompleteCompletion(text: user.displayName,
                                                  context: ["id": user.senderId])
            }*/
        }
        
        if !first_message_sent
        {
            s_suggestion = [AutocompleteCompletion(text: "Schedule a meeting with "), AutocompleteCompletion(text: "Schedule a meeting with Ben"), AutocompleteCompletion(text: "Schedule a meeting with Erik and Ben")]
            
            if prefix == "s" || prefix == "S"
            {
                return s_suggestion
            }
            
            if prefix == "I" || prefix == "i"
            {
                return [AutocompleteCompletion(text: "I want to book a meeting with "), AutocompleteCompletion(text: "I want to book a meeting with Zack"), AutocompleteCompletion(text: "I want to book a meeting with Zack and Ben")]
            }
            
            if prefix == "B" || prefix == "b"
            {
                return [AutocompleteCompletion(text: "Book a meeting with Erik"), AutocompleteCompletion(text: "Book an appointment with Ather"), AutocompleteCompletion(text: "Book a meeting with ")]
            }
            
            if prefix == "A" || prefix == "a"
            {
                return [AutocompleteCompletion(text: "Arrange a meeting with"), AutocompleteCompletion(text: "Arrange an appointment with Ather"), AutocompleteCompletion(text: "Arrange a meeting with ")]
            }
            
            if prefix == "a" || prefix == "A"
            {
                return [AutocompleteCompletion(text: "at 10am"), AutocompleteCompletion(text: "at 2pm")]
            }
            
            if prefix == "#"
            {
                
                return recent_requests
            }
            
        }else
        {
            if missingVariables["time"]!
            {
                print("missing time")
                f_suggestion = [AutocompleteCompletion(text: "From 4 pm to 6pm"), AutocompleteCompletion(text: "From 1pm to 3pm")]
                a_suggestion = [AutocompleteCompletion(text: "at 4pm"), AutocompleteCompletion(text: "at 1pm")]
                if prefix == "A" || prefix == "a"
                {
                    return a_suggestion
                }
                
                if prefix == "F" || prefix == "f"
                {
                    return f_suggestion
                }
                
                if prefix == "n" || prefix == "N"
                {
                    return [AutocompleteCompletion(text: "next week"), AutocompleteCompletion(text: "Next Week")]
                }
                
                if prefix == "B" || prefix == "b"
                {
                    return [AutocompleteCompletion(text: "Between"), AutocompleteCompletion(text: "Between wednesday and thursday")]
                }
                
                if prefix == "t" || prefix == "T"
                {
                    return [AutocompleteCompletion(text: "Tuesday"), AutocompleteCompletion(text: "This week")]
                }
                
                if prefix == "o" || prefix == "O"
                {
                    return [AutocompleteCompletion(text: "on Friday"), AutocompleteCompletion(text: "on Monday")]
                }
                
                if prefix == "#"
                {
                    return [AutocompleteCompletion(text: "Monday"), AutocompleteCompletion(text: "Tuesday"), AutocompleteCompletion(text: "Wednesday"), AutocompleteCompletion(text: "Thursday"), AutocompleteCompletion(text: "Friday")]
                }
            }
                
            else if missingVariables["person"]!
            {
                print("missing person")
                
            }
                
            else if missingVariables["activity"]!
            {
                print("missing activity")
                r_suggestion = [AutocompleteCompletion(text: "routine meeting")]
                hashtag_suggestion = [AutocompleteCompletion(text: "Routine Meeting"), AutocompleteCompletion(text: "Web Dev"), AutocompleteCompletion(text: "Internal Meeting")]
                
                if prefix == "R" || prefix == "r"
                {
                    return  r_suggestion
                }
                
                if prefix == "#"
                {
                    return hashtag_suggestion
                }
            }
                
            else if missingVariables["duration"]!
            {
                
                                if prefix == "t" || prefix == "T"
                {
                    return [AutocompleteCompletion(text: "Two hours")]
                }
                
                if prefix == "1"
                {
                    return [AutocompleteCompletion(text: "1 hour")]
                }
                
                if prefix == "o" || prefix == "O"
                {
                    return [AutocompleteCompletion(text: "One hour")]
                }
                
                if prefix == "2"
                {
                    return [AutocompleteCompletion(text: "2 hours")]
                }
                
                
                print("missing duration")
            }
                
            else if missingVariables["placeholder"]!
            {
                
                print("missing place")
                
                i_suggestion = [AutocompleteCompletion(text: "in the office"), AutocompleteCompletion(text: "in Room A"), AutocompleteCompletion(text: "in WeWork")]
                a_suggestion = [AutocompleteCompletion(text: "at the office"), AutocompleteCompletion(text: "at Room A"), AutocompleteCompletion(text: "at WeWork")]
                
                hashtag_suggestion = [AutocompleteCompletion(text: "Office"), AutocompleteCompletion(text: "Room A"), AutocompleteCompletion(text: "WeWork")]
                
                if prefix == "I" || prefix == "i"
                {
                    return  i_suggestion
                }
                
                if prefix == "A" || prefix == "a"
                {
                    return  a_suggestion
                }
                
                if prefix == "R" || prefix == "r"
                {
                    return [AutocompleteCompletion(text: "Room A"), AutocompleteCompletion(text: "Room B"), AutocompleteCompletion(text: "Room C")]
                }
                
                if prefix == "S" || prefix == "s"
                {
                    return [AutocompleteCompletion(text: "Skype"), AutocompleteCompletion(text: "Starbucks")]
                }
                
                if prefix == "#"
                {
                    return hashtag_suggestion
                }
            }
        }
        /*
        else if prefix == "#" {
            return asyncCompletions
        }*/
        return []
    }
    
    func autocompleteManager(_ manager: AutocompleteManager, tableView: UITableView, cellForRowAt indexPath: IndexPath, for session: AutocompleteSession) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: AutocompleteCell.reuseIdentifier, for: indexPath) as? AutocompleteCell else {
            fatalError("Oops, some unknown error occurred")
        }
        let users = SampleData.shared.senders
        let id = session.completion?.context?["id"] as? String
        let user = users.filter { return $0.senderId == id }.first
        if let sender = user {
            cell.imageView?.image = SampleData.shared.getAvatarFor(sender: sender).image
        }
        cell.imageViewEdgeInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        cell.imageView?.layer.cornerRadius = 14
        cell.imageView?.layer.borderColor = UIColor.primaryColor.cgColor
        cell.imageView?.layer.borderWidth = 1
        cell.imageView?.clipsToBounds = true
        cell.textLabel?.attributedText = manager.attributedText(matching: session, fontSize: 15, keepPrefix: false)
        return cell
    }
    /*
     func autocompleteManager(_ manager: AutocompleteManager, shouldComplete prefix: String, with text: String) -> Bool {
     
     print(prefix)
     print(text)
     
     return false
     
     }*/
    
    // MARK: - AutocompleteManagerDelegate
    
    func autocompleteManager(_ manager: AutocompleteManager, shouldBecomeVisible: Bool) {
        setAutocompleteManager(active: shouldBecomeVisible)
    }
    
    // Optional
    func autocompleteManager(_ manager: AutocompleteManager, shouldRegister prefix: String, at range: NSRange) -> Bool {
        return true
    }
    
    // Optional
    func autocompleteManager(_ manager: AutocompleteManager, shouldUnregister prefix: String) -> Bool {
        return true
    }
    
    // Optional
    func autocompleteManager(_ manager: AutocompleteManager, shouldComplete prefix: String, with text: String) -> Bool {
        return true
    }
    
    // MARK: - AutocompleteManagerDelegate Helper
    
    func setAutocompleteManager(active: Bool) {
        let topStackView = messageInputBar.topStackView
        if active && !topStackView.arrangedSubviews.contains(autocompleteManager.tableView) {
            topStackView.insertArrangedSubview(autocompleteManager.tableView, at: topStackView.arrangedSubviews.count)
            topStackView.layoutIfNeeded()
        } else if !active && topStackView.arrangedSubviews.contains(autocompleteManager.tableView) {
            topStackView.removeArrangedSubview(autocompleteManager.tableView)
            topStackView.layoutIfNeeded()
        }
        messageInputBar.invalidateIntrinsicContentSize()
    }
}

// MARK: - MessagesDisplayDelegate

extension AutocompleteExampleViewController: MessagesDisplayDelegate {
    
    // MARK: - Text Messages
    
    func textColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        return isFromCurrentSender(message: message) ? .white : .darkText
    }
    
    func detectorAttributes(for detector: DetectorType, and message: MessageType, at indexPath: IndexPath) -> [NSAttributedString.Key: Any] {
        switch detector {
        case .hashtag, .mention:
            if isFromCurrentSender(message: message) {
                return [.foregroundColor: UIColor.white]
            } else {
                return [.foregroundColor: UIColor.primaryColor]
            }
        default: return MessageLabel.defaultAttributes
        }
    }
    
    func enabledDetectors(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> [DetectorType] {
        return [.url, .address, .phoneNumber, .date, .transitInformation, .mention, .hashtag]
    }
    
    // MARK: - All Messages
    
    func backgroundColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        return isFromCurrentSender(message: message) ? .primaryColor : UIColor(red: 230/255, green: 230/255, blue: 230/255, alpha: 1)
    }
    
    func messageStyle(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageStyle {
        return .bubble
    }
    
    func configureAvatarView(_ avatarView: AvatarView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        let avatar = SampleData.shared.getAvatarFor(sender: message.sender)
        avatarView.set(avatar: avatar)
        avatarView.isHidden = isNextMessageSameSender(at: indexPath)
        avatarView.layer.borderWidth = 2
        avatarView.layer.borderColor = UIColor.primaryColor.cgColor
    }
    
    func configureAccessoryView(_ accessoryView: UIView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        // Cells are reused, so only add a button here once. For real use you would need to
        // ensure any subviews are removed if not needed
        accessoryView.subviews.forEach { $0.removeFromSuperview() }
        
        let button = UIButton(type: .infoLight)
        button.tintColor = .primaryColor
        accessoryView.addSubview(button)
        button.frame = accessoryView.bounds
        button.isUserInteractionEnabled = false // respond to accessoryView tap through `MessageCellDelegate`
        accessoryView.layer.cornerRadius = accessoryView.frame.height / 2
        accessoryView.backgroundColor = UIColor.primaryColor.withAlphaComponent(0.3)
    }
}

// MARK: - MessagesLayoutDelegate

extension AutocompleteExampleViewController: MessagesLayoutDelegate {
    func cellTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        if isTimeLabelVisible(at: indexPath) {
            return 18
        }
        return 0
    }
    
    func messageTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        if isFromCurrentSender(message: message) {
            return !isPreviousMessageSameSender(at: indexPath) ? 20 : 0
        } else {
            return !isPreviousMessageSameSender(at: indexPath) ? 20 : 0
        }
    }
    
    func messageBottomLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return (!isNextMessageSameSender(at: indexPath) && isFromCurrentSender(message: message)) ? 16 : 0
    }
    
}
