//
//  Tip.swift
//  blendr
//
//  Created by Andrew Nielson on 7/7/24.
//

import Foundation
import TipKit


struct SelectAlcoholTip: Tip {
    var title: Text {
        Text("Select Alcohol Preference")
            .foregroundStyle(Color(hex: 0x002247))
    }
    
    var message: Text? {
        Text("Tap here every time you generate to specify your alcohol preferences.")
    }
}

struct SwipeIndicatorsTip: Tip {
    var title: Text {
        Text("Handling Your Recipes")
            .foregroundStyle(Color(hex: 0x002247))
    }
    
    var message: Text? {
        Text("Swipe **right** to save the recipe to your cookbook.\n\nSwipe **left** to discard the recipe.\n\n**OR**\n\nUse the buttons below.")
    }
}

struct StoreTip: Tip {
    static let homeViewVisitedEvent = Event(id: "homeViewVisited")
    
    var title: Text {
        Text("Get Swipes")
            .foregroundStyle(Color(hex: 0x002247))
    }
    
    var message: Text? {
        Text("Earn or buy swipes from the store.")
    }
    
    var rules: [Rule] {
        #Rule(Self.homeViewVisitedEvent) { event in
            event.donations.count > 1
        }
    }
}

struct CardStackTip: Tip {
    static let recipesGeneratedEvent = Event(id: "recipesGeneratedEvent")
    
    var title: Text {
        Text("Currently Generated Recipes")
            .foregroundStyle(Color(hex: 0x002247))
    }
    
    var message: Text? {
        Text("Don't lose your progress, swipe through your most recently generated recipes.")
    }
    
    var rules: [Rule] {
        #Rule(Self.recipesGeneratedEvent) { event in
            event.donations.count > 0
        }
    }
}
