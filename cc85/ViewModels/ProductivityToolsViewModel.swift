//
//  ProductivityToolsViewModel.swift
//  cc85
//
//  Session ID: 2204
//

import Foundation
import SwiftUI
import Combine

class ProductivityToolsViewModel: ObservableObject {
    @Published var productivityService: ProductivityService
    @Published var selectedCategory: TaskCategory?
    @Published var showCompletedTasks: Bool = false
    
    var tasks: [TaskModel] {
        if showCompletedTasks {
            return productivityService.getCompletedTasks()
        } else {
            if let category = selectedCategory {
                return productivityService.getTasksByCategory(category).filter { !$0.isCompleted }
            } else {
                return productivityService.getIncompleteTasks()
            }
        }
    }
    
    var pomodoroSession: PomodoroSession? {
        productivityService.pomodoroSession
    }
    
    var totalTasksCompleted: Int {
        productivityService.userStats.totalTasksCompleted
    }
    
    var totalPomodorosCompleted: Int {
        productivityService.userStats.totalPomodorosCompleted
    }
    
    var totalPoints: Int {
        productivityService.userStats.totalPoints
    }
    
    init(productivityService: ProductivityService) {
        self.productivityService = productivityService
    }
    
    func addTask(title: String, description: String, category: TaskCategory, priority: TaskPriority) {
        let task = TaskModel(title: title, description: description, category: category, priority: priority)
        productivityService.addTask(task)
    }
    
    func updateTask(_ task: TaskModel) {
        productivityService.updateTask(task)
    }
    
    func deleteTask(_ task: TaskModel) {
        productivityService.deleteTask(task)
    }
    
    func toggleTaskCompletion(_ taskId: UUID) {
        productivityService.toggleTaskCompletion(taskId)
        
        // Provide haptic feedback
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }
    
    func startPomodoro(workDuration: TimeInterval) {
        productivityService.startPomodoro(duration: workDuration)
        
        // Schedule notification
        NotificationService.shared.schedulePomodoroCompletion(in: workDuration)
    }
    
    func startBreak(breakDuration: TimeInterval) {
        productivityService.startBreak(duration: breakDuration)
        
        // Schedule notification
        NotificationService.shared.scheduleBreakComplete(in: breakDuration)
    }
    
    func pausePomodoro() {
        productivityService.pausePomodoro()
        NotificationService.shared.cancelNotification(identifier: "pomodoro_complete")
        NotificationService.shared.cancelNotification(identifier: "break_complete")
    }
    
    func resumePomodoro() {
        productivityService.resumePomodoro()
        
        if let session = pomodoroSession {
            if session.isBreak {
                NotificationService.shared.scheduleBreakComplete(in: session.timeRemaining)
            } else {
                NotificationService.shared.schedulePomodoroCompletion(in: session.timeRemaining)
            }
        }
    }
    
    func stopPomodoro() {
        productivityService.stopPomodoro()
        NotificationService.shared.cancelNotification(identifier: "pomodoro_complete")
        NotificationService.shared.cancelNotification(identifier: "break_complete")
    }
}

