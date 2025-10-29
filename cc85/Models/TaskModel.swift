//
//  TaskModel.swift
//  cc85
//
//  Session ID: 2204
//

import Foundation

enum TaskCategory: String, Codable, CaseIterable {
    case work = "Work"
    case personal = "Personal"
    case health = "Health"
    case learning = "Learning"
    case other = "Other"
    
    var icon: String {
        switch self {
        case .work: return "briefcase.fill"
        case .personal: return "person.fill"
        case .health: return "heart.fill"
        case .learning: return "book.fill"
        case .other: return "star.fill"
        }
    }
}

enum TaskPriority: String, Codable, CaseIterable {
    case low = "Low"
    case medium = "Medium"
    case high = "High"
}

struct TaskModel: Codable, Identifiable {
    let id: UUID
    var title: String
    var description: String
    var category: TaskCategory
    var priority: TaskPriority
    var isCompleted: Bool
    var createdAt: Date
    var completedAt: Date?
    var pomodoroCount: Int
    
    init(id: UUID = UUID(), title: String, description: String = "", category: TaskCategory = .other, priority: TaskPriority = .medium, isCompleted: Bool = false, createdAt: Date = Date(), completedAt: Date? = nil, pomodoroCount: Int = 0) {
        self.id = id
        self.title = title
        self.description = description
        self.category = category
        self.priority = priority
        self.isCompleted = isCompleted
        self.createdAt = createdAt
        self.completedAt = completedAt
        self.pomodoroCount = pomodoroCount
    }
    
    mutating func toggleCompletion() {
        isCompleted.toggle()
        completedAt = isCompleted ? Date() : nil
    }
}

struct PomodoroSession: Codable, Identifiable {
    let id: UUID
    var duration: TimeInterval
    var timeRemaining: TimeInterval
    var isActive: Bool
    var isBreak: Bool
    var completedSessions: Int
    
    init(id: UUID = UUID(), duration: TimeInterval = 1500, timeRemaining: TimeInterval = 1500, isActive: Bool = false, isBreak: Bool = false, completedSessions: Int = 0) {
        self.id = id
        self.duration = duration
        self.timeRemaining = timeRemaining
        self.isActive = isActive
        self.isBreak = isBreak
        self.completedSessions = completedSessions
    }
    
    var progress: Double {
        return 1.0 - (timeRemaining / duration)
    }
    
    var formattedTime: String {
        let minutes = Int(timeRemaining) / 60
        let seconds = Int(timeRemaining) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

