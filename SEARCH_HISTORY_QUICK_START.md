# Search History - Quick Start Guide

## What Happens Now

### For Regular Staff 👥
- **No changes needed!** Everything works automatically
- When you search and select a customer, that search is now recorded
- Your search history helps admins understand workflow

### For Admins 👨‍💼

## Step-by-Step: View Search History

### 1. Navigate to Tools
- Tap the **Tools** button (Admin menu)
- You'll see the admin dashboard

### 2. Find "Search History"
- Scroll down to the **indigo colored card** labeled "Search History"
- It shows: "View staff search activity - Customer Name, Staff Name, Date & Time"

### 3. Open Search History Page
- Tap on the **Search History** card
- You'll see a list of all searches, newest first

## Using Search History Page

### View All Searches
- Simple list showing:
  - 🔍 Icon badge
  - **Customer name** (bold)
  - **Customer ID** (gray text)
  - **Staff name** (who searched)
  - **Date** (formatted: MMM dd, yyyy)
  - **Time** (formatted: hh:mm a)

### Search by Name
- Use the **search box** at the top
- Type customer name or staff name
- Results filter in real-time

### Filter by Staff Member
- Use the **colored chips** below the search box
- Click a staff member's name to see only their searches
- Click "All Staff" to see everything

### Delete Entries
- **Long-press** any entry you want to delete
- Confirm the deletion
- Entry removed from Firestore

### Refresh Data
- Tap the **refresh icon** (⟳) in top right
- Pulls latest data from Firestore

## Data Collection Details

### What's Recorded
✅ Customer Name  
✅ Customer ID  
✅ Staff Name  
✅ Staff ID  
✅ Exact Date & Time  

### When It's Recorded
✅ When customer is **selected from search results**  
✅ Only successful searches (not failed attempts)  
✅ Automatically (no manual entry needed)  

### Where It's Stored
✅ Firestore database  
✅ Collection: `search_history`  
✅ Backed up with app data  

## Common Tasks

### Find all searches by a staff member
1. Open Search History
2. Click their name chip
3. See all their searches sorted by date

### Find searches for a specific customer
1. Open Search History
2. Type customer name in search box
3. See all staff members who searched for them

### Check activity for today
1. Open Search History
2. All searches shown by default (newest first)
3. Look for today's date in the entries

### Audit staff activity
1. Open Search History
2. Filter by staff member chip
3. See their complete search pattern and frequency

## Features at a Glance

| Feature | How to Use |
|---------|-----------|
| **Real-time Data** | Automatically syncs with Firestore |
| **Search by Name** | Type in the search box |
| **Filter by Staff** | Click colored chips |
| **Sort by Date** | Always newest first |
| **Delete Entry** | Long-press and confirm |
| **Refresh Data** | Tap refresh icon |
| **View Stats** | Count shown at top |

## Tips & Tricks

💡 **Bulk Activity View** - Filter by staff to see their complete workday  
💡 **Customer Insights** - Search for customer name to see who's accessing them  
💡 **Trend Analysis** - Regular patterns show which customers are frequently accessed  
💡 **Audit Trail** - Timestamps let you track exact activity times  

## Firestore Collection Info

- **Location**: `search_history` collection
- **Documents**: One per search
- **Size**: Grows over time as searches are recorded
- **Retention**: Indefinite (manual cleanup with delete)
- **Permissions**: Admins only (reads filtered data)

## Troubleshooting

❌ **Can't see Search History button?**
- Verify you're logged in as admin
- Check `isAdmin` flag is true
- Restart the app

❌ **No data showing?**
- App is working, just no searches yet
- Make a test search and come back
- Tap refresh icon to reload

❌ **Searches not saving?**
- Check Firestore rules allow writes to `search_history`
- Verify staff member is logged in (`empIdGlobal` set)
- Check internet connection
