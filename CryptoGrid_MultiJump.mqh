//+------------------------------------------------------------------+
//| CryptoGrid_MultiJump.mqh                                        |
//| Multi-jump reporting helpers                                    |
//| v1.5 reviewed: v1.4.5 multi-jump reporting unchanged.           |
//+------------------------------------------------------------------+
#ifndef __CRYPTOGRID_MULTIJUMP_MQH__
#define __CRYPTOGRID_MULTIJUMP_MQH__

//+------------------------------------------------------------------+
//| Multi-jump helpers                                               |
//+------------------------------------------------------------------+
void AddMultiJumpEvent(const datetime event_time,
                       const double from_price,
                       const double to_price,
                       const int from_index,
                       const int to_index,
                       const int grid_levels,
                       const bool resync,
                       const double equity_before,
                       const double equity_after)
{
   int levels = grid_levels;

   if(levels < 0)
      levels = -levels;

   if(levels <= 1)
      return;

   int n = ArraySize(g_multi_jump_events);
   ArrayResize(g_multi_jump_events, n + 1);

   g_multi_jump_events[n].event_time    = event_time;
   g_multi_jump_events[n].from_price    = from_price;
   g_multi_jump_events[n].to_price      = to_price;
   g_multi_jump_events[n].from_index    = from_index;
   g_multi_jump_events[n].to_index      = to_index;
   g_multi_jump_events[n].grid_levels   = levels;
   g_multi_jump_events[n].equity_before = equity_before;
   g_multi_jump_events[n].equity_after  = equity_after;
   g_multi_jump_events[n].resync        = resync;
}
//+------------------------------------------------------------------+
void PrintMultiJumpSummary()
{
   int n = ArraySize(g_multi_jump_events);

   if(n <= 0)
      return;

   Print("----------------------------------------");
   Print("MULTI-JUMPS");

   for(int i = 0; i < n; i++)
   {
      double price_ret_pct = 0.0;
      double equity_ret_pct = 0.0;

      if(g_multi_jump_events[i].from_price > 0.0)
         price_ret_pct = (g_multi_jump_events[i].to_price /
                          g_multi_jump_events[i].from_price - 1.0) * 100.0;

      if(g_multi_jump_events[i].equity_before > 0.0)
         equity_ret_pct = (g_multi_jump_events[i].equity_after /
                           g_multi_jump_events[i].equity_before - 1.0) * 100.0;

      string resync_text = "";

      if(g_multi_jump_events[i].resync)
         resync_text = " | RESYNC";

      Print((string)(i + 1), ") ", FmtDt(g_multi_jump_events[i].event_time),
            " | grid levels ", (string)g_multi_jump_events[i].grid_levels,
            " | idx ", (string)g_multi_jump_events[i].from_index,
            " -> ", (string)g_multi_jump_events[i].to_index,
            " | price ", FmtMoneyShort(g_multi_jump_events[i].from_price),
            " -> ", FmtMoneyShort(g_multi_jump_events[i].to_price),
            " (", FmtPctShort(price_ret_pct), "%)",
            " | eq ", FmtMoneyShort(g_multi_jump_events[i].equity_before),
            " -> ", FmtMoneyShort(g_multi_jump_events[i].equity_after),
            " (", FmtPctShort(equity_ret_pct), "%)",
            resync_text);
   }
}

#endif // __CRYPTOGRID_MULTIJUMP_MQH__
