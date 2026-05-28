//+------------------------------------------------------------------+
//| CryptoGrid_CycleClosing.mqh                                     |
//| Closing pending cycles                                          |
//| Modular v1.5 branch based on classic v1.4.5 logic. |
//+------------------------------------------------------------------+
#ifndef __CRYPTOGRID_CYCLECLOSING_MQH__
#define __CRYPTOGRID_CYCLECLOSING_MQH__

//+------------------------------------------------------------------+
//| Closing pending cycles                                           |
//+------------------------------------------------------------------+
void CloseTriggeredPendingSells()
{
   int i = 0;

   while(i < ArraySize(g_pending_sells))
   {
      if(g_last_bid > g_pending_sells[i].close_price)
      {
         i++;
         continue;
      }

      ulong  cycle_id        = g_pending_sells[i].cycle_id;
      double base_to_buy     = g_pending_sells[i].base_to_buy_back;
      double reserved_quote  = g_pending_sells[i].quote_reserved;
      double lot_open_price  = g_pending_sells[i].open_price;
      double lot_close_price = g_pending_sells[i].close_price;
      int    open_level      = g_pending_sells[i].open_level;
      int    close_level     = g_pending_sells[i].close_level;
      bool   subline_part    = g_pending_sells[i].subline_part;
      bool   subline_origin  = g_pending_sells[i].subline_origin;
      bool   reached_next    = g_pending_sells[i].subline_reached_next;

      if(base_to_buy <= 0.0 || reserved_quote <= 0.0)
      {
         RemovePendingSellLot(i);
         continue;
      }

      if(g_last_ask <= 0.0)
      {
         i++;
         continue;
      }

      double gross_needed = base_to_buy * g_last_ask / (1.0 - FeeRate());
      double topup_needed = gross_needed - reserved_quote;

      if(topup_needed > 0.0 && topup_needed > g_quote_free)
      {
         g_upper_close_skipped++;

         if(InpInfoDetail == INFO_GRID_EVENTS)
         {
            Print("UPPER CYCLE CLOSE SKIPPED #", (string)cycle_id);
            Print("Time                 : ", FmtDt(g_last_tick_time));
            Print("Reason               : not enough free stable for buyback top-up");
            Print("Reserved stable      : ", FmtMoney(reserved_quote));
            Print("Gross needed         : ", FmtMoney(gross_needed));
            Print("Top-up needed        : ", FmtMoney(topup_needed));
            Print("Free stable          : ", FmtMoney(g_quote_free));
            Print("Balances             : ", BalanceText());
            Print("--------------------------------------------------");
         }

         i++;
         continue;
      }

      double crypto_before_free     = g_base_free;
      double crypto_before_reserved = g_base_reserved;
      double stable_before_free     = g_quote_free;
      double stable_before_reserved = g_quote_reserved;

      g_quote_reserved -= reserved_quote;
      if(g_quote_reserved < 0.0 && MathAbs(g_quote_reserved) < 0.000000000001)
         g_quote_reserved = 0.0;

      double pnl = reserved_quote - gross_needed;

      if(pnl >= 0.0)
      {
         g_quote_free += pnl;
      }
      else
      {
         double topup = -pnl;
         g_quote_free -= topup;
         g_upper_close_topups++;
         g_upper_close_topup_quote += topup;
      }

      g_base_free += base_to_buy;

      double fee = gross_needed * FeeRate();

      g_total_fees_quote += fee;
      g_total_turnover   += gross_needed;

      AddTradeOriginDiagnostics(subline_origin, true, gross_needed);

      g_buy_trades++;
      g_total_trades++;

      AddRealizedPnL(pnl);
      AddRealizedPnLByOrigin(subline_origin, pnl);

      if(subline_part)
      {
         if(reached_next)
         {
            g_subline_upper_promoted_closed++;
            g_subline_upper_promoted_pnl += pnl;
         }
         else
         {
            g_subline_upper_returned_parent++;
            g_subline_upper_returned_pnl += pnl;
         }
      }

      g_upper_cycle_buybacks++;

      if(InpInfoDetail == INFO_GRID_EVENTS)
      {
         if(subline_part && !reached_next)
            Print("UPPER SUB-LINE MINI-CYCLE CLOSED #", (string)cycle_id);
         else if(subline_part && reached_next)
            Print("UPPER SUB-LINE PROMOTED PART CLOSED #", (string)cycle_id);
         else if(subline_origin)
            Print("UPPER SUB-LINE REMAINING PART CLOSED #", (string)cycle_id);
         else
            Print("UPPER CYCLE CLOSED #", (string)cycle_id);
         Print("Time                 : ", FmtDt(g_last_tick_time));
         Print("Open level / close   : ", (string)open_level, " -> ", (string)close_level);
         Print("Open price           : ", FmtPrice(lot_open_price));
         Print("Close trigger        : ", FmtPrice(lot_close_price));
         Print("Bid / ask            : ", FmtPrice(g_last_bid), " / ", FmtPrice(g_last_ask));
         Print("Action               : BUY BACK crypto from RESERVED stable");
         Print("Crypto bought/free   : ", FmtMoney(base_to_buy));
         Print("Stable reserved used : ", FmtMoney(reserved_quote));
         Print("Buyback gross cost   : ", FmtMoney(gross_needed));
         Print("Fee stable           : ", FmtMoney(fee));
         Print("Realized P/L         : ", FmtMoney(pnl));
         Print("Free crypto          : ", FmtMoney(crypto_before_free), " -> ", FmtMoney(g_base_free));
         Print("Resvd crypto         : ", FmtMoney(crypto_before_reserved), " -> ", FmtMoney(g_base_reserved));
         Print("Free stable          : ", FmtMoney(stable_before_free), " -> ", FmtMoney(g_quote_free));
         Print("Resvd stable         : ", FmtMoney(stable_before_reserved), " -> ", FmtMoney(g_quote_reserved));
         Print("Weights after close  : ", WeightsText());
         Print("--------------------------------------------------");
      }

      RemovePendingSellLot(i);
      UpdateRiskStats();
   }
}
//+------------------------------------------------------------------+
void CloseTriggeredPendingBuys()
{
   int i = 0;

   while(i < ArraySize(g_pending_buys))
   {
      if(g_last_bid < g_pending_buys[i].close_price)
      {
         i++;
         continue;
      }

      ulong  cycle_id        = g_pending_buys[i].cycle_id;
      double base_to_sell    = g_pending_buys[i].base_reserved;
      double cost_before     = g_pending_buys[i].gross_quote_cost;
      double lot_open_price  = g_pending_buys[i].open_price;
      double lot_close_price = g_pending_buys[i].close_price;
      int    open_level      = g_pending_buys[i].open_level;
      int    close_level     = g_pending_buys[i].close_level;
      bool   subline_part    = g_pending_buys[i].subline_part;
      bool   subline_origin  = g_pending_buys[i].subline_origin;
      bool   reached_next    = g_pending_buys[i].subline_reached_next;

      if(base_to_sell <= 0.0 || cost_before <= 0.0)
      {
         RemovePendingBuyLot(i);
         continue;
      }

      if(base_to_sell > g_base_reserved + 0.000000000001)
      {
         g_lower_close_skipped++;

         if(InpInfoDetail == INFO_GRID_EVENTS)
         {
            Print("LOWER CYCLE CLOSE SKIPPED #", (string)cycle_id);
            Print("Time                 : ", FmtDt(g_last_tick_time));
            Print("Reason               : reserved crypto mismatch");
            Print("Lot crypto           : ", FmtMoney(base_to_sell));
            Print("Reserved crypto      : ", FmtMoney(g_base_reserved));
            Print("Balances             : ", BalanceText());
            Print("--------------------------------------------------");
         }

         i++;
         continue;
      }

      double crypto_before_free     = g_base_free;
      double crypto_before_reserved = g_base_reserved;
      double stable_before_free     = g_quote_free;
      double stable_before_reserved = g_quote_reserved;

      double base_sold   = 0.0;
      double net_quote   = 0.0;
      double gross_quote = 0.0;

      if(!ExecuteSellReservedToFree(base_to_sell,
                                    false,
                                    "lower-cycle close sell reserved crypto",
                                    base_sold,
                                    net_quote,
                                    gross_quote))
      {
         i++;
         continue;
      }

      AddTradeOriginDiagnostics(subline_origin, false, gross_quote);

      double pnl = net_quote - cost_before;

      AddRealizedPnL(pnl);
      AddRealizedPnLByOrigin(subline_origin, pnl);

      if(subline_part)
      {
         if(reached_next)
         {
            g_subline_lower_promoted_closed++;
            g_subline_lower_promoted_pnl += pnl;
         }
         else
         {
            g_subline_lower_returned_parent++;
            g_subline_lower_returned_pnl += pnl;
         }
      }
      g_lower_cycle_sells++;

      double sell_fee_total = gross_quote * FeeRate();

      if(InpInfoDetail == INFO_GRID_EVENTS)
      {
         if(subline_part && !reached_next)
            Print("LOWER SUB-LINE MINI-CYCLE CLOSED #", (string)cycle_id);
         else if(subline_part && reached_next)
            Print("LOWER SUB-LINE PROMOTED PART CLOSED #", (string)cycle_id);
         else if(subline_origin)
            Print("LOWER SUB-LINE REMAINING PART CLOSED #", (string)cycle_id);
         else
            Print("LOWER CYCLE CLOSED #", (string)cycle_id);
         Print("Time                 : ", FmtDt(g_last_tick_time));
         Print("Open level / close   : ", (string)open_level, " -> ", (string)close_level);
         Print("Open price           : ", FmtPrice(lot_open_price));
         Print("Close trigger        : ", FmtPrice(lot_close_price));
         Print("Bid                  : ", FmtPrice(g_last_bid));
         Print("Action               : SELL RESERVED crypto");
         Print("Crypto sold/resvd    : ", FmtMoney(base_sold));
         Print("Stable received/free : ", FmtMoney(net_quote));
         Print("Fee stable           : ", FmtMoney(sell_fee_total));
         Print("Cycle cost           : ", FmtMoney(cost_before));
         Print("Realized P/L         : ", FmtMoney(pnl));
         Print("Free crypto          : ", FmtMoney(crypto_before_free), " -> ", FmtMoney(g_base_free));
         Print("Resvd crypto         : ", FmtMoney(crypto_before_reserved), " -> ", FmtMoney(g_base_reserved));
         Print("Free stable          : ", FmtMoney(stable_before_free), " -> ", FmtMoney(g_quote_free));
         Print("Resvd stable         : ", FmtMoney(stable_before_reserved), " -> ", FmtMoney(g_quote_reserved));
         Print("Weights after close  : ", WeightsText());
         Print("--------------------------------------------------");
      }

      RemovePendingBuyLot(i);
      UpdateRiskStats();
   }
}

#endif // __CRYPTOGRID_CYCLECLOSING_MQH__
