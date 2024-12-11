//
//  ContentView.swift
//  ColorApp
//
//  Created by Amr Omran on 28.10.24.
//

import SwiftUI
import Combine

struct ContentView: View {
    
    @StateObject var viewModel = ColorViewModel()
    @State private var hexText = ""
    @State private var color = 0
    
    var body: some View {
        VStack {
            Text(viewModel.colorModel?.name.value ?? "Black")
                .font(.system(size: 40, weight: .black, design: .rounded))
                .frame(width: 300)
                .padding(.top)
            
            RoundedRectangle(cornerRadius: 40, style: .continuous)
                .fill(Color(hex: viewModel.colorModel?.hex.value ?? "000000"))
                .frame(width: 250, height: 250)
            
            Picker("", selection: $color) {
                Text("Hex").tag(0)
                Text("RGB").tag(1)
            }
            .pickerStyle(.palette)
            .frame(width: 250)
            .padding(.vertical)
            
            if color == 0 {
                TextField("#000000", text: $hexText)
                    .textFieldStyle(.roundedBorder)
                    .onReceive(Just(hexText)) { _ in limitText(6) }
                    .frame(width: 120)
                
                VStack {
                    if let rgb = viewModel.colorModel?.rgb.value {
                        Text(rgb)
                    }
                }
                .frame(height: 20)
            } else {
                HStack {
                    TextField("r", text: $viewModel.red)
                    TextField("g", text: $viewModel.green)
                    TextField("b", text: $viewModel.blue)
                }
                .textFieldStyle(.roundedBorder)
                .frame(width: 240)
                
                VStack {
                    if let hex = viewModel.colorModel?.hex.value {
                        Text(hex)
                    }
                }
                .frame(height: 20)
            }
            

            Spacer()
                .frame(height: 40)
        }
        .padding(.vertical)
        .padding(.horizontal, 40)
        .onChange(of: hexText) { oldValue, newValue in
            if newValue != oldValue, newValue.count == 6 {
                viewModel.getColor(type: .hex(value: newValue))
            }
        }
        .onChange(of: color) { oldValue, newValue in
            viewModel.colorModel = nil
            hexText = ""
            viewModel.red = ""
            viewModel.green = ""
            viewModel.blue = ""
        }
    }
    
    func limitText(_ upper: Int) {
        if hexText.count > upper {
            hexText = String(hexText.prefix(upper))
        }
    }
}

#Preview {
    ContentView()
}


struct SearchText: View {
    @Binding var text: String
   
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Image(systemName: "magnifyingglass")
                TextField("#000000", text: $text)
                    .autocorrectionDisabled()
//                    .textInputAutocapitalization(.characters)
                    .onReceive(Just(text)) { _ in limitText(6) }
            }
        }
        .padding(10)
        .frame(width: 250)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .overlay {
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.gray)
        }
    }
    
    func limitText(_ upper: Int) {
        if text.count > upper {
            text = String(text.prefix(upper))
        }
    }
}
