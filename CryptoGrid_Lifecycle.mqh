//+------------------------------------------------------------------+
//| CryptoGrid_Lifecycle.mqh                                        |
//| OnInit / OnDeinit / OnTick                                      |
//| v1.5.1 lifecycle: v1.5 plus optional sub-line mode. |
//+------------------------------------------------------------------+
#ifndef __CRYPTOGRID_LIFECYCLE_MQH__
#define __CRYPTOGRID_LIFECYCLE_MQH__

//+------------------------------------------------------------------+
//| Init / Deinit / Tick                                             |
//+------------------------------------------------------------------+
int OnInit()
{
   if(InpInitialAmount <= 0.0)
   {
      Print("ERROR: InpInitialAmount must be > 0");
      return INIT_PARAMETERS_INCORRECT;
   }

   if(InpGridStepPercent <= 0.0 || InpGridStepPercent >= 100.0)
   {
      Print("ERROR: InpGridStepPercent must be > 0 and < 100");
      return INIT_PARAMETERS_INCORRECT;
   }

   if(InpTradePercent <= 0.0 || InpTradePercent >= 100.0)
   {
      Print("ERROR: InpTradePercent must be > 0 and < 100");
      return INIT_PARAMETERS_INCORRECT;
   }

   if(InpFeePercent < 0.0 || InpFeePercent >= 100.0)
   {
      Print("ERROR: InpFeePercent must be >= 0 and < 100");
      return INIT_PARAMETERS_INCORRECT;
   }

   if(SUBLINE_PART_RATE <= 0.0 || SUBLINE_PART_RATE >= 1.0)
   {
      Print("ERROR: SUBLINE_PART_RATE must be > 0 and < 1");
      return INIT_PARAMETERS_INCORRECT;
   }

   if(InpStartTime <= 0 || InpEndTime <= 0)
   {
      Print("ERROR: InpStartTime and InpEndTime must be valid datetime values");
      return INIT_PARAMETERS_INCORRECT;
   }

   if(InpStartTime > InpEndTime)
   {
      Print("ERROR: InpStartTime must be <= InpEndTime");
      return INIT_PARAMETERS_INCORRECT;
   }

   g_step_rate   = InpGridStepPercent / 100.0;
   g_grid_factor = 1.0 + g_step_rate;
   g_trade_rate  = InpTradePercent / 100.0;

   ArrayResize(g_pending_sells, 0);
   ArrayResize(g_pending_buys, 0);
   ArrayResize(g_month_summaries, 0);
   ArrayResize(g_multi_jump_events, 0);

   g_total_ticks                  = 0;
   g_used_ticks                   = 0;

   g_csv_files_read               = 0;
   g_csv_files_missing            = 0;
   g_csv_bad_rows                 = 0;
   g_csv_rows_skipped_time        = 0;
   g_csv_rows_skipped_before      = 0;
   g_csv_rows_skipped_after       = 0;
   g_csv_rows_skipped_skipday     = 0;
   g_skipday_resume_resyncs       = 0;
   g_skip_day_active              = false;
   g_skip_day_active_date         = "";

   g_up_crossings                 = 0;
   g_down_crossings               = 0;
   g_total_crossings              = 0;
   g_multi_jump_ticks             = 0;
   g_grid_resyncs                 = 0;

   g_buy_trades                   = 0;
   g_sell_trades                  = 0;
   g_total_trades                 = 0;

   g_upper_cycle_sells            = 0;
   g_upper_cycle_buybacks         = 0;
   g_lower_cycle_buys             = 0;
   g_lower_cycle_sells            = 0;

   g_subline_upper_touches        = 0;
   g_subline_lower_touches        = 0;
   g_subline_total_touches        = 0;
   g_subline_upper_sells          = 0;
   g_subline_lower_buys           = 0;
   g_subline_upper_skipped        = 0;
   g_subline_lower_skipped        = 0;
   g_subline_upper_skip_interval  = 0;
   g_subline_lower_skip_interval  = 0;
   g_subline_upper_skip_no_base   = 0;
   g_subline_lower_skip_no_quote  = 0;
   g_subline_upper_skip_zero      = 0;
   g_subline_lower_skip_zero      = 0;
   g_subline_upper_skip_exec      = 0;
   g_subline_lower_skip_exec      = 0;
   g_mainline_upper_remaining     = 0;
   g_mainline_lower_remaining     = 0;
   g_subline_upper_reached_next   = 0;
   g_subline_lower_reached_next   = 0;
   g_subline_upper_returned_parent= 0;
   g_subline_lower_returned_parent= 0;
   g_subline_upper_promoted_closed= 0;
   g_subline_lower_promoted_closed= 0;
   g_subline_upper_returned_pnl   = 0.0;
   g_subline_lower_returned_pnl   = 0.0;
   g_subline_upper_promoted_pnl   = 0.0;
   g_subline_lower_promoted_pnl   = 0.0;
   g_main_origin_buy_trades       = 0;
   g_main_origin_sell_trades      = 0;
   g_subline_origin_buy_trades    = 0;
   g_subline_origin_sell_trades   = 0;
   g_main_origin_turnover         = 0.0;
   g_subline_origin_turnover      = 0.0;
   g_main_origin_fees             = 0.0;
   g_subline_origin_fees          = 0.0;
   g_main_origin_realized_pnl     = 0.0;
   g_subline_origin_realized_pnl  = 0.0;

   g_upper_close_topups           = 0;
   g_upper_close_topup_quote      = 0.0;
   g_upper_close_skipped          = 0;
   g_lower_close_skipped          = 0;

   g_total_fees_quote             = 0.0;
   g_total_turnover               = 0.0;

   g_realized_grid_profit_quote   = 0.0;
   g_realized_grid_loss_quote     = 0.0;
   g_realized_grid_net_quote      = 0.0;

   g_next_upper_cycle_id          = 0;
   g_next_lower_cycle_id          = 0;

   g_first_bid                    = 0.0;
   g_first_ask                    = 0.0;
   g_last_bid                     = 0.0;
   g_last_ask                     = 0.0;

   g_grid_anchor_real_price       = 0.0;
   g_current_grid_index           = 0;

   g_first_tick_time              = 0;
   g_last_tick_time               = 0;

   g_jump_prev_bid                = 0.0;
   g_jump_prev_time               = 0;
   g_jump_equity_before           = 0.0;

   g_base_free                    = 0.0;
   g_base_reserved                = 0.0;
   g_quote_free                   = 0.0;
   g_quote_reserved               = 0.0;
   g_initial_value                = 0.0;

   g_hold_base_balance            = 0.0;
   g_hold_quote_balance           = 0.0;

   g_initialized                  = false;
   g_csv_done                     = false;

   g_risk_initialized             = false;
   g_peak_equity                  = 0.0;
   g_peak_equity_time             = 0;
   g_max_drawdown_quote           = 0.0;
   g_max_drawdown_pct             = 0.0;
   g_max_drawdown_time            = 0;
   g_lowest_equity                = 0.0;
   g_lowest_equity_time           = 0;
   g_min_free_stable              = 0.0;
   g_min_free_stable_time         = 0;
   g_min_free_crypto              = 0.0;
   g_min_free_crypto_time         = 0;
   g_max_crypto_weight_pct        = 0.0;
   g_max_crypto_weight_time       = 0;
   g_max_stable_weight_pct        = 0.0;
   g_max_stable_weight_time       = 0;
   g_worst_open_buy_pnl           = 0.0;
   g_worst_open_buy_pnl_time      = 0;
   g_worst_open_sell_pnl          = 0.0;
   g_worst_open_sell_pnl_time     = 0;
   g_worst_open_total_pnl         = 0.0;
   g_worst_open_total_pnl_time    = 0;

   Print("Crypto_grid_csv_explorer_v1_5_1_modular initialized.");
   Print("Version             : CSV v1.5.1 modular, v1.5 cascade + geometric sub-lines");
   Print("File prefix         : ", InpFilePrefix);
   Print("Test period         : ", FmtDt(InpStartTime), " -> ", FmtDt(InpEndTime));
   Print("Initial amount      : ", FmtMoney(InpInitialAmount));
   Print("Initial split       : spend 50% stable to buy free crypto, keep 50% free stable");
   Print("Grid step %         : ", FmtPct(InpGridStepPercent));
   Print("Base trade % at 50/50: ", FmtPct(InpTradePercent));
   Print("Fee %               : ", FmtPct(InpFeePercent));
   Print("Grid center         : first CSV price");
   Print("Trade sizing mode   : source asset portfolio-weight sizing");
   Print("Sub-lines           : ", (InpUseSubLines ? "enabled, one geometric sub-line per interval" : "disabled"));
   Print("Sub-line part       : ", FmtPct(SUBLINE_PART_RATE * 100.0), "% of planned cycle");
   Print("Info detail         : ", InfoText());
   Print("Skip days           : ", SkipDaysText());

   ProcessCsvRange();

   Print("CSV processing finished. Removing EA.");
   ExpertRemove();

   return INIT_SUCCEEDED;
}
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   double final_value_now = 0.0;
   double final_ret_pct   = 0.0;

   double hold_value_now  = 0.0;
   double hold_ret_pct    = 0.0;
   double vs_hold_quote   = 0.0;
   double vs_hold_pp      = 0.0;

   if(g_initialized && g_last_bid > 0.0)
   {
      final_value_now = PortfolioValueBid();

      if(g_initial_value > 0.0)
         final_ret_pct = (final_value_now / g_initial_value - 1.0) * 100.0;

      hold_value_now = HoldValueBid();

      if(g_initial_value > 0.0)
         hold_ret_pct = (hold_value_now / g_initial_value - 1.0) * 100.0;

      vs_hold_quote = final_value_now - hold_value_now;
      vs_hold_pp    = final_ret_pct - hold_ret_pct;
   }

   double audit_pending_buy_base    = PendingBuyBase();
   double audit_pending_sell_quote  = PendingSellQuote();
   double audit_base_reserved_diff  = g_base_reserved - audit_pending_buy_base;
   double audit_quote_reserved_diff = g_quote_reserved - audit_pending_sell_quote;

   Print("========================================");
   Print("Crypto_grid_csv_explorer_v1_5_1_modular finished");

   Print("----------------------------------------");
   Print("GRID ACTIVITY");
   Print("Main-line up crossings : ", (string)g_up_crossings);
   Print("Main-line down crosses : ", (string)g_down_crossings);
   Print("Main-line total crosses: ", (string)g_total_crossings);

   if(g_first_tick_time > 0 && g_last_tick_time > g_first_tick_time)
   {
      double days_count = (double)(g_last_tick_time - g_first_tick_time) / 86400.0;

      if(days_count > 0.0)
         Print("Crossings per day      : ", FmtPct((double)g_total_crossings / days_count));
   }

   if(g_multi_jump_ticks > 0)
   {
      Print("Multi-jump ticks       : ", (string)g_multi_jump_ticks);
   }

   if(g_grid_resyncs > 0)
      Print("Grid resyncs           : ", (string)g_grid_resyncs);

   Print("Upper shift sells      : ", (string)g_upper_cycle_sells);
   Print("Upper buybacks         : ", (string)g_upper_cycle_buybacks);
   Print("Lower shift buys       : ", (string)g_lower_cycle_buys);
   Print("Lower sells            : ", (string)g_lower_cycle_sells);

   if(InpUseSubLines)
   {
      int upper_open_unresolved = CountOpenSellSublineParts(false);
      int lower_open_unresolved = CountOpenBuySublineParts(false);
      int upper_open_promoted   = CountOpenSellSublineParts(true);
      int lower_open_promoted   = CountOpenBuySublineParts(true);

      ulong sub_entries_total = g_subline_upper_sells + g_subline_lower_buys;
      ulong returned_total    = g_subline_upper_returned_parent + g_subline_lower_returned_parent;
      ulong reached_total     = g_subline_upper_reached_next + g_subline_lower_reached_next;
      int   unresolved_total  = upper_open_unresolved + lower_open_unresolved;
      int   promoted_open     = upper_open_promoted + lower_open_promoted;

      Print("----------------------------------------");
      Print("SUB-LINE DIAGNOSTICS");
      Print("Sub-line touches       : upper ", (string)g_subline_upper_touches,
            " / lower ", (string)g_subline_lower_touches,
            " / total ", (string)g_subline_total_touches);
      Print("Sub-line entries       : upper sells ", (string)g_subline_upper_sells,
            " / lower buys ", (string)g_subline_lower_buys,
            " / total ", (string)sub_entries_total);
      Print("Touches without entry  : ",
            (string)(g_subline_total_touches - sub_entries_total));
      Print("Main remaining halves  : upper ", (string)g_mainline_upper_remaining,
            " / lower ", (string)g_mainline_lower_remaining);
      Print("Returned to parent     : upper ", (string)g_subline_upper_returned_parent,
            " / lower ", (string)g_subline_lower_returned_parent,
            " / total ", (string)returned_total);
      Print("Reached next main line : upper ", (string)g_subline_upper_reached_next,
            " / lower ", (string)g_subline_lower_reached_next,
            " / total ", (string)reached_total);
      Print("Still open unresolved  : upper ", (string)upper_open_unresolved,
            " / lower ", (string)lower_open_unresolved,
            " / total ", (string)unresolved_total);
      Print("Still open promoted    : upper ", (string)upper_open_promoted,
            " / lower ", (string)lower_open_promoted,
            " / total ", (string)promoted_open);
      Print("Resolution check       : returned + reached + unresolved = ",
            (string)(returned_total + reached_total + (ulong)unresolved_total),
            " / entries ", (string)sub_entries_total);

      if(sub_entries_total > 0)
      {
         Print("Sub-line useful ratio  : returned ", (string)returned_total,
               " / entries ", (string)sub_entries_total,
               " = ", FmtPct((double)returned_total * 100.0 / (double)sub_entries_total), "%");
         Print("Sub-line promoted ratio: reached ", (string)reached_total,
               " / entries ", (string)sub_entries_total,
               " = ", FmtPct((double)reached_total * 100.0 / (double)sub_entries_total), "%");
      }

      Print("Returned mini P/L      : upper ", FmtMoney(g_subline_upper_returned_pnl),
            " / lower ", FmtMoney(g_subline_lower_returned_pnl),
            " / total ", FmtMoney(g_subline_upper_returned_pnl + g_subline_lower_returned_pnl));
      Print("Promoted-part P/L      : upper ", FmtMoney(g_subline_upper_promoted_pnl),
            " / lower ", FmtMoney(g_subline_lower_promoted_pnl),
            " / total ", FmtMoney(g_subline_upper_promoted_pnl + g_subline_lower_promoted_pnl));

      if(g_subline_upper_skipped > 0 || g_subline_lower_skipped > 0)
      {
         Print("Sub-line skips total   : upper ", (string)g_subline_upper_skipped,
               " / lower ", (string)g_subline_lower_skipped);
         Print("Skip interval occupied : upper ", (string)g_subline_upper_skip_interval,
               " / lower ", (string)g_subline_lower_skip_interval);
         Print("Skip no free asset     : upper no crypto ", (string)g_subline_upper_skip_no_base,
               " / lower no stable ", (string)g_subline_lower_skip_no_quote);
         Print("Skip zero-size         : upper ", (string)g_subline_upper_skip_zero,
               " / lower ", (string)g_subline_lower_skip_zero);
         Print("Skip execution failed  : upper ", (string)g_subline_upper_skip_exec,
               " / lower ", (string)g_subline_lower_skip_exec);
      }
   }

   if(g_upper_close_topups > 0 || g_upper_close_skipped > 0 || g_lower_close_skipped > 0)
   {
      Print("----------------------------------------");
      Print("CLOSE WARNINGS");
      Print("Upper close top-ups    : ", (string)g_upper_close_topups);
      Print("Upper top-up stable    : ", FmtMoney(g_upper_close_topup_quote));
      Print("Upper close skipped    : ", (string)g_upper_close_skipped);
      Print("Lower close skipped    : ", (string)g_lower_close_skipped);
   }

   Print("----------------------------------------");
   Print("TRADING COSTS");
   Print("Buy trades             : ", (string)g_buy_trades);
   Print("Sell trades            : ", (string)g_sell_trades);
   Print("Total trades           : ", (string)g_total_trades);
   Print("Buy trades by origin   : main ", (string)g_main_origin_buy_trades,
         " / sub-line ", (string)g_subline_origin_buy_trades);
   Print("Sell trades by origin  : main ", (string)g_main_origin_sell_trades,
         " / sub-line ", (string)g_subline_origin_sell_trades);
   Print("Turnover stable        : ", FmtMoney(g_total_turnover));
   Print("Turnover by origin     : main ", FmtMoney(g_main_origin_turnover),
         " / sub-line ", FmtMoney(g_subline_origin_turnover));
   Print("Fees stable            : ", FmtMoney(g_total_fees_quote));
   Print("Fees by origin         : main ", FmtMoney(g_main_origin_fees),
         " / sub-line ", FmtMoney(g_subline_origin_fees));
   Print("Realized P/L by origin : main ", FmtMoney(g_main_origin_realized_pnl),
         " / sub-line ", FmtMoney(g_subline_origin_realized_pnl));

   if(g_csv_rows_skipped_skipday > 0 || g_skipday_resume_resyncs > 0)
   {
      Print("----------------------------------------");
      Print("SKIP DAYS");
      Print("Configured skip days   : ", SkipDaysText());
      Print("Rows skipped skipday   : ", (string)g_csv_rows_skipped_skipday);
      Print("Resume resyncs         : ", (string)g_skipday_resume_resyncs);
   }

   if(g_risk_initialized)
   {
      Print("----------------------------------------");
      Print("RISK / DRAWDOWN");
      Print("Peak equity            : ", FmtMoney(g_peak_equity),
            " at ", FmtDt(g_peak_equity_time));
      Print("Max drawdown           : ", FmtMoney(g_max_drawdown_quote),
            " (", FmtPct(g_max_drawdown_pct), "%) at ", FmtDt(g_max_drawdown_time));
      Print("Lowest equity          : ", FmtMoney(g_lowest_equity),
            " at ", FmtDt(g_lowest_equity_time));

      Print("----------------------------------------");
      Print("WORST PORTFOLIO STATE");
      Print("Min free stable        : ", FmtMoney(g_min_free_stable),
            " at ", FmtDt(g_min_free_stable_time));
      Print("Min free crypto        : ", FmtMoney(g_min_free_crypto),
            " at ", FmtDt(g_min_free_crypto_time));
      Print("Max crypto weight %    : ", FmtPct(g_max_crypto_weight_pct),
            " at ", FmtDt(g_max_crypto_weight_time));
      Print("Max stable weight %    : ", FmtPct(g_max_stable_weight_pct),
            " at ", FmtDt(g_max_stable_weight_time));
      Print("Worst open buy P/L     : ", FmtMoney(g_worst_open_buy_pnl),
            " at ", FmtDt(g_worst_open_buy_pnl_time));
      Print("Worst open sell P/L    : ", FmtMoney(g_worst_open_sell_pnl),
            " at ", FmtDt(g_worst_open_sell_pnl_time));
      Print("Worst open total P/L   : ", FmtMoney(g_worst_open_total_pnl),
            " at ", FmtDt(g_worst_open_total_pnl_time));
   }

   Print("----------------------------------------");

   if(MathAbs(audit_base_reserved_diff) <= 0.00000001 &&
      MathAbs(audit_quote_reserved_diff) <= 0.00000001)
   {
      Print("Reserve audit          : OK");
   }
   else
   {
      Print("RESERVE AUDIT WARNING");
      Print("Free crypto            : ", FmtMoney(g_base_free));
      Print("Reserved crypto        : ", FmtMoney(g_base_reserved));
      Print("Total crypto           : ", FmtMoney(TotalBaseBalance()));
      Print("Free stable            : ", FmtMoney(g_quote_free));
      Print("Reserved stable        : ", FmtMoney(g_quote_reserved));
      Print("Total stable           : ", FmtMoney(TotalQuoteBalance()));
      Print("Pending buy crypto     : ", FmtMoney(audit_pending_buy_base));
      Print("Pending sell stable    : ", FmtMoney(audit_pending_sell_quote));
      Print("Reserved crypto diff   : ", FmtMoney(audit_base_reserved_diff));
      Print("Reserved stable diff   : ", FmtMoney(audit_quote_reserved_diff));
   }

   if(ArraySize(g_pending_sells) > 0 || ArraySize(g_pending_buys) > 0)
   {
      Print("Open cycles            : sell ", (string)ArraySize(g_pending_sells),
            " / buy ", (string)ArraySize(g_pending_buys),
            " | sell stable ", FmtMoney(PendingSellQuote()),
            " | buy crypto ", FmtMoney(PendingBuyBase()),
            " | buy cost ", FmtMoney(PendingBuyCost()));
   }

   Print("----------------------------------------");
   Print("RESULT");
   Print("Realized profit        : ", FmtMoney(g_realized_grid_profit_quote));
   Print("Realized loss          : ", FmtMoney(g_realized_grid_loss_quote));
   Print("Realized net           : ", FmtMoney(g_realized_grid_net_quote));
   Print("Open buy P/L          : ", FmtMoney(OpenPendingBuyPnlAtCurrentPrice()));
   Print("Open sell P/L         : ", FmtMoney(OpenPendingSellPnlAtCurrentPrice()));
   Print("Open total P/L        : ", FmtMoney(OpenPendingTotalPnlAtCurrentPrice()));

   if(g_initialized && g_last_bid > 0.0)
   {
      Print("Initial value          : ", FmtMoney(g_initial_value));
      Print("Final value            : ", FmtMoney(final_value_now));
      Print("Return %               : ", FmtPct(final_ret_pct));
      Print("Crypto balance         : ", FmtMoney(TotalBaseBalance()));
      Print("Stable balance         : ", FmtMoney(TotalQuoteBalance()));
      Print("Crypto value           : ", FmtMoney(BaseValueBid()));
      Print("Free crypto value      : ", FmtMoney(FreeBaseValueBid()));
      Print("Reserved crypto value  : ", FmtMoney(ReservedBaseValueBid()));
      Print("Final crypto weight %  : ", FmtPct(BaseWeightPercent()));
      Print("Final stable weight %  : ", FmtPct(QuoteWeightPercent()));

      Print("Passive hold result    : ", FmtMoney(hold_value_now),
            " (", FmtPct(hold_ret_pct), "%) | strategy diff ",
            FmtMoney(vs_hold_quote), " quote / ", FmtPct(vs_hold_pp), " pp");
   }

   if(g_first_bid > 0.0)
   {
      Print("----------------------------------------");
      Print("FINAL MARKET STATE");
      Print("First price            : ", FmtPrice(g_first_bid));
      Print("Last price             : ", FmtPrice(g_last_bid));
      Print("Current grid index     : ", (string)g_current_grid_index);
   }

   PrintMonthlySummary();
   PrintMultiJumpSummary();

   Print("========================================");
}
//+------------------------------------------------------------------+
void OnTick()
{
   // Intentionally empty.
   // This EA reads Binance CSV files in OnInit() and ignores broker ticks.
}
//+------------------------------------------------------------------+
#endif // __CRYPTOGRID_LIFECYCLE_MQH__
