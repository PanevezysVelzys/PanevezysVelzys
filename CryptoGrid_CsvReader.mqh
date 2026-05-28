//+------------------------------------------------------------------+
//| CryptoGrid_CsvReader.mqh                                        |
//| CSV file/range processing                                       |
//| Modular v1.5 branch based on classic v1.4.5 logic. |
//+------------------------------------------------------------------+
#ifndef __CRYPTOGRID_CSVREADER_MQH__
#define __CRYPTOGRID_CSVREADER_MQH__


//+------------------------------------------------------------------+
//| Resume after a skipped crash day without replaying missed grid    |
//| crossings. This is intentionally NOT the same as ProcessTick().   |
//+------------------------------------------------------------------+
void ProcessSkipDayResumeTick(const double bid, const double ask, const datetime tick_time)
{
   g_total_ticks++;

   if(bid <= 0.0 || ask <= 0.0)
      return;

   g_used_ticks++;

   if(g_first_bid == 0.0)
   {
      g_first_bid       = bid;
      g_first_ask       = ask;
      g_last_bid        = bid;
      g_last_ask        = ask;
      g_first_tick_time = tick_time;
      g_last_tick_time  = tick_time;

      g_grid_anchor_real_price = bid;
      g_current_grid_index     = GridIndexForPrice(bid);

      InitialAllocate();
      return;
   }

   g_jump_prev_bid      = g_last_bid;
   g_jump_prev_time     = g_last_tick_time;
   g_jump_equity_before = PortfolioValueBid();

   g_last_bid       = bid;
   g_last_ask       = ask;
   g_last_tick_time = tick_time;

   g_skipday_resume_resyncs++;
   ResyncGridIndexToCurrentBid("skip-day resume: robot re-enabled without replaying missed crossings");

   UpdateRiskStats();
}

