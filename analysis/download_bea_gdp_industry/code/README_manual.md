# Manual BEA Data Download (Fallback)

If the Python API helper fails, download data manually:

## Steps

1. Go to: https://apps.bea.gov/iTable/?reqid=150&step=2&isuri=1&categories=gdpxind
2. Select **GDP by Industry** section
3. Download these tables (all industries, all years, CSV format):

   - **Value Added by Industry** (current dollars)
   - **Components of Value Added by Industry** (compensation, GOS, taxes)
   - **Chain-Type Quantity Indexes for Value Added by Industry**

4. Save CSVs to `../outputs/` as:
   - `bea_va_components.csv`
   - `bea_chain_indexes.csv`

5. Create `../outputs/data_vintage.txt` with:
   - Download date
   - BEA release/revision date (shown on the download page)
   - Which tables were downloaded

6. Then run `main.do` — it will skip the Python download and import directly.
