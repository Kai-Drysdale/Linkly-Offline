// Page 50203 "EFTPOS Capture"
// {
//     // MPG1.00 27-09-16
//     //   New Object
//     //   This page will fire the timer every 1 second.
//     //   This page is run in modal mode, standard NAV timer with event thread wont work, will use control addin no-event thread for this
//     // 
//     // MPG1.05 01-05-19 LP
//     //   Revisited PC-EFTPOS
//     // 
//     // MCS1.00 02-06-20 KK
//     //   JIRA PS-1414 EFTPOS Receipt Changes
//     // MCS1.02 17-06-20 KK
//     //   JIRA PS-1755 EFTPOS Receipt Changes: Added back standard to print merchant copy
//     // 
//     // MCS1.04 18-06-20 KK
//     //   JIRA PS-1753 EFTPOS delay in print receipt

//     Caption = 'EFTPOS Capture';

//     layout
//     {
//         area(content)
//         {
//             usercontrol(timer; "FreddyK.TimerControl.NE")
//             {
//                 ApplicationArea = Basic;
//             }
//         }
//     }

//     actions
//     {
//     }

//     trigger OnOpenPage()
//     begin
//         EFTPOSSetup.Get;
//         WaitforSignature := false;

//         if EFTPOSSetup."Capture Timeout (x 10 MS)" > 0 then
//             timer2 := Format(EFTPOSSetup."Capture Timeout (x 10 MS)")
//         else
//             timer2 := '10'; //1 second

//         if EFTPOSSetup."Event Timeout (Seconds)" > 0 then
//             TimeOut := EFTPOSSetup."Event Timeout (Seconds)"
//         else
//             TimeOut := 60;


//         CallInterface();
//     end;

//     var
//         POSTrans: Record "LSC POS Transaction";
//         EFTPOSRequest: Record "EFTPOS Request";
//         EFTPOSSetup: Record "EFTPOS Setup";
//         Trans: Record "EFTPOS Events";
//         EFTPOSFunctions: Codeunit "EFTPOS Utilities";
//         POSPrint: Codeunit "LSC POS Print Utility";
//         PageMode: Option PurchAuthorisation,PreSettlement,Settlement,PrintLastReceipt,DoLastTransaction,DoLogon,DoReset,DoAbout,TendLastEFT,PayCardSurcharge;
//         timer2: Text;
//         counter2: Integer;
//         [RunOnClient]
//         [WithEvents]
//         PcEftPosRequest: dotnet EFTPOSData;
//         [RunOnClient]
//         [WithEvents]
//         pcEftPosResponse: dotnet EFTPOSData;
//         [RunOnClient]
//         [WithEvents]
//         PcEftPos: dotnet EFTPOS;
//         isReady: Boolean;
//         Refund: Boolean;
//         PurchaseAmount: Decimal;
//         CashOutAmount: Decimal;
//         ReceiptNo: Code[20];
//         ResponseCode: Text[250];
//         WaitforSignature: Boolean;
//         TimeOut: Integer;
//         EntryNo: Integer;
//         SkipMessage: Boolean;
//         EFTPOSReceiptNo: Code[20];


//     procedure SetMode(NewMode: Integer)
//     begin
//         //0 = PurchAuthorisation,
//         //1 = PreSettlement,
//         //2 = Settlement,
//         //3 = PrintLastReceipt,
//         //4 = DoLastTransaction,
//         //5 = DoLogon
//         //6 = DoReset
//         //7 = DoAbout
//         //8 = TendLastEFT
//         //9 = PayCardSurcharge
//         PageMode := NewMode;
//     end;


//     procedure CallInterface()
//     var
//         TranSet: Boolean;
//         _AmountInCents: Integer;
//         _CashOutInCents: Integer;
//     begin
//         Clear(EFTPOSFunctions);

//         EFTPOSFunctions.SetEFTPOSSetup(EFTPOSSetup);

//         case PageMode of
//             Pagemode::PurchAuthorisation:
//                 begin
//                     if Trans.FindSet then
//                         Trans.DeleteAll;

//                     if Trans.FindLast then
//                         EntryNo := Trans."Entry No." + 1;
//                     EFTPOSFunctions.SetParameters(POSTrans, POSTrans."Receipt No.", PurchaseAmount, CashOutAmount, Refund);
//                     EFTPOSFunctions.AddRequestLog();

//                     if IsNull(PcEftPosRequest) then
//                         PcEftPosRequest := PcEftPosRequest.EFTPOSData();
//                     PcEftPosRequest.TimeOut := TimeOut;

