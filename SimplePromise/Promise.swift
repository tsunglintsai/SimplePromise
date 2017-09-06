//
//  Promise.swift
//  Test10
//
//  Created by Henry on 9/5/17.
//  Copyright © 2017 Henry Tsai. All rights reserved.
//

import Foundation

class Promise {
    private var serialQueue = DispatchQueue(label: "com.henry.promise.serial.queue")
    private var pending = [((completion: @escaping (Bool)->Void ) -> Void)]()
    private var done: (() -> Void) = {}
    private var fail: (() -> Void) = {}
    private var failed: Bool = false
    private var semaphore = DispatchSemaphore(value: 0)
    static func first(callback: @escaping ((@escaping  (Bool) -> Void ) -> Void)) -> Promise {
        return Promise().then(callback: callback)
    }
    
    var run: () -> Void {
        let serialQueue = self.serialQueue
        let fail = self.fail
        let done = self.done
        var queue = self.pending
        var semaphore = self.semaphore
        var failed = self.failed
        func resolve() -> () {
            serialQueue.async {
                while !queue.isEmpty {
                    if failed {
                        fail()
                        queue.removeAll()
                        return
                    }
                    let closure = queue.removeFirst()
                    closure() { (success: Bool) in
                        if !success {
                            failed = true
                        }
                        semaphore.signal()
                    }
                    semaphore.wait()
                }
                if failed {
                    fail()
                } else {
                    done()
                }
            }
        }
        return resolve
    }
    
    func then(callback: @escaping ((@escaping  (Bool)->Void ) -> Void)) -> Promise {
        self.pending.append(callback)
        return self
    }
    
    func fail(fail: @escaping (() -> ())) -> Promise {
        self.fail = fail
        return self
    }
    
    func done(done:@escaping (() -> ())) -> Promise {
        self.done = done
        return self
    }
}
