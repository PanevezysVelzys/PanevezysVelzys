//+------------------------------------------------------------------+
//| CryptoGrid_ProfitAccounting.mqh                                 |
//| Realized P/L accounting                                         |
//| Modular v1.5 branch based on classic v1.4.5 logic. |
//+------------------------------------------------------------------+
#ifndef __CRYPTOGRID_PROFITACCOUNTING_MQH__
#define __CRYPTOGRID_PROFITACCOUNTING_MQH__

//+------------------------------------------------------------------+
//| Profit accounting                                                |
//+------------------------------------------------------------------+
void AddRealizedPnL(double pnl)
{
   g_realized_grid_net_quote += pnl;

   if(pnl > 0.0)
      g_realized_grid_profit_quote += pnl;
   else if(pnl < 0.0)
      g_realized_grid_loss_quote += -pnl;
}

//+------------------------------------------------------------------+
void AddRealizedPnLByOrigin(const bool subline_origin,
                            const double pnl)
{
   if(subline_origin)
      g_subline_origin_realized_pnl += pnl;
   else
      g_main_origin_realized_pnl += pnl;
}


#endif // __CRYPTOGRID_PROFITACCOUNTING_MQH__
