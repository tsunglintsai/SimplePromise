//
//  Promise.swift
//  Test10
//
//  Created by Henry on 9/5/17.
//  Copyright © 2017 Henry Tsai. All rights reserved.
//

import Foundation


class Promise {
    enum Resolution {
        case rejected(Error)
        case fulfilled
    }
    
    private struct Task {
        private(set) var runOnMain: Bool = false
        private(set) var closure: TaskClosure
    }
    typealias TaskClosure = ((@escaping (Promise.Resolution) -> Void ) -> Void)
    private var serialQueue = DispatchQueue(label: "com.henry.promise.serial.queue")
    private var pending = [Promise.Task]()
    private var done: (() -> Void) = {}
    private var fail: ((Error) -> Void) = { (error) in }
    private var error: Error?
    private var semaphore = DispatchSemaphore(value: 0)
    static func first(callback: @escaping TaskClosure) -> Promise {
        return Promise().then(callback: callback)
    }
    
    var run: () -> Void {
        let serialQueue = self.serialQueue
        let fail = self.fail
        let done = self.done
        var queue = self.pending
        var semaphore = self.semaphore
        var error = self.error
        func resolve() -> () {
            serialQueue.async {
                while !queue.isEmpty {
                    if let error = error {
                        fail(error)
                        queue.removeAll()
                        return
                    }
                    let task = queue.removeFirst()
                    let runClosure = {
                        task.closure() { (resolution: Promise.Resolution) in
                            switch resolution {
                            case .fulfilled:
                                break
                            case .rejected(let errorForRejection):
                                error = errorForRejection
                            }
                            semaphore.signal()
                        }
                        semaphore.wait()
                    }
                    if task.runOnMain {
                        DispatchQueue.main.sync {
                            runClosure()
                        }
                    } else {
                        runClosure()
                    }
                }
                if let error = error {
                    fail(error)
                } else {
                    done()
                }
            }
        }
        return resolve
    }
    
    func then(callback: @escaping TaskClosure) -> Promise {
        self.pending.append(Promise.Task(runOnMain: false, closure: callback))
        return self
    }
    
    func thenOnMainQueue(callback: @escaping TaskClosure) -> Promise {
        self.pending.append(Promise.Task(runOnMain: true, closure: callback))
        return self
    }
    
    func fail(fail: @escaping ((Error) -> ())) -> Promise {
        self.fail = fail
        return self
    }
    
    func done(done:@escaping (() -> ())) -> Promise {
        self.done = done
        return self
    }
}
