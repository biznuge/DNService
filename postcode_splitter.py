import re
import os
import pandas as pd

def split_uk_postcode(postcode):
    """
    Splits a UK postcode into its four main components: Area, District, Sector, and Unit Postcode.

    The function is based on the format:
    - Outcode: Comprises the Area and District.
    - Incode: Comprises the Sector and Unit.

    Args:
        postcode (str): The UK postcode string. Can be None or not a string.

    Returns:
        dict: A dictionary containing the 'area', 'district', 'sector',
              and 'unit_postcode' if the postcode is valid.
              Returns an empty dictionary if the input is invalid or not a string.
    """
    # Handle cases where the input is not a string (e.g., NaN from pandas)
    if not isinstance(postcode, str):
        return {}

    # UK Postcode regular expression
    # It handles all valid UK postcode formats, including single-digit districts.
    # Groups: 1: Area, 2: District (rest), 3: Sector digit, 4: Unit letters
    postcode_regex = re.compile(r'^([A-Z]{1,2})([0-9][A-Z0-9]?) ?([0-9])([A-Z]{2})$', re.IGNORECASE)

    # Remove all spaces and convert to uppercase for consistent matching
    clean_postcode = postcode.replace(" ", "").upper()

    match = postcode_regex.match(clean_postcode)

    if not match:
        return {}

    # Extract the groups from the regex match
    area_part = match.group(1)
    district_part = match.group(2)
    sector_part = match.group(3)
    unit_part = match.group(4)

    # Construct the full components
    outcode = f"{area_part}{district_part}"
    incode = f"{sector_part}{unit_part}"
    
    result = {
        'area': area_part,
        'district': outcode,
        'sector': f"{outcode} {sector_part}",
        'unit_postcode': f"{outcode} {incode}"
    }

    return result

def process_postcode_files(input_folder, output_folder):
    """
    Processes all CSV files in a given folder, adds postcode parts,
    and saves them to an output folder.

    Args:
        input_folder (str): The path to the folder containing input CSV files.
        output_folder (str): The path where processed files will be saved.
    """
    print(f"--- Starting Postcode Processing ---")
    print(f"Input folder: '{os.path.abspath(input_folder)}'")
    print(f"Output folder: '{os.path.abspath(output_folder)}'")

    # Create the output directory if it doesn't exist
    if not os.path.exists(output_folder):
        os.makedirs(output_folder)
        print(f"Created output folder.")

    # List all files in the input directory
    try:
        files_to_process = [f for f in os.listdir(input_folder) if f.endswith('.csv')]
    except FileNotFoundError:
        print(f"\n[ERROR] Input folder '{input_folder}' not found. Please create it and add data files.")
        return

    if not files_to_process:
        print("\n[INFO] No CSV files found in the input folder.")
        return

    # Process each file
    for filename in files_to_process:
        input_filepath = os.path.join(input_folder, filename)
        output_filename = f"{os.path.splitext(filename)[0]}_processed.csv"
        output_filepath = os.path.join(output_folder, output_filename)
        
        print(f"\nProcessing '{filename}'...")

        try:
            # Read the CSV file into a pandas DataFrame
            df = pd.read_csv(input_filepath)

            # Check if the required postcode column exists
            if 'POSTCODE_LOCATOR' not in df.columns:
                print(f"  - [SKIPPED] Column 'POSTCODE_LOCATOR' not found in '{filename}'.")
                continue

            # Apply the function to the postcode column.
            # The result is a Series of dictionaries.
            postcode_data = df['POSTCODE_LOCATOR'].apply(split_uk_postcode)
            
            # Convert the Series of dictionaries into a new DataFrame
            postcode_df = pd.DataFrame(postcode_data.tolist())

            # Join the new postcode columns with the original DataFrame
            # We select only the required new columns: area, district, sector
            result_df = df.join(postcode_df[['area', 'district', 'sector']])

            # Save the enhanced DataFrame to a new CSV file
            result_df.to_csv(output_filepath, index=False)
            print(f"  - [SUCCESS] Saved processed file to '{output_filepath}'")

        except Exception as e:
            print(f"  - [ERROR] Failed to process '{filename}'. Reason: {e}")

    print("\n--- Processing Complete ---")


# --- Main Execution Block ---
# This part demonstrates how to use the script.
# It creates a dummy input folder and a sample data file.
if __name__ == "__main__":
    # Define folder names
    INPUT_DATA_FOLDER = './raw_data'
    OUTPUT_DATA_FOLDER = './transformed_data'

    # Create a dummy data file for demonstration purposes
#     if not os.path.exists(INPUT_DATA_FOLDER):
#         os.makedirs(INPUT_DATA_FOLDER)

#     sample_data = """UPRN,COUNTRY,TOWN_NAME,ADMINISTRATIVE_AREA,POSTCODE_LOCATOR
# 10001,E,,,M1 1AA
# 100012,E,,,M1 1AA
# 100013,E,,,M1 1AA
# 100014,E,,,M1 1AA
# 10002,E,,,M1 1AB
# 10003,E,,,M1 1AD
# 10004,E,,,M1 1AE
# 10005,E,,,M1 1AF
# 10006,E,,,M2 2AA
# 10007,E,,,M2 2AB
# 10008,E,,,M2 2AD
# 99999,E,,,INVALID
# """
#     sample_filepath = os.path.join(INPUT_DATA_FOLDER, 'address_data.csv')
#     with open(sample_filepath, 'w') as f:
#         f.write(sample_data)

    # Run the processing function
    process_postcode_files(input_folder=INPUT_DATA_FOLDER, output_folder=OUTPUT_DATA_FOLDER)
