//
//  CommonModel.swift
//  MyPT
//
//  Created by techsaga corp on 21/02/25.
//

import Foundation

//MARK: ------------ SECTION MODEL
struct SectionModel {
    let title: String
    let items: [String]
}


//MARK: ------------ HYDRATION MODEL
struct HydrationModel {
    let title: String
    var items: [HydrationDataModel]
    
    // Function to update quantity
      mutating func updateQuantity(for subTitle: String, newQuantity: String) {
          if let index = items.firstIndex(where: { $0.subTitle.trimmingCharacters(in: .whitespaces) == subTitle }) {
              items[index].qnty = newQuantity
          }
      }
}

//MARK: ------------ HYDRATION MODEL
struct HydrationDataModel {
    let subTitle: String
    var qnty: String
    
}
