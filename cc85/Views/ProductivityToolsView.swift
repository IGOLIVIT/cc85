//
//  ProductivityToolsView.swift
//  cc85
//
//  Session ID: 2204
//

import SwiftUI

struct ProductivityToolsView: View {
    @ObservedObject var viewModel: ProductivityToolsViewModel
    let preferences: AppPreferencesModel
    @State private var showAddTask = false
    @State private var showPomodoro = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(hex: "FFFFFF")
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Stats Header
                    StatsHeaderView(viewModel: viewModel, preferences: preferences)
                        .padding()
                    
                    // Category Filter
                    CategoryFilterView(selectedCategory: $viewModel.selectedCategory)
                        .padding(.horizontal)
                        .padding(.bottom, 10)
                    
                    // Toggle Completed Tasks
                    Toggle("Show Completed", isOn: $viewModel.showCompletedTasks)
                        .padding(.horizontal)
                        .padding(.vertical, 8)
                        .tint(Color(hex: "FF3C00"))
                    
                    // Tasks List
                    if viewModel.tasks.isEmpty {
                        EmptyTasksView()
                    } else {
                        ScrollView {
                            VStack(spacing: 12) {
                                ForEach(viewModel.tasks) { task in
                                    TaskRowView(task: task, viewModel: viewModel)
                                }
                            }
                            .padding()
                        }
                    }
                }
            }
            .navigationTitle("Productivity")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { showPomodoro = true }) {
                        Image(systemName: "timer")
                            .foregroundColor(Color(hex: "FF3C00"))
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showAddTask = true }) {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(Color(hex: "FF3C00"))
                    }
                }
            }
            .sheet(isPresented: $showAddTask) {
                AddTaskView(viewModel: viewModel)
            }
            .sheet(isPresented: $showPomodoro) {
                PomodoroView(viewModel: viewModel, preferences: preferences)
            }
        }
    }
}

struct StatsHeaderView: View {
    @ObservedObject var viewModel: ProductivityToolsViewModel
    let preferences: AppPreferencesModel
    
    var body: some View {
        HStack(spacing: 15) {
            MiniStatCard(icon: "flame.fill", value: "\(preferences.dailyStreak)", label: "Streak")
            MiniStatCard(icon: "checkmark.circle.fill", value: "\(viewModel.totalTasksCompleted)", label: "Tasks")
            MiniStatCard(icon: "timer", value: "\(viewModel.totalPomodorosCompleted)", label: "Focus")
            MiniStatCard(icon: "star.fill", value: "\(viewModel.totalPoints)", label: "Points")
        }
    }
}

struct MiniStatCard: View {
    let icon: String
    let value: String
    let label: String
    
    var body: some View {
        VStack(spacing: 5) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(Color(hex: "FF3C00"))
            
            Text(value)
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.black)
            
            Text(label)
                .font(.system(size: 10))
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(hex: "FFFFFF"))
                .shadow(color: Color.black.opacity(0.08), radius: 5, x: 3, y: 3)
                .shadow(color: Color.white.opacity(0.7), radius: 5, x: -3, y: -3)
        )
    }
}

struct CategoryFilterView: View {
    @Binding var selectedCategory: TaskCategory?
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                CategoryChip(category: nil, isSelected: selectedCategory == nil) {
                    selectedCategory = nil
                }
                
                ForEach(TaskCategory.allCases, id: \.self) { category in
                    CategoryChip(category: category, isSelected: selectedCategory == category) {
                        selectedCategory = category
                    }
                }
            }
        }
    }
}

struct CategoryChip: View {
    let category: TaskCategory?
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 5) {
                if let category = category {
                    Image(systemName: category.icon)
                        .font(.system(size: 14))
                    Text(category.rawValue)
                        .font(.system(size: 14, weight: .semibold))
                } else {
                    Text("All")
                        .font(.system(size: 14, weight: .semibold))
                }
            }
            .foregroundColor(isSelected ? .white : .black)
            .padding(.horizontal, 15)
            .padding(.vertical, 8)
            .background(
                Capsule()
                    .fill(isSelected ? Color(hex: "FF3C00") : Color(hex: "FFFFFF"))
                    .shadow(color: Color.black.opacity(isSelected ? 0.2 : 0.1), radius: 5, x: 2, y: 2)
            )
        }
    }
}

