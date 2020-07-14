/**/

import UIKit
import MessageKit
import InputBarAccessoryView

    public var recent_requests = [AutocompleteCompletion(text: "Book a meeting with Ather at 4pm next week in Starbucks"), AutocompleteCompletion(text: "Book a meeting with Zack next week in Room A")]

public var scenario = 1

/// A base class for the example controllers
class ChatViewController: MessagesViewController, MessagesDataSource {
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    var done = false
    var api_response = false
    var time = [String: String]()
    var person = [String]()
    var duration = Int()
    var activity = [String]()
    var placeholder = [String]()
    var missingVariables = ["time": true, "duration": true, "activity": true, "person": true, "placeholder": true]
    var askForVariable = ""
    var messageList: [MockMessage] = []
    var first_message_sent = false

    let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }()
    
    var token = ""
    var organAI = OrganAIHandler()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureMessageCollectionView()
        configureMessageInputBar()
        
        title = "OrganAI"
        organAI.getToken(completion: { (str) in
            self.token = str
            self.loadFirstMessages()
        })
        
        
        messagesCollectionView.isUserInteractionEnabled = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    //    self.navigationController!.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
      //  self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.backgroundColor = .white
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    func gotoAppleCalendar(date: NSDate) {
        let interval = date.timeIntervalSinceReferenceDate
        if let url = URL(string: "calshow:\(interval)") {
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            } else {
                // Fallback on earlier versions
            }
        }
    }
    
    func loadFirstMessages() {
        DispatchQueue.global(qos: .userInitiated).async {
            let count = UserDefaults.standard.mockMessagesCount()
                DispatchQueue.main.async {
                    self.messageList = [
                        MockMessage(text: "Good Morning 😃", user: MockUser(senderId: "asdf", displayName: "Booking Assistant"), messageId: "ajskflj", date: Date()),
                        MockMessage(text: "I am your virtual assistant. You can ask me to book any meeting for you 😃", user: MockUser(senderId: "asdf", displayName: "Booking Assistant"), messageId: "ajskflj", date: Date())]
                    self.messagesCollectionView.reloadData()
                    self.messagesCollectionView.scrollToBottom()
                }
            
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let messagesDataSource = messagesCollectionView.messagesDataSource else {
            fatalError("Nil data source for messages")
        }
        
        guard !isSectionReservedForTypingIndicator(indexPath.section) else {
            return super.collectionView(collectionView, cellForItemAt: indexPath)
        }
        /**/
        let message = messagesDataSource.messageForItem(at: indexPath, in: messagesCollectionView)
        
        if case .custom(let dates) = message.kind {
            
            print(dates)
            
            if let _date = dates as? [String]
            {
                let cell = messagesCollectionView.dequeueReusableCell(withReuseIdentifier: "incomingTextCellID", for: indexPath) as? IncomingTextCell
                cell?.date_1.setTitle(_date[1], for: .normal)
                cell?.date_2.setTitle(_date[2], for: .normal)
                cell?.date_3.setTitle(_date[3], for: .normal)
                if _date[0] == "T"
                {
                    cell?.confirmSelectorView.isHidden = true
                    cell?.timeSelector.isHidden = false
                }else
                {
                    cell?.timeSelector.isHidden = true
                    cell?.confirmSelectorView.isHidden = false
                }
                cell?.VC = self
                return cell!
            }
        }
        
        return super.collectionView(collectionView, cellForItemAt: indexPath)
    }
    
    func configureMessageCollectionView() {        
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messageCellDelegate = self
        
        scrollsToBottomOnKeyboardBeginsEditing = true // default false
        maintainPositionOnKeyboardFrameChanged = true // default false
    }
    
    func configureMessageInputBar() {
        messageInputBar.delegate = self
        messageInputBar.inputTextView.tintColor = .primaryColor
        messageInputBar.sendButton.setTitleColor(.primaryColor, for: .normal)
        messageInputBar.sendButton.setTitleColor(
            UIColor.primaryColor.withAlphaComponent(0.3),
            for: .highlighted
        )
    }
    
    // MARK: - Helpers
    
    func insertMessage(_ message: MockMessage) {
        messageList.append(message)
        // Reload last section to update header/footer labels and insert a new one
        messagesCollectionView.performBatchUpdates({
            messagesCollectionView.insertSections([messageList.count - 1])
            if messageList.count >= 2 {
                messagesCollectionView.reloadSections([messageList.count - 2])
            }
        }, completion: { [weak self] _ in
            if self?.isLastSectionVisible() == true {
                self?.messagesCollectionView.scrollToBottom(animated: true)
            }
        })
    }
    
    func isLastSectionVisible() -> Bool {
        
        guard !messageList.isEmpty else { return false }
        
        let lastIndexPath = IndexPath(item: 0, section: messageList.count - 1)
        
        return messagesCollectionView.indexPathsForVisibleItems.contains(lastIndexPath)
    }
    
    // MARK: - MessagesDataSource
    
    func currentSender() -> SenderType {
        return SampleData.shared.currentSender
    }
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return messageList.count
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return messageList[indexPath.section]
    }
    
    func cellTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        if indexPath.section % 3 == 0 {
            return NSAttributedString(string: MessageKitDateFormatter.shared.string(from: message.sentDate), attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 10), NSAttributedString.Key.foregroundColor: UIColor.darkGray])
        }
        return nil
    }
    
    func cellBottomLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        
        return NSAttributedString(string: "Read", attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 10), NSAttributedString.Key.foregroundColor: UIColor.darkGray])
    }
    
    func messageTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        let name = message.sender.displayName
        return NSAttributedString(string: name, attributes: [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .caption1)])
    }
    
    func messageBottomLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        
        let dateString = formatter.string(from: message.sentDate)
        return NSAttributedString(string: dateString, attributes: [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .caption2)])
    }
}

