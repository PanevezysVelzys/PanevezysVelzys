//+------------------------------------------------------------------+
//| CryptoGrid_Globals.mqh                                          |
//| Global state                                                    |
//| v1.5.1: v1.5 globals plus sub-line activity counters. |
//+------------------------------------------------------------------+
#ifndef __CRYPTOGRID_GLOBALS_MQH__
#define __CRYPTOGRID_GLOBALS_MQH__

//+------------------------------------------------------------------+
//| Globals                                                          |
//+------------------------------------------------------------------+
PendingSellLot  g_pending_sells[];
PendingBuyLot   g_pending_buys[];
MonthSummary    g_month_summaries[];
MultiJumpEvent  g_multi_jump_events[];

// Stats
ulong    g_total_ticks                  = 0;
ulong    g_used_ticks                   = 0;

ulong    g_csv_files_read               = 0;
ulong    g_csv_files_missing            = 0;
ulong    g_csv_bad_rows                 = 0;
ulong    g_csv_rows_skipped_time        = 0;
ulong    g_csv_rows_skipped_before      = 0;
ulong    g_csv_rows_skipped_after       = 0;
ulong    g_csv_rows_skipped_skipday     = 0;
ulong    g_skipday_resume_resyncs       = 0;
bool     g_skip_day_active              = false;
string   g_skip_day_active_date         = "";

ulong    g_up_crossings                 = 0;
ulong    g_down_crossings               = 0;
ulong    g_total_crossings              = 0;
ulong    g_multi_jump_ticks             = 0;
ulong    g_grid_resyncs                 = 0;

ulong    g_buy_trades                   = 0;
ulong    g_sell_trades                  = 0;
ulong    g_total_trades                 = 0;

ulong    g_upper_cycle_sells            = 0;
ulong    g_upper_cycle_buybacks         = 0;
ulong    g_lower_cycle_buys             = 0;
ulong    g_lower_cycle_sells            = 0;

ulong    g_subline_upper_touches        = 0;
ulong    g_subline_lower_touches        = 0;
ulong    g_subline_total_touches        = 0;

ulong    g_subline_upper_sells          = 0;
ulong    g_subline_lower_buys           = 0;
ulong    g_subline_upper_skipped        = 0;
ulong    g_subline_lower_skipped        = 0;
ulong    g_subline_upper_skip_interval  = 0;
ulong    g_subline_lower_skip_interval  = 0;
ulong    g_subline_upper_skip_no_base   = 0;
ulong    g_subline_lower_skip_no_quote  = 0;
ulong    g_subline_upper_skip_zero      = 0;
ulong    g_subline_lower_skip_zero      = 0;
ulong    g_subline_upper_skip_exec      = 0;
ulong    g_subline_lower_skip_exec      = 0;

ulong    g_mainline_upper_remaining     = 0;
ulong    g_mainline_lower_remaining     = 0;
ulong    g_subline_upper_reached_next   = 0;
ulong    g_subline_lower_reached_next   = 0;
ulong    g_subline_upper_returned_parent= 0;
ulong    g_subline_lower_returned_parent= 0;
ulong    g_subline_upper_promoted_closed= 0;
ulong    g_subline_lower_promoted_closed= 0;

double   g_subline_upper_returned_pnl   = 0.0;
double   g_subline_lower_returned_pnl   = 0.0;
double   g_subline_upper_promoted_pnl   = 0.0;
double   g_subline_lower_promoted_pnl   = 0.0;

ulong    g_main_origin_buy_trades       = 0;
ulong    g_main_origin_sell_trades      = 0;
ulong    g_subline_origin_buy_trades    = 0;
ulong    g_subline_origin_sell_trades   = 0;
double   g_main_origin_turnover         = 0.0;
double   g_subline_origin_turnover      = 0.0;
double   g_main_origin_fees             = 0.0;
double   g_subline_origin_fees          = 0.0;
double   g_main_origin_realized_pnl     = 0.0;
double   g_subline_origin_realized_pnl  = 0.0;

ulong    g_upper_close_topups           = 0;
double   g_upper_close_topup_quote      = 0.0;

ulong    g_upper_close_skipped          = 0;
ulong    g_lower_close_skipped          = 0;

// Turnover and fees.
// Fees are counted in quote currency.
// For Binance aggTrades paper mode bid=ask=price.
double   g_total_fees_quote             = 0.0;
double   g_total_turnover               = 0.0;

double   g_realized_grid_profit_quote   = 0.0;
double   g_realized_grid_loss_quote     = 0.0;
double   g_realized_grid_net_quote      = 0.0;

ulong    g_next_upper_cycle_id          = 0;
ulong    g_next_lower_cycle_id          = 0;

// Prices and grid state
double   g_first_bid                    = 0.0;
double   g_first_ask                    = 0.0;
double   g_last_bid                     = 0.0;
double   g_last_ask                     = 0.0;

double   g_grid_anchor_real_price       = 0.0;
double   g_grid_factor                  = 1.0;
double   g_step_rate                    = 0.0;
double   g_trade_rate                   = 0.0;

int      g_current_grid_index           = 0;

datetime g_first_tick_time              = 0;
datetime g_last_tick_time               = 0;

// Previous tick snapshot used only for multi-jump diagnostics.
double   g_jump_prev_bid                = 0.0;
datetime g_jump_prev_time               = 0;
double   g_jump_equity_before           = 0.0;

// Portfolio balances.
// FREE balances may be used by new shift trades.
// RESERVED balances belong to open pending cycles and may NOT be reused.
double   g_base_free                    = 0.0;
double   g_base_reserved                = 0.0;
double   g_quote_free                   = 0.0;
double   g_quote_reserved               = 0.0;

double   g_initial_value                = 0.0;

double   g_hold_base_balance            = 0.0;
double   g_hold_quote_balance           = 0.0;

bool     g_initialized                  = false;
bool     g_csv_done                     = false;

// Risk / drawdown tracking.
bool     g_risk_initialized             = false;
double   g_peak_equity                  = 0.0;
datetime g_peak_equity_time             = 0;
double   g_max_drawdown_quote           = 0.0;
double   g_max_drawdown_pct             = 0.0;
datetime g_max_drawdown_time            = 0;
double   g_lowest_equity                = 0.0;
datetime g_lowest_equity_time           = 0;

double   g_min_free_stable              = 0.0;
datetime g_min_free_stable_time         = 0;
double   g_min_free_crypto              = 0.0;
datetime g_min_free_crypto_time         = 0;
double   g_max_crypto_weight_pct        = 0.0;
datetime g_max_crypto_weight_time       = 0;
double   g_max_stable_weight_pct        = 0.0;
datetime g_max_stable_weight_time       = 0;

double   g_worst_open_buy_pnl           = 0.0;
datetime g_worst_open_buy_pnl_time      = 0;
double   g_worst_open_sell_pnl          = 0.0;
datetime g_worst_open_sell_pnl_time     = 0;
double   g_worst_open_total_pnl         = 0.0;
datetime g_worst_open_total_pnl_time    = 0;

#endif // __CRYPTOGRID_GLOBALS_MQH__
