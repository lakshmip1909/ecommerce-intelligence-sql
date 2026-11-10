"""Prepare Olist review comments for MySQL CSV import."""

import csv
from pathlib import Path

DATA_DIR = Path(__file__).resolve().parent.parent / "data"

source = DATA_DIR / "olist_order_reviews_dataset.csv"
destination = DATA_DIR / "olist_order_reviews_clean.csv"

with source.open("r", encoding="utf-8-sig", newline="") as infile, \
     destination.open("w", encoding="utf-8", newline="") as outfile:

    reader = csv.DictReader(infile)
    writer = csv.DictWriter(outfile, fieldnames=reader.fieldnames)

    writer.writeheader()

    count = 0

    for row in reader:
        row["review_comment_message"] = (
            row["review_comment_message"]
            .replace("\r", " ")
            .replace("\n", " ")
        )

        writer.writerow(row)
        count += 1

print(f"Prepared {count:,} reviews.")
print(f"Saved to: {destination}")
