//+------------------------------------------------------------------+
//| CryptoGrid_MonthlySummary.mqh                                   |
//| Monthly summary reporting                                       |
//| Modular v1.5 branch based on classic v1.4.5 logic. |
//+------------------------------------------------------------------+
#ifndef __CRYPTOGRID_MONTHLYSUMMARY_MQH__
#define __CRYPTOGRID_MONTHLYSUMMARY_MQH__

//+------------------------------------------------------------------+
//| Monthly summary helpers                                          |
//+------------------------------------------------------------------+
void AddMonthSummary(const string month_key,
                     const bool has_data,
                     const datetime first_time,
                     const datetime last_time,
                     const double first_price,
                     const double last_price,
                     const double equity_start,
                     const double equity_end,
                     const ulong rows_used,
                     const ulong bad_rows,
                     const ulong skipped_rows,
                     const ulong up_crossings,
                     const ulong down_crossings,
                     const ulong trades,
                     const double fees)
{
   int n = ArraySize(g_month_summaries);
   ArrayResize(g_month_summaries, n + 1);

   g_month_summaries[n].month_key      = month_key;
   g_month_summaries[n].has_data       = has_data;
   g_month_summaries[n].first_time     = first_time;
   g_month_summaries[n].last_time      = last_time;
   g_month_summaries[n].first_price    = first_price;
   g_month_summaries[n].last_price     = last_price;
   g_month_summaries[n].equity_start   = equity_start;
   g_month_summaries[n].equity_end     = equity_end;
   g_month_summaries[n].rows_used      = rows_used;
   g_month_summaries[n].bad_rows       = bad_rows;
   g_month_summaries[n].skipped_rows   = skipped_rows;
   g_month_summaries[n].up_crossings   = up_crossings;
   g_month_summaries[n].down_crossings = down_crossings;
   g_month_summaries[n].trades         = trades;
   g_month_summaries[n].fees           = fees;
}
//+------------------------------------------------------------------+
void PrintMonthlySummary()
{
   int n = ArraySize(g_month_summaries);

   if(n <= 0)
      return;

   Print("----------------------------------------");
   Print("MONTHLY SUMMARY");

   for(int i = 0; i < n; i++)
   {
      if(!g_month_summaries[i].has_data)
      {
         Print(g_month_summaries[i].month_key,
               " | NO DATA | rows 0 | check CSV file / date range");
         continue;
      }

      double market_ret_pct = 0.0;
      double equity_ret_pct = 0.0;

      if(g_month_summaries[i].first_price > 0.0)
         market_ret_pct = (g_month_summaries[i].last_price /
                           g_month_summaries[i].first_price - 1.0) * 100.0;

      if(g_month_summaries[i].equity_start > 0.0)
         equity_ret_pct = (g_month_summaries[i].equity_end /
                           g_month_summaries[i].equity_start - 1.0) * 100.0;

      ulong crossings = g_month_summaries[i].up_crossings +
                        g_month_summaries[i].down_crossings;

      Print(g_month_summaries[i].month_key,
            " | price ", FmtPriceMonthly(g_month_summaries[i].first_price),
            " -> ", FmtPriceMonthly(g_month_summaries[i].last_price),
            " (", FmtPctShort(market_ret_pct), "%)",
            " | eq ", FmtMoneyShort(g_month_summaries[i].equity_start),
            " -> ", FmtMoneyShort(g_month_summaries[i].equity_end),
            " (", FmtPctShort(equity_ret_pct), "%)",
            " | cross ", (string)crossings,
            " | trades ", (string)g_month_summaries[i].trades,
            " | fees ", FmtMoneyShort(g_month_summaries[i].fees));
   }
}

#endif // __CRYPTOGRID_MONTHLYSUMMARY_MQH__
