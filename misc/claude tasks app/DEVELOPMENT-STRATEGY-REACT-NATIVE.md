# Anagrafica Tecnica Mobile App - Development Strategy (React Native)

This document outlines the React Native version of the development strategy, highlighting differences from the native iOS (Swift) implementation.

## Overview

The development is structured into the same **7 major phases**, but with React Native/JavaScript ecosystem technologies instead of Swift/iOS native frameworks.

## Key Technology Changes

| Component | Swift/iOS Native | React Native |
|-----------|-----------------|--------------|
| **UI Framework** | SwiftUI | React Native + TypeScript |
| **State Management** | @State, @Observable | Redux Toolkit / Zustand / MobX |
| **Local Storage** | Core Data | WatermelonDB / SQLite + react-native-sqlite-storage |
| **Navigation** | NavigationStack | React Navigation 6+ |
| **Networking** | URLSession | axios / fetch API |
| **Photo Capture** | AVFoundation | react-native-camera / expo-camera |
| **Background Tasks** | BackgroundTasks framework | react-native-background-task / @react-native-community/background-fetch |
| **File Storage** | FileManager | react-native-fs |
| **Testing** | XCTest, XCUITest | Jest, React Native Testing Library, Detox |
| **Build System** | Xcode / SwiftPM | Metro Bundler / npm/yarn |
| **Type Safety** | Swift | TypeScript |
| **Platform** | iOS only | iOS + Android (cross-platform) |

## Folder Structure

```
anagrafica-tecnica-app/
├── src/
│   ├── core/                       # Core modules
│   │   ├── models/                # Data models (TypeScript interfaces/classes)
│   │   ├── storage/               # Local database (WatermelonDB/SQLite)
│   │   ├── network/               # API client (axios)
│   │   ├── services/              # Business logic services
│   │   └── sync/                  # Sync engine
│   ├── design-system/             # Reusable UI components
│   │   ├── components/            # Common components
│   │   ├── theme/                 # Colors, spacing, typography
│   │   └── hooks/                 # Custom React hooks
│   ├── features/                  # Feature modules
│   │   ├── projects/              # Projects list
│   │   ├── floorplan/             # Floorplan viewer
│   │   ├── add-asset-wizard/      # Asset creation wizard
│   │   ├── room/                  # Room management
│   │   ├── survey-report/         # Reporting
│   │   └── export/                # Project export
│   ├── navigation/                # React Navigation setup
│   ├── store/                     # Redux/Zustand store
│   ├── utils/                     # Utility functions
│   └── App.tsx                    # Root component
├── assets/                        # Static assets
├── android/                       # Android native code
├── ios/                           # iOS native code
├── __tests__/                     # Test files
├── package.json                   # Dependencies
├── tsconfig.json                  # TypeScript config
├── metro.config.js                # Metro bundler config
└── babel.config.js                # Babel config
```

---

## Phase 1: Foundation (Core Package)

### 1.1 DataModels
**Technology Changes:**
- TypeScript interfaces and classes instead of Swift structs
- Zod or Yup for runtime validation instead of Swift's type system
- date-fns or day.js for date handling
- uuid library for UUIDv7 generation

**Deliverables:**
- `src/core/models/Project.ts` - TypeScript interface/class
- `src/core/models/Level.ts`
- `src/core/models/Room.ts`
- `src/core/models/Family.ts`
- `src/core/models/Type.ts`
- `src/core/models/Instance.ts`
- `src/core/models/Parameter.ts`
- `src/core/models/Photo.ts`
- `src/core/models/RoomNote.ts`
- `src/core/models/SchemaVersion.ts`
- `src/core/models/Event.ts`

**Example:**
```typescript
// Swift
struct Project: Codable, Identifiable {
    let id: UUID
    var name: String
    var state: ProjectState
}

// TypeScript
interface Project {
    id: string;
    name: string;
    state: ProjectState;
}

class ProjectModel implements Project {
    id: string;
    name: string;
    state: ProjectState;

    constructor(data: Project) {
        this.id = data.id;
        this.name = data.name;
        this.state = data.state;
    }
}
```

