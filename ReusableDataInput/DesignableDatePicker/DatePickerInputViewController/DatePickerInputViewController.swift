//
//  DatePickerInputViewController.swift
//  DesignableDataInput
//
//  Created by Oleksandr Pronin on 09.10.17.
//  Copyright © 2017 Alexander Pronin. All rights reserved.
//

import UIKit

protocol DatePickerInputViewControllerDelegate: class, NSObjectProtocol {
    func datePickerInputViewControllerDidCancel(_ controller: DatePickerInputViewController)
    func datePickerInput(_ controller: DatePickerInputViewController, doneWithDate date: NSDate)
    func datePickerInput(_ controller: DatePickerInputViewController, changedWithDate date: NSDate)
}

class DatePickerInputViewController: UIViewController {
    // MARK: - Public
    @IBOutlet weak var toolbar: UIToolbar!
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    @IBOutlet weak var doneButton: UIBarButtonItem!
    @IBOutlet weak var datePicker: UIDatePicker!
    public weak var delegate: DatePickerInputViewControllerDelegate?
    var tintColor: UIColor? {
        didSet {
            self.cancelButton.tintColor = tintColor
            self.doneButton.tintColor = tintColor
            self.dividerView.backgroundColor = tintColor
            // TODO: need to setup textColor for date picker
        }
    }
    var backgroundColor: UIColor? {
        didSet {
            self.datePicker.backgroundColor = backgroundColor
            self.toolbar.backgroundColor = backgroundColor
        }
    }
    var selectedDate: NSDate?
    // MARK: - Private properties
    @IBOutlet fileprivate weak var dividerView: UIView!
    // MARK: - View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupViewsOnLoad()
    }
    override func viewWillAppear(_ animated: Bool) {
        //        print("[\(type(of: self)) \(#function)]")
        DispatchQueue.main.async {
            guard let selectedDate = self.selectedDate else { return }
            self.datePicker.date = selectedDate as Foundation.Date
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    // MARK: - Actions
    @IBAction fileprivate func cancelAction(_ sender: UIBarButtonItem) {
        self.delegate?.datePickerInputViewControllerDidCancel(self)
    }
    @IBAction fileprivate func doneAction(_ sender: UIBarButtonItem) {
        self.selectedDate = self.datePicker.date as NSDate
        guard let selectedDate = self.selectedDate else {
            return
        }
        self.delegate?.datePickerInput(self, doneWithDate: selectedDate)
    }
    @objc fileprivate func datePickerDidChangeValue(sender: UIDatePicker) {
        self.delegate?.datePickerInput(self, changedWithDate: sender.date as NSDate)
        //        print("[\(type(of: self)) \(#function)] date: \(sender.date.description)")
    }
    // MARK: - Private
    fileprivate func setupViewsOnLoad() {
        #if !TARGET_INTERFACE_BUILDER
        self.datePicker.addTarget(self, action: #selector(datePickerDidChangeValue(sender:)), for: .valueChanged)
        #endif
    }
}
