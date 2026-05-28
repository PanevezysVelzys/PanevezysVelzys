//+------------------------------------------------------------------+
//| CryptoGrid_Formatting.mqh                                       |
//| Formatting helpers                                              |
//| Modular v1.5 branch based on classic v1.4.5 logic. |
//+------------------------------------------------------------------+
#ifndef __CRYPTOGRID_FORMATTING_MQH__
#define __CRYPTOGRID_FORMATTING_MQH__

//+------------------------------------------------------------------+
//| Formatting                                                       |
//+------------------------------------------------------------------+
string InfoText()
{
   if(InpInfoDetail == INFO_GRID_EVENTS)
      return "INFO_GRID_EVENTS";

   return "INFO_FINAL_ONLY";
}
//+------------------------------------------------------------------+
string BoolText(bool v)
{
   if(v)
      return "true";

   return "false";
}
//+------------------------------------------------------------------+
string FmtPrice(double v)
{
   return DoubleToString(v, 8);
}
//+------------------------------------------------------------------+
string FmtPriceLong(double v)
{
   return DoubleToString(v, 12);
}
//+------------------------------------------------------------------+
string FmtMoney(double v)
{
   return DoubleToString(v, 8);
}
//+------------------------------------------------------------------+
string FmtPct(double v)
{
   return DoubleToString(v, 4);
}
//+------------------------------------------------------------------+
string FmtPctShort(double v)
{
   return DoubleToString(v, 2);
}
//+------------------------------------------------------------------+
string FmtMoneyShort(double v)
{
   return DoubleToString(v, 2);
}
//+------------------------------------------------------------------+
string FmtPriceMonthly(double v)
{
   double av = MathAbs(v);

   if(av >= 1000.0)
      return DoubleToString(v, 2);

   if(av >= 1.0)
      return DoubleToString(v, 4);

   if(av >= 0.01)
      return DoubleToString(v, 6);

   return DoubleToString(v, 8);
}
//+------------------------------------------------------------------+
string FmtDt(datetime t)
{
   if(t <= 0)
      return "-";

   return TimeToString(t, TIME_DATE | TIME_SECONDS);
}

#endif // __CRYPTOGRID_FORMATTING_MQH__