---

### 1.2 LocalStorage
**Technology Changes:**
- **WatermelonDB** (recommended for offline-first) or **SQLite** with react-native-sqlite-storage
- Alternative: Realm (realm-js)
- AsyncStorage for simple key-value pairs
- react-native-fs for file storage

**Deliverables:**
- `src/core/storage/database.ts` - WatermelonDB setup
- `src/core/storage/schema.ts` - Database schema
- `src/core/storage/models/` - WatermelonDB models
- `src/core/storage/ProjectStore.ts` - Project CRUD
- `src/core/storage/AssetStore.ts` - Asset CRUD
- `src/core/storage/EventLog.ts` - Event queue
- `src/core/storage/PhotoQueue.ts` - Photo upload queue
- `src/core/storage/TileCache.ts` - Vector tile cache

**Example:**
```typescript
// WatermelonDB model
import { Model } from '@nozbe/watermelondb';
import { field, date, readonly } from '@nozbe/watermelondb/decorators';

class Project extends Model {
    static table = 'projects';

    @field('name') name!: string;
    @field('state') state!: string;
    @readonly @date('created_at') createdAt!: Date;
    @readonly @date('updated_at') updatedAt!: Date;
}
```

**Dependencies:**
```json
{
  "@nozbe/watermelondb": "^0.27.0",
  "@react-native-async-storage/async-storage": "^1.21.0",
  "react-native-fs": "^2.20.0"
}
```

---

### 1.3 NetworkLayer
**Technology Changes:**
- axios instead of URLSession
- react-native-background-upload for background photo uploads
- @react-native-community/netinfo for network detection
- axios-retry for automatic retry

**Deliverables:**
- `src/core/network/apiClient.ts` - Axios instance with interceptors
- `src/core/network/ProjectAPI.ts` - Project endpoints
- `src/core/network/SyncAPI.ts` - Sync endpoints
- `src/core/network/PhotoUploadAPI.ts` - Photo upload with background support
- `src/core/network/SchemaAPI.ts` - Schema endpoints
- `src/core/network/NetworkMonitor.ts` - Network state monitoring

**Example:**
```typescript
// Axios client setup
import axios from 'axios';
import axiosRetry from 'axios-retry';
import NetInfo from '@react-native-community/netinfo';

const apiClient = axios.create({
    baseURL: process.env.API_BASE_URL,
    timeout: 30000,
    headers: {
        'Content-Type': 'application/json',
    },
});

// Retry logic
axiosRetry(apiClient, {
    retries: 3,
    retryDelay: axiosRetry.exponentialDelay,
    retryCondition: (error) => {
        return axiosRetry.isNetworkOrIdempotentRequestError(error);
    },
});
```

**Dependencies:**
```json
{
  "axios": "^1.6.0",
  "axios-retry": "^4.0.0",
  "@react-native-community/netinfo": "^11.0.0",
  "react-native-background-upload": "^6.6.0"
}
```

---

### 1.4 CoreServices
**Technology Changes:**
- JavaScript libraries for fuzzy matching (fuzzysort, fuse.js)
- date-fns for date handling
- Custom JavaScript/TypeScript implementations

**Deliverables:**
- `src/core/services/ValidationService.ts`
- `src/core/services/FuzzyMatchingService.ts` - Using fuse.js
- `src/core/services/CoordinateService.ts`
- `src/core/services/IDGenerator.ts` - Using uuid library
- `src/core/services/PhotoNamingService.ts`
- `src/core/services/StateManager.ts`
- `src/core/services/PermissionsManager.ts` - Using react-native-permissions

**Example:**
```typescript
// Fuzzy matching with fuse.js
import Fuse from 'fuse.js';

class FuzzyMatchingService {
    private fuse: Fuse<Type>;

    constructor(types: Type[]) {
        this.fuse = new Fuse(types, {
            keys: ['name', 'manufacturer', 'model'],
            threshold: 0.3,
        });
    }

    findSimilar(query: string, limit: number = 5): Type[] {
        return this.fuse.search(query, { limit }).map(result => result.item);
    }
}
```

