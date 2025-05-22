# BreadCrumb

BreadCrumb is a simple and user-friendly calorie tracking app designed to support foods from a wide variety of cuisines that are often underrepresented in other apps. It focuses especially on dishes from Indian, Mexican, Chinese, Middle Eastern, African, and other global cultures.

## Features

- Track calories across diverse cuisines
- Simple meal logging with nutritional information
- User profiles with customizable calorie goals
- Google Sign-In authentication
- Favorite cuisines and foods

## Setup Instructions

### Prerequisites

- Xcode 15.0+
- iOS 15.0+
- Supabase account
- Google Cloud Platform account for OAuth

### 1. Supabase Setup

1. Create a new Supabase project at https://supabase.com
2. Set up the following tables in your Supabase project:

#### `profiles` Table
```sql
CREATE TABLE public.profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id),
  name TEXT NOT NULL,
  daily_calorie_goal INTEGER DEFAULT 2000,
  favorite_cuisines JSONB DEFAULT '[]'::jsonb,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

-- Enable RLS
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

-- Create policy for users to manage their own profiles
CREATE POLICY "Users can only access their own profiles" 
  ON public.profiles 
  FOR ALL 
  USING (auth.uid() = id);
```

#### `foods` Table
```sql
CREATE TABLE public.foods (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name TEXT NOT NULL,
  calories INTEGER NOT NULL,
  cuisine TEXT NOT NULL,
  protein DOUBLE PRECISION DEFAULT 0,
  carbs DOUBLE PRECISION DEFAULT 0,
  fat DOUBLE PRECISION DEFAULT 0,
  serving_size TEXT DEFAULT '1 serving',
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

-- Enable RLS
ALTER TABLE public.foods ENABLE ROW LEVEL SECURITY;

-- Create policy to allow all authenticated users to read foods
CREATE POLICY "Allow all authenticated users to read foods" 
  ON public.foods 
  FOR SELECT 
  USING (auth.role() = 'authenticated');
```

#### `meal_entries` Table
```sql
CREATE TABLE public.meal_entries (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES auth.users(id),
  food JSONB NOT NULL,
  date TIMESTAMP WITH TIME ZONE DEFAULT now(),
  meal_type TEXT NOT NULL,
  quantity DOUBLE PRECISION DEFAULT 1.0,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

-- Enable RLS
ALTER TABLE public.meal_entries ENABLE ROW LEVEL SECURITY;

-- Create policy for users to manage their own meal entries
CREATE POLICY "Users can manage their own meal entries" 
  ON public.meal_entries 
  FOR ALL 
  USING (auth.uid() = user_id);
```

#### `favorite_foods` Table
```sql
CREATE TABLE public.favorite_foods (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES auth.users(id),
  food_id UUID NOT NULL REFERENCES public.foods(id),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
  UNIQUE(user_id, food_id)
);

-- Enable RLS
ALTER TABLE public.favorite_foods ENABLE ROW LEVEL SECURITY;

-- Create policy for users to manage their own favorites
CREATE POLICY "Users can manage their own favorites" 
  ON public.favorite_foods 
  FOR ALL 
  USING (auth.uid() = user_id);
```

3. Enable Google OAuth in Supabase Authentication settings

### 2. Google Cloud Setup

1. Create a new project in Google Cloud Console
2. Configure OAuth consent screen
3. Create OAuth 2.0 Client ID for iOS
4. Add your bundle identifier and configure the redirect URL

### 3. App Configuration

1. Update `SupabaseManager.swift` with your Supabase URL and anon key:
```swift
private let supabaseURL = URL(string: "https://YOUR_PROJECT_URL.supabase.co")!
private let supabaseKey = "YOUR_ANON_KEY"
```

2. Update `Info.plist` with your Google Client ID:
```xml
<key>GIDClientID</key>
<string>YOUR_CLIENT_ID.apps.googleusercontent.com</string>

<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleTypeRole</key>
        <string>Editor</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>com.googleusercontent.apps.YOUR_CLIENT_ID</string>
        </array>
    </dict>
</array>
```

### 4. Install Dependencies

The app uses Swift Package Manager for dependencies. Open the project in Xcode and wait for the dependencies to be resolved, or run:

```
swift package resolve
```

## Running the App

Open the project in Xcode and run it on your device or simulator.

## License

This project is licensed under the MIT License.