struct TaskRowView: View {
    let task: TaskModel
    @ObservedObject var viewModel: ProductivityToolsViewModel
    @State private var showTaskDetail = false
    
    var body: some View {
        Button(action: { showTaskDetail = true }) {
            HStack(spacing: 15) {
                Button(action: {
                    viewModel.toggleTaskCompletion(task.id)
                }) {
                    Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                        .font(.system(size: 24))
                        .foregroundColor(task.isCompleted ? Color(hex: "FF3C00") : .gray)
                }
                
                VStack(alignment: .leading, spacing: 5) {
                    Text(task.title)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.black)
                        .strikethrough(task.isCompleted)
                    
                    HStack(spacing: 8) {
                        Image(systemName: task.category.icon)
                            .font(.system(size: 10))
                        Text(task.category.rawValue)
                            .font(.system(size: 12))
                        
                        Text("•")
                            .font(.system(size: 12))
                        
                        Text(task.priority.rawValue)
                            .font(.system(size: 12))
                            .foregroundColor(priorityColor(task.priority))
                    }
                    .foregroundColor(.gray)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 15)
                    .fill(Color(hex: "FFFFFF"))
                    .shadow(color: Color.black.opacity(0.08), radius: 8, x: 4, y: 4)
                    .shadow(color: Color.white.opacity(0.7), radius: 8, x: -4, y: -4)
            )
        }
        .sheet(isPresented: $showTaskDetail) {
            TaskDetailView(task: task, viewModel: viewModel)
        }
    }
    
    func priorityColor(_ priority: TaskPriority) -> Color {
        switch priority {
        case .high: return .red
        case .medium: return .orange
        case .low: return .green
        }
    }
}

struct EmptyTasksView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "tray")
                .font(.system(size: 60))
                .foregroundColor(.gray.opacity(0.5))
            
            Text("No tasks yet")
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(.gray)
            
            Text("Tap the + button to add your first task")
                .font(.system(size: 14))
                .foregroundColor(.gray.opacity(0.8))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct AddTaskView: View {
    @ObservedObject var viewModel: ProductivityToolsViewModel
    @Environment(\.presentationMode) var presentationMode
    
    @State private var title = ""
    @State private var description = ""
    @State private var selectedCategory: TaskCategory = .other
    @State private var selectedPriority: TaskPriority = .medium
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(hex: "FFFFFF")
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        VStack(alignment: .leading, spacing: 15) {
                            Text("Task Details")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.gray)
                            
                            NeumorphicCard {
                                VStack(spacing: 12) {
                                    TextField("Title", text: $title)
                                        .font(.system(size: 16))
                                        .padding(12)
                                        .background(Color.gray.opacity(0.1))
                                        .cornerRadius(10)
                                    
                                    TextField("Description (optional)", text: $description)
                                        .font(.system(size: 16))
                                        .padding(12)
                                        .background(Color.gray.opacity(0.1))
                                        .cornerRadius(10)
                                }
                            }
                        }
                        
                        VStack(alignment: .leading, spacing: 15) {
                            Text("Category")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.gray)
                            
                            VStack(spacing: 10) {
                                ForEach(TaskCategory.allCases, id: \.self) { category in
                                    Button(action: {
                                        selectedCategory = category
                                    }) {
                                        HStack {
                                            Image(systemName: category.icon)
                                                .font(.system(size: 20))
                                                .frame(width: 30)
                                            
                                            Text(category.rawValue)
                                                .font(.system(size: 16, weight: .semibold))
                                            
                                            Spacer()
                                            
                                            if selectedCategory == category {
                                                Image(systemName: "checkmark.circle.fill")
                                                    .font(.system(size: 22))
                                                    .foregroundColor(Color(hex: "FF3C00"))
                                            }
                                        }
                                        .foregroundColor(selectedCategory == category ? Color(hex: "FF3C00") : .black)
                                        .padding()
                                        .background(
                                            RoundedRectangle(cornerRadius: 12)
                                                .fill(Color(hex: "FFFFFF"))
                                                .shadow(color: Color.black.opacity(0.08), radius: 5, x: 3, y: 3)
                                                .shadow(color: Color.white.opacity(0.7), radius: 5, x: -3, y: -3)
                                        )
                                    }
                                }
                            }
                        }
                        
                        VStack(alignment: .leading, spacing: 15) {
                            Text("Priority")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.gray)
                            
                            HStack(spacing: 12) {
                                ForEach(TaskPriority.allCases, id: \.self) { priority in
                                    Button(action: {
                                        selectedPriority = priority
                                    }) {
                                        Text(priority.rawValue)
                                            .font(.system(size: 14, weight: .semibold))
                                            .foregroundColor(selectedPriority == priority ? .white : .black)
                                            .frame(maxWidth: .infinity)
                                            .padding(.vertical, 12)
                                            .background(
                                                RoundedRectangle(cornerRadius: 10)
                                                    .fill(selectedPriority == priority ? Color(hex: "FF3C00") : Color(hex: "FFFFFF"))
                                                    .shadow(color: Color.black.opacity(0.08), radius: 5, x: 3, y: 3)
                                            )
                                    }
                                }
                            }
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("New Task")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Add") {
                        viewModel.addTask(title: title, description: description, category: selectedCategory, priority: selectedPriority)
                        presentationMode.wrappedValue.dismiss()
                    }
                    .disabled(title.isEmpty)
                    .foregroundColor(title.isEmpty ? .gray : Color(hex: "FF3C00"))
                }
            }
        }
    }
}

