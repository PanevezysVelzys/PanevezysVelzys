//+------------------------------------------------------------------+
//| CryptoGrid_Types.mqh                                            |
//| Enums and structs                                               |
//| v1.5.1: v1.5 structs plus sub-line lot marker.    |
//+------------------------------------------------------------------+
#ifndef __CRYPTOGRID_TYPES_MQH__
#define __CRYPTOGRID_TYPES_MQH__

enum ENUM_INFO_DETAIL
{
   INFO_FINAL_ONLY  = 0,
   INFO_GRID_EVENTS = 1
};

//+------------------------------------------------------------------+
//| Pending cycles                                                   |
//+------------------------------------------------------------------+
struct PendingSellLot
{
   ulong  cycle_id;
   double base_to_buy_back;
   double quote_reserved;
   double open_price;
   double close_price;
   int    open_level;
   int    close_level;
   bool   subline_part;
   bool   subline_origin;
   bool   subline_reached_next;
};

struct PendingBuyLot
{
   ulong  cycle_id;
   double base_reserved;
   double gross_quote_cost;
   double open_price;
   double close_price;
   int    open_level;
   int    close_level;
   bool   subline_part;
   bool   subline_origin;
   bool   subline_reached_next;
};

//+------------------------------------------------------------------+
//| Monthly summary rows                                             |
//+------------------------------------------------------------------+
struct MonthSummary
{
   string   month_key;
   bool     has_data;

   datetime first_time;
   datetime last_time;

   double   first_price;
   double   last_price;

   double   equity_start;
   double   equity_end;

   ulong    rows_used;
   ulong    bad_rows;
   ulong    skipped_rows;

   ulong    up_crossings;
   ulong    down_crossings;
   ulong    trades;

   double   fees;
};

//+------------------------------------------------------------------+
//| Multi-jump report rows                                           |
//+------------------------------------------------------------------+
struct MultiJumpEvent
{
   datetime event_time;

   double   from_price;
   double   to_price;

   int      from_index;
   int      to_index;
   int      grid_levels;

   double   equity_before;
   double   equity_after;

   bool     resync;
};

#endif // __CRYPTOGRID_TYPES_MQH__
