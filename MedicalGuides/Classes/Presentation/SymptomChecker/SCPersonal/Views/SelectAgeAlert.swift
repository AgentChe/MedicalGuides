//
//  SelectAgeAlert.swift
//  MedicalGuides
//
//  Created by Андрей Чернышев on 24.05.2023.
//

import UIKit

final class SelectAgeAlert: NSObject {
    private lazy var ages = Array(stride(from: 16, to: 100, by: 1))
    
    private lazy var pickerView = UIPickerView(frame: CGRect(x: 10.scale, y: 50.scale, width: 250.scale, height: 150.scale))
}

// MARK: Public
extension SelectAgeAlert {
    func alert(didSelect: @escaping (Int) -> Void) -> UIAlertController {
        pickerView.dataSource = self
        pickerView.delegate = self
        
        let alert = UIAlertController(title: "SymptomChecker.Personal.Age".localized, message: "\n\n\n\n\n\n\n\n\n\n", preferredStyle: .alert)
        alert.view.addSubview(pickerView)
        
        let okAction = UIAlertAction(title: "OK".localized, style: .default) { [weak self] action in
            guard let self = self else {
                return
            }
            
            let age = self.ages[self.pickerView.selectedRow(inComponent: 0)]
            didSelect(age)
        }
        alert.addAction(okAction)
        
        let cancelAction = UIAlertAction(title: "Cancel".localized, style: .cancel)
        alert.addAction(cancelAction)
        
        return alert
    }
}

// MARK: UIPickerViewDataSource
extension SelectAgeAlert: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        ages.count
    }
}

// MARK: UIPickerViewDelegate
extension SelectAgeAlert: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        "\(ages[row])"
    }
}
