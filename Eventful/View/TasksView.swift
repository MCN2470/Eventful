import SwiftUI

struct TasksView: View {
    @State private var tasks: [Task] = [] // List of tasks
    @State private var newTaskName = ""  // For adding a new task
    @State private var showAlert = false // For authentication failure alert
    @State private var alertMessage = "" // Message for the alert

    // Load tasks from UserDefaults when the view appears
    func loadTasks() {
        if let data = UserDefaults.standard.data(forKey: "tasks") {
            if let decodedTasks = try? JSONDecoder().decode([Task].self, from: data) {
                tasks = decodedTasks
            }
        }
    }

    // Save tasks to UserDefaults
    func saveTasks() {
        if let data = try? JSONEncoder().encode(tasks) {
            UserDefaults.standard.set(data, forKey: "tasks")
        }
    }

    var body: some View {
        NavigationView {
            VStack {
                // Add Task Section
                HStack {
                    TextField("New Task", text: $newTaskName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    Button(action: addTask) {
                        Image(systemName: "plus")
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .clipShape(Circle())
                    }
                }
                .padding()

                // Task List
                List {
                    ForEach(tasks) { task in
                        HStack {
                            Text(task.name)
                                .strikethrough(task.isCompleted, color: .gray)
                                .foregroundColor(task.isCompleted ? .gray : .primary)
                            Spacer()
                            Button(action: { toggleTaskStatus(task) }) {
                                Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                                    .foregroundColor(task.isCompleted ? .green : .gray)
                            }
                        }
                    }
                    .onDelete(perform: deleteTask)
                }
                .listStyle(InsetGroupedListStyle())

                // Clear All Tasks Button
                if !tasks.isEmpty {
                    Button("Clear All Tasks") {
                        clearAllTasks()
                    }
                    .foregroundColor(.red)
                    .padding()
                }
            }
            .navigationTitle("Tasks")
            .onAppear(perform: loadTasks) // Load tasks when view appears
            .alert("Authentication Failed", isPresented: $showAlert) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(alertMessage)
            }
        }
    }

    // Add a new task
    func addTask() {
        guard !newTaskName.isEmpty else { return }
        let newTask = Task(name: newTaskName, isCompleted: false)
        tasks.append(newTask)
        newTaskName = ""
        saveTasks() // Save tasks to UserDefaults
    }

    // Toggle task completion status
    func toggleTaskStatus(_ task: Task) {
        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            tasks[index].isCompleted.toggle()
            saveTasks() // Save tasks to UserDefaults
        }
    }

    // Delete a task
    func deleteTask(at offsets: IndexSet) {
        tasks.remove(atOffsets: offsets)
        saveTasks() // Save tasks to UserDefaults
    }

    // Clear all tasks (requires biometric authentication)
    func clearAllTasks() {
        BiometricAuthenticator.authenticateUser { success, errorMessage in
            if success {
                // Biometric authentication succeeded, clear all tasks
                tasks.removeAll()
                saveTasks() // Save the updated (empty) tasks to UserDefaults
            } else {
                // Biometric authentication failed, show an alert
                alertMessage = errorMessage ?? "Authentication failed."
                showAlert = true // Show the "Authentication Failed" alert
            }
        }
    }
}
