//
//  main.swift
//  SimplePromise
//
//  Created by Henry on 9/5/17.
//  Copyright © 2017 Henry Tsai. All rights reserved.
//

import Foundation

Promise.first { completion in
    DispatchQueue.global().async {
        print(1)
        sleep(3)
        completion(true)
    }
}.then { completion in
    DispatchQueue.global().async {
        print(2)
        sleep(1)
        completion(true)
    }
}.then { completion in
    DispatchQueue.global().async {
        print(3)
        sleep(1)
        completion(true)
    }
}.fail {
    print("failed")
}.done {
    print("done")
}.run()

sleep(10)


Promise.first { completion in
    DispatchQueue.global().async {
        print(1)
        sleep(3)
        completion(true)
    }
}.then { completion in
    DispatchQueue.global().async {
        print(2)
        sleep(1)
        completion(true)
    }
}.then { completion in
    DispatchQueue.global().async {
        print(3)
        sleep(1)
        completion(false)
    }
}.fail {
    print("failed")
}.done {
    print("done")
}.run()

sleep(10)