**Dependencies:**
```json
{
  "fuse.js": "^7.0.0",
  "uuid": "^9.0.0",
  "date-fns": "^3.0.0",
  "react-native-permissions": "^4.0.0"
}
```

---

## Phase 2: Core UI (Design System + Features)

### 2.1 ProjectsList
**Technology Changes:**
- React functional components instead of SwiftUI views
- FlatList for list rendering
- React Navigation for navigation
- Redux/Zustand for state management

**Deliverables:**
- `src/features/projects/ProjectsListScreen.tsx`
- `src/features/projects/components/ProjectCard.tsx`
- `src/features/projects/components/ProjectSearchBar.tsx`
- `src/features/projects/components/ProjectStateLabel.tsx`
- `src/features/projects/components/SyncStatusIndicator.tsx`
- `src/features/projects/hooks/useProjectsList.ts`
- `src/features/projects/store/projectsSlice.ts` (Redux)

**Example:**
```typescript
// React Native component
import React from 'react';
import { FlatList, StyleSheet } from 'react-native';
import { useSelector } from 'react-redux';
import ProjectCard from './components/ProjectCard';

const ProjectsListScreen: React.FC = () => {
    const projects = useSelector(state => state.projects.list);

    return (
        <FlatList
            data={projects}
            renderItem={({ item }) => <ProjectCard project={item} />}
            keyExtractor={item => item.id}
            contentContainerStyle={styles.container}
        />
    );
};

const styles = StyleSheet.create({
    container: {
        padding: 16,
    },
});
```

**Dependencies:**
```json
{
  "react": "^18.2.0",
  "react-native": "^0.73.0",
  "@react-navigation/native": "^6.1.0",
  "@reduxjs/toolkit": "^2.0.0",
  "react-redux": "^9.0.0"
}
```

---

### 2.2 FloorplanViewer
**Technology Changes:**
- **react-native-svg** for vector rendering
- **react-native-gesture-handler** for pan/zoom
- **react-native-reanimated** for smooth animations
- Alternative: WebView with Leaflet.js or Mapbox GL JS for tile rendering

**Deliverables:**
- `src/features/floorplan/FloorplanView.tsx`
- `src/features/floorplan/components/VectorTileRenderer.tsx` - SVG-based
- `src/features/floorplan/components/RoomLayer.tsx`
- `src/features/floorplan/components/RoomBadge.tsx`
- `src/features/floorplan/components/LevelPicker.tsx`
- `src/features/floorplan/hooks/useGestures.ts`
- `src/features/floorplan/hooks/useFloorplan.ts`

**Example:**
```typescript
// Floorplan with gestures
import React from 'react';
import { GestureDetector, Gesture } from 'react-native-gesture-handler';
import Animated, { useSharedValue, useAnimatedStyle } from 'react-native-reanimated';
import Svg, { Path, Circle } from 'react-native-svg';

const FloorplanView: React.FC = () => {
    const scale = useSharedValue(1);
    const translateX = useSharedValue(0);
    const translateY = useSharedValue(0);

    const pinchGesture = Gesture.Pinch()
        .onUpdate((e) => {
            scale.value = e.scale;
        });

    const panGesture = Gesture.Pan()
        .onUpdate((e) => {
            translateX.value = e.translationX;
            translateY.value = e.translationY;
        });

    const composed = Gesture.Simultaneous(pinchGesture, panGesture);

    const animatedStyle = useAnimatedStyle(() => ({
        transform: [
            { translateX: translateX.value },
            { translateY: translateY.value },
            { scale: scale.value },
        ],
    }));

    return (
        <GestureDetector gesture={composed}>
            <Animated.View style={animatedStyle}>
                <Svg width="100%" height="100%">
                    {/* Render rooms, badges, etc. */}
                </Svg>
            </Animated.View>
        </GestureDetector>
    );
};
```

**Dependencies:**
```json
{
  "react-native-svg": "^14.0.0",
  "react-native-gesture-handler": "^2.14.0",
  "react-native-reanimated": "^3.6.0"
}
```

