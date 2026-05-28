//+------------------------------------------------------------------+
//| CryptoGrid_Risk.mqh                                             |
//| Risk and drawdown tracking                                      |
//| Modular v1.5 branch based on classic v1.4.5 logic. |
//+------------------------------------------------------------------+
#ifndef __CRYPTOGRID_RISK_MQH__
#define __CRYPTOGRID_RISK_MQH__

//+------------------------------------------------------------------+
//| Risk / drawdown helpers                                          |
//+------------------------------------------------------------------+
double OpenPendingBuyPnlAtCurrentPrice()
{
   if(g_last_bid <= 0.0)
      return 0.0;

   double pnl = 0.0;

   for(int i = 0; i < ArraySize(g_pending_buys); i++)
   {
      double net_if_sold = g_pending_buys[i].base_reserved * g_last_bid * (1.0 - FeeRate());
      pnl += net_if_sold - g_pending_buys[i].gross_quote_cost;
   }

   return pnl;
}
//+------------------------------------------------------------------+
double OpenPendingSellPnlAtCurrentPrice()
{
   if(g_last_ask <= 0.0)
      return 0.0;

   double pnl = 0.0;

   for(int i = 0; i < ArraySize(g_pending_sells); i++)
   {
      double buyback_cost = g_pending_sells[i].base_to_buy_back * g_last_ask / (1.0 - FeeRate());
      pnl += g_pending_sells[i].quote_reserved - buyback_cost;
   }

   return pnl;
}
//+------------------------------------------------------------------+
double OpenPendingTotalPnlAtCurrentPrice()
{
   return OpenPendingBuyPnlAtCurrentPrice() + OpenPendingSellPnlAtCurrentPrice();
}
//+------------------------------------------------------------------+
void UpdateRiskStats()
{
   if(g_last_bid <= 0.0 || g_last_tick_time <= 0)
      return;

   double equity = PortfolioValueBid();

   if(!MathIsValidNumber(equity) || equity <= 0.0)
      return;

   double base_weight_pct  = BaseWeightPercent();
   double quote_weight_pct = QuoteWeightPercent();

   double open_buy_pnl   = OpenPendingBuyPnlAtCurrentPrice();
   double open_sell_pnl  = OpenPendingSellPnlAtCurrentPrice();
   double open_total_pnl = open_buy_pnl + open_sell_pnl;

   if(!g_risk_initialized)
   {
      g_peak_equity               = equity;
      g_peak_equity_time          = g_last_tick_time;
      g_max_drawdown_quote        = 0.0;
      g_max_drawdown_pct          = 0.0;
      g_max_drawdown_time         = g_last_tick_time;
      g_lowest_equity             = equity;
      g_lowest_equity_time        = g_last_tick_time;

      g_min_free_stable           = g_quote_free;
      g_min_free_stable_time      = g_last_tick_time;
      g_min_free_crypto           = g_base_free;
      g_min_free_crypto_time      = g_last_tick_time;
      g_max_crypto_weight_pct     = base_weight_pct;
      g_max_crypto_weight_time    = g_last_tick_time;
      g_max_stable_weight_pct     = quote_weight_pct;
      g_max_stable_weight_time    = g_last_tick_time;

      g_worst_open_buy_pnl        = open_buy_pnl;
      g_worst_open_buy_pnl_time   = g_last_tick_time;
      g_worst_open_sell_pnl       = open_sell_pnl;
      g_worst_open_sell_pnl_time  = g_last_tick_time;
      g_worst_open_total_pnl      = open_total_pnl;
      g_worst_open_total_pnl_time = g_last_tick_time;

      g_risk_initialized          = true;
      return;
   }

   if(equity > g_peak_equity)
   {
      g_peak_equity      = equity;
      g_peak_equity_time = g_last_tick_time;
   }

   double dd_quote = g_peak_equity - equity;
   double dd_pct   = 0.0;

   if(g_peak_equity > 0.0)
      dd_pct = dd_quote / g_peak_equity * 100.0;

   if(dd_quote > g_max_drawdown_quote)
   {
      g_max_drawdown_quote = dd_quote;
      g_max_drawdown_pct   = dd_pct;
      g_max_drawdown_time  = g_last_tick_time;
   }

   if(equity < g_lowest_equity)
   {
      g_lowest_equity      = equity;
      g_lowest_equity_time = g_last_tick_time;
   }

   if(g_quote_free < g_min_free_stable)
   {
      g_min_free_stable      = g_quote_free;
      g_min_free_stable_time = g_last_tick_time;
   }

   if(g_base_free < g_min_free_crypto)
   {
      g_min_free_crypto      = g_base_free;
      g_min_free_crypto_time = g_last_tick_time;
   }

   if(base_weight_pct > g_max_crypto_weight_pct)
   {
      g_max_crypto_weight_pct  = base_weight_pct;
      g_max_crypto_weight_time = g_last_tick_time;
   }

   if(quote_weight_pct > g_max_stable_weight_pct)
   {
      g_max_stable_weight_pct  = quote_weight_pct;
      g_max_stable_weight_time = g_last_tick_time;
   }

   if(open_buy_pnl < g_worst_open_buy_pnl)
   {
      g_worst_open_buy_pnl      = open_buy_pnl;
      g_worst_open_buy_pnl_time = g_last_tick_time;
   }

   if(open_sell_pnl < g_worst_open_sell_pnl)
   {
      g_worst_open_sell_pnl      = open_sell_pnl;
      g_worst_open_sell_pnl_time = g_last_tick_time;
   }

   if(open_total_pnl < g_worst_open_total_pnl)
   {
      g_worst_open_total_pnl      = open_total_pnl;
      g_worst_open_total_pnl_time = g_last_tick_time;
   }
}

#endif // __CRYPTOGRID_RISK_MQH__
