//+------------------------------------------------------------------+
//| CryptoGrid_TimeCsvHelpers.mqh                                   |
//| Month and timestamp helpers                                     |
//| Modular v1.5 branch based on classic v1.4.5 logic. |
//+------------------------------------------------------------------+
#ifndef __CRYPTOGRID_TIMECSVHELPERS_MQH__
#define __CRYPTOGRID_TIMECSVHELPERS_MQH__

string Month2(int m)
{
   if(m < 10)
      return "0" + (string)m;

   return (string)m;
}
//+------------------------------------------------------------------+
string BuildMonthlyFileName(int year, int month)
{
   return InpFilePrefix + (string)year + "-" + Month2(month) + ".csv";
}
//+------------------------------------------------------------------+
bool MonthLessOrEqual(int y1, int m1, int y2, int m2)
{
   if(y1 < y2)
      return true;

   if(y1 > y2)
      return false;

   return (m1 <= m2);
}
//+------------------------------------------------------------------+
void NextMonth(int &year, int &month)
{
   month++;

   if(month > 12)
   {
      month = 1;
      year++;
   }
}
//+------------------------------------------------------------------+
void YearMonthFromTime(datetime t, int &year, int &month)
{
   MqlDateTime s;
   TimeToStruct(t, s);

   year  = s.year;
   month = s.mon;
}

//+------------------------------------------------------------------+
//| Timestamp helpers                                                |
//+------------------------------------------------------------------+
string CleanTimestampString(string s)
{
   string out     = "";
   bool   started = false;

   int n = StringLen(s);

   for(int i = 0; i < n; i++)
   {
      ushort ch = StringGetCharacter(s, i);

      if(ch >= 48 && ch <= 57)
      {
         out += StringSubstr(s, i, 1);
         started = true;
         continue;
      }

      if(started)
         break;
   }

   return out;
}
//+------------------------------------------------------------------+
string TimestampUnitTextFromDigits(string digits)
{
   int len = StringLen(digits);

   if(len <= 0)
      return "invalid";

   if(len >= 19)
      return "nanoseconds";

   if(len >= 16)
      return "microseconds";

   if(len >= 13)
      return "milliseconds";

   return "seconds";
}
//+------------------------------------------------------------------+
string TimestampUnitTextFromString(string s)
{
   string digits = CleanTimestampString(s);
   return TimestampUnitTextFromDigits(digits);
}
//+------------------------------------------------------------------+
datetime TimestampFromString(string s)
{
   string digits = CleanTimestampString(s);

   if(digits == "")
      return 0;

   long raw = (long)StringToInteger(digits);

   if(raw <= 0)
      return 0;

   string unit = TimestampUnitTextFromDigits(digits);

   if(unit == "nanoseconds")
      return (datetime)(raw / 1000000000);

   if(unit == "microseconds")
      return (datetime)(raw / 1000000);

   if(unit == "milliseconds")
      return (datetime)(raw / 1000);

   if(unit == "seconds")
      return (datetime)raw;

   return 0;
}

//+------------------------------------------------------------------+
//| Skip-day helpers                                                 |
//+------------------------------------------------------------------+
string DateOnlyString(datetime t)
{
   return TimeToString(t, TIME_DATE);
}
//+------------------------------------------------------------------+
bool IsSkipDaySlot(const string slot, const string date_text)
{
   if(slot == "")
      return false;

   return (slot == date_text);
}
//+------------------------------------------------------------------+
bool IsSkipDay(datetime t)
{
   string d = DateOnlyString(t);

   if(IsSkipDaySlot(InpSkipDay1, d))
      return true;

   if(IsSkipDaySlot(InpSkipDay2, d))
      return true;

   if(IsSkipDaySlot(InpSkipDay3, d))
      return true;

   if(IsSkipDaySlot(InpSkipDay4, d))
      return true;

   return false;
}
//+------------------------------------------------------------------+
string AppendSkipDayText(string txt, const string slot)
{
   if(slot == "")
      return txt;

   if(txt == "")
      return slot;

   return txt + ", " + slot;
}
//+------------------------------------------------------------------+
string SkipDaysText()
{
   string txt = "";

   txt = AppendSkipDayText(txt, InpSkipDay1);
   txt = AppendSkipDayText(txt, InpSkipDay2);
   txt = AppendSkipDayText(txt, InpSkipDay3);
   txt = AppendSkipDayText(txt, InpSkipDay4);

   if(txt == "")
      return "none";

   return txt;
}

#endif // __CRYPTOGRID_TIMECSVHELPERS_MQH__
