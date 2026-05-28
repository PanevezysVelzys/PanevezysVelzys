//+------------------------------------------------------------------+
//| CryptoGrid_SubLines.mqh                                         |
//| Sub-line helpers                                                |
//| Modular v1.5.1 branch: one geometric sub-line per grid interval.|
//+------------------------------------------------------------------+
#ifndef __CRYPTOGRID_SUBLINES_MQH__
#define __CRYPTOGRID_SUBLINES_MQH__

//+------------------------------------------------------------------+
//| Pending lot search helpers                                       |
//+------------------------------------------------------------------+
bool IsSameInterval(const int a_open_level,
                    const int a_close_level,
                    const int lower_level,
                    const int upper_level)
{
   int a_lower = a_open_level;
   int a_upper = a_close_level;

   if(a_lower > a_upper)
   {
      a_lower = a_close_level;
      a_upper = a_open_level;
   }

   return (a_lower == lower_level && a_upper == upper_level);
}
//+------------------------------------------------------------------+
bool FindPendingBuyLot(const int open_level,
                       const int close_level,
                       const bool subline_part,
                       int &index)
{
   index = -1;

   for(int i = 0; i < ArraySize(g_pending_buys); i++)
   {
      if(g_pending_buys[i].open_level   == open_level &&
         g_pending_buys[i].close_level  == close_level &&
         g_pending_buys[i].subline_part == subline_part)
      {
         index = i;
         return true;
      }
   }

   return false;
}
//+------------------------------------------------------------------+
bool FindPendingSellLot(const int open_level,
                        const int close_level,
                        const bool subline_part,
                        int &index)
{
   index = -1;

   for(int i = 0; i < ArraySize(g_pending_sells); i++)
   {
      if(g_pending_sells[i].open_level   == open_level &&
         g_pending_sells[i].close_level  == close_level &&
         g_pending_sells[i].subline_part == subline_part)
      {
         index = i;
         return true;
      }
   }

   return false;
}
//+------------------------------------------------------------------+
bool HasPendingLotInInterval(const int lower_level,
                             const int upper_level)
{
   for(int i = 0; i < ArraySize(g_pending_buys); i++)
   {
      if(IsSameInterval(g_pending_buys[i].open_level,
                        g_pending_buys[i].close_level,
                        lower_level,
                        upper_level))
         return true;
   }

   for(int j = 0; j < ArraySize(g_pending_sells); j++)
   {
      if(IsSameInterval(g_pending_sells[j].open_level,
                        g_pending_sells[j].close_level,
                        lower_level,
                        upper_level))
         return true;
   }

   return false;
}

//+------------------------------------------------------------------+
//| Sub-line resolution markers                                      |
//+------------------------------------------------------------------+
bool MarkPendingSellSublineReachedNext(const int open_level,
                                        const int close_level)
{
   int index = -1;

   if(!FindPendingSellLot(open_level, close_level, true, index))
      return false;

   if(index < 0 || index >= ArraySize(g_pending_sells))
      return false;

   if(!g_pending_sells[index].subline_reached_next)
   {
      g_pending_sells[index].subline_reached_next = true;
      g_subline_upper_reached_next++;
   }

   return true;
}
//+------------------------------------------------------------------+
bool MarkPendingBuySublineReachedNext(const int open_level,
                                       const int close_level)
{
   int index = -1;

   if(!FindPendingBuyLot(open_level, close_level, true, index))
      return false;

   if(index < 0 || index >= ArraySize(g_pending_buys))
      return false;

   if(!g_pending_buys[index].subline_reached_next)
   {
      g_pending_buys[index].subline_reached_next = true;
      g_subline_lower_reached_next++;
   }

   return true;
}
//+------------------------------------------------------------------+
int CountOpenSellSublineParts(const bool reached_next)
{
   int count = 0;

   for(int i = 0; i < ArraySize(g_pending_sells); i++)
   {
      if(g_pending_sells[i].subline_part &&
         g_pending_sells[i].subline_reached_next == reached_next)
         count++;
   }

   return count;
}
//+------------------------------------------------------------------+
int CountOpenBuySublineParts(const bool reached_next)
{
   int count = 0;

   for(int i = 0; i < ArraySize(g_pending_buys); i++)
   {
      if(g_pending_buys[i].subline_part &&
         g_pending_buys[i].subline_reached_next == reached_next)
         count++;
   }

   return count;
}

//+------------------------------------------------------------------+
double RemainingPartFromSubPart(const double sub_part_amount)
{
   if(SUBLINE_PART_RATE <= 0.0 || SUBLINE_PART_RATE >= 1.0)
      return sub_part_amount;

   return sub_part_amount * (1.0 - SUBLINE_PART_RATE) / SUBLINE_PART_RATE;
}
//+------------------------------------------------------------------+
bool CrossedUpLevel(const double from_price,
                    const double to_price,
                    const double level_price)
{
   return (from_price < level_price && to_price >= level_price);
}
//+------------------------------------------------------------------+
bool CrossedDownLevel(const double from_price,
                      const double to_price,
                      const double level_price)
{
   return (from_price > level_price && to_price <= level_price);
}

#endif // __CRYPTOGRID_SUBLINES_MQH__
