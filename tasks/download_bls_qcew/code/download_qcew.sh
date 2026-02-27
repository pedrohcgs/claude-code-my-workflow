#!/bin/bash
# Download BLS QCEW annual averages (national level)
# Downloads annual single-file CSVs for each year
#
# Usage: bash download_qcew.sh
# Output: ../output/raw/ directory with unzipped CSVs

set -e

OUTPUT_DIR="$(cd "$(dirname "$0")/../output" && pwd)"
RAW_DIR="$OUTPUT_DIR/raw"
mkdir -p "$RAW_DIR"

START_YEAR=1997
END_YEAR=2024

echo "============================================"
echo "BLS QCEW Annual Averages Download"
echo "Date: $(date -Iseconds)"
echo "Years: $START_YEAR to $END_YEAR"
echo "Output: $RAW_DIR"
echo "============================================"

downloaded=0
skipped=0
failed=0

for year in $(seq $START_YEAR $END_YEAR); do
    csv_file="$RAW_DIR/${year}_annual_singlefile.csv"

    # Skip if already downloaded
    if [ -f "$csv_file" ]; then
        echo "  $year: already exists, skipping"
        skipped=$((skipped + 1))
        continue
    fi

    url="https://data.bls.gov/cew/data/files/${year}/csv/${year}_annual_singlefile.zip"
    zip_file="$RAW_DIR/${year}_annual_singlefile.zip"

    echo -n "  $year: downloading... "

    if curl -sS -f -L -o "$zip_file" "$url" 2>/dev/null; then
        # Unzip, overwrite existing
        if unzip -o -q "$zip_file" -d "$RAW_DIR" 2>/dev/null; then
            rm -f "$zip_file"
            echo "OK"
            downloaded=$((downloaded + 1))
        else
            echo "UNZIP FAILED"
            rm -f "$zip_file"
            failed=$((failed + 1))
        fi
    else
        echo "DOWNLOAD FAILED (may not be available yet)"
        rm -f "$zip_file"
        failed=$((failed + 1))
    fi

    # Brief pause to be polite to BLS servers
    sleep 1
done

echo ""
echo "Summary: downloaded=$downloaded, skipped=$skipped, failed=$failed"
echo ""

# Write vintage info
cat > "$OUTPUT_DIR/data_vintage.txt" << EOF
Data Source: BLS Quarterly Census of Employment and Wages (QCEW)
Download Timestamp: $(date -Iseconds)
URL Pattern: https://data.bls.gov/cew/data/files/{YEAR}/csv/{YEAR}_annual_singlefile.zip
Years Attempted: $START_YEAR to $END_YEAR
Downloaded: $downloaded
Skipped (already existed): $skipped
Failed: $failed
Scope: National level (filtered in Stata)
EOF

echo "Done."
