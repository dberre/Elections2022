//
//  DataModelSubscription.swift
//  Elections2022
//
//  Created by Dominique Berre on 01/07/2022.
//

import Foundation
import Combine
import TabularData

struct DataModelPublisher: Publisher {
    let dataModel: DataModel
    let department: String
    let circo: Int
    
    typealias Output = [PoolingResult]
    
    typealias Failure = Error
    
    func receive<S>(subscriber: S) where S : Subscriber, Failure == S.Failure, [PoolingResult] == S.Input {
        let subscription = DataModelSubscription(
            dataModel: dataModel,
            department: department,
            circo: circo,
            downStream: subscriber,
            combineIdentifier: CombineIdentifier())
        
        subscriber.receive(subscription: subscription)
    }

    struct DataModelSubscription<DownStream: Subscriber>: Subscription where DownStream.Input == [PoolingResult]  {
        let dataModel: DataModel
        let department: String
        let circo: Int
        let downStream: DownStream
        var combineIdentifier: CombineIdentifier

        func request(_ demand: Subscribers.Demand) {
            let extract = dataModel.result(department: department, circoCode: circo)
            _ = downStream.receive(extract)
        }
        
        func cancel() {
            // not cancellable
        }
    }
}
