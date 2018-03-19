//
//  CountryZipcode.swift
//  QuickTutor
//
//  Created by QuickTutor on 11/20/17.
//  Copyright © 2017 QuickTutor. All rights reserved.
//

import UIKit
import SnapKit
import CoreLocation

class CountryZipcodeView : RegistrationNavBarKeyboardView {
    
    var addressTextField   = RegistrationTextField()
    var cityTextField      = RegistrationTextField()
    var stateTextField     = RegistrationTextField()
    var zipcodeTextField   = RegistrationTextField()
    
    override func configureView() {
        super.configureView()
        contentView.addSubview(addressTextField)
        contentView.addSubview(cityTextField)
        contentView.addSubview(stateTextField)
        contentView.addSubview(zipcodeTextField)
        
        titleLabel.label.text = "Country Information"
        
        addressTextField.textField.becomeFirstResponder()
        addressTextField.placeholder.text = "Address Line 1"
        cityTextField.placeholder.text  = "City"
        stateTextField.placeholder.text = "State"
        zipcodeTextField.placeholder.text = "Zipcode"
        
        let textFields = [addressTextField.textField, cityTextField.textField, stateTextField.textField, zipcodeTextField.textField]
        for textField in textFields{
            textField.delegate = self
            textField.returnKeyType = .next
        }
        applyConstraints()
    }
    
    override func applyConstraints() {
        super.applyConstraints()
        
        addressTextField.snp.makeConstraints { (make) in
            make.top.equalTo(titleLabel.snp.bottom)
            make.left.equalTo(titleLabel)
            make.right.equalTo(titleLabel)
            make.height.equalToSuperview().multipliedBy(0.4)
        }
        
        cityTextField.snp.makeConstraints { (make) in
            make.top.equalTo(addressTextField.snp.bottom)
            make.left.equalTo(titleLabel)
            make.right.equalTo(titleLabel)
            make.height.equalToSuperview().multipliedBy(0.4)
        }
        stateTextField.snp.makeConstraints { (make) in
            make.top.equalTo(cityTextField.snp.bottom)
            make.width.equalToSuperview().multipliedBy(0.3)
            make.left.equalTo(titleLabel)
            make.height.equalToSuperview().multipliedBy(0.4)
        }
        zipcodeTextField.snp.makeConstraints { (make) in
            make.top.equalTo(cityTextField.snp.bottom)
            make.width.equalToSuperview().multipliedBy(0.5)
            make.right.equalTo(titleLabel)
            make.height.equalToSuperview().multipliedBy(0.4)
        }
    }
}

class CountryZipcode: BaseViewController {
    
    override var contentView: CountryZipcodeView {
        return view as! CountryZipcodeView
    }
    override func loadView() {
        view = CountryZipcodeView()
    }
    
    var address : String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
     //   contentView.nextButton.button.addTarget(self, action: #selector(nextButton), for: .touchUpInside)
       // contentView.backButton.button.addTarget(self, action: #selector(backButton), for: .touchUpInside)
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    private func validateTextFields() -> Bool {
        address = ""
        var isValid = true
        //need further validation, this just checks if they aren't empty
        if contentView.addressTextField.textField.text != "" {
            address.append(contentView.addressTextField.textField.text!)
        } else {
            print("Enter address")
            isValid = false
        }
        if contentView.cityTextField.textField.text != "" {
            address.append(", \(contentView.cityTextField.textField.text!), ")
        } else {
            print("Enter a city")
            isValid = false
        }
        if contentView.stateTextField.textField.text != "" {
            address.append(" \(contentView.stateTextField.textField.text!) ")
        } else {
            print("Enter valid state")
            isValid = false
        }
        if contentView.zipcodeTextField.textField.text != "" {
            address.append(" \(contentView.zipcodeTextField.textField.text!) ")
        } else {
            print("Enter valid zipcode")
            isValid = false
        }
        return isValid
    }
    
    @objc
    private func backButton(_ sender: UIButton!){
        navigationController?.popViewController(animated: true)
    }
    
    @objc
    private func nextButton(_ sender: UIButton!) {
        
        if validateTextFields(){
            
//            TutorRegistration.address_line1 = contentView.addressTextField.textField.text!
//            TutorRegistration.city = contentView.cityTextField.textField.text!
//            TutorRegistration.state = contentView.stateTextField.textField.text!
//            TutorRegistration.zipcode = contentView.zipcodeTextField.textField.text!
//
            let geocoder = CLGeocoder()
            geocoder.geocodeAddressString(address, completionHandler: { (placemarks, error) in
                
                if let error = error {
                    print(error.localizedDescription)
                }
                guard
                    let placemarks = placemarks,
                    let location = placemarks.first?.location
                    else{
                        print("could not find address")
                        return
                }
//                TutorRegistration.location = [location.coordinate.latitude, location.coordinate.longitude]
//                TutorRegistration.geohash = Geohash.encode(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude, 8)
            })
            //go somewhere from here...
            
        } else {
            print("Information is missing")
        }
    }
}
extension CountryZipcodeView : UITextFieldDelegate {
    
    internal func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case addressTextField.textField:
            cityTextField.textField.becomeFirstResponder()
        case cityTextField.textField:
            stateTextField.textField.becomeFirstResponder()
        case stateTextField.textField:
            zipcodeTextField.textField.becomeFirstResponder()
        default:
            resignFirstResponder()
        }
        return true
    }
    internal func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        let char = string.cString(using: String.Encoding.utf8)!
        let isBackSpace = strcmp(char, "\\b")
        
        let allowedCharacters = CharacterSet.decimalDigits
        let characterSet = CharacterSet(charactersIn: string)
        
        switch textField {
        case cityTextField.textField:
            if (isBackSpace == Constants.BCK_SPACE){
                textField.text!.removeLast()
            }
            return !allowedCharacters.isSuperset(of: characterSet)
        case zipcodeTextField.textField:
            return allowedCharacters.isSuperset(of: characterSet)
        default:
            return true
        }
    }
}
