//+------------------------------------------------------------------+
//| CryptoGrid_Processing.mqh                                       |
//| Tick, grid-crossing and sub-line processing                     |
//| v1.5.1: v1.5 cascade processing with optional sub-line entries. |
//+------------------------------------------------------------------+
#ifndef __CRYPTOGRID_PROCESSING_MQH__
#define __CRYPTOGRID_PROCESSING_MQH__

//+------------------------------------------------------------------+
//| Processing                                                       |
//+------------------------------------------------------------------+
void ProcessGridCrossings()
{
   int start_index  = g_current_grid_index;
   int target_index = GridIndexForPrice(g_last_bid);
   int index_gap    = target_index - g_current_grid_index;

   if(index_gap > MAX_LOCAL_CROSSINGS)
   {
      g_multi_jump_ticks++;
      AddMultiJumpEvent(g_last_tick_time,
                        g_jump_prev_bid,
                        g_last_bid,
                        start_index,
                        target_index,
                        index_gap,
                        true,
                        g_jump_equity_before,
                        PortfolioValueBid());
      ResyncGridIndexToCurrentBid("pre-check: up catch-up exceeded 1000 grid levels");
      return;
   }

   if(index_gap < -MAX_LOCAL_CROSSINGS)
   {
      g_multi_jump_ticks++;
      AddMultiJumpEvent(g_last_tick_time,
                        g_jump_prev_bid,
                        g_last_bid,
                        start_index,
                        target_index,
                        -index_gap,
                        true,
                        g_jump_equity_before,
                        PortfolioValueBid());
      ResyncGridIndexToCurrentBid("pre-check: down catch-up exceeded 1000 grid levels");
      return;
   }

   int    local_crossings = 0;
   double path_price      = g_jump_prev_bid;

   // A sub-line mini-cycle can return to the current parent line without
   // moving g_current_grid_index. Close that parent-line return first,
   // but only when the tick actually crosses the current main line.
   double current_line_price = GridLinePrice(g_current_grid_index);

   if(g_last_bid > path_price && current_line_price > 0.0 &&
      CrossedUpLevel(path_price, g_last_bid, current_line_price))
   {
      CloseTriggeredPendingBuys();
      path_price = current_line_price;
   }
   else if(g_last_bid < path_price && current_line_price > 0.0 &&
           CrossedDownLevel(path_price, g_last_bid, current_line_price))
   {
      CloseTriggeredPendingSells();
      path_price = current_line_price;
   }

   while(g_last_bid >= GridLinePrice(g_current_grid_index + 1))
   {
      int    upper_level   = g_current_grid_index + 1;
      double subline_price = GridSubLinePrice(g_current_grid_index);

      if(InpUseSubLines && subline_price > 0.0 &&
         CrossedUpLevel(path_price, g_last_bid, subline_price))
      {
         g_subline_upper_touches++;
         g_subline_total_touches++;
         OpenUpperSellSubCycle(upper_level, subline_price);
         path_price = subline_price;
      }

      g_current_grid_index++;

      double line_price = GridLinePrice(g_current_grid_index);

      g_up_crossings++;
      g_total_crossings++;
      local_crossings++;

      if(InpUseSubLines)
         MarkPendingSellSublineReachedNext(g_current_grid_index, g_current_grid_index - 1);

      // Two-stage UP crossing:
      // 1) close lower buys,
      // 2) sell part of FREE crypto.
      CloseTriggeredPendingBuys();
      OpenUpperSellCycle(g_current_grid_index, line_price);

      path_price = line_price;

      if(local_crossings >= MAX_LOCAL_CROSSINGS)
      {
         ResyncGridIndexToCurrentBid("runtime: local up crossings reached 1000");
         return;
      }
   }

   while(g_last_bid <= GridLinePrice(g_current_grid_index - 1))
   {
      int    lower_level   = g_current_grid_index - 1;
      double subline_price = GridSubLinePrice(lower_level);

      if(InpUseSubLines && subline_price > 0.0 &&
         CrossedDownLevel(path_price, g_last_bid, subline_price))
      {
         g_subline_lower_touches++;
         g_subline_total_touches++;
         OpenLowerBuySubCycle(lower_level, subline_price);
         path_price = subline_price;
      }

      g_current_grid_index--;

      double line_price = GridLinePrice(g_current_grid_index);

      g_down_crossings++;
      g_total_crossings++;
      local_crossings++;

      if(InpUseSubLines)
         MarkPendingBuySublineReachedNext(g_current_grid_index, g_current_grid_index + 1);

      // Two-stage DOWN crossing:
      // 1) close upper sells,
      // 2) buy crypto with part of FREE stable.
      CloseTriggeredPendingSells();
      OpenLowerBuyCycle(g_current_grid_index, line_price);

      path_price = line_price;

      if(local_crossings >= MAX_LOCAL_CROSSINGS)
      {
         ResyncGridIndexToCurrentBid("runtime: local down crossings reached 1000");
         return;
      }
   }

   if(g_last_bid > path_price)
   {
      int    upper_level   = g_current_grid_index + 1;
      double subline_price = GridSubLinePrice(g_current_grid_index);

      if(InpUseSubLines && subline_price > 0.0 &&
         CrossedUpLevel(path_price, g_last_bid, subline_price))
      {
         g_subline_upper_touches++;
         g_subline_total_touches++;
         OpenUpperSellSubCycle(upper_level, subline_price);
      }
   }
   else if(g_last_bid < path_price)
   {
      int    lower_level   = g_current_grid_index - 1;
      double subline_price = GridSubLinePrice(lower_level);

      if(InpUseSubLines && subline_price > 0.0 &&
         CrossedDownLevel(path_price, g_last_bid, subline_price))
      {
         g_subline_lower_touches++;
         g_subline_total_touches++;
         OpenLowerBuySubCycle(lower_level, subline_price);
      }
   }

   // A final close pass catches sub-line lots that return to their
   // parent main line on a tick that did not move the main grid index.
   CloseTriggeredPendingBuys();
   CloseTriggeredPendingSells();

   if(local_crossings > 1)
   {
      g_multi_jump_ticks++;
      AddMultiJumpEvent(g_last_tick_time,
                        g_jump_prev_bid,
                        g_last_bid,
                        start_index,
                        g_current_grid_index,
                        local_crossings,
                        false,
                        g_jump_equity_before,
                        PortfolioValueBid());
   }
}
//+------------------------------------------------------------------+
void ProcessTick(const double bid, const double ask, const datetime tick_time)
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
      g_current_grid_index = GridIndexForPrice(bid);

      InitialAllocate();
      return;
   }

   g_jump_prev_bid      = g_last_bid;
   g_jump_prev_time     = g_last_tick_time;
   g_jump_equity_before = PortfolioValueBid();

   g_last_bid       = bid;
   g_last_ask       = ask;
   g_last_tick_time = tick_time;

   ProcessGridCrossings();
   UpdateRiskStats();
}

#endif // __CRYPTOGRID_PROCESSING_MQH__
