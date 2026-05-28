//+------------------------------------------------------------------+
//| CryptoGrid_Inputs.mqh                                           |
//| User inputs                                                     |
//| v1.5.1 inputs: classic set + optional sub-lines and crash-day skip slots.       |
//+------------------------------------------------------------------+
#ifndef __CRYPTOGRID_INPUTS_MQH__
#define __CRYPTOGRID_INPUTS_MQH__

//+------------------------------------------------------------------+
//| Inputs                                                           |
//+------------------------------------------------------------------+
input double                InpInitialAmount          = 2000.0;
input double                InpGridStepPercent        = 5.0;
input double                InpTradePercent           = 5.0;
input double                InpFeePercent             = 0.10;
input bool                  InpUseSubLines            = true;
input ENUM_INFO_DETAIL      InpInfoDetail             = INFO_FINAL_ONLY;

// CSV inputs
input string                InpFilePrefix             = "ADAUSDT-aggTrades-";
input datetime              InpStartTime              = D'2024.01.01 00:00:00';
input datetime              InpEndTime                = D'2026.04.30 23:59:59';

// Optional crash-day skips. Format must be YYYY.MM.DD. Empty string disables the slot.
// During a skipped day the robot is treated as OFF: no cycle closes, no cycle opens,
// no fees, no balance changes. On the first non-skipped tick after the day,
// the robot is resumed at the current price without replaying missed crossings.
input string                InpSkipDay1               = "2025.10.10";
input string                InpSkipDay2               = "";
input string                InpSkipDay3               = "";
input string                InpSkipDay4               = "";

#endif // __CRYPTOGRID_INPUTS_MQH__