//+------------------------------------------------------------------+
//| CSV processing                                                   |
//+------------------------------------------------------------------+
bool ReadOneAggTradesFile(string file_name, string month_key, ulong &rows_used)
{
   rows_used = 0;

   ulong rows_skipped_time   = 0;
   ulong rows_skipped_before = 0;
   ulong rows_skipped_after  = 0;
   ulong rows_skipped_skipday= 0;
   ulong rows_bad            = 0;
   ulong diag_printed        = 0;

   datetime file_first_time  = 0;
   datetime file_last_time   = 0;
   string   detected_unit    = "-";

   double   first_price      = 0.0;
   double   last_price       = 0.0;
   double   equity_start     = 0.0;
   double   equity_end       = 0.0;

   ulong    up_start         = g_up_crossings;
   ulong    down_start       = g_down_crossings;
   ulong    trades_start     = g_total_trades;
   double   fees_start       = g_total_fees_quote;

   int handle = FileOpen(file_name,
                         FILE_READ | FILE_CSV | FILE_ANSI,
                         ',');

   if(handle == INVALID_HANDLE)
   {
      g_csv_files_missing++;

      Print("CSV WARNING: cannot open file | ", file_name,
            " | error=", (string)GetLastError());

      AddMonthSummary(month_key, false, 0, 0, 0.0, 0.0, 0.0, 0.0,
                      0, 0, 0, 0, 0, 0, 0.0);

      return false;
   }

   g_csv_files_read++;

   if(InpInfoDetail == INFO_GRID_EVENTS)
      Print("Reading CSV file: ", file_name);

   while(!FileIsEnding(handle))
   {
      string agg_id = FileReadString(handle);

      if(FileIsEnding(handle) && agg_id == "")
         break;

      string price_s  = FileReadString(handle);
      string qty_s    = FileReadString(handle);
      string first_id = FileReadString(handle);
      string last_id  = FileReadString(handle);
      string ts_s     = FileReadString(handle);
      string maker_s  = FileReadString(handle);
      string best_s   = FileReadString(handle);

      if(price_s == "" || ts_s == "")
      {
         g_csv_bad_rows++;
         rows_bad++;
         continue;
      }

      double price = StringToDouble(price_s);
      datetime tick_time = TimestampFromString(ts_s);

      if(detected_unit == "-")
         detected_unit = TimestampUnitTextFromString(ts_s);

      if(price <= 0.0 || tick_time <= 0)
      {
         g_csv_bad_rows++;
         rows_bad++;
         continue;
      }

      if(file_first_time <= 0)
         file_first_time = tick_time;

      file_last_time = tick_time;

      if(tick_time < InpStartTime || tick_time > InpEndTime)
      {
         g_csv_rows_skipped_time++;
         rows_skipped_time++;

         if(tick_time < InpStartTime)
         {
            g_csv_rows_skipped_before++;
            rows_skipped_before++;
         }
         else
         {
            g_csv_rows_skipped_after++;
            rows_skipped_after++;
         }

         if(CSV_TIME_DIAGNOSTICS && diag_printed < (ulong)MathMax(0, CSV_TIME_DIAG_ROWS_PER_FILE))
         {
            Print("Skipped by time      : file=", file_name,
                  " | raw ts=", ts_s,
                  " | unit=", TimestampUnitTextFromString(ts_s),
                  " | parsed=", FmtDt(tick_time),
                  " | period=", FmtDt(InpStartTime), " -> ", FmtDt(InpEndTime));
            diag_printed++;
         }

         continue;
      }

      if(IsSkipDay(tick_time))
      {
         g_csv_rows_skipped_skipday++;
         rows_skipped_skipday++;

         if(!g_skip_day_active)
         {
            g_skip_day_active      = true;
            g_skip_day_active_date = DateOnlyString(tick_time);

            if(InpInfoDetail == INFO_GRID_EVENTS)
               Print("SKIP DAY START     : ", g_skip_day_active_date,
                     " | robot OFF | balances and reserves unchanged");
         }

         continue;
      }

      if(rows_used == 0)
      {
         first_price = price;

         if(g_initialized)
            equity_start = PortfolioValueAtPrice(price);
      }

      // Binance aggTrades has one price.
      // For this paper explorer bid=ask=price.
      if(g_skip_day_active)
      {
         if(InpInfoDetail == INFO_GRID_EVENTS)
            Print("SKIP DAY END       : ", g_skip_day_active_date,
                  " | robot ON | resume at ", FmtDt(tick_time),
                  " | price ", FmtPrice(price));

         g_skip_day_active      = false;
         g_skip_day_active_date = "";

         ProcessSkipDayResumeTick(price, price, tick_time);
      }
      else
      {
         ProcessTick(price, price, tick_time);
      }

      if(rows_used == 0 && equity_start <= 0.0 && g_initialized)
         equity_start = PortfolioValueBid();

      last_price = price;
      rows_used++;
   }

   FileClose(handle);

   if(rows_used > 0 && g_initialized)
      equity_end = PortfolioValueBid();

   bool has_warning = (rows_used <= 0 || rows_bad > 0 || rows_skipped_time > 0);

   if(InpInfoDetail == INFO_GRID_EVENTS)
   {
      Print("Finished CSV file: ", file_name);
      Print("Timestamp unit    : ", detected_unit);
      Print("File time range   : ", FmtDt(file_first_time), " -> ", FmtDt(file_last_time));
      Print("Rows used         : ", (string)rows_used);
      Print("Rows skipped time : ", (string)rows_skipped_time);
      Print("Skipped before    : ", (string)rows_skipped_before);
      Print("Skipped after     : ", (string)rows_skipped_after);
      Print("Skipped skip days : ", (string)rows_skipped_skipday);
      Print("Bad rows          : ", (string)rows_bad);
      Print("Last price        : ", FmtPrice(g_last_bid));
      Print("Last time         : ", FmtDt(g_last_tick_time));
   }
   else if(has_warning)
   {
      Print("CSV WARNING: ", file_name);
      Print("Rows used         : ", (string)rows_used);

      if(rows_skipped_time > 0)
         Print("Rows skipped time : ", (string)rows_skipped_time);

      if(rows_skipped_before > 0)
         Print("Skipped before    : ", (string)rows_skipped_before);

      if(rows_skipped_after > 0)
         Print("Skipped after     : ", (string)rows_skipped_after);

      if(rows_bad > 0)
         Print("Bad rows          : ", (string)rows_bad);

      if(rows_skipped_skipday > 0)
         Print("Rows skipped skipday: ", (string)rows_skipped_skipday);
   }

   AddMonthSummary(month_key,
                   (rows_used > 0),
                   file_first_time,
                   file_last_time,
                   first_price,
                   last_price,
                   equity_start,
                   equity_end,
                   rows_used,
                   rows_bad,
                   rows_skipped_time,
                   g_up_crossings - up_start,
                   g_down_crossings - down_start,
                   g_total_trades - trades_start,
                   g_total_fees_quote - fees_start);

   return true;
}
//+------------------------------------------------------------------+
void ProcessCsvRange()
{
   int y_start = 0;
   int m_start = 0;
   int y_end   = 0;
   int m_end   = 0;

   YearMonthFromTime(InpStartTime, y_start, m_start);
   YearMonthFromTime(InpEndTime,   y_end,   m_end);

   Print("CSV range            : ", (string)y_start, "-", Month2(m_start),
         " -> ", (string)y_end, "-", Month2(m_end));

   int y = y_start;
   int m = m_start;

   while(MonthLessOrEqual(y, m, y_end, m_end))
   {
      string month_key = (string)y + "-" + Month2(m);
      string file_name = BuildMonthlyFileName(y, m);

      ulong rows_used = 0;
      ReadOneAggTradesFile(file_name, month_key, rows_used);

      NextMonth(y, m);
   }

   bool data_quality_ok = (g_csv_files_missing == 0 &&
                           g_csv_bad_rows == 0 &&
                           g_csv_rows_skipped_time == 0 &&
                           g_total_ticks == g_used_ticks);

   if(data_quality_ok)
   {
      Print("CSV range done       : OK | files ", (string)g_csv_files_read,
            " | ticks ", (string)g_used_ticks);
      Print("Data quality         : OK | period ", FmtDt(g_first_tick_time),
            " -> ", FmtDt(g_last_tick_time));

      if(g_csv_rows_skipped_skipday > 0)
         Print("Rows skipped skipday : ", (string)g_csv_rows_skipped_skipday,
               " | resume resyncs ", (string)g_skipday_resume_resyncs);
   }
   else
   {
      Print("CSV range done       : WARNINGS | files ", (string)g_csv_files_read,
            " | missing ", (string)g_csv_files_missing,
            " | bad rows ", (string)g_csv_bad_rows,
            " | skipped ", (string)g_csv_rows_skipped_time,
            " | skipday ", (string)g_csv_rows_skipped_skipday);
      Print("DATA QUALITY WARNING");
      Print("CSV files read       : ", (string)g_csv_files_read);
      Print("CSV files missing    : ", (string)g_csv_files_missing);
      Print("CSV bad rows         : ", (string)g_csv_bad_rows);
      Print("Rows skipped by time : ", (string)g_csv_rows_skipped_time);
      Print("Rows skipped skipday : ", (string)g_csv_rows_skipped_skipday);
      Print("Skipday resume resync: ", (string)g_skipday_resume_resyncs);

      if(g_csv_rows_skipped_before > 0)
         Print("Rows skipped before  : ", (string)g_csv_rows_skipped_before);

      if(g_csv_rows_skipped_after > 0)
         Print("Rows skipped after   : ", (string)g_csv_rows_skipped_after);

      Print("Used ticks           : ", (string)g_used_ticks);

      if(g_total_ticks != g_used_ticks)
         Print("Total processed ticks: ", (string)g_total_ticks);

      Print("First tick time      : ", FmtDt(g_first_tick_time));
      Print("Last tick time       : ", FmtDt(g_last_tick_time));
   }

   g_csv_done = true;
}

#endif // __CRYPTOGRID_CSVREADER_MQH__