//                     if Refund then begin
//                         PcEftPosRequest.AmtPurchase := Abs(PurchaseAmount);
//                         PcEftPosRequest.TxnType := 'R';
//                         PcEftPosRequest.TxnRef := EFTPOSReceiptNo;
//                     end
//                     else begin
//                         PcEftPosRequest.AmtPurchase := Abs(PurchaseAmount);
//                         PcEftPosRequest.AmtCash := Abs(CashOutAmount);
//                         PcEftPosRequest.TxnType := 'P';
//                         PcEftPosRequest.TxnRef := EFTPOSReceiptNo;
//                     end;

//                     //MESSAGE(POSTrans."Receipt No.");
//                     if IsNull(PcEftPos) then
//                         PcEftPos := PcEftPos.EFTPOS();
//                     PcEftPos.DoTransaction(PcEftPosRequest);
//                     EFTPOSFunctions.AddEFTPOSLog(3, EFTPOSFunctions.GetNextEFTPOSEntry(), StrSubstNo('EFTPOS %1 %2 Start', Format(PageMode), PcEftPosRequest.TxnType), pcEftPosResponse);
//                 end;

//             Pagemode::PreSettlement:
//                 begin
//                     if Trans.FindLast then
//                         EntryNo := Trans."Entry No." + 1;
//                     EFTPOSFunctions.SetParameters(POSTrans, POSTrans."Receipt No.", 0, 0, false);
//                     PcEftPosRequest := PcEftPosRequest.EFTPOSData();

//                     PcEftPosRequest.CutReceipt := false;
//                     PcEftPosRequest.ReceiptAutoPrint := false;
//                     PcEftPosRequest.TxnType := 'P';
//                     PcEftPosRequest.ResetTotals := false;
//                     EFTPOSFunctions.AddEFTPOSLog(3, EFTPOSFunctions.GetNextEFTPOSEntry(), StrSubstNo('EFTPOS %1 Start', Format(PageMode)), pcEftPosResponse);
//                     PcEftPos := PcEftPos.EFTPOS();
//                     PcEftPos.DoSettlement(PcEftPosRequest);
//                 end;

//             Pagemode::Settlement:
//                 begin
//                     if Trans.FindLast then
//                         EntryNo := Trans."Entry No." + 1;
//                     EFTPOSFunctions.SetParameters(POSTrans, POSTrans."Receipt No.", 0, 0, false);
//                     PcEftPosRequest := PcEftPosRequest.EFTPOSData();

//                     PcEftPosRequest.CutReceipt := false;
//                     PcEftPosRequest.ReceiptAutoPrint := false;
//                     PcEftPosRequest.TxnType := 'S';
//                     PcEftPosRequest.ResetTotals := false;

//                     EFTPOSFunctions.AddEFTPOSLog(3, EFTPOSFunctions.GetNextEFTPOSEntry(), StrSubstNo('EFTPOS %1 Start', Format(PageMode)), pcEftPosResponse);
//                     PcEftPos := PcEftPos.EFTPOS();
//                     PcEftPos.DoSettlement(PcEftPosRequest);
//                 end;

//             Pagemode::PrintLastReceipt:
//                 begin
//                     if Trans.FindLast then
//                         EntryNo := Trans."Entry No." + 1;
//                     EFTPOSFunctions.SetParameters(POSTrans, POSTrans."Receipt No.", 0, 0, false);
//                     EFTPOSFunctions.AddEFTPOSLog(3, EFTPOSFunctions.GetNextEFTPOSEntry(), StrSubstNo('EFTPOS %1 Start', Format(PageMode)), pcEftPosResponse);
//                     PcEftPosRequest := PcEftPosRequest.EFTPOSData();
//                     PcEftPos := PcEftPos.EFTPOS();
//                     PcEftPos.DoGetLastReceipt(PcEftPosRequest);
//                 end;

//             Pagemode::DoLastTransaction:
//                 begin

//                     if Trans.FindSet then
//                         Trans.DeleteAll;

//                     if Trans.FindLast then
//                         EntryNo := Trans."Entry No." + 1;
//                     if CheckRequest() then begin
//                         if EFTPOSRequest."Refund Amount" <> 0 then
//                             EFTPOSFunctions.SetParameters(POSTrans, POSTrans."Receipt No.", -EFTPOSRequest."Refund Amount", 0, true)
//                         else
//                             EFTPOSFunctions.SetParameters(POSTrans, POSTrans."Receipt No.", EFTPOSRequest."Purchase Amount", EFTPOSRequest."Cashout Amount", false);

