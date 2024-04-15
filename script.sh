#!/bin/bash

# Configuration
DB_DIR="Databases" # Directory where your database files are located
SQL_DIR="Queries"  # Directory where your SQL files are located
OUTPUT_DIR="Results" # Output directory for results

# Ensure the output directory exists
mkdir -p "${OUTPUT_DIR}"

# Get a list of all SQL files
SQL_FILES=("${SQL_DIR}"/*.sql)
NUM_FILES=${#SQL_FILES[@]}

# Check if there are any SQL files
if [ $NUM_FILES -eq 0 ]; then
    echo "No SQL files found in ${SQL_DIR}. Exiting."
    exit 1
fi

# Loop through each database file in the DB_DIR
for DB_PATH in "${DB_DIR}"/*.db; do
    DB_NAME=$(basename "${DB_PATH}" .db)
    
    # Define a results file name for each database
    RESULTS_FILE="${OUTPUT_DIR}/${DB_NAME}_queries_throughput.txt"
    
    # Clear the results file for this database to start fresh, or create it if it doesn't exist
    echo "Results for ${DB_NAME}:" > "${RESULTS_FILE}"
    echo "" >> "${RESULTS_FILE}"
    
    # Process each SQL file against the current database
    for SQL_FILE in "${SQL_FILES[@]}"; do
        FILE_NAME=$(basename "${SQL_FILE}")
        
        # Measure the start time
        START_TIME=$(date +%s.%N)
    
        # Execute the SQL file
        sqlite3 "${DB_PATH}" < "${SQL_FILE}" > /dev/null 2>&1
        
        # Measure the end time
        END_TIME=$(date +%s.%N)
    
        # Calculate elapsed time in seconds
        ELAPSED_TIME=$(echo "$END_TIME - $START_TIME" | bc)
    
        # Assuming each file contains one query, calculate throughput as queries per second
        THROUGHPUT=$(echo "scale=2; 1 / $ELAPSED_TIME" | bc)
        # Measure the cycles per second using perf
        CYCLES_PER_SECOND=$(perf stat -e cycles -r 1 sqlite3 "${DB_PATH}" < "${SQL_FILE}" 2>&1 | awk '/cycles/ {print $1}')

        # Append the cycles per second to the database-specific results file
        echo "Cycles per second: ${CYCLES_PER_SECOND}" >> "${RESULTS_FILE}"
        # Append the results for this file to the database-specific results file
        echo "File: ${FILE_NAME}" >> "${RESULTS_FILE}"
        echo "Total execution time: ${ELAPSED_TIME} seconds" >> "${RESULTS_FILE}"
        echo "Throughput: ${THROUGHPUT} queries per second" >> "${RESULTS_FILE}"
        echo "--------------------------------------" >> "${RESULTS_FILE}"
        echo "File: ${FILE_NAME}" >> "${RESULTS_FILE}"
        echo "Total execution time: ${ELAPSED_TIME} seconds" >> "${RESULTS_FILE}"
        echo "Throughput: ${THROUGHPUT} queries per second" >> "${RESULTS_FILE}"
        echo "--------------------------------------" >> "${RESULTS_FILE}"
    done

    # Optionally, output the combined results for this database to the console
    echo "Results for ${DB_NAME}:"
    cat "${RESULTS_FILE}"
    echo ""
    echo "--------------------------------------"
done
