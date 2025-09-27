# kal_merge_diag.py
from __future__ import annotations
from typing import Dict, Any, List
from collections import Counter
from datetime import datetime

class MergeDiag:
    def __init__(self) -> None:
        self.files: List[str] = []
        self.file_reports: List[str] = []
        self.counts = Counter()
        self.ambiguous_examples: List[str] = []
        self.bad_rows_examples: List[str] = []
        self.nfp_preview: List[str] = []  # keli „Nonfarm“ pavyzdžiai iš galutinio rinkinio

    def add_file(self, path: str) -> None:
        self.files.append(path)

    def add_report(self, text: str) -> None:
        self.file_reports.append(text)

    def add_ambiguous(self, raw: str) -> None:
        if len(self.ambiguous_examples) < 10:
            self.ambiguous_examples.append(raw)
        self.counts["ambiguous"] += 1

    def add_bad_row(self, text: str) -> None:
        if len(self.bad_rows_examples) < 10:
            self.bad_rows_examples.append(text)
        self.counts["bad_rows"] += 1

    def add_format_hits(self, local: Dict[str, int]) -> None:
        for k, v in local.items():
            self.counts[k] += v

    def add_nfp_preview(self, dt: datetime, cur: str, ev: str) -> None:
        if "nonfarm" in ev.lower() and len(self.nfp_preview) < 8:
            self.nfp_preview.append(f"{dt:%Y-%m-%d %H:%M:%S} | {cur} | {ev}")

    def write_summary(self, path: str, rows_total: int, rows_kept: int) -> None:
        if not path:
            return
        with open(path, "w", encoding="utf-8") as f:
            f.write("\n".join(self.file_reports))
            f.write("\n\nSUMMARY\n")
            f.write(f"Files processed: {len(self.files)}\n")
            f.write(f"Rows total:     {rows_total}\n")
            f.write(f"Rows kept:      {rows_kept}\n")
            for k, v in self.counts.most_common():
                f.write(f"{k}: {v}\n")
            if self.ambiguous_examples:
                f.write("\nAmbiguous date samples (MM/DD vs DD/MM):\n")
                for s in self.ambiguous_examples:
                    f.write(f"  {s}\n")
            if self.bad_rows_examples:
                f.write("\nBad row samples:\n")
                for s in self.bad_rows_examples:
                    f.write(f"  {s}\n")
            if self.nfp_preview:
                f.write("\nNFP preview (first few found in merge):\n")
                for s in self.nfp_preview:
                    f.write(f"  {s}\n")
