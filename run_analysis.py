"""Build local SQLite database from sample CSVs and execute analytical SQL."""
import csv
import sqlite3
from pathlib import Path

ROOT = Path(__file__).resolve().parent
DB = ROOT / 'retail_analytics.sqlite'


def run():
    with sqlite3.connect(DB) as con:
        con.executescript((ROOT / 'sql/01_schema.sql').read_text(encoding='utf-8'))
        for table in ('customers', 'products', 'orders', 'order_items'):
            with (ROOT / 'data' / f'{table}.csv').open(newline='', encoding='utf-8') as f:
                reader = csv.reader(f)
                columns = next(reader)
                placeholders = ','.join('?' for _ in columns)
                con.executemany(f"INSERT INTO {table} VALUES ({placeholders})", reader)
        sql = (ROOT / 'sql/02_analysis.sql').read_text(encoding='utf-8')
        queries = [q.strip() for q in sql.split(';') if q.strip()]
        for n, query in enumerate(queries, 1):
            cur = con.execute(query)
            print(f"\nANALYSIS {n}: {', '.join(c[0] for c in cur.description)}")
            for row in cur.fetchmany(6):
                print(row)
        print(f'\nDatabase saved: {DB.name}')


if __name__ == '__main__':
    run()
