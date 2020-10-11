//+------------------------------------------------------------------+
//|                                                        Boxer.mq5 |
//|                                                Christian de Beer |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Christian de Beer"
#property link      "https://www.mql5.com"
#property version   "1.00"

input string          LnHigh="HighLine";     // Line High
input string          LnLow="LowLine";     // Line Low
input int             InpPrice=25;         // Line price, %
input color           InpColor=clrRed;     // Line color
input ENUM_LINE_STYLE InpStyle=STYLE_DASH; // Line style
input int             InpWidth=3;          // Line width
input bool            InpBack=false;       // Background line
input bool            InpSelection=true;   // Highlight to move
input bool            InpHidden=true;      // Hidden in the object list
input long            InpZOrder=0;         // Priority for mouse click

uint counter = 0;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- create timer
   EventSetTimer(4);
   
   double Ask = NormalizeDouble(SymbolInfoDouble(_Symbol,SYMBOL_ASK),_Digits); // Get the Ask Price
   double Bid = NormalizeDouble(SymbolInfoDouble(_Symbol,SYMBOL_BID),_Digits); // Get the Bid Price
   
   HLineCreate(0,LnLow,0,Ask,clrRed,InpStyle,InpWidth,InpBack,InpSelection,InpHidden,InpZOrder);
   HLineCreate(0,LnHigh,0,Bid,clrBlue,InpStyle,InpWidth,InpBack,InpSelection,InpHidden,InpZOrder);
   ChartRedraw();
   
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//--- destroy timer
   EventKillTimer();
   
   HLineDelete(0,LnHigh);
   HLineDelete(0,LnLow);
   
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {

   // Bid and Ask line -------- >>
   double Ask = NormalizeDouble(SymbolInfoDouble(_Symbol,SYMBOL_ASK),_Digits); // Get the Ask Price
   double Bid = NormalizeDouble(SymbolInfoDouble(_Symbol,SYMBOL_BID),_Digits); // Get the Bid Price

   HLineMove(0,LnHigh,Ask); 
   HLineMove(0,LnLow,Bid);  
   ChartRedraw();
   // --------- 
   
  }
//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer()
  {
   
   // Every 2 Seconds
   // counter++;
   
   // Delete all orders
   DeleteAllOrdersByMagic(9999);
   
   // Orders
   uint res = 0;
    res=SendLowPendingOrder(9999);
    res=SendHighPendingOrder(9999);
   
   // Comments
   // Comment(StringFormat("Counter : %d", counter));
   
  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Create the horizontal line                                       |
//+------------------------------------------------------------------+
bool HLineCreate(const long            chart_ID=0,        // chart's ID
                 const string          name="HLine",      // line name
                 const int             sub_window=0,      // subwindow index
                 double                price=0,           // line price
                 const color           clr=clrRed,        // line color
                 const ENUM_LINE_STYLE style=STYLE_SOLID, // line style
                 const int             width=1,           // line width
                 const bool            back=false,        // in the background
                 const bool            selection=true,    // highlight to move
                 const bool            hidden=true,       // hidden in the object list
                 const long            z_order=0)         // priority for mouse click
  {
//--- if the price is not set, set it at the current Bid price level
   if(!price)
      price=SymbolInfoDouble(Symbol(),SYMBOL_BID);
//--- reset the error value
   ResetLastError();
//--- create a horizontal line
   if(!ObjectCreate(chart_ID,name,OBJ_HLINE,sub_window,0,price))
     {
      Print(__FUNCTION__,
            ": failed to create a horizontal line! Error code = ",GetLastError());
      return(false);
     }
//--- set line color
   ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,clr);
//--- set line display style
   ObjectSetInteger(chart_ID,name,OBJPROP_STYLE,style);
//--- set line width
   ObjectSetInteger(chart_ID,name,OBJPROP_WIDTH,width);
//--- display in the foreground (false) or background (true)
   ObjectSetInteger(chart_ID,name,OBJPROP_BACK,back);
//--- enable (true) or disable (false) the mode of moving the line by mouse
//--- when creating a graphical object using ObjectCreate function, the object cannot be
//--- highlighted and moved by default. Inside this method, selection parameter
//--- is true by default making it possible to highlight and move the object
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTABLE,selection);
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTED,selection);
//--- hide (true) or display (false) graphical object name in the object list
   ObjectSetInteger(chart_ID,name,OBJPROP_HIDDEN,hidden);
//--- set the priority for receiving the event of a mouse click in the chart
   ObjectSetInteger(chart_ID,name,OBJPROP_ZORDER,z_order);
//--- successful execution
   return(true);
  }
  
  //+------------------------------------------------------------------+
//| Move horizontal line                                             |
//+------------------------------------------------------------------+
bool HLineMove(const long   chart_ID=0,   // chart's ID
               const string name="HLine", // line name
               double       price=0)      // line price
  {
//--- if the line price is not set, move it to the current Bid price level
   if(!price)
      price=SymbolInfoDouble(Symbol(),SYMBOL_BID);
//--- reset the error value
   ResetLastError();
//--- move a horizontal line
   if(!ObjectMove(chart_ID,name,0,0,price))
     {
      Print(__FUNCTION__,
            ": failed to move the horizontal line! Error code = ",GetLastError());
      return(false);
     }
//--- successful execution
   return(true);
  }
//+------------------------------------------------------------------+
//| Delete a horizontal line                                         |
//+------------------------------------------------------------------+
bool HLineDelete(const long   chart_ID=0,   // chart's ID
                 const string name="HLine") // line name
  {
//--- reset the error value
   ResetLastError();
//--- delete a horizontal line
   if(!ObjectDelete(chart_ID,name))
     {
      Print(__FUNCTION__,
            ": failed to delete a horizontal line! Error code = ",GetLastError());
      return(false);
     }
//--- successful execution
   return(true);
  }
  
  //+------------------------------------------------------------------+