**Alternative for tile rendering:**
```json
{
  "react-native-webview": "^13.6.0",
  "leaflet": "^1.9.0",
  "mapbox-gl": "^3.0.0"
}
```

---

### 2.3 CommonComponents
**Technology Changes:**
- React Native components instead of SwiftUI
- react-hook-form for form management
- styled-components or StyleSheet for styling

**Deliverables:**
- `src/design-system/components/FormField.tsx`
- `src/design-system/components/DropdownField.tsx` - Using react-native-picker
- `src/design-system/components/ToggleField.tsx`
- `src/design-system/components/DateField.tsx` - Using react-native-date-picker
- `src/design-system/components/PhotoGrid.tsx`
- `src/design-system/components/ProgressTracker.tsx`
- `src/design-system/components/ActionButton.tsx`
- `src/design-system/components/AlertView.tsx`
- `src/design-system/theme/colors.ts`
- `src/design-system/theme/spacing.ts`
- `src/design-system/theme/typography.ts`

**Example:**
```typescript
// FormField component
import React from 'react';
import { TextInput, Text, View, StyleSheet } from 'react-native';
import { Controller, Control } from 'react-hook-form';

interface FormFieldProps {
    name: string;
    control: Control;
    label: string;
    required?: boolean;
    error?: string;
}

const FormField: React.FC<FormFieldProps> = ({ name, control, label, required, error }) => {
    return (
        <View style={styles.container}>
            <Text style={styles.label}>
                {label} {required && <Text style={styles.required}>*</Text>}
            </Text>
            <Controller
                control={control}
                name={name}
                render={({ field: { onChange, onBlur, value } }) => (
                    <TextInput
                        style={[styles.input, error && styles.inputError]}
                        onBlur={onBlur}
                        onChangeText={onChange}
                        value={value}
                    />
                )}
            />
            {error && <Text style={styles.error}>{error}</Text>}
        </View>
    );
};
```

**Dependencies:**
```json
{
  "react-hook-form": "^7.49.0",
  "@react-native-picker/picker": "^2.6.0",
  "react-native-date-picker": "^4.3.0",
  "styled-components": "^6.1.0"
}
```

---

### 2.4 Navigation
**Technology Changes:**
- React Navigation instead of SwiftUI NavigationStack
- Stack, Tab, and Modal navigators

**Deliverables:**
- `src/navigation/AppNavigator.tsx` - Main navigator
- `src/navigation/MainStack.tsx` - Stack navigator
- `src/navigation/types.ts` - TypeScript types for navigation
- `src/navigation/linking.ts` - Deep linking config

**Example:**
```typescript
// Navigation setup
import { NavigationContainer } from '@react-navigation/native';
import { createNativeStackNavigator } from '@react-navigation/native-stack';

type RootStackParamList = {
    Projects: undefined;
    Floorplan: { projectId: string };
    RoomView: { roomId: string };
    AddAsset: { roomId: string };
};

const Stack = createNativeStackNavigator<RootStackParamList>();

const AppNavigator: React.FC = () => {
    return (
        <NavigationContainer>
            <Stack.Navigator initialRouteName="Projects">
                <Stack.Screen name="Projects" component={ProjectsListScreen} />
                <Stack.Screen name="Floorplan" component={FloorplanScreen} />
                <Stack.Screen name="RoomView" component={RoomViewScreen} />
                <Stack.Screen
                    name="AddAsset"
                    component={AddAssetWizard}
                    options={{ presentation: 'modal' }}
                />
            </Stack.Navigator>
        </NavigationContainer>
    );
};
```

**Dependencies:**
```json
{
  "@react-navigation/native": "^6.1.0",
  "@react-navigation/native-stack": "^6.9.0",
  "@react-navigation/bottom-tabs": "^6.5.0",
  "react-native-screens": "^3.29.0",
  "react-native-safe-area-context": "^4.8.0"
}
```

---

## Phase 3: Asset Management

### 3.5 PhotoCapture
**Technology Changes:**
- **react-native-camera** or **expo-camera** for camera
- **react-native-image-resizer** for compression
- **react-native-fs** for file storage
- Alternative: **vision-camera** (more modern)

