//+------------------------------------------------------------------+
//| CryptoGrid_CycleOpening.mqh                                     |
//| Opening upper/lower cycles                                      |
//| v1.5.2: v1.5 openings plus conservative two-way half-size sub-line entries. |
//+------------------------------------------------------------------+
#ifndef __CRYPTOGRID_CYCLEOPENING_MQH__
#define __CRYPTOGRID_CYCLEOPENING_MQH__

//+------------------------------------------------------------------+
//| Opening cycles                                                   |
//+------------------------------------------------------------------+
void OpenUpperSellSubCycle(int upper_level, double subline_price)
{
   if(!InpUseSubLines)
      return;

   int close_level = upper_level - 1;

   bool two_way_entry = false;

   if(!CanOpenUpperSellSubCycle(close_level, upper_level, two_way_entry))
   {
      g_subline_upper_skipped++;
      g_subline_upper_skip_interval++;
      return;
   }

   if(g_base_free <= 0.0 || g_last_bid <= 0.0)
   {
      g_subline_upper_skipped++;
      g_subline_upper_skip_no_base++;
      return;
   }

   double crypto_before_free     = g_base_free;
   double crypto_before_reserved = g_base_reserved;
   double stable_before_free     = g_quote_free;
   double stable_before_reserved = g_quote_reserved;

   double sell_rate    = SellTradeRate();
   double base_to_sell = g_base_free * sell_rate * SUBLINE_PART_RATE;

   if(base_to_sell <= 0.0)
   {
      g_subline_upper_skipped++;
      g_subline_upper_skip_zero++;
      return;
   }

   double base_sold   = 0.0;
   double net_quote   = 0.0;
   double gross_quote = 0.0;

   if(!ExecuteSellFreeToReserved(base_to_sell,
                                 false,
                                 "upper sub-line sell free crypto",
                                 base_sold,
                                 net_quote,
                                 gross_quote))
   {
      g_subline_upper_skipped++;
      g_subline_upper_skip_exec++;
      return;
   }

   if(base_sold <= 0.0 || net_quote <= 0.0)
   {
      g_subline_upper_skipped++;
      g_subline_upper_skip_exec++;
      return;
   }

   g_next_upper_cycle_id++;
   ulong cycle_id = g_next_upper_cycle_id;

   double close_price = GridLinePrice(close_level);
   double fee         = gross_quote * FeeRate();

   AddTradeOriginDiagnostics(true, false, gross_quote);

   AddPendingSellLot(cycle_id,
                     base_sold,
                     net_quote,
                     g_last_bid,
                     close_price,
                     upper_level,
                     close_level,
                     true,
                     true,
                     false);

   g_upper_cycle_sells++;
   g_subline_upper_sells++;

   if(two_way_entry)
      g_subline_upper_twoway_sells++;

   UpdateRiskStats();

   if(InpInfoDetail == INFO_GRID_EVENTS)
   {
      if(two_way_entry)
         Print("UPPER TWO-WAY SUB-LINE CYCLE OPENED #", (string)cycle_id);
      else
         Print("UPPER SUB-LINE CYCLE OPENED #", (string)cycle_id);
      Print("Time                 : ", FmtDt(g_last_tick_time));
      Print("Interval levels      : ", (string)close_level, " -> ", (string)upper_level);
      Print("Sub-line real        : ", FmtPrice(subline_price));
      Print("Bid                  : ", FmtPrice(g_last_bid));
      if(two_way_entry)
         Print("Action               : TWO-WAY SELL ", FmtPct(SUBLINE_PART_RATE * 100.0),
               "% of planned cycle using FREE crypto only");
      else
         Print("Action               : SELL ", FmtPct(SUBLINE_PART_RATE * 100.0),
               "% of planned cycle");
      Print("Base weight sizing   : base weight ", FmtPct(BaseWeightPercent()),
            "% | base input ", FmtPct(InpTradePercent), "%");
      Print("Crypto sold/free     : ", FmtMoney(base_sold));
      Print("Stable received/resvd: ", FmtMoney(net_quote));
      Print("Fee / gross stable   : ", FmtMoney(fee), " / ", FmtMoney(gross_quote));
      Print("Close level / price  : ", (string)close_level, " / ", FmtPrice(close_price));
      Print("Free crypto          : ", FmtMoney(crypto_before_free), " -> ", FmtMoney(g_base_free));
      Print("Resvd crypto         : ", FmtMoney(crypto_before_reserved), " -> ", FmtMoney(g_base_reserved));
      Print("Free stable          : ", FmtMoney(stable_before_free), " -> ", FmtMoney(g_quote_free));
      Print("Resvd stable         : ", FmtMoney(stable_before_reserved), " -> ", FmtMoney(g_quote_reserved));
      Print("Weights              : ", WeightsText());
      Print("--------------------------------------------------");
   }
}
//+------------------------------------------------------------------+
void OpenLowerBuySubCycle(int lower_level, double subline_price)
{
   if(!InpUseSubLines)
      return;

   int close_level = lower_level + 1;

   bool two_way_entry = false;

   if(!CanOpenLowerBuySubCycle(lower_level, close_level, two_way_entry))
   {
      g_subline_lower_skipped++;
      g_subline_lower_skip_interval++;
      return;
   }

   if(g_quote_free <= 0.0 || g_last_ask <= 0.0)
   {
      g_subline_lower_skipped++;
      g_subline_lower_skip_no_quote++;
      return;
   }

   double crypto_before_free     = g_base_free;
   double crypto_before_reserved = g_base_reserved;
   double stable_before_free     = g_quote_free;
   double stable_before_reserved = g_quote_reserved;

   double buy_rate       = BuyTradeRate();
   double quote_to_spend = g_quote_free * buy_rate * SUBLINE_PART_RATE;

   if(quote_to_spend <= 0.0)
   {
      g_subline_lower_skipped++;
      g_subline_lower_skip_zero++;
      return;
   }

   double base_bought = 0.0;
   double quote_spent = 0.0;

   if(!ExecuteBuyFreeToReserved(quote_to_spend,
                                false,
                                "lower sub-line buy reserved crypto",
                                base_bought,
                                quote_spent))
   {
      g_subline_lower_skipped++;
      g_subline_lower_skip_exec++;
      return;
   }

   if(base_bought <= 0.0 || quote_spent <= 0.0)
   {
      g_subline_lower_skipped++;
      g_subline_lower_skip_exec++;
      return;
   }

   g_next_lower_cycle_id++;
   ulong cycle_id = g_next_lower_cycle_id;

   double close_price = GridLinePrice(close_level);
   double fee         = quote_spent * FeeRate();

   AddTradeOriginDiagnostics(true, true, quote_spent);

   AddPendingBuyLot(cycle_id,
                    base_bought,
                    quote_spent,
                    g_last_ask,
                    close_price,
                    lower_level,
                    close_level,
                    true,
                    true,
                    false);

   g_lower_cycle_buys++;
   g_subline_lower_buys++;

   if(two_way_entry)
      g_subline_lower_twoway_buys++;

   UpdateRiskStats();

   if(InpInfoDetail == INFO_GRID_EVENTS)
   {
      if(two_way_entry)
         Print("LOWER TWO-WAY SUB-LINE CYCLE OPENED #", (string)cycle_id);
      else
         Print("LOWER SUB-LINE CYCLE OPENED #", (string)cycle_id);
      Print("Time                 : ", FmtDt(g_last_tick_time));
      Print("Interval levels      : ", (string)lower_level, " -> ", (string)close_level);
      Print("Sub-line real        : ", FmtPrice(subline_price));
      Print("Ask                  : ", FmtPrice(g_last_ask));
      if(two_way_entry)
         Print("Action               : TWO-WAY BUY crypto with ", FmtPct(SUBLINE_PART_RATE * 100.0),
               "% of planned cycle using FREE stable only");
      else
         Print("Action               : BUY crypto with ", FmtPct(SUBLINE_PART_RATE * 100.0),
               "% of planned cycle");
      Print("Quote weight sizing  : stable weight ", FmtPct(QuoteWeightPercent()),
            "% | base input ", FmtPct(InpTradePercent), "%");
      Print("Crypto bought/resvd  : ", FmtMoney(base_bought));
      Print("Stable spent/free    : ", FmtMoney(quote_spent));
      Print("Fee stable           : ", FmtMoney(fee));
      Print("Close level / price  : ", (string)close_level, " / ", FmtPrice(close_price));
      Print("Free crypto          : ", FmtMoney(crypto_before_free), " -> ", FmtMoney(g_base_free));
      Print("Resvd crypto         : ", FmtMoney(crypto_before_reserved), " -> ", FmtMoney(g_base_reserved));
      Print("Free stable          : ", FmtMoney(stable_before_free), " -> ", FmtMoney(g_quote_free));
      Print("Resvd stable         : ", FmtMoney(stable_before_reserved), " -> ", FmtMoney(g_quote_reserved));
      Print("Weights              : ", WeightsText());
      Print("--------------------------------------------------");
   }
}
//+------------------------------------------------------------------+
void OpenUpperSellCycle(int level_index, double line_price)
{
   if(g_base_free <= 0.0 || g_last_bid <= 0.0)
      return;

   int close_level = level_index - 1;

   int  sub_index  = -1;
   int  main_index = -1;
   bool has_sub    = (InpUseSubLines && FindPendingSellLot(level_index, close_level, true, sub_index));
   bool has_main   = (InpUseSubLines && FindPendingSellLot(level_index, close_level, false, main_index));

   if(has_sub && has_main)
      return;

   double crypto_before_free     = g_base_free;
   double crypto_before_reserved = g_base_reserved;
   double stable_before_free     = g_quote_free;
   double stable_before_reserved = g_quote_reserved;

   double sell_rate    = SellTradeRate();
   double base_to_sell = g_base_free * sell_rate;
   bool   remaining    = false;
   ulong  cycle_id     = 0;

   if(has_sub)
   {
      base_to_sell = RemainingPartFromSubPart(g_pending_sells[sub_index].base_to_buy_back);
      cycle_id     = g_pending_sells[sub_index].cycle_id;
      remaining    = true;
   }

   if(base_to_sell <= 0.0)
      return;

   double base_sold   = 0.0;
   double net_quote   = 0.0;
   double gross_quote = 0.0;

   if(!ExecuteSellFreeToReserved(base_to_sell,
                                 false,
                                 "upper shift sell free crypto",
                                 base_sold,
                                 net_quote,
                                 gross_quote))
      return;

   if(base_sold <= 0.0 || net_quote <= 0.0)
      return;

   if(!remaining)
   {
      g_next_upper_cycle_id++;
      cycle_id = g_next_upper_cycle_id;
   }
   else
   {
      g_mainline_upper_remaining++;
   }

   double close_price = GridLinePrice(close_level);
   double fee         = gross_quote * FeeRate();

   AddTradeOriginDiagnostics(remaining, false, gross_quote);

   AddPendingSellLot(cycle_id,
                     base_sold,
                     net_quote,
                     g_last_bid,
                     close_price,
                     level_index,
                     close_level,
                     false,
                     remaining,
                     remaining);

   g_upper_cycle_sells++;

   UpdateRiskStats();

   if(InpInfoDetail == INFO_GRID_EVENTS)
   {
      if(remaining)
         Print("UPPER CYCLE REMAINING HALF OPENED #", (string)cycle_id);
      else
         Print("UPPER CYCLE OPENED #", (string)cycle_id);

      Print("Time                 : ", FmtDt(g_last_tick_time));
      Print("Level / line real    : ", (string)level_index, " / ", FmtPrice(line_price));
      Print("Bid                  : ", FmtPrice(g_last_bid));

      if(remaining)
         Print("Action               : SELL remaining planned half after sub-line entry");
      else
         Print("Action               : SELL ", FmtPct(sell_rate * 100.0), "% of FREE crypto");

      Print("Base weight sizing   : base weight ", FmtPct(BaseWeightPercent()),
            "% | base input ", FmtPct(InpTradePercent), "%");
      Print("Crypto sold/free     : ", FmtMoney(base_sold));
      Print("Stable received/resvd: ", FmtMoney(net_quote));
      Print("Fee / gross stable   : ", FmtMoney(fee), " / ", FmtMoney(gross_quote));
      Print("Close level / price  : ", (string)close_level, " / ", FmtPrice(close_price));
      Print("Free crypto          : ", FmtMoney(crypto_before_free), " -> ", FmtMoney(g_base_free));
      Print("Resvd crypto         : ", FmtMoney(crypto_before_reserved), " -> ", FmtMoney(g_base_reserved));
      Print("Free stable          : ", FmtMoney(stable_before_free), " -> ", FmtMoney(g_quote_free));
      Print("Resvd stable         : ", FmtMoney(stable_before_reserved), " -> ", FmtMoney(g_quote_reserved));
      Print("Weights              : ", WeightsText());
      Print("Next grid up          : ", GridUpText(g_current_grid_index));
      Print("Next grid down        : ", GridDownText(g_current_grid_index));
      Print("--------------------------------------------------");
   }
}
//+------------------------------------------------------------------+
void OpenLowerBuyCycle(int level_index, double line_price)
{
   if(g_quote_free <= 0.0 || g_last_ask <= 0.0)
      return;

   int close_level = level_index + 1;

   int  sub_index  = -1;
   int  main_index = -1;
   bool has_sub    = (InpUseSubLines && FindPendingBuyLot(level_index, close_level, true, sub_index));
   bool has_main   = (InpUseSubLines && FindPendingBuyLot(level_index, close_level, false, main_index));

   if(has_sub && has_main)
      return;

   double crypto_before_free     = g_base_free;
   double crypto_before_reserved = g_base_reserved;
   double stable_before_free     = g_quote_free;
   double stable_before_reserved = g_quote_reserved;

   double buy_rate       = BuyTradeRate();
   double quote_to_spend = g_quote_free * buy_rate;
   bool   remaining      = false;
   ulong  cycle_id       = 0;

   if(has_sub)
   {
      quote_to_spend = RemainingPartFromSubPart(g_pending_buys[sub_index].gross_quote_cost);
      cycle_id       = g_pending_buys[sub_index].cycle_id;
      remaining      = true;
   }

   if(quote_to_spend <= 0.0)
      return;

   double base_bought = 0.0;
   double quote_spent = 0.0;

   if(!ExecuteBuyFreeToReserved(quote_to_spend,
                                false,
                                "lower shift buy reserved crypto",
                                base_bought,
                                quote_spent))
      return;

   if(base_bought <= 0.0 || quote_spent <= 0.0)
      return;

   if(!remaining)
   {
      g_next_lower_cycle_id++;
      cycle_id = g_next_lower_cycle_id;
   }
   else
   {
      g_mainline_lower_remaining++;
   }

   double close_price = GridLinePrice(close_level);
   double fee         = quote_spent * FeeRate();

   AddTradeOriginDiagnostics(remaining, true, quote_spent);

   AddPendingBuyLot(cycle_id,
                    base_bought,
                    quote_spent,
                    g_last_ask,
                    close_price,
                    level_index,
                    close_level,
                    false,
                    remaining,
                    remaining);

   g_lower_cycle_buys++;

   UpdateRiskStats();

   if(InpInfoDetail == INFO_GRID_EVENTS)
   {
      if(remaining)
         Print("LOWER CYCLE REMAINING HALF OPENED #", (string)cycle_id);
      else
         Print("LOWER CYCLE OPENED #", (string)cycle_id);

      Print("Time                 : ", FmtDt(g_last_tick_time));
      Print("Level / line real    : ", (string)level_index, " / ", FmtPrice(line_price));
      Print("Ask                  : ", FmtPrice(g_last_ask));

      if(remaining)
         Print("Action               : BUY remaining planned half after sub-line entry");
      else
         Print("Action               : BUY crypto with ", FmtPct(buy_rate * 100.0),
               "% of FREE stable");

      Print("Quote weight sizing  : stable weight ", FmtPct(QuoteWeightPercent()),
            "% | base input ", FmtPct(InpTradePercent), "%");
      Print("Crypto bought/resvd  : ", FmtMoney(base_bought));
      Print("Stable spent/free    : ", FmtMoney(quote_spent));
      Print("Fee stable           : ", FmtMoney(fee));
      Print("Close level / price  : ", (string)close_level, " / ", FmtPrice(close_price));
      Print("Free crypto          : ", FmtMoney(crypto_before_free), " -> ", FmtMoney(g_base_free));
      Print("Resvd crypto         : ", FmtMoney(crypto_before_reserved), " -> ", FmtMoney(g_base_reserved));
      Print("Free stable          : ", FmtMoney(stable_before_free), " -> ", FmtMoney(g_quote_free));
      Print("Resvd stable         : ", FmtMoney(stable_before_reserved), " -> ", FmtMoney(g_quote_reserved));
      Print("Weights              : ", WeightsText());
      Print("Next grid up          : ", GridUpText(g_current_grid_index));
      Print("Next grid down        : ", GridDownText(g_current_grid_index));
      Print("--------------------------------------------------");
   }
}

#endif // __CRYPTOGRID_CYCLEOPENING_MQH__
