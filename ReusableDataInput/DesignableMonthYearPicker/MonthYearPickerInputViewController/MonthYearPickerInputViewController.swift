//
//  PickerInputViewController.swift
//  DesignableDataInput
//
//  Created by Oleksandr Pronin on 25.09.17.
//  Copyright © 2017 Aleksandr Pronin. All rights reserved.
//

import UIKit

protocol MonthYearPickerInputViewControllerDelegate: NSObjectProtocol {
    func pickerInputViewControllerDidCancel(_ controller: MonthYearPickerInputViewController)
    func pickerInput(_ controller: MonthYearPickerInputViewController, doneWithMonth month: Int, year: Int)
    func pickerInput(_ controller: MonthYearPickerInputViewController, changedWithMonth month: Int, year: Int)
    func pickerInput(_ controller: MonthYearPickerInputViewController, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView?
    func pickerInput(_ controller: MonthYearPickerInputViewController, titleForRow row: Int, forComponent component: Int) -> String?
    func pickerInputRowHeight(_ controller: MonthYearPickerInputViewController) -> CGFloat?
}

class MonthYearPickerInputViewController: UIViewController {
    // MARK: - Public
    @IBOutlet var toolbar: UIToolbar!
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    @IBOutlet weak var doneButton: UIBarButtonItem!
    public weak var delegate: MonthYearPickerInputViewControllerDelegate?
    public var font: UIFont?
    public var tintColor: UIColor? {
        didSet {
            self.cancelButton.tintColor = tintColor
            self.doneButton.tintColor = tintColor
            self.dividerView.backgroundColor = tintColor
        }
    }
    var textColor: UIColor? = .black
    public var backgroundColor: UIColor? {
        didSet {
            self.picker.backgroundColor = backgroundColor
            self.toolbar.backgroundColor = backgroundColor
        }
    }
    public var month: Int {
        get {
            return self._month
        }
        set {
            guard self._month != newValue else {
                return
            }
            self._month = newValue
            if newValue <= 0 {
                self._month = 1
            }
            if newValue > 12 {
                self._month = 12
            }
            self.picker.selectRow(self._month - 1, inComponent: 0, animated: false)
        }
    }
    public var year: Int = 0 {
        didSet {
            guard year != oldValue else {
                return
            }
            guard let indexOfYear = self.years.firstIndex(of: year) else {
                return
            }
            self.picker.selectRow(indexOfYear, inComponent: 1, animated: false)
        }
    }
    public var maximumYears: Int = 11
    // MARK: - Private properties
    @IBOutlet fileprivate weak var picker: UIPickerView!
    @IBOutlet fileprivate weak var dividerView: UIView!
    fileprivate let rowHeightForComponent: CGFloat = 44.0
    fileprivate var months: [String]!
    fileprivate var years: [Int]!
    fileprivate var _month: Int = 0
    // MARK: - View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupViewsOnLoad()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    // MARK: - Actions
    @IBAction fileprivate func cancelAction(_ sender: UIBarButtonItem) {
        self.delegate?.pickerInputViewControllerDidCancel(self)
    }
    @IBAction fileprivate func doneAction(_ sender: UIBarButtonItem) {
        guard let delegate = self.delegate else { return }
        self.month = self.picker.selectedRow(inComponent: 0) + 1
        self.year = self.years[self.picker.selectedRow(inComponent: 1)]
        delegate.pickerInput(self, doneWithMonth: self.month, year: self.year)
    }
    // MARK: - Private
    fileprivate func setupViewsOnLoad() {
        #if !TARGET_INTERFACE_BUILDER
        self.picker.dataSource = self
        self.picker.delegate = self
        #endif
        var yearsArray: [Int] = []
        var currentYear = NSCalendar(identifier: NSCalendar.Identifier.gregorian)!.component(.year, from: NSDate() as Foundation.Date)
        for _ in 1...self.maximumYears {
            yearsArray.append(currentYear)
            currentYear += 1
        }
        self.years = yearsArray
        var monthsArray: [String] = []
        /*
         var monthCount = 0
         for _ in 1...12 {
         monthsArray.append(DateFormatter().monthSymbols[monthCount].capitalized)
         monthCount += 1
         }
         */
        for monthCount in 1...12 {
            monthsArray.append("\(String(format: "%02d", monthCount))")
        }
        self.months = monthsArray
        let currentMonth = NSCalendar(identifier: NSCalendar.Identifier.gregorian)!.component(.month, from: NSDate() as Foundation.Date)
        self.picker.selectRow(currentMonth - 1, inComponent: 0, animated: false)
    }
}

extension MonthYearPickerInputViewController: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int { 2 }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch component {
        case 0:
            return self.months.count
        case 1:
            return self.years.count
        default:
            return 0
        }
    }
}

extension MonthYearPickerInputViewController: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        if let rowHeightForComponent = self.delegate?.pickerInputRowHeight(self) {
            // try to get height from delegate
            return rowHeightForComponent
        }
        return self.rowHeightForComponent
    }
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        if let delegateView = self.delegate?.pickerInput(self, viewForRow: row, forComponent: component, reusing: view) {
            return delegateView
        }
        let label: UILabel
        if view == nil || !(view is UILabel) {
            let frame = CGRect(
                x: 0,
                y: 0,
                width: self.picker.rowSize(forComponent: component).width,
                height: self.picker.rowSize(forComponent: component).height
            )
            label = UILabel(frame: frame)
            label.textAlignment = .center
            let title: String
            if let delegateTitle = self.delegate?.pickerInput(self, titleForRow: row, forComponent: component) {
                // try to get title from delegate
                title = delegateTitle
            } else {
                switch component {
                case 0:
                    title = self.months[row]
                case 1:
                    title = "\(self.years[row])"
                default:
                    title = ""
                }
            }
            label.text = title
            if let font = self.font {
                label.font = font
            }
        } else {
            guard let safeLabel = view as? UILabel else {
                preconditionFailure("Unable to cast view to UILabel!")
            }
            label = safeLabel
        }
        if let color = self.textColor {
            label.textColor = color
        } else if let color = self.tintColor {
            label.textColor = color
        }
        return label
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        guard let delegate = self.delegate else { return }
        self.month = self.picker.selectedRow(inComponent: 0) + 1
        self.year = self.years[self.picker.selectedRow(inComponent: 1)]
        delegate.pickerInput(self, changedWithMonth: self.month, year: self.year)
    }
}
