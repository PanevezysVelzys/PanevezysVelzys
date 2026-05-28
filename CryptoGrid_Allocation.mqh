//+------------------------------------------------------------------+
//| CryptoGrid_Allocation.mqh                                       |
//| Initial allocation                                              |
//| Modular v1.5 branch based on classic v1.4.5 logic. |
//+------------------------------------------------------------------+
#ifndef __CRYPTOGRID_ALLOCATION_MQH__
#define __CRYPTOGRID_ALLOCATION_MQH__

//+------------------------------------------------------------------+
//| Initial allocation                                               |
//+------------------------------------------------------------------+
void InitialAllocate()
{
   g_quote_free     = InpInitialAmount;
   g_quote_reserved = 0.0;
   g_base_free      = 0.0;
   g_base_reserved  = 0.0;

   double quote_for_crypto = InpInitialAmount * 0.5;

   double base_bought = 0.0;
   double quote_spent = 0.0;

   if(quote_for_crypto > 0.0)
   {
      if(ExecuteBuyFreeToFree(quote_for_crypto,
                              false,
                              "initial allocation",
                              base_bought,
                              quote_spent))
      {
         AddTradeOriginDiagnostics(false, true, quote_spent);
      }
   }

   g_initial_value      = PortfolioValueBid();
   g_hold_base_balance  = TotalBaseBalance();
   g_hold_quote_balance = TotalQuoteBalance();
   g_initialized        = true;

   UpdateRiskStats();

   if(InpInfoDetail == INFO_GRID_EVENTS)
   {
      Print("INITIAL ALLOCATION");
      Print("Time                 : ", FmtDt(g_last_tick_time));
      Print("Bid / Ask            : ", FmtPrice(g_last_bid), " / ", FmtPrice(g_last_ask));
      Print("Current grid index   : ", (string)g_current_grid_index);
      Print("Next grid up          : ", GridUpText(g_current_grid_index));
      Print("Next grid down        : ", GridDownText(g_current_grid_index));
      Print("Initial value        : ", FmtMoney(g_initial_value));
      Print("Initial hold base    : ", FmtMoney(g_hold_base_balance));
      Print("Initial hold stable  : ", FmtMoney(g_hold_quote_balance));
      Print("Balances             : ", BalanceText());
      Print("Weights              : ", WeightsText());
      Print("--------------------------------------------------");
   }
}

#endif // __CRYPTOGRID_ALLOCATION_MQH__