// MARK: - MessageCellDelegate

extension ChatViewController: MessageCellDelegate {
    
    func didTapAvatar(in cell: MessageCollectionViewCell) {
        print("Avatar tapped")
    }
    
    func didTapMessage(in cell: MessageCollectionViewCell) {
        print("Message tapped")
    }
    
    func didTapImage(in cell: MessageCollectionViewCell) {
        print("Image tapped")
    }
    
    func didTapCellTopLabel(in cell: MessageCollectionViewCell) {
        print("Top cell label tapped")
    }
    
    func didTapCellBottomLabel(in cell: MessageCollectionViewCell) {
        print("Bottom cell label tapped")
    }
    
    func didTapMessageTopLabel(in cell: MessageCollectionViewCell) {
        print("Top message label tapped")
    }
    
    func didTapMessageBottomLabel(in cell: MessageCollectionViewCell) {
        print("Bottom label tapped")
    }
    
    func didTapAccessoryView(in cell: MessageCollectionViewCell) {
        print("Accessory view tapped")
    }
    
}

// MARK: - MessageLabelDelegate

extension ChatViewController: MessageLabelDelegate {
    
    func didSelectAddress(_ addressComponents: [String: String]) {
        print("Address Selected: \(addressComponents)")
    }
    
    func didSelectDate(_ date: Date) {
        print("Date Selected: \(date)")
    }
    
    func didSelectPhoneNumber(_ phoneNumber: String) {
        print("Phone Number Selected: \(phoneNumber)")
    }
    
    func didSelectURL(_ url: URL) {
        print("URL Selected: \(url)")
    }
    
    func didSelectTransitInformation(_ transitInformation: [String: String]) {
        print("TransitInformation Selected: \(transitInformation)")
    }
    
    func didSelectHashtag(_ hashtag: String) {
        print("Hashtag selected: \(hashtag)")
    }
    
    func didSelectMention(_ mention: String) {
        print("Mention selected: \(mention)")
    }
    
    func didSelectCustom(_ pattern: String, match: String?) {
        print("Custom data detector patter selected: \(pattern)")
    }
    
}

// MARK: - MessageInputBarDelegate

extension ChatViewController: InputBarAccessoryViewDelegate {
    
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        
        // Here we can parse for which substrings were autocompleted
        let attributedText = messageInputBar.inputTextView.attributedText!
        
        print("Message I sent \(attributedText.string)")
        
