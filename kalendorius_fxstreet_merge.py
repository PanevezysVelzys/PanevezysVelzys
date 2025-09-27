#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
FXStreet ketvirčių CSV sujungimas → VIENAS UTC CSV „news.csv“
• 100% be poslinkių (laikai paliekami tokie, kokie yra šaltinyje – laikome kaip UTC).
• Griežtai imami tik failai, atitinkantys ^20\\d{2}Q[1-4]\\.csv
• Diagnostika: formatų hit'ai, dviprasmybės, „blogos“ eilutės, NFP peržiūra.

Naudojimas:
  python3 kalendorius_fxstreet_merge.py \
    --in-dir "/home/administrator/Desktop/Kalendorius" \
    --out-news "/home/administrator/Desktop/Kalendorius/news.csv" \
    --log "/home/administrator/Desktop/Kalendorius/merge_report.txt" \
    --debug
"""

from __future__ import annotations
import os, glob, argparse
from datetime import datetime
import pandas as pd

from kal_merge_patterns import FILE_RE
from kal_merge_parse import (
    read_df_any, find_columns, parse_dt_unified, parse_dt_pair,
    looks_like_ccy, guess_event_col, clean_event
)
from kal_merge_diag import MergeDiag

def merge_folder(in_dir: str, out_news: str, log_path: str|None,
                 debug: bool, require_time: bool, dedupe: bool):
    diag = MergeDiag()

    # rinkti TIK ketvirčius
    all_paths = sorted(glob.glob(os.path.join(in_dir, "*.csv")))
    paths = [p for p in all_paths if FILE_RE.search(os.path.basename(p) or "")]
    if not paths:
        raise SystemExit(f"Nerasta ketvirtinių CSV {in_dir} (pagal ^20..Q[1-4].csv). "
                         f"Rasta kitų CSV: {len(all_paths)}")

    rows_total = 0
    out_rows: list[tuple[str,str,str,str]] = []  # date_utc, time_utc, cur, ev

    for p in paths:
        diag.add_file(p)
        df = read_df_any(p)
        df = df.loc[:, ~(df.isna().all())]

        cmap = find_columns(df)
        cur_col = cmap["cur"]
        ev_col  = cmap["ev"]
        dt_col  = cmap["dt"]
        d_col   = cmap["d"]
        t_col   = cmap["t"]

        # Jei neradom valiutos – logika pagal turinį
        if cur_col is None:
            best, best_sc = None, -1.0
            for col in df.columns:
                sc = looks_like_ccy(df[col])
                if sc > best_sc:
                    best, best_sc = col, sc
            if best_sc >= 0.3:
                cur_col = best

        # Jei neradom event – spėjame
        if ev_col is None:
            ev_col = guess_event_col(df, exclude={cur_col, dt_col, d_col, t_col})

        kept = 0
        fmt_hits_local: dict[str,int] = {}

        for _, r in df.iterrows():
            rows_total += 1
            cur = (str(r[cur_col]).strip().upper() if cur_col and cur_col in df.columns else "")
            ev  = clean_event(r[ev_col]) if ev_col and ev_col in df.columns else ""
            if not cur or not ev:
                diag.add_bad_row(f"{os.path.basename(p)} | missing cur/ev")
                continue

            dt_utc: datetime | None = None

            # 1) vienas datetime
            if dt_col and dt_col in df.columns:
                txt = str(r[dt_col])
                d = parse_dt_unified(txt, fmt_hits_local)
                if d is None:
                    # gal įrašas turi tik datą „Start“?
                    # pabandome split'inti, jei yra tarpas
                    parts = str(txt).split()
                    if len(parts) == 2:
                        d = parse_dt_pair(parts[0], parts[1], require_time, fmt_hits_local)
                dt_utc = d

            # 2) pora (data + laikas)
            if dt_utc is None and (d_col in df.columns or t_col in df.columns):
                dtxt = str(r[d_col]) if d_col in df.columns else ""
                ttxt = str(r[t_col]) if t_col in df.columns else ""
                dt_utc = parse_dt_pair(dtxt, ttxt, require_time, fmt_hits_local)

            # 3) nepavyko
            if dt_utc is None:
                diag.add_bad_row(f"{os.path.basename(p)} | cannot parse dt")
                continue

            # įrašom (UTC – be jokių poslinkių)
            out_rows.append((
                dt_utc.strftime("%Y-%m-%d"),
                dt_utc.strftime("%H:%M:%S"),
                cur,
                ev
            ))
            kept += 1
            diag.add_nfp_preview(dt_utc, cur, ev)

        # failo ataskaita
        diag.add_format_hits(fmt_hits_local)
        msg = (f"[OK] {os.path.basename(p)} kept={kept} "
               f"(cur='{cur_col}', ev='{ev_col}', dt='{dt_col or (str(d_col or '?')+'+'+str(t_col or '?'))}')")
        if debug:
            msg += f" | fmt: {dict(fmt_hits_local)}"
        diag.add_report(msg)
        print(msg)

    # finaliniai darbai
    df_all = pd.DataFrame(out_rows, columns=["date_utc","time_utc","currency","event"])
    if dedupe:
        df_all = df_all.drop_duplicates()
    df_all = df_all.sort_values(["date_utc","time_utc","currency","event"]).reset_index(drop=True)

    os.makedirs(os.path.dirname(out_news) or ".", exist_ok=True)
    df_all.to_csv(out_news, index=False, encoding="utf-8")

    diag.write_summary(log_path or "", rows_total, len(df_all))

    print("\nSUMMARY")
    print(f"  Files : {len(paths)}")
    print(f"  OUT   : {out_news}")
    print(f"  Rows  : {len(df_all)}")
    if len(df_all):
        print(f"  Range : {df_all.iloc[0,0]} {df_all.iloc[0,1]} → {df_all.iloc[-1,0]} {df_all.iloc[-1,1]} (UTC)")
    if log_path:
        print(f"  Log   : {log_path}")
    if diag.nfp_preview:
        print("  NFP preview:")
        for s in diag.nfp_preview: print("   ", s)

def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--in-dir", required=True, help="Aplankas su ketvirtiniais CSV (pvz., 2011Q1.csv)")
    ap.add_argument("--out-news", required=True, help="Kur rašyti sujungtą UTC CSV (pvz., news.csv)")
    ap.add_argument("--log", default=None, help="Kur rašyti diagnostikos ataskaitą")
    ap.add_argument("--debug", action="store_true")
    ap.add_argument("--no-require-time", dest="require_time", action="store_false",
                    help="Leisti įrašus be tikslaus laiko (jei šaltinis neturi laiko)")
    ap.add_argument("--require-time", action="store_true", default=True)
    ap.add_argument("--no-dedupe", dest="dedupe", action="store_false")
    ap.add_argument("--dedupe", action="store_true", default=True)
    args = ap.parse_args()

    merge_folder(args.in_dir, args.out_news, log_path=args.log, debug=args.debug,
                 require_time=args.require_time, dedupe=args.dedupe)

if __name__ == "__main__":
    main()
