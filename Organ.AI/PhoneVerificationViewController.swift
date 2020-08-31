//
//  PhoneVerificationViewController.swift
//  Organ.AI
//
//  Created by Ben on 2020/8/28.
//  Copyright © 2020 Organ.AI. All rights reserved.
//

import UIKit
import FlagPhoneNumber
import FirebaseAuth
import FirebaseCore

class PhoneVerificationViewController: UIViewController {

    @IBOutlet weak var phoneNumber: FPNTextField!
    @IBOutlet weak var vertificationTextfield: UITextField!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var label: UILabel!
    
    var isSignUp = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        vertificationTextfield.isHidden = true
        
        Utilities.styleTextField(phoneNumber)
        Utilities.styleTextField(vertificationTextfield)
        Utilities.styleFilledButton(nextButton)
        
        if !isSignUp
        {
            label.text = "Sign In With Your Phone Number"
        }
        

        // Do any additional setup after loading the view.
    }
    
    var vertificationID: String? = nil
    
    @IBAction func phoneNumberCompleteTapped(_ sender: Any) {
        
        if vertificationTextfield.isHidden
        {
            if !(phoneNumber.text!.isEmpty)
            {
            PhoneAuthProvider.provider().verifyPhoneNumber(phoneNumber.getFormattedPhoneNumber(format: .E164)!, uiDelegate: nil) { (ID, error) in
                if(error != nil)
                {
                    print(error?.localizedDescription)
                    return
                }else
                {
                    self.vertificationID = ID
                    self.phoneNumber.isHidden = true
                    self.vertificationTextfield.isHidden = false
                    self.label.text = "Please enter the 6-digit code your received"
                }
            }
            }else
            {
                print("please enter number")
            }
        }else
        {
            if vertificationID != nil
            {
            let credential = PhoneAuthProvider.provider().credential(withVerificationID: vertificationID!, verificationCode: vertificationTextfield.text!)
                Auth.auth().signIn(with: credential) { (autoData, Erro) in
                    if (Erro != nil)
                    {
                        
                    }else
                    {
                        print("Auth success \(autoData?.user.phoneNumber)")
                        
                        if self.isSignUp
                        {
                        self.performSegue(withIdentifier: "userInfoSegue", sender: nil)
                        }else
                        {
                            self.performSegue(withIdentifier: "toHomeSegue", sender: nil)
                        }
                        
                        
                    }
                    
                }
            }else
            {
                print("error")
            }
        }
        

        
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
