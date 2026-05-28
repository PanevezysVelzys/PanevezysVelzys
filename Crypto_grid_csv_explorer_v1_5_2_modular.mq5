//+------------------------------------------------------------------+
//|           Crypto_grid_csv_explorer_v1_5_2_modular.mq5              |
//| Modular v1.5.2: v1.5 cascade + conservative two-way sub-line funicular entries.                             |
//|                                                                  |
//| Purpose: keep v1.5 cascade/source-weight sizing and add sub-lines |
//| for half-size early and conservative opposite-direction entries between main grid lines.           |
//|                                                                  |
//| CSV format expected: Binance aggTrades monthly CSV:              |
//| aggId,price,qty,firstId,lastId,timestamp,isBuyerMaker,isBestMatch|
//+------------------------------------------------------------------+
#property strict

#include "CryptoGrid_Config.mqh"
#include "CryptoGrid_Types.mqh"
#include "CryptoGrid_Inputs.mqh"
#include "CryptoGrid_Globals.mqh"

#include "CryptoGrid_Formatting.mqh"
#include "CryptoGrid_TimeCsvHelpers.mqh"
#include "CryptoGrid_Portfolio.mqh"
#include "CryptoGrid_GridMath.mqh"
#include "CryptoGrid_PendingLots.mqh"
#include "CryptoGrid_Risk.mqh"
#include "CryptoGrid_Execution.mqh"
#include "CryptoGrid_ProfitAccounting.mqh"
#include "CryptoGrid_CycleClosing.mqh"
#include "CryptoGrid_SubLines.mqh"
#include "CryptoGrid_CycleOpening.mqh"
#include "CryptoGrid_Allocation.mqh"
#include "CryptoGrid_MultiJump.mqh"
#include "CryptoGrid_Processing.mqh"
#include "CryptoGrid_MonthlySummary.mqh"
#include "CryptoGrid_CsvReader.mqh"
#include "CryptoGrid_Lifecycle.mqh"
//+------------------------------------------------------------------+
