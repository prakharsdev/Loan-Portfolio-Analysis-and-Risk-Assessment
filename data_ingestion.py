import pandas as pd
from sqlalchemy import create_engine
from tqdm import tqdm

def ingest_data(file_path, table_name, engine, chunk_size=1000):
    """
    Ingest data from a CSV file into a PostgreSQL table in chunks.

    Parameters:
    - file_path: Path to the CSV file to be ingested.
    - table_name: Name of the PostgreSQL table to insert data into.
    - engine: SQLAlchemy engine connected to the PostgreSQL database.
    - chunk_size: Number of rows to insert per chunk (default is 1000).
    """
    # Load the CSV file into a DataFrame
    df = pd.read_csv(file_path, low_memory=False)

    # Set up a progress bar with the total number of chunks to be inserted
    total_rows = len(df)
    num_chunks = (total_rows // chunk_size) + 1

    with tqdm(total=num_chunks, desc=f"Inserting {table_name} rows into PostgreSQL", unit="chunk") as pbar:
        for i in range(0, total_rows, chunk_size):
            chunk = df.iloc[i:i + chunk_size]
            chunk.to_sql(table_name, engine, if_exists='append', index=False, method='multi')
            pbar.update(1)

    print(f"{table_name} has been successfully inserted into the PostgreSQL table.")

# File paths to the CSV files
loan_data_file_path = 'C:/Users/Allthingdata/DE_project/Bondora/LoanData.csv'
repayments_data_file_path = 'C:/Users/Allthingdata/DE_project/Bondora/RepaymentsData.csv'

# Connect to the PostgreSQL database
engine = create_engine('postgresql://postgres:1234@localhost:5432/bondora')

# Ingest LoanData into the PostgreSQL database
ingest_data(loan_data_file_path, 'LoanData', engine)

# Ingest RepaymentsData into the PostgreSQL database
ingest_data(repayments_data_file_path, 'RepaymentsData', engine)
