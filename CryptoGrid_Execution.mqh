//+------------------------------------------------------------------+
//| CryptoGrid_Execution.mqh                                        |
//| Execution/balance-transfer helpers                              |
//| Modular v1.5 branch based on classic v1.4.5 logic. |
//+------------------------------------------------------------------+
#ifndef __CRYPTOGRID_EXECUTION_MQH__
#define __CRYPTOGRID_EXECUTION_MQH__


//+------------------------------------------------------------------+
//| Diagnostic trade-origin accounting                               |
//+------------------------------------------------------------------+
void AddTradeOriginDiagnostics(const bool subline_origin,
                               const bool is_buy,
                               const double turnover_quote)
{
   double fee = turnover_quote * FeeRate();

   if(subline_origin)
   {
      if(is_buy)
         g_subline_origin_buy_trades++;
      else
         g_subline_origin_sell_trades++;

      g_subline_origin_turnover += turnover_quote;
      g_subline_origin_fees     += fee;
   }
   else
   {
      if(is_buy)
         g_main_origin_buy_trades++;
      else
         g_main_origin_sell_trades++;

      g_main_origin_turnover += turnover_quote;
      g_main_origin_fees     += fee;
   }
}

//+------------------------------------------------------------------+
//| Execution helpers                                                |
//+------------------------------------------------------------------+
bool ExecuteBuyFreeToFree(double quote_gross,
                          bool detailed_log,
                          string tag,
                          double &base_bought,
                          double &quote_spent)
{
   base_bought = 0.0;
   quote_spent = 0.0;

   if(quote_gross <= 0.0 || g_last_ask <= 0.0)
      return false;

   if(quote_gross > g_quote_free)
      quote_gross = g_quote_free;

   if(quote_gross <= 0.0)
      return false;

   double fee             = quote_gross * FeeRate();
   double quote_after_fee = quote_gross - fee;

   if(quote_after_fee <= 0.0)
      return false;

   base_bought = quote_after_fee / g_last_ask;
   quote_spent = quote_gross;

   g_quote_free -= quote_gross;
   g_base_free  += base_bought;

   g_total_fees_quote += fee;
   g_total_turnover   += quote_gross;

   g_buy_trades++;
   g_total_trades++;

   if(detailed_log && InpInfoDetail == INFO_GRID_EVENTS)
   {
      Print("BUY FREE->FREE");
      Print("Time                 : ", FmtDt(g_last_tick_time));
      Print("Tag                  : ", tag);
      Print("Ask                  : ", FmtPrice(g_last_ask));
      Print("Crypto bought        : ", FmtMoney(base_bought));
      Print("Stable spent         : ", FmtMoney(quote_gross));
      Print("Fee stable           : ", FmtMoney(fee));
      Print("Balances             : ", BalanceText());
      Print("Weights              : ", WeightsText());
      Print("--------------------------------------------------");
   }

   return true;
}
//+------------------------------------------------------------------+
bool ExecuteBuyFreeToReserved(double quote_gross,
                              bool detailed_log,
                              string tag,
                              double &base_bought,
                              double &quote_spent)
{
   base_bought = 0.0;
   quote_spent = 0.0;

   if(quote_gross <= 0.0 || g_last_ask <= 0.0)
      return false;

   if(quote_gross > g_quote_free)
      quote_gross = g_quote_free;

   if(quote_gross <= 0.0)
      return false;

   double fee             = quote_gross * FeeRate();
   double quote_after_fee = quote_gross - fee;

   if(quote_after_fee <= 0.0)
      return false;

   base_bought = quote_after_fee / g_last_ask;
   quote_spent = quote_gross;

   g_quote_free    -= quote_gross;
   g_base_reserved += base_bought;

   g_total_fees_quote += fee;
   g_total_turnover   += quote_gross;

   g_buy_trades++;
   g_total_trades++;

   if(detailed_log && InpInfoDetail == INFO_GRID_EVENTS)
   {
      Print("BUY FREE_STABLE->RESERVED_CRYPTO");
      Print("Time                 : ", FmtDt(g_last_tick_time));
      Print("Tag                  : ", tag);
      Print("Ask                  : ", FmtPrice(g_last_ask));
      Print("Crypto bought/resvd  : ", FmtMoney(base_bought));
      Print("Stable spent         : ", FmtMoney(quote_gross));
      Print("Fee stable           : ", FmtMoney(fee));
      Print("Balances             : ", BalanceText());
      Print("Weights              : ", WeightsText());
      Print("--------------------------------------------------");
   }

   return true;
}
//+------------------------------------------------------------------+
bool ExecuteSellFreeToReserved(double base_amount,
                               bool detailed_log,
                               string tag,
                               double &base_sold,
                               double &net_quote,
                               double &gross_quote)
{
   base_sold   = 0.0;
   net_quote   = 0.0;
   gross_quote = 0.0;

   if(base_amount <= 0.0 || g_last_bid <= 0.0)
      return false;

   if(base_amount > g_base_free)
      base_amount = g_base_free;

   if(base_amount <= 0.0)
      return false;

   gross_quote = base_amount * g_last_bid;
   double fee  = gross_quote * FeeRate();
   net_quote   = gross_quote - fee;

   if(net_quote <= 0.0)
      return false;

   base_sold = base_amount;

   g_base_free      -= base_amount;
   g_quote_reserved += net_quote;

   g_total_fees_quote += fee;
   g_total_turnover   += gross_quote;

   g_sell_trades++;
   g_total_trades++;

   if(detailed_log && InpInfoDetail == INFO_GRID_EVENTS)
   {
      Print("SELL FREE_CRYPTO->RESERVED_STABLE");
      Print("Time                 : ", FmtDt(g_last_tick_time));
      Print("Tag                  : ", tag);
      Print("Bid                  : ", FmtPrice(g_last_bid));
      Print("Crypto sold          : ", FmtMoney(base_amount));
      Print("Stable reserved      : ", FmtMoney(net_quote));
      Print("Gross stable         : ", FmtMoney(gross_quote));
      Print("Fee stable           : ", FmtMoney(fee));
      Print("Balances             : ", BalanceText());
      Print("Weights              : ", WeightsText());
      Print("--------------------------------------------------");
   }

   return true;
}
//+------------------------------------------------------------------+
bool ExecuteSellReservedToFree(double base_amount,
                               bool detailed_log,
                               string tag,
                               double &base_sold,
                               double &net_quote,
                               double &gross_quote)
{
   base_sold   = 0.0;
   net_quote   = 0.0;
   gross_quote = 0.0;

   if(base_amount <= 0.0 || g_last_bid <= 0.0)
      return false;

   if(base_amount > g_base_reserved)
      base_amount = g_base_reserved;

   if(base_amount <= 0.0)
      return false;

   gross_quote = base_amount * g_last_bid;
   double fee  = gross_quote * FeeRate();
   net_quote   = gross_quote - fee;

   if(net_quote <= 0.0)
      return false;

   base_sold = base_amount;

   g_base_reserved -= base_amount;
   g_quote_free    += net_quote;

   g_total_fees_quote += fee;
   g_total_turnover   += gross_quote;

   g_sell_trades++;
   g_total_trades++;

   if(detailed_log && InpInfoDetail == INFO_GRID_EVENTS)
   {
      Print("SELL RESERVED_CRYPTO->FREE_STABLE");
      Print("Time                 : ", FmtDt(g_last_tick_time));
      Print("Tag                  : ", tag);
      Print("Bid                  : ", FmtPrice(g_last_bid));
      Print("Crypto sold/resvd    : ", FmtMoney(base_amount));
      Print("Stable received/free : ", FmtMoney(net_quote));
      Print("Gross stable         : ", FmtMoney(gross_quote));
      Print("Fee stable           : ", FmtMoney(fee));
      Print("Balances             : ", BalanceText());
      Print("Weights              : ", WeightsText());
      Print("--------------------------------------------------");
   }

   return true;
}

#endif // __CRYPTOGRID_EXECUTION_MQH__
