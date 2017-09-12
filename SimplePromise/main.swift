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
        completion(Promise.Resolution.fulfilled)
    }
}.then { completion in
    DispatchQueue.global().async {
        print(2)
        sleep(1)
        completion(Promise.Resolution.fulfilled)
    }
}.then { completion in
    DispatchQueue.global().async {
        print(3)
        sleep(1)
        completion(Promise.Resolution.fulfilled)
    }
}.fail { (error) in
    print("failed:\(error)")
}.done {
    print("done")
}.run()

sleep(10)


Promise.first { completion in
    DispatchQueue.global().async {
        print(1)
        sleep(3)
        completion(Promise.Resolution.fulfilled)
    }
}.then { completion in
    DispatchQueue.global().async {
        print(2)
        sleep(1)
        completion(Promise.Resolution.fulfilled)
    }
}.then { completion in
    DispatchQueue.global().async {
        print(3)
        sleep(1)
        completion(Promise.Resolution.rejected(NSError(domain: "", code: 10, userInfo: nil)))
    }
}.fail { (error) in
    print("failed:\(error)")
}.done {
    print("done")
}.run()

sleep(10)

Promise.first { completion in
        DispatchQueue.global().async {
            print(1)
            sleep(3)
            completion(Promise.Resolution.fulfilled)
        }
    }.then { completion in
        DispatchQueue.global().async {
            print(2)
            sleep(1)
            completion(Promise.Resolution.fulfilled)
        }
    }.thenOnMain { completion in
        print(3)
        completion(Promise.Resolution.fulfilled)
    }.then { completion in
        DispatchQueue.global().async {
            print(4)
            sleep(1)
            completion(Promise.Resolution.fulfilled)
        }
    }.fail { (error) in
        print("failed:\(error)")
    }.done {
        print("done")
    }.run()

sleep(20)
