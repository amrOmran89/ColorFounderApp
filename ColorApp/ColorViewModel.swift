//
//  ColorViewModel.swift
//  ColorApp
//
//  Created by Amr Omran on 28.10.24.
//

import Foundation
import Combine

class ColorViewModel: ObservableObject {
    
    @Published var colorModel: ColorModel?
    @Published var error: Error?
    
    @Published var red = ""
    @Published var green = ""
    @Published var blue = ""
    
    var cancellable = Set<AnyCancellable>()
    
    init() {
        Publishers.CombineLatest3($red, $green, $blue)
            .filter {
                !$0.0.isEmpty && !$0.1.isEmpty && !$0.2.isEmpty
            }
            .debounce(for: .seconds(0.5), scheduler: RunLoop.main)
            .sink { [weak self] r, g, b in
                guard let self, let redInt = UInt8(r), let greenInt = UInt8(g), let blueInt = UInt8(b) else { return }
                if redInt <= 255 && greenInt <= 255 && blueInt <= 255 {
                    getColor(type: .rgb(r: redInt, g: greenInt, b: blueInt))
                }
            }
            .store(in: &cancellable)
    }
    
    enum ColorType {
        case hex(value: String)
        case rgb(r: UInt8, g: UInt8, b: UInt8)
    }
    
    func getColor(type: ColorType) {
        Task {
            do {
                try await getColorApi(type: type)
            } catch let err {
                await MainActor.run {
                    self.error = err
                }
            }
        }
    }
    
    private func getColorApi(type: ColorType) async throws {
        let colorQuery = switch type {
        case .hex(let value):
            "hex=\(value)"
        case .rgb(let r, let g, let b):
            "rgb=\(r),\(g),\(b)"
        }
        let urlString = "https://www.thecolorapi.com/id?\(colorQuery)&format=json"
        guard let url = URL(string: urlString) else {
            throw ColorError.wrongUrl
        }
        let urlRequest = URLRequest(url: url)
        
        let (data, response) = try await URLSession.shared.data(for: urlRequest)
      
        guard let response = response as? HTTPURLResponse else {
            throw ColorError.cannotCastItToHTTPURLResponse
        }
        guard response.statusCode == 200 else {
            throw ColorError.statusCode(response.statusCode)
        }
        
        let json = try JSONDecoder().decode(ColorModel.self, from: data)
        
        await MainActor.run {
            colorModel = json
        }
    }
}

enum ColorError: Error {
    case wrongUrl
    case cannotCastItToHTTPURLResponse
    case statusCode(Int)
}
