# SQL
Project Summary: Maji Ndogo Water Crisis Data Analysis
Overview: The Maji Ndogo Water Crisis Data Analysis project aims to leverage a comprehensive database of 60,000 survey records to address critical water access and quality issues in Maji Ndogo. Collected by a dedicated team of engineers, field workers, scientists, and analysts, this dataset captures detailed information on water sources, visit patterns, water quality, and pollution levels. The project’s primary goal is to extract actionable insights to inform data-driven solutions for the region’s water crisis, ensuring safe and equitable water access for communities.

Key Objectives:

Understand Data Structure: Explore the database’s foundational tables (e.g., water_sources, visits, water_quality, well_pollution) to understand their structure, relationships, and variables, laying the groundwork for analysis.
Analyze Water Sources: Identify and categorize water source types (e.g., wells, taps, rivers) to assess their distribution and accessibility across regions.
Evaluate Visit Patterns: Analyze the visits table to uncover frequency and distribution of visits to water sources, highlighting areas with high demand or long queue times (e.g., over 8 hours), which indicate access challenges.
Assess Water Quality: Investigate water quality scores in the water_quality table, focusing on high-quality sources (e.g., home taps with scores of 10) and identifying inconsistencies, such as multiple visits to sources that should not be revisited, to ensure data accuracy.
Investigate Pollution Issues: Examine the well_pollution table to verify the integrity of contamination data for wells, correcting errors where wells are misclassified as Clean despite biological contamination (biological > 0.01 CFU/mL) or incorrect descriptions (e.g., “Clean Bacteria: E. coli”).
Key Findings and Actions:

Long Queue Times: Identified sources with extreme queue times (>500 minutes), indicating significant access barriers, particularly for certain source types (e.g., shared taps). Further analysis links these source_id values to the water_sources table to understand contributing factors.
Data Quality Issues: Discovered inconsistencies, such as 218 records of high-quality home taps (score = 10) with multiple visits, against survey protocol, and 38 wells with incorrect “Clean” descriptions despite biological contamination. These errors suggest data entry mistakes by surveyors.
Corrective Measures: Implemented SQL queries to update the well_pollution table, correcting descriptions (e.g., from “Clean Bacteria: E. coli” to “Bacteria: E. coli”) and reclassifying mislabeled Clean wells as Contaminated: Biological. Used a backup table (well_pollution_copy) to test changes safely before applying them to the production database.
Recommendations: Proposed an independent audit to verify data accuracy, improved training for data personnel to prevent misinterpretation of scientist notes, and ongoing validation processes to maintain data integrity.