//| Receives the current number of orders with specified ORDER_MAGIC |
//+------------------------------------------------------------------+
int GetOrdersTotalByMagic(long const magic_number)
  {
   ulong order_ticket;
   int total=0;
//--- go through all pending orders
   for(int i=0;i<OrdersTotal();i++)
      if((order_ticket=OrderGetTicket(i))>0)
         if(magic_number==OrderGetInteger(ORDER_MAGIC)) total++;
//---
   return(total);
  }
  
  //+------------------------------------------------------------------+
//| Sets a pending order in a random way                             |
//+------------------------------------------------------------------+
uint SendLowPendingOrder(long const magic_number)
  {
//--- prepare a request
   MqlTradeRequest request={0};
   request.action=TRADE_ACTION_PENDING;         // setting a pending order
   request.magic=magic_number;                  // ORDER_MAGIC
   request.symbol=_Symbol;                      // symbol
   request.volume=1.0;                          // volume in 0.1 lots
   request.sl=0;                                // Stop Loss is not specified  
//--- form the order type
   request.type=ORDER_TYPE_SELL_STOP;                // order type
   request.tp=GetTP(request.type);              // Take Profit is not specified  
//--- form the price for the pending order
   request.price=GetPrice(request.type);  // open price
//--- send a trade request
   MqlTradeResult result={0};
   OrderSend(request,result);
//--- write the server reply to log  
   Print(__FUNCTION__,":",result.comment);
   if(result.retcode==10016) Print(result.bid,result.ask,result.price);
//--- return code of the trade server reply
   return result.retcode;
  }
  
    //+------------------------------------------------------------------+
//| Sets a pending order in a random way                             |
//+------------------------------------------------------------------+
uint SendHighPendingOrder(long const magic_number)
  {
//--- prepare a request
   MqlTradeRequest request={0};
   request.action=TRADE_ACTION_PENDING;         // setting a pending order
   request.magic=magic_number;                  // ORDER_MAGIC
   request.symbol=_Symbol;                      // symbol
   request.volume=1.0;                          // volume in 0.1 lots
   request.sl=0;                                // Stop Loss is not specified 
//--- form the order type
   request.type=ORDER_TYPE_BUY_STOP;                // order type
   request.tp=GetTP(request.type);                                // Take Profit is not specified    
//--- form the price for the pending order
   request.price=GetPrice(request.type);  // open price
//--- send a trade request
   MqlTradeResult result={0};
   OrderSend(request,result);
//--- write the server reply to log  
   Print(__FUNCTION__,":",result.comment);
   if(result.retcode==10016) Print(result.bid,result.ask,result.price);
//--- return code of the trade server reply
   return result.retcode;
  }
  
  //+------------------------------------------------------------------+
//| Returns price in a random way                                    |
//+------------------------------------------------------------------+
double GetPrice(ENUM_ORDER_TYPE type)
  {
   int t=(int)type;
//--- stop levels for the symbol
   int distance=(int)SymbolInfoInteger(_Symbol,SYMBOL_TRADE_STOPS_LEVEL);
//--- receive data of the last tick
   MqlTick last_tick={0};
   SymbolInfoTick(_Symbol,last_tick);
//--- calculate price according to the type
   double price;
   if(t==2 || t==5) // ORDER_TYPE_BUY_LIMIT or ORDER_TYPE_SELL_STOP
     {
      price=last_tick.bid; // depart from price Bid
      price=price-(distance+(4)*5)*_Point;
     }
   else             // ORDER_TYPE_SELL_LIMIT or ORDER_TYPE_BUY_STOP
     {
      price=last_tick.ask; // depart from price Ask
      price=price+(distance+(4)*5)*_Point;
     }
//---
   return(price);
  }
  
  double GetTP(ENUM_ORDER_TYPE type)
  {
   int t=(int)type;
//--- stop levels for the symbol
   int distance=(int)SymbolInfoInteger(_Symbol,SYMBOL_TRADE_STOPS_LEVEL);
//--- receive data of the last tick
   MqlTick last_tick={0};
   SymbolInfoTick(_Symbol,last_tick);
//--- calculate price according to the type
   double price;
   if(t==2 || t==5) // ORDER_TYPE_BUY_LIMIT or ORDER_TYPE_SELL_STOP
     {
      price=last_tick.bid; // depart from price Bid
      price=price-(distance+(5)*5)*_Point;
     }
   else             // ORDER_TYPE_SELL_LIMIT or ORDER_TYPE_BUY_STOP
     {
      price=last_tick.ask; // depart from price Ask
      price=price+(distance+(5)*5)*_Point;
     }
//---
   return(price);
  }
  
//+------------------------------------------------------------------+
//| Deletes all pending orders with specified ORDER_MAGIC            |
//+------------------------------------------------------------------+
void DeleteAllOrdersByMagic(long const magic_number)
  {
   ulong order_ticket;
//--- go through all pending orders
   for(int i=OrdersTotal()-1;i>=0;i--)
      if((order_ticket=OrderGetTicket(i))>0)
         //--- order with appropriate ORDER_MAGIC
         if(magic_number==OrderGetInteger(ORDER_MAGIC))
           {
            MqlTradeResult result={0};
            MqlTradeRequest request={0};
            request.order=order_ticket;
            request.action=TRADE_ACTION_REMOVE;
            OrderSend(request,result);
            //--- write the server reply to log
            Print(__FUNCTION__,": ",result.comment," reply code ",result.retcode);
           }
//---
  }