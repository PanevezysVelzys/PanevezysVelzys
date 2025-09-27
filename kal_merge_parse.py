# kal_merge_parse.py
from __future__ import annotations
import pandas as pd
from datetime import datetime
import re
from typing import Optional, Tuple, Dict, Any, List
from kal_merge_patterns import (
    DATETIME_COL_CANDS, DATE_COL_CANDS, TIME_COL_CANDS, CURRENCY_COL_CANDS, EVENT_COL_CANDS
)

WS_RE    = re.compile(r"\s+")
DASH_RE  = re.compile(r"[–—−]")
TZ_RE    = re.compile(r"\s+(GMT|UTC|GMT\+0|UTC\+0)$", re.IGNORECASE)

# ---- valymas ----
def clean_event(ev: str) -> str:
    s = "" if ev is None else str(ev)
    s = s.strip().strip('"').strip("'")
    s = DASH_RE.sub("-", s)
    s = WS_RE.sub(" ", s).strip()
    return s

def read_df_any(path: str) -> pd.DataFrame:
    for sep in [None, ",", ";", "\t", "|"]:
        try:
            df = pd.read_csv(path, sep=sep, engine="python", encoding="utf-8-sig")
            if df.shape[1] >= 2 and df.shape[0] >= 1:
                return df
        except Exception:
            pass
    return pd.read_csv(path, engine="python", encoding="utf-8-sig")

# ---- stulpelių radimas ----
def _pick_by_keywords(cols: List[str], pool: List[str]) -> Optional[str]:
    low = [c.lower().strip() for c in cols]
    for cand in pool:
        for i, name in enumerate(low):
            if cand in name:
                return cols[i]
    return None

def find_columns(df: pd.DataFrame) -> Dict[str, Optional[str]]:
    cols = [str(c).strip() for c in df.columns]
    return {
        "dt":  _pick_by_keywords(cols, DATETIME_COL_CANDS),
        "d":   _pick_by_keywords(cols, DATE_COL_CANDS),
        "t":   _pick_by_keywords(cols, TIME_COL_CANDS),
        "cur": _pick_by_keywords(cols, CURRENCY_COL_CANDS),
        "ev":  _pick_by_keywords(cols, EVENT_COL_CANDS),
    }

# ---- datų parsinimas (UTC – be persukimų) ----
# Aiški politika: FXStreet dažniausiai pateikia JAV formatu → **pirmiau MM/DD**,
# bet detektuojam ir dviprasmybes, kad galėtume pranešti diagnostikai.

FMT_US_DATETIME = [
    "%m/%d/%Y %H:%M:%S", "%m/%d/%Y %H:%M",
    "%b %d, %Y %H:%M:%S", "%b %d, %Y %H:%M",
    "%Y-%m-%d %H:%M:%S",  "%Y-%m-%d %H:%M",
]
FMT_EU_DATETIME = [
    "%d/%m/%Y %H:%M:%S", "%d/%m/%Y %H:%M",
    "%d %b %Y %H:%M:%S", "%d %b %Y %H:%M",
]

FMT_US_DATE = ["%m/%d/%Y", "%b %d, %Y", "%Y-%m-%d"]
FMT_EU_DATE = ["%d/%m/%Y", "%d %b %Y", "%Y-%m-%d"]
FMT_TIME    = ["%H:%M:%S", "%H:%M"]

def _strip_tz(s: str) -> str:
    return TZ_RE.sub("", s.strip().strip('"'))

def _try_parse(s: str, fmts: List[str]) -> Optional[datetime]:
    for f in fmts:
        try:
            return datetime.strptime(s, f)
        except ValueError:
            pass
    return None

def parse_dt_unified(text: str, diag: Dict[str, Any]) -> Optional[datetime]:
    s = _strip_tz(text)
    # US-first
    d = _try_parse(s, FMT_US_DATETIME)
    if d is not None:
        diag["fmt_us"] = diag.get("fmt_us", 0) + 1
        return d
    # EU-second
    d = _try_parse(s, FMT_EU_DATETIME)
    if d is not None:
        diag["fmt_eu"] = diag.get("fmt_eu", 0) + 1
        return d
    return None

def parse_dt_pair(date_text: str, time_text: str, require_time: bool, diag: Dict[str, Any]) -> Optional[datetime]:
    ds = _strip_tz(date_text)
    ts = _strip_tz(time_text)
    # su laiku
    if ds and ts:
        # bandome US ir EU
        for tf in FMT_TIME:
            t = _try_parse(ts, [tf])
            if t is None:
                continue
            # US
            d_us = _try_parse(ds, FMT_US_DATE)
            if d_us is not None:
                diag["fmt_pair_us"] = diag.get("fmt_pair_us", 0) + 1
                return d_us.replace(hour=t.hour, minute=t.minute, second=getattr(t, "second", 0))
            # EU
            d_eu = _try_parse(ds, FMT_EU_DATE)
            if d_eu is not None:
                diag["fmt_pair_eu"] = diag.get("fmt_pair_eu", 0) + 1
                return d_eu.replace(hour=t.hour, minute=t.minute, second=getattr(t, "second", 0))
        return None
    # tik diena (jei leidžiama)
    if not require_time and ds:
        d_us = _try_parse(ds, FMT_US_DATE)
        if d_us is not None:
            diag["fmt_date_us"] = diag.get("fmt_date_us", 0) + 1
            return d_us
        d_eu = _try_parse(ds, FMT_EU_DATE)
        if d_eu is not None:
            diag["fmt_date_eu"] = diag.get("fmt_date_eu", 0) + 1
            return d_eu
    return None

def looks_like_ccy(series: pd.Series) -> float:
    s = series.astype(str).str.strip()
    return float(s.str.match(r"^[A-Za-z]{3}$", na=False).mean())

def guess_event_col(df: pd.DataFrame, exclude: set) -> Optional[str]:
    best, score = None, -1.0
    for col in df.columns:
        if col in exclude: 
            continue
        s = df[col].astype(str).fillna("")
        if s.str.match(r"^\d+(\.\d+)?$", na=False).mean() > 0.5:
            continue
        uniq = s.nunique()
        avg_len = s.str.len().mean()
        sc = uniq + 0.1*avg_len
        if sc > score:
            score, best = sc, col
    return best
