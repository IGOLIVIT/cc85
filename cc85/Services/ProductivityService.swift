//
//  ProductivityService.swift
//  cc85
//
//  Session ID: 2204
//

import Foundation
import Combine

class ProductivityService: ObservableObject {
    @Published var tasks: [TaskModel] = []
    @Published var pomodoroSession: PomodoroSession?
    @Published var userStats: UserStats
    
    private let tasksKey = "GamePlus_Tasks"
    private let statsKey = "GamePlus_UserStats"
    private var timer: Timer?
    
    init() {
        // Load saved tasks
        if let data = UserDefaults.standard.data(forKey: tasksKey),
           let savedTasks = try? JSONDecoder().decode([TaskModel].self, from: data) {
            self.tasks = savedTasks
        }
        
        // Load saved stats
        if let data = UserDefaults.standard.data(forKey: statsKey),
           let savedStats = try? JSONDecoder().decode(UserStats.self, from: data) {
            self.userStats = savedStats
        } else {
            self.userStats = UserStats()
        }
    }
    
    // MARK: - Task Management
    
    func addTask(_ task: TaskModel) {
        tasks.append(task)
        saveTasks()
    }
    
    func updateTask(_ task: TaskModel) {
        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            tasks[index] = task
            saveTasks()
        }
    }
    
    func deleteTask(_ task: TaskModel) {
        tasks.removeAll { $0.id == task.id }
        saveTasks()
    }
    
    func toggleTaskCompletion(_ taskId: UUID) {
        if let index = tasks.firstIndex(where: { $0.id == taskId }) {
            tasks[index].toggleCompletion()
            if tasks[index].isCompleted {
                userStats.totalTasksCompleted += 1
                userStats.totalPoints += 10
                saveStats()
            }
            saveTasks()
        }
    }
    
    func getTasksByCategory(_ category: TaskCategory) -> [TaskModel] {
        return tasks.filter { $0.category == category }
    }
    
    func getIncompleteTasks() -> [TaskModel] {
        return tasks.filter { !$0.isCompleted }.sorted { $0.createdAt > $1.createdAt }
    }
    
    func getCompletedTasks() -> [TaskModel] {
        return tasks.filter { $0.isCompleted }.sorted { ($0.completedAt ?? Date()) > ($1.completedAt ?? Date()) }
    }
    
    // MARK: - Pomodoro Timer
    
    func startPomodoro(duration: TimeInterval = 1500) {
        pomodoroSession = PomodoroSession(duration: duration, timeRemaining: duration, isActive: true, isBreak: false, completedSessions: pomodoroSession?.completedSessions ?? 0)
        
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.updatePomodoroTimer()
        }
    }
    
    func startBreak(duration: TimeInterval = 300) {
        pomodoroSession = PomodoroSession(duration: duration, timeRemaining: duration, isActive: true, isBreak: true, completedSessions: pomodoroSession?.completedSessions ?? 0)
        
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.updatePomodoroTimer()
        }
    }
    
    func pausePomodoro() {
        pomodoroSession?.isActive = false
        timer?.invalidate()
    }
    
    func resumePomodoro() {
        pomodoroSession?.isActive = true
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.updatePomodoroTimer()
        }
    }
    
    func stopPomodoro() {
        timer?.invalidate()
        pomodoroSession = nil
    }
    
    private func updatePomodoroTimer() {
        guard var session = pomodoroSession, session.isActive else { return }
        
        session.timeRemaining -= 1.0
        
        if session.timeRemaining <= 0 {
            timer?.invalidate()
            
            if !session.isBreak {
                session.completedSessions += 1
                userStats.totalPomodorosCompleted += 1
                userStats.totalPoints += 5
                saveStats()
            }
            
            session.isActive = false
            pomodoroSession = session
        } else {
            pomodoroSession = session
        }
    }
    
    // MARK: - Persistence
    
    private func saveTasks() {
        if let encoded = try? JSONEncoder().encode(tasks) {
            UserDefaults.standard.set(encoded, forKey: tasksKey)
        }
    }
    
    private func saveStats() {
        if let encoded = try? JSONEncoder().encode(userStats) {
            UserDefaults.standard.set(encoded, forKey: statsKey)
        }
    }
    
    func resetAllData() {
        timer?.invalidate()
        tasks.removeAll()
        pomodoroSession = nil
        userStats = UserStats()
        UserDefaults.standard.removeObject(forKey: tasksKey)
        UserDefaults.standard.removeObject(forKey: statsKey)
    }
}

