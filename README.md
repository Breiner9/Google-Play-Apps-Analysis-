# 📊 Google Play Store - Data Analysis Project

## Description
This project analyzes a dataset of 10,000+ applications from the Google Play Store to identify key factors that influence an app's success, measured by number of installs and user ratings. The analysis covers data cleaning, transformation, and exploratory analysis using SQL, with visualizations built in Power BI.

## 🛠️ Tools Used
- **PostgreSQL** — Data cleaning, transformation, and analysis queries
- **Power BI** — Dashboard and data visualization

## 📁 Project Structure
```
google-play-analysis/
├── README.md
├── documentation/
│   └── analysis_google_play.docx
├── sql/
│   ├── cleaning_google_play.sql
│   └── analysis_google_play.sql
├── data/
│   └── apps_clean.csv
└── powerbi/
    └── dashboard.pbix
```

## 📋 Dataset Overview
- **Source:** Google Play Store
- **Records:** 8,000+ apps
- **Columns (13):** app, category, rating, reviews, size, installs, type, price, content_rating, genres, last_updated, current_ver, android_ver

## 🧹 Data Cleaning Process

| Step | Description |
|------|-------------|
| 1. Exploration | Reviewed table structure, column types, and data preview |
| 2. Problem Detection | Used regex to find non-numeric values, checked for nulls and invalid ratings |
| 3. Duplicate Removal | Removed 1,170 duplicates using `ROW_NUMBER()`, keeping the row with the most reviews per app |
| 4. Size Cleaning | Converted `M` and `k` suffixes to numeric (MB), set `Varies with device` to NULL |
| 5. Type Conversion | Converted `reviews`, `installs`, `price` to NUMERIC and `last_updated` to DATE |
| 6. Categorical Validation | Verified consistency of `type`, `category`, and `content_rating` values |

## ❓ Analysis Questions

### 1. Which categories have the most installs and best average rating?
**Skill:** Grouping and sorting

### 2. Do paid apps have better ratings than free apps?
**Skill:** Segment comparison

### 3. What is the price range with the highest acceptance in terms of installs and rating?
**Skill:** Segmentation and business logic

### 4. Is there a relationship between the number of reviews and the rating?
**Skill:** Correlation analysis

### 5. Which categories are saturated and which represent a growth opportunity?
**Skill:** Market vision

## 📈 Key Findings

| # | Question | Insight |
|---|----------|---------|
| 1 | Top categories | GAME leads with 590M installs and 4.24 avg rating |
| 2 | Free vs Paid | Paid apps have slightly better ratings (4.26 vs 4.17) |
| 3 | Price ranges | $0-$5 has the best balance: highest rating (4.28) and most installs among paid apps |
| 4 | Reviews vs Rating | Strong relationship — High-rated apps average 338,930 reviews vs 180 for low-rated |
| 5 | Market saturation | 3 saturated (Family, Game, Tools) vs 5 opportunity categories (Communication, Photography, Social, Video Players, Entertainment) |

## 👤 Author
**Breiner Pinilla** — Data Analyst


## 👤 Author
**Breiner Pinilla** — Data Analyst
