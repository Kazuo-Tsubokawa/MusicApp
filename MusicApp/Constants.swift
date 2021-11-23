//
//  Constants.swift
//  MusicApp
//
//  Created by 坪川和生 on 2021/11/22.
//

import Foundation

struct Constants {
    static let shared = Constants()
    private init() {}
    
    let baseUrl = "http://localhost/api"
    let loginUrl = "http://localhost/api/login"
    let registerUrl = "http://localhost/api/register"
    let service = "MusicApp"
}