        let range = NSRange(location: 0, length: attributedText.length)
        attributedText.enumerateAttribute(.autocompleted, in: range, options: []) { (_, range, _) in
            
            let substring = attributedText.attributedSubstring(from: range)
            let context = substring.attribute(.autocompletedContext, at: 0, effectiveRange: nil)
            print("Autocompleted: `", substring, "` with context: ", context ?? [])
        }
        
        //傳出
        
        if true
        {
            
            organAI.queryProcessor(token: token, query: attributedText.string) { (intention, data) in
                
                        print("\napi response\n")
                    print(data)
                    var msg = ""
                
                if intention == "greet"
                {
                 msg = "Hello! How can I help you?"
                }else
                {
              //      recent_requests.append(AutocompleteCompletion(text: attributedText.string))
                    
                    /*For Testing*/
                    
                    if attributedText.string.contains("SEO")
                    {
                        self.activity = ["SEO Campaign"]
                    }
                    
                    /*------**/
                    
                    if !self.first_message_sent
                    {
                    recent_requests.insert(AutocompleteCompletion(text: attributedText.string), at: 0)
                    }
                    self.first_message_sent = true
                    if self.api_response == false
                    {
                        self.time = data["time"] as! [String: String]
                        self.person = data["person"] as! [String]
                        self.activity = data["activity"] as! [String]
                        self.duration = data["duration"] as! Int
                        self.placeholder = data["placeholder"] as! [String]
                    }
                    
                    if (data["time"] as! [String: String]).count > 0
                    {
                        self.time = data["time"] as! [String: String]
                        self.missingVariables["time"] = false
                    }
                    
                    if (data["person"] as! [String]).count > 0
                    {
                        self.person = data["person"] as! [String]
                        self.missingVariables["person"] = false
                    }
                    
                    if (data["activity"] as! [String]).count > 0
                    {
                        self.activity = data["activity"] as! [String]
                        self.missingVariables["activity"] = false
                    }

                    if (data["duration"] as! Int) != 0
                    {
                        if (data["time"] as! [String: String]).count == 2
                        {
                            self.duration = data["duration"] as! Int
                        }
                        self.duration = data["duration"] as! Int
                        self.missingVariables["duration"] = false
                    }
                    
                    if (data["placeholder"] as! [String]).count > 0
                    {
                        self.placeholder = data["placeholder"] as! [String]
                        self.missingVariables["placeholder"] = false
                    }
                    
                    self.api_response = true
                    
                    if self.time.count <= 0
                    {
                        // self.time = data["time"] as! [String: String]
                        self.askForVariable = "time"
                        msg = "When do you want the meeting to be?"
                        self.missingVariables["time"] = true
                    }
                        
                    else if self.person.count <= 0
                    {
                        //   self.person = data["person"] as! [String]
                        self.askForVariable = "person"
                        msg = "Who do you want to meet?"
                        self.missingVariables["person"] = true
                    }
                        
                    else if self.activity.count <= 0
                    {
                        //        self.activity = data["activity"] as! [String]
                        self.askForVariable = "activity"
                        msg = "What's the topic about?"
                        self.missingVariables["activity"] = true
                    }
                        
                    else if self.duration == 0
                    {
                        //       self.duration = data["duration"] as! Int
                        self.askForVariable = "duration"
                        msg = "What's the duration?"
                        self.missingVariables["duration"] = true
                    }else if self.placeholder.count <= 0
                    {
                        msg = "Where do you want to meet?"
                        self.missingVariables["placeholder"] = true
                    }
                        
                    else
                    {
                        print(self.time)
                        print(self.person)
                        print(self.activity)
                        print(self.duration)
                        print(self.placeholder)
                        self.done = true
                    }
                    
                    let formatter = DateFormatter()
                    formatter.dateFormat = "yyyy/MM/dd"
                }
                    
                    DispatchQueue.main.async {
                        if !self.done
                        {
                            self.setTypingIndicatorViewHidden(true, animated: true)
                            self.insertMessage(MockMessage(text: msg, user: MockUser(senderId: "ajdsklf", displayName: "Booking Assistant"), messageId: "asjdfkl", date: Date()))
                            
                            if msg == "Who do you want to meet?"
                            {
                                self.insertMessage(MockMessage(text: "Tip: Type '@' to look for contacts", user: MockUser(senderId: "asdf", displayName: "Booking Assistant"), messageId: "ajskflj", date: Date()))
                            }
                            
                        }else
                        {
                            msg = "I am checking the time with \(self.person.joined(separator: ","))... hold on for a second..."
                            self.insertMessage(MockMessage(text: msg, user: MockUser(senderId: "ajdsklf", displayName: "Booking Assistant"), messageId: "asjdfkl", date: Date()))
                            
                            
                            DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                                self.setTypingIndicatorViewHidden(true, animated: true)
                                
                                msg = "This is all the available timeslots of \(self.person.joined(separator: ",")). Pick a time that you prefer and I will book it for you:"
                                
                                if let controller = self.storyboard?.instantiateViewController(identifier: "PickAvailabilityViewController") {
                                   controller.isModalInPresentation = true
                                    self.present(controller, animated: true, completion: nil)
                                }
                                
                                
                                /*self.insertMessage(MockMessage(text: msg, user: MockUser(senderId: "ajdsklf", displayName: "Booking Assistant"), messageId: "asjdfkl", date: Date()))
                                
                                var timesets = [String]()
                                if scenario == 1
                                {
                                    timesets = ["Tuesday 6/2 12:00 - 14:00", "Tuesday 6/2 12:30 - 14:30", "Tuesday 6/2 15:30 - 17:30"]
                                                                    self.insertMessage(MockMessage(custom: ["T", "Tuesday 6/2 12:00 - 14:00", "Tuesday 6/2 12:30 - 14:30", "Tuesday 6/2 15:30 - 17:30"], user: MockUser(senderId: "Time", displayName: "Booking Assistant"), messageId: "adsf", date: Date()))
                                }else if scenario == 2
                                {
                                    timesets = ["Wednesday 6/3 10:00 - 11:00", "Thusday 6/4 12:30 - 13:30", "Friday 6/5 15:30 - 16:30"]
                                                                    self.insertMessage(MockMessage(custom: ["T", "Wednesday 6/3 10:00 - 11:00", "Thusday 6/4 12:30 - 13:30", "Friday 6/5 15:30 - 16:30"], user: MockUser(senderId: "Time", displayName: "Booking Assistant"), messageId: "adsf", date: Date()))
                                }else
                                {
                                     timesets = ["Thursday 6/4 10:00 - 11:00", "Thusday 6/4 14:30 - 15:30", "Friday 6/5 11:30 - 12:30"]
                                                                    self.insertMessage(MockMessage(custom: ["T", "Thursday 6/4 10:00 - 11:00", "Thusday 6/4 14:30 - 15:30", "Friday 6/5 11:30 - 12:30"], user: MockUser(senderId: "Time", displayName: "Booking Assistant"), messageId: "adsf", date: Date()))
                                }*/
                            }
                        }
                        self.messagesCollectionView.scrollToBottom()
                    }
                }
            }
            
        let components = inputBar.inputTextView.components
        messageInputBar.inputTextView.text = String()
        messageInputBar.invalidatePlugins()
        
        // Send button activity animation
        messageInputBar.sendButton.startAnimating()
        messageInputBar.inputTextView.placeholder = "Sending..."
        DispatchQueue.global(qos: .default).async {
            // fake send request task
            sleep(1)
            DispatchQueue.main.async { [weak self] in
                self?.setTypingIndicatorViewHidden(false, animated: true)
                self?.messageInputBar.sendButton.stopAnimating()
                self?.messageInputBar.inputTextView.placeholder = "Aa"
                self?.insertMessages(components)
                self?.messagesCollectionView.scrollToBottom(animated: true)
            }
        }
    }
    
    private func insertMessages(_ data: [Any]) {
        for component in data {
            let user = SampleData.shared.currentSender
            if let str = component as? String {
                let message = MockMessage(text: str, user: user, messageId: UUID().uuidString, date: Date())
                insertMessage(message)
            } else if let img = component as? UIImage {
                let message = MockMessage(image: img, user: user, messageId: UUID().uuidString, date: Date())
                insertMessage(message)
            }
        }
    }
}
