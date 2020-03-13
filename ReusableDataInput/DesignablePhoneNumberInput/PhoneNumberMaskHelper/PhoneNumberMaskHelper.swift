//
//  PhoneNumberMaskHelper.swift
//  DesignableDataInput
//
//  Created by Oleksandr Pronin on 15.12.17.
//  Copyright © 2017 Alexander Pronin. All rights reserved.
//

import Foundation

final public class PhoneNumberMaskHelper {
    public init() {
        let podBundle = Bundle(for: PhoneNumberMaskHelper.self)
//        print("[\(type(of: self)) \(#function)] podBundle: \(podBundle)")
        guard let bundleURL = podBundle.url(forResource: SDKUtility.frameworkName(), withExtension: "bundle") else {
            fatalError("Could not find bundle URL for \(SDKUtility.frameworkName())")
        }
//        print("[\(type(of: self)) \(#function)] bundleURL: \(bundleURL)")
        guard let bundle = Bundle(url: bundleURL) else {
            fatalError("Could not load the bundle for \(SDKUtility.frameworkName())")
        }
//        print("[\(type(of: self)) \(#function)] bundle: \(bundle)")
        guard let plistPath = bundle.path(forResource: "PhoneNumberMaskHelper", ofType: "plist") else {
            fatalError("Not found PhoneNumberMaskHelper.plist")
        }
//        print("[\(type(of: self)) \(#function)] plistPath: \(plistPath)")
        let plistXML = FileManager.default.contents(atPath: plistPath)!
        do {//convert the data to a dictionary and handle errors.
            var propertyListForamt =  PropertyListSerialization.PropertyListFormat.xml
            guard let plistData: [String: String] = try PropertyListSerialization.propertyList(from: plistXML, options: .mutableContainersAndLeaves, format: &propertyListForamt) as? [String: String] else {
                preconditionFailure("Unable to parse plist!")
            }
            self.phoneNumberMaskDictionary = plistData
        } catch {
            print("[\(type(of: self)) \(#function)] error reading plist: \(error)")
            self.phoneNumberMaskDictionary = [:]
        }
    }
    public func phoneNumberMask(byISOCode perhapsISOCode: String?) -> String? {
        guard
            let isoCode = perhapsISOCode,
            let mask = self.phoneNumberMaskDictionary[isoCode.uppercased()]
        else
        {
            return nil
        }
        if mask.isEmpty {
            return nil
        }
        return mask
    }
    // MARK: - Private
    fileprivate var phoneNumberMaskDictionary: [String: String]
}