**Deliverables:**
- `src/features/photo/CameraService.ts`
- `src/features/photo/PhotoCompressor.ts`
- `src/features/photo/PhotoStorage.ts`
- `src/features/photo/components/CameraView.tsx`
- `src/features/photo/components/PhotoViewer.tsx`
- `src/features/photo/components/PhotoGrid.tsx`

**Example:**
```typescript
// Camera component
import React from 'react';
import { Camera, useCameraDevices } from 'react-native-vision-camera';
import ImageResizer from '@bam.tech/react-native-image-resizer';

const CameraView: React.FC = () => {
    const devices = useCameraDevices();
    const device = devices.back;
    const camera = React.useRef<Camera>(null);

    const takePhoto = async () => {
        if (camera.current) {
            const photo = await camera.current.takePhoto({
                qualityPrioritization: 'balanced',
            });

            // Compress photo
            const compressed = await ImageResizer.createResizedImage(
                photo.path,
                1280,  // max width
                1280,  // max height
                'JPEG',
                80,    // quality 0.8
                0,     // rotation
                undefined,
                false,
                { mode: 'contain', onlyScaleDown: true }
            );

            return compressed;
        }
    };

    return (
        <Camera
            ref={camera}
            style={{ flex: 1 }}
            device={device}
            isActive={true}
            photo={true}
        />
    );
};
```

**Dependencies:**
```json
{
  "react-native-vision-camera": "^3.6.0",
  "@bam.tech/react-native-image-resizer": "^3.0.0",
  "react-native-fs": "^2.20.0",
  "react-native-permissions": "^4.0.0"
}
```

---

## Phase 6: Synchronization

### 6.1 SyncEngine
**Technology Changes:**
- Background tasks with different approach
- **@react-native-community/background-fetch** for periodic sync
- **react-native-background-timer** for retry scheduling
- **react-native-background-upload** for photo uploads

**Deliverables:**
- `src/core/sync/SyncManager.ts`
- `src/core/sync/EventUploader.ts`
- `src/core/sync/PhotoUploader.ts`
- `src/core/sync/RetryScheduler.ts`
- `src/core/sync/BackgroundSyncTask.ts`

**Example:**
```typescript
// Background sync setup
import BackgroundFetch from '@react-native-community/background-fetch';

class SyncManager {
    async initializeBackgroundSync() {
        await BackgroundFetch.configure(
            {
                minimumFetchInterval: 15, // minutes
                stopOnTerminate: false,
                enableHeadless: true,
                startOnBoot: true,
            },
            async (taskId) => {
                console.log('[BackgroundFetch] Event received:', taskId);

                // Perform sync
                await this.syncEvents();
                await this.syncPhotos();

                // Signal completion
                BackgroundFetch.finish(taskId);
            },
            (error) => {
                console.error('[BackgroundFetch] Failed to start:', error);
            }
        );
    }

    async syncEvents() {
        // Upload events logic
    }

    async syncPhotos() {
        // Upload photos logic
    }
}
```

**Dependencies:**
```json
{
  "@react-native-community/background-fetch": "^4.2.0",
  "react-native-background-timer": "^2.4.0",
  "react-native-background-upload": "^6.6.0"
}
```

---

## Phase 7: Testing

### 7.3 Testing
**Technology Changes:**
- **Jest** instead of XCTest
- **React Native Testing Library** instead of XCUITest
- **Detox** for E2E testing
- **jest-expo** for snapshot testing

**Test Structure:**
```
__tests__/
├── unit/
│   ├── models/
│   ├── services/
│   └── utils/
├── integration/
│   ├── storage/
│   ├── network/
│   └── sync/
├── e2e/
│   ├── add-asset.test.ts
│   ├── survey-completion.test.ts
│   └── sync.test.ts
└── __snapshots__/
```