//                         PcEftPosRequest := PcEftPosRequest.EFTPOSData();
//                         PcEftPos := PcEftPos.EFTPOS();
//                         PcEftPos.DoGetLastTransaction(PcEftPosRequest);
//                         EFTPOSFunctions.AddEFTPOSLog(3, EFTPOSFunctions.GetNextEFTPOSEntry(), StrSubstNo('EFTPOS %1 Start', Format(PageMode)), pcEftPosResponse);

//                     end
//                     else begin
//                         CurrPage.Close;
//                     end;
//                 end;

//             Pagemode::DoLogon:
//                 begin
//                     EFTPOSFunctions.SetParameters(POSTrans, POSTrans."Receipt No.", 0, 0, Refund);
//                     PcEftPosRequest := PcEftPosRequest.EFTPOSData();
//                     PcEftPos := PcEftPos.EFTPOS();
//                     PcEftPos.DoLogon(PcEftPosRequest);
//                 end;

//             Pagemode::DoReset:
//                 begin
//                     PcEftPos := PcEftPos.EFTPOS();
//                     PcEftPos.DoReset();
//                 end;

//             Pagemode::DoAbout:
//                 begin
//                     PcEftPos := PcEftPos.EFTPOS();
//                     PcEftPos.DoAbout();
//                 end;

//             Pagemode::TendLastEFT:
//                 begin

//                 end;

//         end;

//         isReady := true;
//     end;


//     procedure SetParamsPurchAuth(vAmount: Decimal; vCashOutAmount: Decimal; vRefund: Boolean; vSkipMessage: Boolean)
//     begin
//         PurchaseAmount := vAmount;
//         CashOutAmount := vCashOutAmount;
//         Refund := vRefund;
//         SkipMessage := vSkipMessage;
//     end;


//     procedure SetPOSTrans(vPOSTrans: Record "LSC POS Transaction")
//     begin
//         POSTrans := vPOSTrans;
//         // EFTPOS only allows 16 characters on their receipt.
//         //EFTPOSReceiptNo := DELCHR(UPPERCASE(POSTrans"Receipt No."), '=', 'ABCDEFGHIJKLMNOPQRSTUVWXYZ')
//         EFTPOSReceiptNo := CopyStr(POSTrans."Receipt No.", StrPos(POSTrans."Receipt No.", 'T') + 1);
//     end;


//     procedure GetResponse(): Text[250]
//     begin
//         exit(ResponseCode);
//     end;

//     local procedure ConvertDatetoText(NewDate: Date) DateYYYYMMDD: Text
//     var
//         YearInt: Integer;
//         MonthInt: Integer;
//         DayInt: Integer;
//         MonthTxt: Text;
//         DayTxt: Text;
//     begin
//         DayInt := Date2dmy(NewDate, 1);
//         MonthInt := Date2dmy(NewDate, 2);
//         YearInt := Date2dmy(NewDate, 3);
//         if DayInt < 10 then
//             DayTxt := '0' + Format(DayInt)
//         else
//             DayTxt := Format(DayInt);
//         if MonthInt < 10 then
//             MonthTxt := '0' + Format(MonthInt)
//         else
//             MonthTxt := Format(MonthInt);

//         exit(Format(YearInt) + MonthTxt + DayTxt);
//     end;


//     procedure CheckRequest() RequestFound: Boolean
//     begin
//         if EFTPOSRequest.Get(POSTrans."Store No.", POSTrans."POS Terminal No.", POSTrans."Receipt No.") then
//             exit(true)
//         else begin
//             EFTPOSRequest.Init;
//             exit(false);
//         end;
//     end;

//     local procedure FindCardEntry(): Boolean
//     var
//         POSCardEntry: Record "LSC POS Card Entry";
//         StanTxt: Text;
//     begin
//         POSCardEntry.Reset;
//         POSCardEntry.SetCurrentkey("Store No.", "POS Terminal No.", "Receipt No.");
//         POSCardEntry.SetRange("Store No.", EFTPOSRequest."Store No.");
//         POSCardEntry.SetRange("POS Terminal No.", EFTPOSRequest."POS Terminal No.");
//         POSCardEntry.SetRange("Receipt No.", EFTPOSRequest."Receipt No.");
//         POSCardEntry.SetRange("Authorisation Ok", true);
//         //>> MPG1.05
//         //Check for Stan (System trace audit number)
//         StanTxt := Format(pcEftPosResponse.Stan);
//         POSCardEntry.SetRange("EFT Stan", StanTxt);
//         //<< MPG1.05
//         if POSCardEntry.FindLast then
//             exit(true)
//         else
//             exit(false);
//     end;
// }

