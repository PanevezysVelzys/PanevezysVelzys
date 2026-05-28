//+------------------------------------------------------------------+
//| CryptoGrid_GridMath.mqh                                         |
//| Fixed geometric grid calculations                               |
//| Modular v1.5.1 branch based on v1.5 logic. |
//+------------------------------------------------------------------+
#ifndef __CRYPTOGRID_GRIDMATH_MQH__
#define __CRYPTOGRID_GRIDMATH_MQH__

//+------------------------------------------------------------------+
//| Fixed geometric grid                                             |
//+------------------------------------------------------------------+
double GridLinePrice(int index)
{
   if(g_grid_anchor_real_price <= 0.0 || g_grid_factor <= 1.0)
      return 0.0;

   double exponent = (double)index * MathLog(g_grid_factor);

   if(exponent > 690.0)
      return 1.0e300;

   if(exponent < -690.0)
      return 0.0;

   double price = g_grid_anchor_real_price * MathExp(exponent);

   if(!MathIsValidNumber(price) || price < 0.0)
      return 0.0;

   return price;
}
//+------------------------------------------------------------------+
double GridLineLabel(int index)
{
   if(g_grid_factor <= 1.0)
      return 0.0;

   double exponent = (double)index * MathLog(g_grid_factor);

   if(exponent > 690.0)
      return 1.0e300;

   if(exponent < -690.0)
      return 0.0;

   double label = GRID_CENTER_LABEL * MathExp(exponent);

   if(!MathIsValidNumber(label) || label < 0.0)
      return 0.0;

   return label;
}

//+------------------------------------------------------------------+
double GridSubLinePrice(const int lower_index)
{
   if(g_grid_factor <= 1.0)
      return 0.0;

   double lower_price = GridLinePrice(lower_index);

   if(lower_price <= 0.0)
      return 0.0;

   double price = lower_price * MathSqrt(g_grid_factor);

   if(!MathIsValidNumber(price) || price < 0.0)
      return 0.0;

   return price;
}
//+------------------------------------------------------------------+
double GridSubLineLabel(const int lower_index)
{
   if(g_grid_factor <= 1.0)
      return 0.0;

   double lower_label = GridLineLabel(lower_index);

   if(lower_label <= 0.0)
      return 0.0;

   double label = lower_label * MathSqrt(g_grid_factor);

   if(!MathIsValidNumber(label) || label < 0.0)
      return 0.0;

   return label;
}
//+------------------------------------------------------------------+
double NormalizedPriceLabel(double real_price)
{
   if(real_price <= 0.0 || g_grid_anchor_real_price <= 0.0)
      return 0.0;

   return GRID_CENTER_LABEL * real_price / g_grid_anchor_real_price;
}
//+------------------------------------------------------------------+
int GridIndexForPrice(double price)
{
   if(price <= 0.0 || g_grid_anchor_real_price <= 0.0 || g_grid_factor <= 1.0)
      return 0;

   double raw = MathLog(price / g_grid_anchor_real_price) / MathLog(g_grid_factor);

   if(!MathIsValidNumber(raw))
      return 0;

   if(raw > (double)GRID_INDEX_CAP)
      return GRID_INDEX_CAP;

   if(raw < -(double)GRID_INDEX_CAP)
      return -GRID_INDEX_CAP;

   return (int)MathFloor(raw + 0.0000000001);
}
//+------------------------------------------------------------------+
string GridUpText(int from_index)
{
   return FmtPriceLong(GridLinePrice(from_index + 1));
}
//+------------------------------------------------------------------+
string GridDownText(int from_index)
{
   return FmtPriceLong(GridLinePrice(from_index - 1));
}
//+------------------------------------------------------------------+
void ResyncGridIndexToCurrentBid(string reason)
{
   g_current_grid_index = GridIndexForPrice(g_last_bid);
   g_grid_resyncs++;

   if(InpInfoDetail == INFO_GRID_EVENTS)
   {
      Print("GRID INDEX RESYNCED");
      Print("Time                 : ", FmtDt(g_last_tick_time));
      Print("Reason               : ", reason);
      Print("Current bid          : ", FmtPrice(g_last_bid));
      Print("Current index        : ", (string)g_current_grid_index);
      Print("Next grid up          : ", GridUpText(g_current_grid_index));
      Print("Next grid down        : ", GridDownText(g_current_grid_index));
      Print("Balances             : ", BalanceText());
      Print("--------------------------------------------------");
   }
}

#endif // __CRYPTOGRID_GRIDMATH_MQH__
