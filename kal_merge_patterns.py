# kal_merge_patterns.py
import re

# Priimami failų pavadinimai (tik ketvirčiai, kad neįtrauktų mūsų pačių news.csv ir pan.)
FILE_RE = re.compile(r"^20\d{2}Q[1-4]\.csv$", re.IGNORECASE)

# Kandidatai stulpeliams
DATETIME_COL_CANDS = [
    "start", "date/time", "datetime", "timestamp", "time (gmt)", "gmt time", "gmt", "utc",
]
DATE_COL_CANDS     = ["date", "day", "published", "release date"]
TIME_COL_CANDS     = ["time", "time (gmt)", "gmt", "gmt time", "utc", "release time"]
CURRENCY_COL_CANDS = ["currency", "cur", "ccy"]
EVENT_COL_CANDS    = ["event", "title", "news", "subject", "indicator", "name"]
