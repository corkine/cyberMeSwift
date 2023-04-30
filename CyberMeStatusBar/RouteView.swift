//
//  RouteView.swift
//  CyberMeWGStatusBar
//
//  Created by Corkine on 2023/4/30.
//


import SwiftUI
import SystemConfiguration

func getAllInterfaces() -> [SCNetworkInterface] {
    var interfaces = [SCNetworkInterface]()
    
    let allInterfaces = SCNetworkInterfaceCopyAll() as! [SCNetworkInterface]
    for interface in allInterfaces {
        interfaces.append(interface)
    }
    
    return interfaces
}

func getRoutingTableInfo() -> String {
    let task = Process()
    task.launchPath = "/usr/sbin/netstat"
    task.arguments = ["-rn"]
    
    let pipe = Pipe()
    task.standardOutput = pipe
    task.launch()
    
    let data = pipe.fileHandleForReading.readDataToEndOfFile()
    let output = String(data: data, encoding: .utf8) ?? "Invoke netstat failed"
    
    return output
}

struct RouteInfo: Identifiable {
    var id: String {
        destination + gateway + flags
    }
    var destination: String
    var gateway: String
    var flags: String
}


func parseRoutingTableInfo(_ output: String) -> [RouteInfo] {
    var routeInfos = [RouteInfo]()
    
    let lines = output.components(separatedBy: .newlines)
    for line in lines {
        let fields = line.components(separatedBy: .whitespaces).filter { !$0.isEmpty }
        if fields.count >= 4 && fields.first! != "Destination" {
            let routeInfo = RouteInfo(destination: fields[0], gateway: fields[1], flags: fields[2])
            routeInfos.append(routeInfo)
        }
    }
    
    return routeInfos
}


func getRoutingTableInfo() -> [String: String] {
    var routingTableInfo = [String: String]()
    
    if let routingDict = SCDynamicStoreCopyValue(nil, "State:/Network/Global/IPv4" as CFString) as? [String: Any] {
        print(routingDict)
    }
    
    if let routingDict = SCDynamicStoreCopyValue(nil, "State:/Network/Global/IPv4" as CFString) as? [String: Any],
       let interfaces = routingDict["Interfaces"] as? [String: Any] {
        for (interfaceName, interfaceInfo) in interfaces {
            if let interfaceDict = interfaceInfo as? [String: Any],
               let ipv4 = interfaceDict["IPv4"] as? [String: Any],
               let addresses = ipv4["Addresses"] as? [String] {
                routingTableInfo[interfaceName] = addresses.joined(separator: ", ")
            }
        }
    }
    
    return routingTableInfo
}


struct RouteView: View {
    @State var routes: [RouteInfo] = []
    var body: some View {
        Group {
            if routes.isEmpty {
                HStack(spacing: 10) {
                    ProgressView()
                    Text("Loading...")
                }
            } else {
                HStack {
                    VStack(alignment:.leading) {
                        ForEach(routes[0...2]) { route in
                            Text(route.destination)
                        }
                    }
                    VStack(alignment:.leading) {
                        ForEach(routes[0...2]) { route in
                            Text(route.gateway)
                        }
                    }
                    VStack(alignment:.leading) {
                        ForEach(routes[0...2]) { route in
                            Text(route.flags)
                        }
                    }
                }
                .padding(.horizontal, 10)
                .background(Color.clear)
            }
        }
        .onAppear {
            routes = parseRoutingTableInfo(getRoutingTableInfo())
        }
    }
}

struct RouteView_Previews: PreviewProvider {
    static var previews: some View {
        RouteView()
    }
}

