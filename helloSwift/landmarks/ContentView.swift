//
//  ContentView.swift
//  helloSwift
//
//  Created by corkine on 2022/8/31.
//

import SwiftUI
import MapKit
import CoreLocation
import Foundation
import Combine

struct ContentView: View {
    @State private var selection: Tab = .featured
    @EnvironmentObject var service:CyberService
    enum Tab { case featured, list }
    @EnvironmentObject var model:ModelData
    var body: some View {
        TabView(selection: $selection) {
            CategoryHome()
                .tabItem {
                    Label("Featured", systemImage: "star")
                }
                .tag(Tab.featured)
            LandmarkList(selectedLandmark: .constant(nil))
                .tabItem {
                    Label("List", systemImage: "list.bullet")
                }
                .tag(Tab.list)
        }
    }
}

struct CategoryHome: View {
    @EnvironmentObject var model:ModelData
    @EnvironmentObject var service:CyberService
    @State private var showingProfile = false
    @State private var showFeature: Landmark?
    var body: some View {
        NavigationView {
            List {
                PageView(pages: model.features.map { FeatureCard(landmark: $0) })
                        .aspectRatio(3 / 2, contentMode: .fit)
                        .listRowInsets(EdgeInsets())
                ForEach(model.categories.keys.sorted(),
                        id:\.self) { key in
                    CategoryRow(categoryName:key,
                                items:model.categories[key]!)
                }.listRowInsets(EdgeInsets())
            }
            .navigationTitle("Featured")
            .listStyle(.inset)
            .toolbar {
                ToolbarItem {
                    Menu {
                        Button {
                            showingProfile.toggle()
                        } label: {
                            Label("User Profile", systemImage: "person.crop.circle")
                        }
                        Button {
                            service.landing = false
                        } label: {
                            Label("EXIT", systemImage: "xmark")
                        }
                    } label: {
                        Label("User Profile", systemImage: "person.crop.circle")
                    }
                }
            }.sheet(isPresented:$showingProfile) {
                ProfileHost().environmentObject(model)
            }
        }
    }
}

struct ProfileHost: View {
    @Environment(\.editMode) var editMode
    @EnvironmentObject var model:ModelData
    @State private var draftProfile = Profile.default
    var body: some View {
        VStack(alignment:.leading, spacing: 20) {
            HStack {
                if editMode?.wrappedValue == .active {
                    Button("Cancel") {
                        draftProfile = model.profile
                        editMode?.animation().wrappedValue = .inactive
                    }
                }
                Spacer()
                EditButton()
            }
            if editMode?.wrappedValue == .inactive {
                ProfileSummary(profile: model.profile)
            } else {
                ProfileEditor(profile: $draftProfile)
                    .onAppear {
                        draftProfile = model.profile
                    }
                    .onDisappear {
                        model.profile = draftProfile
                    }
            }
        }.padding()
    }
}

struct ProfileSummary: View {
    @EnvironmentObject var modelData: ModelData
    var profile: Profile
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 10) {
                Text(profile.username)
                    .bold()
                    .font(.title)
                Text("Notifications: \(profile.prefersNotifications ? "On": "Off" )")
                Text("Seasonal Photos: \(profile.seasonalPhoto.rawValue)")
                Text("Goal Date: ") + Text(profile.goalDate, style: .date)
                Divider()
                VStack(alignment: .leading) {
                    Text("Completed Badges")
                        .font(.headline)
                    ScrollView(.horizontal) {
                        HStack {
                            HikeBadge(name: "First Hike")
                            HikeBadge(name: "Earth Day")
                                .hueRotation(Angle(degrees: 90))
                            HikeBadge(name: "Tenth Hike")
                                .grayscale(0.5)
                                .hueRotation(Angle(degrees: 45))
                        }
                        .padding(.bottom)
                    }
                }
                Divider()
                VStack(alignment: .leading) {
                    Text("Recent Hikes")
                        .font(.headline)
                    HikeView(hike: modelData.hikes[0])
                }
            }
            .padding()
        }
    }
}

struct ProfileEditor: View {
    @Binding var profile: Profile
    var dateRange:ClosedRange<Date> {
        Calendar.current.date(byAdding: .year, value: -1, to: profile.goalDate)!
        ...
        Calendar.current.date(byAdding: .year, value: 1, to: profile.goalDate)!
    }
    var body: some View {
        List {
            HStack {
                Text("Username").bold()
                Divider()
                TextField("Username", text: $profile.username)
            }
            Toggle(isOn: $profile.prefersNotifications) {
                Text("Enable Notification").bold()
            }
            VStack(alignment:.leading, spacing: 20) {
                Text("Seasonal Photo").bold()
                Picker("Seasonal Photo", selection: $profile.seasonalPhoto) {
                    ForEach(Profile.Season.allCases) { s in
                        Text(s.id).tag(s)
                    }
                }.pickerStyle(.segmented)
            }
            DatePicker(selection: $profile.goalDate, in: dateRange,
                       displayedComponents: .date) {
                Text("Goal Date").bold()
            }
        }
    }
}

struct CategoryRow: View {
    var categoryName:String
    var items:[Landmark]
    var body: some View {
        VStack(alignment:.leading) {
            Text(categoryName)
                .font(.headline)
                .padding(.leading, 15)
                .padding(.top, 15)
                .padding(.bottom, -5)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(alignment: .top, spacing: 0) {
                    ForEach(items) { land in
                        NavigationLink{
                            LandmarkDetail(land: land)
                        } label: {
                            CategoryItem(land:land)
                        }
                    }
                }
            }.frame(height:185)
        }
    }
}

struct CategoryItem: View {
    var land:Landmark
    var body: some View {
        VStack(alignment: .leading) {
            land.image.renderingMode(.original)
                .resizable()
                .frame(width: 155, height: 144)
                .cornerRadius(5)
            Text(land.name)
                .foregroundColor(.primary)
                .font(.caption)
        }.padding(.leading, 15)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var model = ModelData()
    static var previews: some View {
//        FavoriteButton(isSet: .constant(true))
//            .previewLayout(.fixed(width: 300, height: 70))
//        LandmarkDetail(land: (model.landmarks)[3])
//            .environmentObject(model)
        ContentView()
            .preferredColorScheme(.dark)
            .environmentObject(model)
//        ProfileSummary(profile: Profile.default)
//            .environmentObject(model)
//        ProfileHost()
//            .environmentObject(model)
//        ProfileEditor(profile: .constant(Profile.default))
//            .environmentObject(model)
//            .previewDevice("iPhone 11")
//        Group {
//            LandmarkRow(land: landmarks[0])
//            LandmarkRow(land: landmarks[1])
//        }.previewLayout(.fixed(width: 300, height: 70))
    }
}
