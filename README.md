# Sejeli - Task Management App

A Flutter application for managing tasks and tracking individual progress with a competitive leaderboard system.

## Features

- **User Authentication**: Phone number-based login and registration
- **Task Management**: Create and manage tasks for individuals
- **Leaderboard System**: Real-time ranking based on task completion
- **Modern UI**: Beautiful, responsive design with gradient backgrounds

## Leaderboard Functionality

The app includes a comprehensive leaderboard system that:

- **Ranks Users**: Automatically sorts users by task completion count
- **Visual Rankings**: Top 3 users get special highlighting (Gold, Silver, Bronze)
- **Real-time Updates**: Refresh button to get latest rankings
- **Score Calculation**: Each completed task = 10 points
- **Beautiful Design**: Modern card-based UI with shadows and gradients

### Leaderboard Features

- **Rank Display**: Circular rank indicators with special colors for top performers
- **User Names**: Clear display of participant names
- **Task Count**: Shows total completed tasks per user
- **Score Calculation**: Automatic point calculation (tasks × 10)
- **Responsive Design**: Works on all screen sizes
- **Pull to Refresh**: Easy data refresh functionality

## Firebase Integration

The app uses Firebase for:
- **Authentication**: User login and registration
- **Firestore Database**: Storing user data and task information
- **Real-time Updates**: Live data synchronization

### Database Structure

```
individuals/
  ├── userId/
  │   ├── name: "User Name"
  │   └── taskNumbers: ["task1", "task2", "task3"]
```

## Getting Started

1. Clone the repository
2. Install Flutter dependencies: `flutter pub get`
3. Configure Firebase (add your `google-services.json` and `firebase_options.dart`)
4. Run the app: `flutter run`

## API Functions

### DataBaseService
- `getLeaderboardData()`: Fetches and sorts all users by task count
- `getUserStats(userId)`: Gets detailed statistics for a specific user
- `createTask(taskNumber, individualId)`: Adds/removes tasks for users
- `createIndividual(name)`: Creates new user profiles

### AuthenticationService
- `loginUser(phoneNumber, password)`: User authentication
- `registerUser(phoneNumber, password, fullName)`: User registration
- `signOut()`: User logout

## Screenshots

The leaderboard features:
- Beautiful gradient background
- Card-based design with shadows
- Top 3 user highlighting
- Responsive table layout
- Modern Material Design icons

## Contributing

Feel free to submit issues and enhancement requests!
