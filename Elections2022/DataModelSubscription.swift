//
//  DataModelSubscription.swift
//  Elections2022
//
//  Created by Dominique Berre on 01/07/2022.
//

import Foundation
import Combine
import TabularData

// Defines a Publisher to extract asynchronously the result of a request on the whole data
struct DataModelPublisher: Publisher {
    let dataModel: DataModel
    let department: String
    let circo: Int
    
    typealias Output = [PoolingResult]
    typealias Failure = Never
    
    func receive<S>(subscriber: S) where S : Subscriber, Failure == S.Failure, [PoolingResult] == S.Input {
        let subscription = DataModelSubscription(
            dataModel: dataModel,
            department: department,
            circo: circo,
            suscriber: subscriber)
        
        subscriber.receive(subscription: subscription)
    }

    final class DataModelSubscription<S: Subscriber>: Subscription where S.Input == [PoolingResult]  {
        let dataModel: DataModel
        let department: String
        let circo: Int
        var suscriber: S?
        
        internal init(dataModel: DataModel, department: String, circo: Int, suscriber: S? = nil) {
            self.dataModel = dataModel
            self.department = department
            self.circo = circo
            self.suscriber = suscriber
        }

        func request(_ demand: Subscribers.Demand) {
            if demand > 0 {
                let extract = dataModel.result(department: department, circoCode: circo)
                _ = suscriber?.receive(extract)
                suscriber?.receive(completion: .finished)
            }
        }
        
        func cancel() {
            suscriber = nil
        }
    }
}
