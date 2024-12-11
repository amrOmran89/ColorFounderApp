//
//  ColorInfo.swift
//  ColorApp
//
//  Created by Amr Omran on 28.10.24.
//


import Foundation

struct ColorModel: Codable {
    let hex: Hex
    let rgb: RGB
    let name: Name
    struct Hex: Codable {
        let value: String
        let clean: String
    }

    struct RGB: Codable {
        let fraction: RGBFraction
        let r: Int
        let g: Int
        let b: Int
        let value: String

        struct RGBFraction: Codable {
            let r: Double
            let g: Double
            let b: Double
        }
    }

    struct Name: Codable {
        let value: String
        let distance: Int
    }
}