**Example:**
```typescript
// Unit test with Jest
import { FuzzyMatchingService } from '@/core/services/FuzzyMatchingService';

describe('FuzzyMatchingService', () => {
    const types = [
        { id: '1', name: 'Philips 30W LED Panel', manufacturer: 'Philips' },
        { id: '2', name: 'Osram 50W LED Panel', manufacturer: 'Osram' },
    ];

    it('should find similar types', () => {
        const service = new FuzzyMatchingService(types);
        const results = service.findSimilar('Philips LED');

        expect(results).toHaveLength(1);
        expect(results[0].id).toBe('1');
    });
});

// Component test
import { render, fireEvent } from '@testing-library/react-native';
import ProjectCard from '@/features/projects/components/ProjectCard';

describe('ProjectCard', () => {
    it('should render project name', () => {
        const project = { id: '1', name: 'Test Project', state: 'READY' };
        const { getByText } = render(<ProjectCard project={project} />);

        expect(getByText('Test Project')).toBeTruthy();
    });

    it('should call onPress when tapped', () => {
        const onPress = jest.fn();
        const project = { id: '1', name: 'Test Project', state: 'READY' };
        const { getByTestId } = render(<ProjectCard project={project} onPress={onPress} />);

        fireEvent.press(getByTestId('project-card'));
        expect(onPress).toHaveBeenCalled();
    });
});

// E2E test with Detox
describe('Add Asset Flow', () => {
    beforeAll(async () => {
        await device.launchApp();
    });

    it('should create a new asset', async () => {
        await element(by.id('project-card-1')).tap();
        await element(by.id('room-101')).tap();
        await element(by.id('add-asset-button')).tap();

        await element(by.id('family-lights')).tap();
        await element(by.id('create-new-type')).tap();

        // Take photo
        await element(by.id('camera-shutter')).tap();

        // Fill type form
        await element(by.id('type-name')).typeText('Test Light');
        await element(by.id('save-type')).tap();

        // Fill instance form
        await element(by.id('instance-serial')).typeText('SN123');
        await element(by.id('save-asset')).tap();

        await expect(element(by.text('Asset saved'))).toBeVisible();
    });
});
```

**Dependencies:**
```json
{
  "@testing-library/react-native": "^12.4.0",
  "@testing-library/jest-native": "^5.4.0",
  "jest": "^29.7.0",
  "detox": "^20.16.0"
}
```

---

## Key Architectural Differences

### 1. **State Management**

**Swift/SwiftUI:**
```swift
@Observable class ProjectsViewModel {
    var projects: [Project] = []
}
```

**React Native:**
```typescript
// Redux Toolkit
const projectsSlice = createSlice({
    name: 'projects',
    initialState: { list: [], loading: false },
    reducers: {
        setProjects: (state, action) => {
            state.list = action.payload;
        },
    },
});

// Or Zustand (simpler)
const useProjectsStore = create<ProjectsState>((set) => ({
    projects: [],
    setProjects: (projects) => set({ projects }),
}));
```

### 2. **Offline Database**

**Swift/iOS:**
- Core Data (native, built-in)

**React Native:**
- WatermelonDB (recommended for offline-first)
- Realm (cross-platform, good performance)
- SQLite (lightweight, requires more setup)

### 3. **Cross-Platform Advantage**

With React Native, you automatically get:
- iOS support
- Android support (with minimal additional work)
- Shared business logic
- Single codebase for both platforms

**Platform-specific code when needed:**
```typescript
import { Platform } from 'react-native';

const styles = StyleSheet.create({
    container: {
        paddingTop: Platform.OS === 'ios' ? 20 : 0,
    },
});

// Or separate files
import CameraService from './CameraService.ios';
import CameraService from './CameraService.android';
```

### 4. **Vector Tile Rendering**

This is the most challenging part to translate:

**Options:**
1. **react-native-svg** - Pure React Native solution (limited performance)
2. **WebView + Leaflet/Mapbox** - Best rendering, slight overhead
3. **Native module** - Write Swift/Kotlin module, call from JS (best performance)

**Recommendation:** WebView + Mapbox GL JS for production-quality tile rendering

### 5. **Performance Considerations**

React Native has different performance characteristics:

| Aspect | Swift/iOS | React Native |
|--------|-----------|--------------|
| **UI Rendering** | Native, very fast | Bridge overhead, slightly slower |
| **List Performance** | Excellent (LazyVStack) | Good (FlatList with optimization) |
| **Animations** | Excellent | Good (Reanimated for 60fps) |
| **Startup Time** | Fast | Slower (JS bundle load) |
| **Memory** | Efficient | Higher (JS runtime) |
| **Photo Compression** | Fast (native) | Good (native modules) |

**Optimization strategies:**
- Use `React.memo` for components
- Implement `getItemLayout` for FlatList
- Use Reanimated for animations (runs on UI thread)
- Hermes engine for faster startup (enabled by default)
- Code splitting to reduce bundle size

---

## Dependencies Summary

### Core Dependencies
```json
{
  "react": "^18.2.0",
  "react-native": "^0.73.0",
  "typescript": "^5.3.0"
}
```

### Navigation & State
```json
{
  "@react-navigation/native": "^6.1.0",
  "@react-navigation/native-stack": "^6.9.0",
  "@reduxjs/toolkit": "^2.0.0",
  "react-redux": "^9.0.0"
}
```

### Storage
```json
{
  "@nozbe/watermelondb": "^0.27.0",
  "@react-native-async-storage/async-storage": "^1.21.0",
  "react-native-fs": "^2.20.0"
}
```

### Networking
```json
{
  "axios": "^1.6.0",
  "axios-retry": "^4.0.0",
  "@react-native-community/netinfo": "^11.0.0"
}
```

### UI & Gestures
```json
{
  "react-native-gesture-handler": "^2.14.0",
  "react-native-reanimated": "^3.6.0",
  "react-native-svg": "^14.0.0",
  "styled-components": "^6.1.0"
}
```

### Photo & Camera
```json
{
  "react-native-vision-camera": "^3.6.0",
  "@bam.tech/react-native-image-resizer": "^3.0.0",
  "react-native-permissions": "^4.0.0"
}
```

### Background Tasks
```json
{
  "@react-native-community/background-fetch": "^4.2.0",
  "react-native-background-upload": "^6.6.0"
}
```

### Forms & Utilities
```json
{
  "react-hook-form": "^7.49.0",
  "zod": "^3.22.0",
  "date-fns": "^3.0.0",
  "uuid": "^9.0.0",
  "fuse.js": "^7.0.0"
}
```

### Testing
```json
{
  "@testing-library/react-native": "^12.4.0",
  "jest": "^29.7.0",
  "detox": "^20.16.0"
}
```

---

## Development Timeline

**Same 28-week timeline**, but with these considerations:

### Faster:
- Cross-platform by default (iOS + Android)
- Faster UI development with React
- Larger ecosystem of JavaScript libraries
- Hot reload for faster iteration

### Slower:
- Initial setup more complex (iOS + Android)
- Performance optimization requires more work
- Bridging to native modules when needed
- Vector tile rendering requires custom solution

---

## Key Recommendations for React Native

1. **Use TypeScript** - Essential for large codebase
2. **WatermelonDB** - Best offline-first database
3. **React Navigation** - De facto navigation library
4. **Redux Toolkit** - If complex state, otherwise Zustand
5. **Vision Camera** - Modern camera solution
6. **Reanimated** - For smooth animations
7. **WebView + Mapbox** - For vector tile rendering
8. **Detox** - For E2E testing
9. **Hermes** - Enable for better performance
10. **Code Push** - For OTA updates (future)

---

## What Stays the Same

1. **7 Phase structure** - Same logical breakdown
2. **Business logic** - Same requirements and flows
3. **Offline-first approach** - Same strategy
4. **Event sourcing** - Same sync pattern
5. **Data models** - Same entities and relationships
6. **UX/UI design** - Same user flows
7. **Testing strategy** - Same coverage goals

---

## Platform-Specific Challenges

### iOS Specific:
- Background task limitations (same as Swift)
- Push notifications setup
- App Store review process
- TestFlight distribution

### Android Specific (bonus with React Native):
- Background task handling different
- Different permission model
- Play Store review process
- More device fragmentation

---

**Document Version:** 1.0
**Last Updated:** 2026-01-05
**Status:** Alternative Implementation Strategy