struct TaskDetailView: View {
    let task: TaskModel
    @ObservedObject var viewModel: ProductivityToolsViewModel
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(hex: "FFFFFF")
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        NeumorphicCard {
                            VStack(alignment: .leading, spacing: 15) {
                                Text(task.title)
                                    .font(.system(size: 24, weight: .bold))
                                    .foregroundColor(.black)
                                
                                if !task.description.isEmpty {
                                    Text(task.description)
                                        .font(.system(size: 16))
                                        .foregroundColor(.gray)
                                }
                                
                                Divider()
                                
                                HStack {
                                    VStack(alignment: .leading, spacing: 5) {
                                        Text("Category")
                                            .font(.system(size: 12))
                                            .foregroundColor(.gray)
                                        HStack {
                                            Image(systemName: task.category.icon)
                                            Text(task.category.rawValue)
                                        }
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundColor(.black)
                                    }
                                    
                                    Spacer()
                                    
                                    VStack(alignment: .leading, spacing: 5) {
                                        Text("Priority")
                                            .font(.system(size: 12))
                                            .foregroundColor(.gray)
                                        Text(task.priority.rawValue)
                                            .font(.system(size: 16, weight: .semibold))
                                            .foregroundColor(.black)
                                    }
                                }
                                
                                if task.isCompleted, let completedDate = task.completedAt {
                                    Divider()
                                    
                                    VStack(alignment: .leading, spacing: 5) {
                                        Text("Completed")
                                            .font(.system(size: 12))
                                            .foregroundColor(.gray)
                                        Text(completedDate, style: .date)
                                            .font(.system(size: 16, weight: .semibold))
                                            .foregroundColor(.black)
                                    }
                                }
                            }
                        }
                        
                        PrimaryActionButton(title: task.isCompleted ? "Mark Incomplete" : "Mark Complete") {
                            viewModel.toggleTaskCompletion(task.id)
                        }
                        
