//+------------------------------------------------------------------+
//| CryptoGrid_Portfolio.mqh                                        |
//| Basic helpers and portfolio calculations                        |
//| v1.5 reviewed: v1.4.5 portfolio helpers + source-weight sizing. |
//+------------------------------------------------------------------+
#ifndef __CRYPTOGRID_PORTFOLIO_MQH__
#define __CRYPTOGRID_PORTFOLIO_MQH__

//+------------------------------------------------------------------+
//| Basic helpers                                                    |
//+------------------------------------------------------------------+
double ClampDouble(double v, double lo, double hi)
{
   if(v < lo)
      return lo;

   if(v > hi)
      return hi;

   return v;
}
//+------------------------------------------------------------------+
double FeeRate()
{
   return InpFeePercent / 100.0;
}
//+------------------------------------------------------------------+
double TradeRate()
{
   return g_trade_rate;
}
//+------------------------------------------------------------------+
double TotalBaseBalance()
{
   return g_base_free + g_base_reserved;
}
//+------------------------------------------------------------------+
double TotalQuoteBalance()
{
   return g_quote_free + g_quote_reserved;
}
//+------------------------------------------------------------------+
double PortfolioValueBid()
{
   return TotalQuoteBalance() + TotalBaseBalance() * g_last_bid;
}
//+------------------------------------------------------------------+
double PortfolioValueAtPrice(double price)
{
   if(price <= 0.0)
      return 0.0;

   return TotalQuoteBalance() + TotalBaseBalance() * price;
}
//+------------------------------------------------------------------+
double BaseValueBid()
{
   return TotalBaseBalance() * g_last_bid;
}
//+------------------------------------------------------------------+
double FreeBaseValueBid()
{
   return g_base_free * g_last_bid;
}
//+------------------------------------------------------------------+
double ReservedBaseValueBid()
{
   return g_base_reserved * g_last_bid;
}
//+------------------------------------------------------------------+
double BaseWeightFraction()
{
   double value_now = PortfolioValueBid();

   if(value_now <= 0.0)
      return 0.0;

   return BaseValueBid() / value_now;
}
//+------------------------------------------------------------------+
double QuoteWeightFraction()
{
   double value_now = PortfolioValueBid();

   if(value_now <= 0.0)
      return 0.0;

   return TotalQuoteBalance() / value_now;
}
//+------------------------------------------------------------------+
double BaseWeightPercent()
{
   return BaseWeightFraction() * 100.0;
}
//+------------------------------------------------------------------+
double QuoteWeightPercent()
{
   return QuoteWeightFraction() * 100.0;
}
//+------------------------------------------------------------------+
//| v1.5 portfolio-weight sizing                                     |
//|                                                                  |
//| Base idea: InpTradePercent is the trade percent at ideal 50/50.   |
//| BUY uses the stable/quote weight as the source asset.             |
//| SELL uses the crypto/base weight as the source asset.             |
//| Example with InpTradePercent=5: quote weight 30% -> buy 3%.       |
//| Example with InpTradePercent=5: base  weight 40% -> sell 4%.      |
//+------------------------------------------------------------------+
double SourceWeightTradeRate(const double source_weight_pct)
{
   if(source_weight_pct <= 0.0)
      return 0.0;

   double factor = source_weight_pct / 50.0;
   double rate   = g_trade_rate * factor;

   if(rate < 0.0)
      rate = 0.0;

   // Defensive cap only. In normal 0..100% portfolio weights and
   // InpTradePercent=5%, this will never be approached.
   if(rate > 1.0)
      rate = 1.0;

   return rate;
}
//+------------------------------------------------------------------+
double BuyTradeRate()
{
   return SourceWeightTradeRate(QuoteWeightPercent());
}
//+------------------------------------------------------------------+
double SellTradeRate()
{
   return SourceWeightTradeRate(BaseWeightPercent());
}
//+------------------------------------------------------------------+
double BuyTradePercent()
{
   return BuyTradeRate() * 100.0;
}
//+------------------------------------------------------------------+
double SellTradePercent()
{
   return SellTradeRate() * 100.0;
}
//+------------------------------------------------------------------+
string WeightsText()
{
   return "crypto " + FmtPct(BaseWeightPercent()) +
          "% | stable " + FmtPct(QuoteWeightPercent()) + "%";
}
//+------------------------------------------------------------------+
string BalanceText()
{
   return "free crypto " + FmtMoney(g_base_free) +
          " | reserved crypto " + FmtMoney(g_base_reserved) +
          " | free stable " + FmtMoney(g_quote_free) +
          " | reserved stable " + FmtMoney(g_quote_reserved);
}
//+------------------------------------------------------------------+
double HoldValueBid()
{
   if(g_last_bid <= 0.0)
      return 0.0;

   return g_hold_quote_balance + g_hold_base_balance * g_last_bid;
}

#endif // __CRYPTOGRID_PORTFOLIO_MQH__
