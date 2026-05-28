//+------------------------------------------------------------------+
//| CryptoGrid_PendingLots.mqh                                      |
//| Pending-cycle lot arrays                                        |
//| Modular v1.5.1 branch based on v1.5 logic. |
//+------------------------------------------------------------------+
#ifndef __CRYPTOGRID_PENDINGLOTS_MQH__
#define __CRYPTOGRID_PENDINGLOTS_MQH__

//+------------------------------------------------------------------+
//| Pending summaries                                                |
//+------------------------------------------------------------------+
double PendingSellBase()
{
   double sum = 0.0;

   for(int i = 0; i < ArraySize(g_pending_sells); i++)
      sum += g_pending_sells[i].base_to_buy_back;

   return sum;
}
//+------------------------------------------------------------------+
double PendingSellQuote()
{
   double sum = 0.0;

   for(int i = 0; i < ArraySize(g_pending_sells); i++)
      sum += g_pending_sells[i].quote_reserved;

   return sum;
}
//+------------------------------------------------------------------+
double PendingBuyBase()
{
   double sum = 0.0;

   for(int i = 0; i < ArraySize(g_pending_buys); i++)
      sum += g_pending_buys[i].base_reserved;

   return sum;
}
//+------------------------------------------------------------------+
double PendingBuyCost()
{
   double sum = 0.0;

   for(int i = 0; i < ArraySize(g_pending_buys); i++)
      sum += g_pending_buys[i].gross_quote_cost;

   return sum;
}
//+------------------------------------------------------------------+
void RemovePendingSellLot(int index)
{
   int n = ArraySize(g_pending_sells);

   if(index < 0 || index >= n)
      return;

   for(int i = index + 1; i < n; i++)
      g_pending_sells[i - 1] = g_pending_sells[i];

   ArrayResize(g_pending_sells, n - 1);
}
//+------------------------------------------------------------------+
void RemovePendingBuyLot(int index)
{
   int n = ArraySize(g_pending_buys);

   if(index < 0 || index >= n)
      return;

   for(int i = index + 1; i < n; i++)
      g_pending_buys[i - 1] = g_pending_buys[i];

   ArrayResize(g_pending_buys, n - 1);
}
//+------------------------------------------------------------------+
void AddPendingSellLot(ulong cycle_id,
                       double base_amount,
                       double quote_reserved,
                       double open_price,
                       double close_price,
                       int open_level,
                       int close_level,
                       bool subline_part,
                       bool subline_origin,
                       bool subline_reached_next)
{
   if(base_amount <= 0.0 || quote_reserved <= 0.0 || open_price <= 0.0 || close_price <= 0.0)
      return;

   int n = ArraySize(g_pending_sells);
   ArrayResize(g_pending_sells, n + 1);

   g_pending_sells[n].cycle_id         = cycle_id;
   g_pending_sells[n].base_to_buy_back = base_amount;
   g_pending_sells[n].quote_reserved   = quote_reserved;
   g_pending_sells[n].open_price       = open_price;
   g_pending_sells[n].close_price      = close_price;
   g_pending_sells[n].open_level       = open_level;
   g_pending_sells[n].close_level      = close_level;
   g_pending_sells[n].subline_part         = subline_part;
   g_pending_sells[n].subline_origin       = subline_origin;
   g_pending_sells[n].subline_reached_next = subline_reached_next;
}
//+------------------------------------------------------------------+
void AddPendingBuyLot(ulong cycle_id,
                      double base_reserved,
                      double gross_quote_cost,
                      double open_price,
                      double close_price,
                      int open_level,
                      int close_level,
                      bool subline_part,
                      bool subline_origin,
                      bool subline_reached_next)
{
   if(base_reserved <= 0.0 || gross_quote_cost <= 0.0 || open_price <= 0.0 || close_price <= 0.0)
      return;

   int n = ArraySize(g_pending_buys);
   ArrayResize(g_pending_buys, n + 1);

   g_pending_buys[n].cycle_id         = cycle_id;
   g_pending_buys[n].base_reserved    = base_reserved;
   g_pending_buys[n].gross_quote_cost = gross_quote_cost;
   g_pending_buys[n].open_price       = open_price;
   g_pending_buys[n].close_price      = close_price;
   g_pending_buys[n].open_level       = open_level;
   g_pending_buys[n].close_level      = close_level;
   g_pending_buys[n].subline_part         = subline_part;
   g_pending_buys[n].subline_origin       = subline_origin;
   g_pending_buys[n].subline_reached_next = subline_reached_next;
}

#endif // __CRYPTOGRID_PENDINGLOTS_MQH__
