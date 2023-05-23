//
//  MessageBus.swift
//  CyberMe
//
//  Created by Corkine on 2023/5/20.
//

import Foundation
import Combine

enum Command {
    case ticketAdd(ticketId: String)
    case ticketDelete(ticketId: String)
    case shortLinkAdd(shortUrl: String)
    case expressAdd(id: String)
    case expressDelete(id: String)
    func dispatch(afterSeconds: Int = 0) {
        if afterSeconds != 0 {
            DispatchQueue.global(qos: .background).asyncAfter(deadline: .now() + .seconds(afterSeconds)) {
                bus.send(self)
            }
        } else {
            bus.send(self)
        }
    }
}

var subscriptions = Set<AnyCancellable>()

var bus = PassthroughSubject<Command,Never>()

enum CommandRegister {
    static func dashboardRegCommand(service:CyberService) {
        print("reg dashboard command start...")
        bus.filter { cmd in
            if case .expressAdd = cmd {
                return true
            } else if case .expressDelete = cmd {
                return true
            }
            return false
        }
        .sink(receiveValue: { cmd in
            print("fetch summary because of \(cmd) added")
            service.fetchSummary()
        })
        .store(in: &subscriptions)
    }
}