                        Button(action: {
                            viewModel.deleteTask(task)
                            presentationMode.wrappedValue.dismiss()
                        }) {
                            Text("Delete Task")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.red)
                                .frame(maxWidth: .infinity)
                                .frame(height: 56)
                                .background(
                                    RoundedRectangle(cornerRadius: 15)
                                        .stroke(Color.red, lineWidth: 2)
                                )
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Task Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        presentationMode.wrappedValue.dismiss()
                    }
                    .foregroundColor(Color(hex: "FF3C00"))
                }
            }
        }
    }
}

struct PomodoroView: View {
    @ObservedObject var viewModel: ProductivityToolsViewModel
    let preferences: AppPreferencesModel
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(hex: "FFFFFF")
                    .ignoresSafeArea()
                
                if let session = viewModel.pomodoroSession {
                    ActivePomodoroView(session: session, viewModel: viewModel)
                } else {
                    InactivePomodoroView(preferences: preferences, viewModel: viewModel)
                }
            }
            .navigationTitle("Pomodoro Timer")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        presentationMode.wrappedValue.dismiss()
                    }
                    .foregroundColor(Color(hex: "FF3C00"))
                }
            }
        }
    }
}

struct ActivePomodoroView: View {
    let session: PomodoroSession
    @ObservedObject var viewModel: ProductivityToolsViewModel
    
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            Text(session.isBreak ? "Break Time" : "Focus Time")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.black)
            
            ZStack {
                Circle()
                    .stroke(Color.gray.opacity(0.2), lineWidth: 20)
                    .frame(width: 250, height: 250)
                
                Circle()
                    .trim(from: 0, to: CGFloat(session.progress))
                    .stroke(Color(hex: "FF3C00"), style: StrokeStyle(lineWidth: 20, lineCap: .round))
                    .frame(width: 250, height: 250)
                    .rotationEffect(.degrees(-90))
                    .animation(.linear(duration: 0.5), value: session.progress)
                
                Text(session.formattedTime)
                    .font(.system(size: 48, weight: .bold))
                    .foregroundColor(.black)
            }
            
            HStack(spacing: 20) {
                Button(action: {
                    if session.isActive {
                        viewModel.pausePomodoro()
                    } else {
                        viewModel.resumePomodoro()
                    }
                }) {
                    Image(systemName: session.isActive ? "pause.circle.fill" : "play.circle.fill")
                        .font(.system(size: 60))
                        .foregroundColor(Color(hex: "FF3C00"))
                }
                
                Button(action: {
                    viewModel.stopPomodoro()
                }) {
                    Image(systemName: "stop.circle.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.gray)
                }
            }
            
            Text("Sessions completed: \(session.completedSessions)")
                .font(.system(size: 16))
                .foregroundColor(.gray)
            
            Spacer()
        }
        .padding()
    }
}

struct InactivePomodoroView: View {
    let preferences: AppPreferencesModel
    @ObservedObject var viewModel: ProductivityToolsViewModel
    
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            Image(systemName: "timer")
                .font(.system(size: 80))
                .foregroundColor(Color(hex: "FF3C00"))
            
            Text("Ready to Focus?")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.black)
            
            Text("Use the Pomodoro technique to maintain focus and productivity.")
                .font(.system(size: 16))
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            VStack(spacing: 15) {
                PrimaryActionButton(title: "Start Focus Session") {
                    viewModel.startPomodoro(workDuration: preferences.pomodoroWorkDuration)
                }
                
                Button(action: {
                    viewModel.startBreak(breakDuration: preferences.pomodoroBreakDuration)
                }) {
                    Text("Start Break")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(Color(hex: "FF3C00"))
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(
                            RoundedRectangle(cornerRadius: 15)
                                .stroke(Color(hex: "FF3C00"), lineWidth: 2)
                        )
                }
            }
            .padding(.horizontal, 30)
            
            Spacer()
        }
    }
}

struct ProductivityToolsView_Previews: PreviewProvider {
    static var previews: some View {
        ProductivityToolsView(viewModel: ProductivityToolsViewModel(productivityService: ProductivityService()), preferences: AppPreferencesModel())
    }
}

