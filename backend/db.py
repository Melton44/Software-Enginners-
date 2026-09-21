import psycopg2

def get_db_connection():
    conn = psycopg2.connect(
        host="localhost",
        database="TUIYMET",  # Replace with your DB name
        user="postgres",                # Replace with your DB username
        password="1041",        # Replace with your DB password
        port="5432"
    )
    return conn