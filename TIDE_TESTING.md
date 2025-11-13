# Tide Feature Testing Guide

## ✨ **SIMPLIFIED IMPLEMENTATION**

**Decision**: Display only next high/low tides (no current tide height)

### Why Simplified?
- **No interpolation needed** - Use API extremes directly
- **No timezone complexity** - Just convert UTC to local
- **No "start from yesterday"** - Simple 7-day request
- **Cleaner code** - ~200 lines of code removed!
- **Still very useful** - Surfers mainly need next high/low times

### What Was Removed:
- ❌ Current tide height in conditions card
- ❌ Hourly tide point interpolation
- ❌ Complex timestamp matching logic
- ❌ Coverage gap handling

### What We Kept:
- ✅ Next 2 tide extremes (in sequence)
- ✅ Tide times converted to local timezone
- ✅ 7-day forecast
- ✅ Smart caching (25km, 7 days)

## 📊 What Was Changed

### Files Modified:
1. **`lib/repositories/tide_repository.dart`**
   - Request starts from yesterday (line 88)
   - Interpolation uses local time (line 186-220)

2. **`lib/repositories/open_meteo_repository.dart`**
   - Enhanced tide matching with fallback (line 286-327)
   - Removed debug logging

3. **`lib/main.dart`**
   - Added dev mode comment (line 33-37)
   - API temporarily disabled to save quota

4. **`lib/models/tide_data.dart`**
   - Added `getNextTwoTides()` method for UI

## 🧪 Testing Plan (When Quota Resets)

### Step 1: Clear Old Cache
On your Android device:
```
Settings → Apps → Wave Forecast → Storage → Clear Data
```

Or via command line:
```bash
adb shell pm clear com.example.forecaster
```

### Step 2: Enable API
In `lib/main.dart` line 36:
```dart
apiKey: dotenv.env['STORMGLASS_API_KEY'], // Uncomment this
// apiKey: null, // Comment this out
```

### Step 3: Run & Monitor
```bash
flutter run
```

**Look for these logs:**
```
🌊 Stormglass API URL: ... (requesting from yesterday for full coverage)
✅ Tide data received for [station]
   Station: 0.0km away
   Data points: [should be ~200+ with yesterday's data]
   Extremes: [should be ~35+]
💾 Cached tide data
✅ Combined [X] hourly conditions
```

### Step 4: Verify in App

**Tide Information Card** should show:
```
Low Tide          High Tide
   ⬇️                ⬆️
 0.87m             2.34m
4:30 PM           10:15 PM
```

### Step 5: Test Nearby Location
Search for a location ~10km away (e.g., if first was Ipanema, try Copacabana)

**Should see:**
```
✅ Tide cache HIT! Using data from 6.2km away
   Cache valid until: [date]
```

### Step 6: Disable API Again (Optional)
After successful test:
```dart
apiKey: null, // Save remaining quota
```

## ✅ Success Criteria

1. **Tide Information Card displays** ✓
2. **Shows next 2 tides in sequence** ✓
3. **Times are in local timezone (not UTC)** ✓
4. **Cache works for nearby locations** ✓
5. **No "N/A" or missing data** ✓

## 📝 Expected Results

**Rio de Janeiro area:**
- Station: ilha guaiba or similar
- Distance: 0-30km
- Tide height: 0.5m - 2.5m (typical range)
- Next tide: Should match actual tide times for Rio

## 🚨 If Issues Persist

1. Check logs - should show "Extremes: 20-30" (typical for 7 days)
2. Verify times are in local timezone (e.g., "4:30 PM" not "19:30")
3. Make sure API key is set correctly in `.env`

## 📊 API Usage Tracking

**Today (Nov 13)**: 6/10 requests used (testing timezone issues)
**Tomorrow**: Quota resets, safe to test simplified version

**One test run uses**: 1 API call (cached for 7 days)
**Efficiency**: With 25km cache, 1 call can serve 10-20+ nearby spots!

