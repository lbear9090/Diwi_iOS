//
// SKProduct+LocalizedPrice.swift
// SwiftyStoreKit
//
// Created by Andrea Bizzotto on 19/10/2016.
// Copyright (c) 2015 Andrea Bizzotto (bizz84@gmail.com)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import StoreKit

public extension SKProduct {

    var localizedPrice: String? {
        return priceFormatter(locale: priceLocale).string(from: price)
    }

    var localizedPriceWithStrikethroughStyle: NSMutableAttributedString? {
        let attributeString: NSMutableAttributedString =  NSMutableAttributedString(string: localizedPrice ?? "")
        attributeString.addAttribute(NSAttributedString.Key.strikethroughStyle, value: 2, range: NSMakeRange(0, attributeString.length))
        return attributeString
    }

    var localizedPriceWithNormalStyle: NSMutableAttributedString? {
        let attributeString: NSMutableAttributedString =  NSMutableAttributedString(string: localizedPrice ?? "")
        return attributeString
    }

    private func priceFormatter(locale: Locale) -> NumberFormatter {
        let formatter = NumberFormatter()
        //CWC-669: if the price in the local currency is greater than 10, round down the price and eliminate any decimals in the price
        if(price.floatValue.truncatingRemainder(dividingBy: 1) == 0){
            formatter.maximumFractionDigits = 0
        }
        formatter.locale = locale
        formatter.numberStyle = .currency
        return formatter
    }
}

@available(iOS 11.2, *)
extension SKProductDiscount {

    public func localizedPrice(locale: Locale) -> String? {
        return priceFormatter(locale: locale).string(from: price)
    }

    public func localizedPriceWithAttributedNormalStyle(locale: Locale) -> NSMutableAttributedString? {
        let attributeString: NSMutableAttributedString =  NSMutableAttributedString(string: localizedPrice(locale: locale) ?? "")
        return attributeString
    }

    private func priceFormatter(locale: Locale) -> NumberFormatter {
        let formatter = NumberFormatter()
        formatter.locale = locale
        formatter.numberStyle = .currency
        return formatter
    }

}
