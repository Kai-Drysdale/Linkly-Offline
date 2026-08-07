// codeunit 50209 "EFTPOS Events Old"
// {


//     var
//         //EFT Variables
//         gCashOutAmt: Decimal;
//         gRefund: Boolean;
//         Text095: label 'This Tender Type may not be used';
//         Text096: label 'This Tender Type may not be used\in training mode';
//         Text097: label 'Payment not allowed in this state!';
//         //EFT Variables
//         TenderType_TG: Record "LSC Tender Type";
//         Store_TG: Record "LSC Store";
//         POSTransaction_CG: Codeunit "LSC POS Transaction";
//         POSFunction_CG: Codeunit "LSC POS Functions";
//         POSSession_CG: Codeunit "LSC POS Session";
//         POSView_CG: Codeunit "LSC POS View";
//         NewLine_TG: Record "LSC POS Trans. Line";
//         CardEntry_TG: Record "LSC POS Card Entry";
//         POSPrint_CG: Codeunit "LSC POS Print Utility";
//         LineLen_G: Integer;
//         Value: array[10] of Text;

//     [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS Transaction Events", 'OnBeforeRunCommand', '', true, true)]
//     procedure OnBeforeRunCommand(var POSTransaction: Record "LSC POS Transaction"; var POSTransLine: Record "LSC POS Trans. Line"; var CurrInput: Text; var POSMenuLine: Record "LSC POS Menu Line"; var isHandled: Boolean; TenderType: Record "LSC Tender Type"; var CusomterOrCardNo: Code[20])
//     var
//     begin
//         case POSMenuLine.Command of
//             'EFTPOS':
//                 begin
//                     EFTPOS(POSTransaction, POSMenuLine);
//                 end;
//             'EFTPOS_DOLASTRANS':
//                 begin
//                     EFTPOSDoLastTrans(POSTransaction, false);
//                 end;
//             'EFTPOS_LSTREC':
//                 begin
//                     EFTPOSPrintLastReceipt(POSTransaction, POSMenuLine);
//                 end;
//             'EFTPOS_PRESET':
//                 begin
//                     EFTPOSSettlement(POSTransaction, POSMenuLine, 1);
//                 end;
//             'EFTPOS_FINSET':
//                 begin
//                     EFTPOSSettlement(POSTransaction, POSMenuLine, 2);
//                 end;
//             'EFTPOS_RESET':
//                 begin
//                     EFTPOSDoReset(POSTransaction, POSMenuLine);
//                 end;
//             'EFTPOS_ABOUT':
//                 begin
//                     EFTPOSDoAbout(POSTransaction, POSMenuLine);
//                 end;
//             'EFTPOS_LOGON':
//                 begin
//                     EFTPOSLogon(POSTransaction, POSMenuLine);
//                 end;
//             'EFTPOS_TMSLOGON':
//                 begin
//                     EFTPOSLogon(POSTransaction, POSMenuLine);
//                 end;

//         end;
//     end;

//     procedure EFTPOS(POSTransaction_TP: Record "LSC POS Transaction"; MenuLine: Record "LSC POS Menu Line") lCloseCommand: Code[20]
//     var
//         EFTPOSPopup: Codeunit "EFTPOS POS Popup";
//         RespCode: Code[20];
//         EFTPOSCaptureResp_LC: Codeunit "EFTPOS Capture";
//         EFTRespCodes: Record "EFTPOS Approval Code List";
//         EFTSetup: Record "EFTPOS Setup";
//         LOCCardEntry: Record "LSC POS Card Entry";
//         LPAYAmt: Decimal;
//         lTmp: Record "LSC Report Temp Table";
//         lOldCurrInput: Decimal;
//         NewBalance: Decimal;
//         lPOSTransLine_Exp: Record "LSC POS Trans. Line";
//         AmountInCurrencyOut_L: Decimal;
//         PaymentAmountOut_L: Decimal;
//         BalanceOut_L: Decimal;
//         // Currency_TL: Record Currency;

//         PaymentAmount_L: Decimal;
//         PCashoutEnabled: Boolean;
//         CCSPCT: Decimal;
//         SurChargeTender: Code[10];
//         SurChargeAmount: Decimal;
//     begin
//         // MPG1.00
//         //EFTPOS
//         Store_TG.Get(POSTransaction_TP."Store No.");
//         EFTSetup.Get;
//         EFTSetup.TestField("Capture Timeout (x 10 MS)");
//         TenderType_TG.Get(Store_TG."No.", 'CR_EFTPOS');

//         POSTransaction_CG.GetAmtAndBalance(AmountInCurrencyOut_L, PaymentAmountOut_L, BalanceOut_L);
//         LPAYAmt := BalanceOut_L;
//         gCashOutAmt := 0;

//         lCloseCommand := '';
//         RespCode := '';

//         Clear(EFTPOSPopup);
//         Clear(EFTPOSCaptureResp_LC);
//         EFTPOSCaptureResp_LC.SetMode(0); //PurchaseAutorisation/DoTransaction
//         EFTPOSCaptureResp_LC.SetPOSTrans(POSTransaction_TP);
//         if EFTPOSCaptureResp_LC.CheckRequest() then
//             exit(EFTPOSDoLastTrans(POSTransaction_TP, false));


//         //ERROR(EFTPOSTxt001,REC."Receipt No.");

//         //kevin
//         // if Store_TG."No." <> POSTransaction_TP."Store No." then
//         //     Error(Text296, REC.FieldCaption(REC."Store No."), REC."Store No.");

//         //POSTransaction_CG.CalcTotals;
//         //Clear(Currency_TL);
//         //Clear(CardEntry_TG);
//         //InitNewLine(POSTransaction_TP);
//         // CustomerOrCardNo := '';
//         // ReadFromMSR := false;
//         // ChangeTender := false;
//         if not TenderType_TG."May Be Used" then begin
//             POSTransaction_CG.ErrorBeep(Text095);
//             exit;
//         end;
//         if POSView_CG.GetTrainingMode() and (TenderType_TG."Function" = TenderType_TG."function"::Card) then begin
//             POSTransaction_CG.ErrorBeep(Text096);
//             exit;
//         end;
//         if POSTransaction_CG.GetPosState() <> 'PAYMENT' then begin
//             POSTransaction_CG.ErrorBeep(Text097);
//             exit;
//         end;

//         if (POSTransaction_TP."Sale Is Return Sale") and (BalanceOut_L > 0) then
//             gRefund := true;
//         if (POSTransaction_TP."Sale Is Return Sale") and (BalanceOut_L < 0) then
//             gRefund := false;

//         if (not POSTransaction_TP."Sale Is Return Sale") and (BalanceOut_L < 0) then
//             gRefund := true;
//         if (not POSTransaction_TP."Sale Is Return Sale") and (BalanceOut_L > 0) then
//             gRefund := false;

//         //MCS Added Surcharge Changes++
//         lPOSTransLine_Exp.Reset;
//         lPOSTransLine_Exp.SetRange("Receipt No.", POSTransaction_TP."Receipt No.");
//         lPOSTransLine_Exp.SetRange("Entry Type", lPOSTransLine_Exp."entry type"::IncomeExpense);
//         lPOSTransLine_Exp.SetRange(Number, TenderType_TG."Charge to Account No.");
//         if lPOSTransLine_Exp.FindFirst then
//             lPOSTransLine_Exp.Delete;

//         //kevin
//         // if ((LPAYAmt >= 3) and (gRefund = false)) then begin
//         //     TenderChargeSelect := TenderCharge(POSTransaction_TP."Store No.", TenderType, CurrInput, lTmp, CardType);
//         //     if TenderChargeSelect = -1 then
//         //         exit;

//         //     case TenderChargeSelect of
//         //         0: //CHARGE_ZERO
//         //             ;
//         //         1: //CHARGE_ACCEPTED
//         //             begin
//         //                 if CurrInput <> '' then begin
//         //                     if not Evaluate(lOldCurrInput, CurrInput) then begin
//         //                         ErrorBeep(Text101);
//         //                         exit;
//         //                     end;
//         //                 end else
//         //                     lOldCurrInput := 0;

//         //                 CurrInput := Format(lTmp.Amount3); //Charge

//         //                 if lTmp.Amount3 <> 0 then
//         //                     IncExpPressed(lTmp."Sort Code");   //Charge Account

//         //                 if lOldCurrInput > lTmp."Sales Amount" then
//         //                     CurrInput := Format(lOldCurrInput)
//         //                 else
//         //                     CurrInput := Format(lTmp."Sales Amount");
//         //                 PaymentAmount := lTmp."Sales Amount";
//         //             end;
//         //         2: //CHARGE_CANCEL
//         //             exit;
//         //         else begin
//         //             ErrorBeep(Text719);
//         //             exit;
//         //         end;
//         //     end;
//         // end;

//         NewBalance := ROUND(BalanceOut_L, 0.01, '=');
//         //MCS Added Surcharge++

//         EFTPOSPopup.SETGlobalVar(POSTransaction_TP."Receipt No.", NewBalance, gCashOutAmt, POSTransaction_TP, gRefund, PCashoutEnabled, CCSPCT, SurChargeTender);
//         if MenuLine.Parameter = '' then
//             lCloseCommand := EFTPOSPopup.ShowPanel;

//         //update:kevin
//         // if lCloseCommand = 'OK' then begin
//         //     EFTPOSPopup.GETGlobalVar(POSTransaction_TP."Receipt No.", BalanceOut_L, gCashOutAmt, POSTransaction_TP, gRefund, PCashoutEnabled, SurChargeAmount, SurChargeTender);
//         //     Clear(RespCode);
//         //     EFTPOSCaptureResp.SetParamsPurchAuth(BalanceOut_L, gCashOutAmt, gRefund, not EFTSetup."Debug Mode");
//         //     //MCS1.07 Jira 1787>>>
//         //     //EFTPOSCaptureResp.RUNMODAL;
//         //     EFTPOSCaptureResp.Run;
//         //     //MCS1.07 Jira 1787<<<
//         //     RespCode := EFTPOSCaptureResp.GetResponse;
//         // end;

//         // if lCloseCommand = 'CANCEL' then begin
//         //     //MCS Added++
//         //     lPOSTransLine_Exp.Reset;
//         //     lPOSTransLine_Exp.SetRange("Receipt No.", POSTransaction_TP."Receipt No.");
//         //     lPOSTransLine_Exp.SetRange("Entry Type", lPOSTransLine_Exp."entry type"::IncomeExpense);
//         //     lPOSTransLine_Exp.SetRange(Number, TenderType_TG."Charge to Account No.");
//         //     if lPOSTransLine_Exp.FindFirst then
//         //         lPOSTransLine_Exp.Delete;
//         //     //MCS Added++
//         //     EFTPOSPopup.RevertBalance(LPAYAmt);
//         //     //Balance := LPAYAmt;
//         //     gCashOutAmt := 0;
//         // end;

//         // if EFTRespCodes.Get(EFTSetup."Interface Type", EFTSetup."Country Code", EFTSetup."Bank Name", RespCode) then begin
//         //     if EFTRespCodes.Approve then begin
//         //         CardEntry_TG.Reset;
//         //         CardEntry_TG.SetCurrentkey("Store No.", "POS Terminal No.", "Receipt No.");
//         //         CardEntry_TG.SetRange("Store No.", POSTransaction_TP."Store No.");
//         //         CardEntry_TG.SetRange("POS Terminal No.", POSTransaction_TP."POS Terminal No.");
//         //         CardEntry_TG.SetRange("Receipt No.", POSTransaction_TP."Receipt No.");
//         //         if CardEntry_TG.FindLast then begin
//         //             if gRefund and POSTransaction_TP."Sale Is Return Sale" then
//         //                 PaymentAmount_L := -CardEntry_TG.Amount
//         //             else
//         //                 PaymentAmount_L := CardEntry_TG.Amount;
//         //         end;

//         //         PaymentAmount_L := POSFunction_CG.RoundTender(TenderType_TG, PaymentAmount_L);
//         //         AdjustAmountToShow(PaymentAmount_L);

//         //         POSTransaction_CG.TenderKeyPressedEx(TenderType_TG.Code, Format(PaymentAmount_L));
//         //         exit(lCloseCommand);
//         //     end
//         //     else begin
//         //         EFTPOSPopup.RevertBalance(LPAYAmt);
//         //         //Balance := LPAYAmt;
//         //         gCashOutAmt := 0;
//         //     end;
//         // end;

//         exit(lCloseCommand);
//     end;

//     procedure EFTPOSDoLastTrans(POSTransaction_TP: Record "LSC POS Transaction"; RunFromStartup: Boolean) lCloseCommand: Code[20]
//     var
//         EFTPOSPopup: Codeunit "EFTPOS POS Popup";
//         RespCode: Code[20];
//         EFTPOSCaptureResp: Codeunit "EFTPOS Capture";
//         EFTRespCodes: Record "EFTPOS Approval Code List";
//         EFTSetup: Record "EFTPOS Setup";
//         LOCCardEntry: Record "LSC POS Card Entry";
//         LPAYAmt: Decimal;
//         PaymentAmount_L: Decimal;
//     begin
//         // MPG1.00
//         if not EFTSetup.Get then
//             exit;
//         lCloseCommand := '';
//         RespCode := '';
//         Store_TG.Get(POSTransaction_TP."Store No.");
//         TenderType_TG.Get(Store_TG."No.", 'CR_EFTPOS');
//         Clear(EFTPOSCaptureResp);
//         EFTPOSCaptureResp.SetMode(4);
//         EFTPOSCaptureResp.SetPOSTrans(POSTransaction_TP);
//         if EFTPOSCaptureResp.CheckRequest then begin
//             /*IF NOT PosConfirm(EFTPOSTxt002,FALSE) THEN BEGIN
//               lCloseCommand := 'CANCEL';
//               EXIT(lCloseCommand);
//             END;*/
//             //MCS1.07 Jira 1787>>>>
//             //EFTPOSCaptureResp.RUNMODAL;
//             EFTPOSCaptureResp.Run;
//             //MCS1.07 Jira 1787<<<<
//             RespCode := EFTPOSCaptureResp.GetResponse;
//         end
//         else begin
//             RespCode := '';
//             if not RunFromStartup then
//                 POSTransaction_CG.PosMessage('No request found');
//             lCloseCommand := 'CANCEL';
//             exit(lCloseCommand);
//         end;

//         if (RespCode = '00') or (RespCode = '08') then begin
//             lCloseCommand := 'OK';
//         end;

//         if EFTRespCodes.Get(EFTSetup."Interface Type", EFTSetup."Country Code", EFTSetup."Bank Name", RespCode) then begin
//             if EFTRespCodes.Approve then begin
//                 CardEntry_TG.Reset;
//                 CardEntry_TG.SetCurrentkey("Store No.", "POS Terminal No.", "Receipt No.");
//                 CardEntry_TG.SetRange("Store No.", POSTransaction_TP."Store No.");
//                 CardEntry_TG.SetRange("POS Terminal No.", POSTransaction_TP."POS Terminal No.");
//                 CardEntry_TG.SetRange("Receipt No.", POSTransaction_TP."Receipt No.");
//                 if CardEntry_TG.FindLast then begin
//                     if gRefund and POSTransaction_TP."Sale Is Return Sale" then
//                         PaymentAmount_L := -CardEntry_TG.Amount
//                     else
//                         PaymentAmount_L := CardEntry_TG.Amount;
//                 end;
//                 //gInsertTmpPayment := false;
//                 if EFTRespCodes."Force Get Last Transaction" then;

//                 // InitNewLine;
//                 // InsertPaymentLine;
//                 POSTransaction_CG.TenderKeyPressedEx(TenderType_TG.Code, Format(PaymentAmount_L));
//                 exit(lCloseCommand);
//             end;
//         end;
//         //CalcTotals;

//         exit(lCloseCommand);

//     end;

//     procedure EFTPOSPrintLastReceipt(POSTransaction_TP: Record "LSC POS Transaction"; MenuLine: Record "LSC POS Menu Line") lCloseCommand: Code[20]
//     var
//         EFTPOSCaptureResp: Codeunit "EFTPOS Capture";
//         RespCode: Code[20];
//     begin
//         // MPG1.00
//         Clear(EFTPOSCaptureResp);
//         lCloseCommand := '';
//         RespCode := '';
//         EFTPOSCaptureResp.SetMode(3);
//         EFTPOSCaptureResp.SetPOSTrans(POSTransaction_TP);
//         //MCS1.07 Jira 1787>>>>
//         //EFTPOSCaptureResp.RUNMODAL;
//         EFTPOSCaptureResp.Run;
//         //MCS1.07 Jira 1787<<<<
//         RespCode := EFTPOSCaptureResp.GetResponse;

//         lCloseCommand := 'OK';

//         exit(lCloseCommand);
//     end;

//     procedure EFTPOSSettlement(POSTransaction_TP: Record "LSC POS Transaction"; MenuLine: Record "LSC POS Menu Line"; PreSettleOrSettle: Integer) lCloseCommand: Code[20]
//     var
//         EFTPOSCaptureResp: Codeunit "EFTPOS Capture";
//         RespCode: Code[20];
//     begin
//         // MPG1.00
//         // Run EFTPOS Settlement for PreSettle or Settle depending on the option passed.
//         Clear(EFTPOSCaptureResp);
//         lCloseCommand := '';
//         RespCode := '';
//         // Presettlement = 1 , Settlement = 2
//         EFTPOSCaptureResp.SetMode(PreSettleOrSettle);
//         EFTPOSCaptureResp.SetPOSTrans(POSTransaction_TP);
//         //MCS1.07 Jira 1787>>>>
//         //EFTPOSCaptureResp.RUNMODAL;
//         EFTPOSCaptureResp.Run;
//         //MCS1.07 Jira 1787<<<<
//         RespCode := EFTPOSCaptureResp.GetResponse;

//         lCloseCommand := 'OK';

//         exit(lCloseCommand);
//     end;

//     procedure EFTPOSDoReset(POSTransaction_TP: Record "LSC POS Transaction"; MenuLine: Record "LSC POS Menu Line") lCloseCommand: Code[20]
//     var
//         EFTPOSCaptureResp: Codeunit "EFTPOS Capture";
//         RespCode: Code[20];
//     begin
//         // MPG1.00
//         Clear(EFTPOSCaptureResp);
//         lCloseCommand := '';
//         RespCode := '';
//         EFTPOSCaptureResp.SetMode(6);
//         EFTPOSCaptureResp.SetPOSTrans(POSTransaction_TP);
//         //MCS1.07 Jira 1787>>>>
//         //EFTPOSCaptureResp.RUNMODAL;
//         EFTPOSCaptureResp.Run;
//         //MCS1.07 Jira 1787<<<<
//         RespCode := EFTPOSCaptureResp.GetResponse;

//         lCloseCommand := 'OK';
//     end;


//     procedure EFTPOSDoAbout(POSTransaction_TP: Record "LSC POS Transaction"; MenuLine: Record "LSC POS Menu Line") lCloseCommand: Code[20]
//     var
//         EFTPOSCaptureResp: Codeunit "EFTPOS Capture";
//         RespCode: Code[20];
//     begin
//         // MPG1.00
//         // Doesn't actually return anything from PCEFTPOS. Added just in case
//         Clear(EFTPOSCaptureResp);
//         lCloseCommand := '';
//         RespCode := '';
//         EFTPOSCaptureResp.SetMode(7);
//         EFTPOSCaptureResp.SetPOSTrans(POSTransaction_TP);
//         //MCS1.07 Jira 1787>>>>
//         //EFTPOSCaptureResp.RUNMODAL;
//         EFTPOSCaptureResp.Run;
//         //MCS1.07 Jira 1787<<<<
//         RespCode := EFTPOSCaptureResp.GetResponse;

//         lCloseCommand := 'OK';
//     end;


//     procedure EFTPOSLogon(POSTransaction_TP: Record "LSC POS Transaction"; MenuLine: Record "LSC POS Menu Line") lCloseCommand: Code[20]
//     var
//         EFTPOSCaptureResp: Codeunit "EFTPOS Capture";
//         RespCode: Code[20];
//     begin
//         // MPG1.00
//         Clear(EFTPOSCaptureResp);
//         lCloseCommand := '';
//         RespCode := '';
//         EFTPOSCaptureResp.SetMode(5);
//         EFTPOSCaptureResp.SetPOSTrans(POSTransaction_TP);
//         //MCS1.07 Jira 1787>>>>
//         //EFTPOSCaptureResp.RUNMODAL;
//         EFTPOSCaptureResp.Run;
//         //MCS1.07 Jira 1787<<<<
//         RespCode := EFTPOSCaptureResp.GetResponse;

//         lCloseCommand := 'OK';
//     end;


//     procedure EFTPOSTendLastEFT(POSTransaction_TP: Record "LSC POS Transaction"; MenuLine: Record "LSC POS Menu Line") lCloseCommand: Code[20]
//     var
//         EFTPOSCaptureResp: Codeunit "EFTPOS Capture";
//         RespCode: Code[20];
//     begin
//         // MPG1.00
//         Clear(EFTPOSCaptureResp);
//         lCloseCommand := '';
//         RespCode := '';
//         EFTPOSCaptureResp.SetMode(8);
//         EFTPOSCaptureResp.SetPOSTrans(POSTransaction_TP);
//         //MCS1.07 Jira 1787>>>>
//         //EFTPOSCaptureResp.RUNMODAL;
//         EFTPOSCaptureResp.Run;
//         //MCS1.07 Jira 1787<<<<
//         RespCode := EFTPOSCaptureResp.GetResponse;

//         lCloseCommand := 'OK';
//     end;
//     // procedure InitNewLine(POSTransaction_P: Record "LSC POS Transaction")
//     // var
//     //     MenuTypeRec: Record "LSC Restaurant Menu Type";
//     // begin
//     //     Clear(NewLine_TG);
//     //     NewLine_TG."Store No." := POSTransaction_P."Store No.";
//     //     NewLine_TG."POS Terminal No." := POSTransaction_P."POS Terminal No.";
//     //     NewLine_TG."Receipt No." := POSTransaction_P."Receipt No.";

//     // end;

//     procedure AdjustAmountToShow(var Value: Decimal)
//     var
//         PosFuncProfile_LT: Record "LSC POS Func. Profile";
//     begin
//         //Function to adjust amount to show on pop-up tender/qty form on the POS
//         PosFuncProfile_LT.Get(POSSession_CG.FunctionalityProfileID());
//         if PosFuncProfile_LT."Decimals in Entry" > 0 then
//             Value := Round(Value * Power(10, PosFuncProfile_LT."Decimals in Entry"));
//     end;


//     [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS Transaction Events", 'OnBeforeVoidTransaction', '', true, true)]
//     procedure OnBeforeVoidTransaction(var POSTransaction: Record "LSC POS Transaction"; var IsHandled: Boolean)
//     begin
//         EFTPOSCheckVoidLine(POSTransaction."Receipt No.");
//     end;

//     [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS Transaction Events", 'OnBeforevoidLinePressed', '', true, true)]
//     procedure OnBeforevoidLinePressed(var POSTransaction: Record "LSC POS Transaction"; var IsHandled: Boolean)
//     begin
//         EFTPOSCheckVoidLine(POSTransaction."Receipt No.");
//     end;

//     procedure EFTPOSCheckVoidLine(ReceiptNo: Code[20])
//     var
//         PosTransLine: Record "LSC POS Trans. Line";
//         EFTPOSTxt003: label 'You cannot void a payment line when the payment is already processed.';
//     begin
//         // MPG1.00
//         PosTransLine.Reset;
//         PosTransLine.SetRange("Receipt No.", ReceiptNo);
//         if PosTransLine.FindSet then
//             repeat
//                 if (PosTransLine."Entry Type" = PosTransLine."entry type"::Payment) and (PosTransLine."Card Type" <> '') then begin
//                     POSTransaction_CG.ErrorBeep(EFTPOSTxt003);
//                     Error(EFTPOSTxt003);
//                 end;
//             until PosTransLine.Next = 0;
//     end;

//     procedure PrintEFTReceipt(Tray: Integer; var POSTrans: Record "LSC POS Transaction"; SubHeader: Boolean; MerchantCopyOnly: Boolean; FromEntryNo: Integer): Boolean
//     var
//         POSEFTReceipt: Record "EFTPOS Receipt Text";
//         DSTR1: Text[100];
//         LineLength2: Integer;

//         QRPath: Text;
//     begin
//         //MPG1.00
//         //PrintEFTREceipt
//         //PCEFTPOS-EDD6.2

//         //MCS1.09: PS-1890: Added parameters MerchantCopyOnly, FromEntryNo

//         //WindowInitialize();
//         if Tray = 2 then
//             LineLength2 := 40;
//         LineLen_G := 40;

//         POSEFTReceipt.Reset;
//         POSEFTReceipt.SetRange("Store No.", POSTrans."Store No.");
//         POSEFTReceipt.SetRange("POS Terminal No.", POSTrans."POS Terminal No.");
//         POSEFTReceipt.SetRange("Receipt Code", POSTrans."Receipt No.");
//         //>>MCS1.09: PS-1890
//         if FromEntryNo <> 0 then
//             POSEFTReceipt.SetFilter("Entry No.", '>%1', FromEntryNo);
//         if MerchantCopyOnly then
//             //<<MCS1.09: PS-1890
//             POSEFTReceipt.SetRange("Signature Required", true);//MCS1.02 JIRA PS-1755
//         //POSEFTReceipt.SETFILTER("EFTPOS Receipt Text",'<>%1','');
//         //MCS1.00 JIRA PS-1414>>>>
//         if not (POSEFTReceipt.Count > 1) then
//             exit(false);
//         //MCS1.00 JIRA PS-1414<<<<<
//         if POSEFTReceipt.FindFirst then begin
//             if not POSPrint_CG.OpenReceiptPrinter(2, 'SALES', '', 0, POSTrans."Receipt No.") then
//                 exit(false);
//             if POSTrans."Receipt No." <> '' then
//                 if SubHeader then begin
//                     POSPrint_CG.PrintBitmap(Tray, QRPath, 1);
//                     POSPrint_CG.PrintSeperator(2);
//                     PrintEFTSubHeader(POSTrans, 2, POSTrans."Trans. Date", POSTrans."Trans Time");
//                 end;
//             repeat
//                 DSTR1 := CopyStr('#C##############################', 1, LineLength2);//MCS1.00 JIRA PS-1414
//                 Value[1] := CopyStr(POSEFTReceipt."EFTPOS Receipt Text", 1, 30);
//                 POSPrint_CG.PrintLine(Tray, POSPrint_CG.FormatLine(POSPrint_CG.FormatStr(Value, DSTR1), false, false, false, false));
//             until POSEFTReceipt.Next = 0;
//             POSPrint_CG.PrintSeperator(2);
//             if not POSPrint_CG.ClosePrinter(2) then
//                 exit(false);
//         end;

//         POSEFTReceipt.Reset;
//         POSEFTReceipt.SetRange("Store No.", POSTrans."Store No.");
//         POSEFTReceipt.SetRange("POS Terminal No.", POSTrans."POS Terminal No.");
//         POSEFTReceipt.SetRange("Receipt Code", POSTrans."Receipt No.");
//         //>>MCS1.09: PS-1890
//         if FromEntryNo <> 0 then
//             POSEFTReceipt.SetFilter("Entry No.", '>%1', FromEntryNo);
//         if MerchantCopyOnly then
//             //<<MCS1.09: PS-1890
//             POSEFTReceipt.SetRange("Signature Required", true);//MCS1.02 Jira PS-1755
//         if POSEFTReceipt.FindFirst then
//             POSEFTReceipt.DeleteAll;
//         exit(true);
//     end;

//     procedure PrintEFTSubHeader(var POSTransaction: Record "LSC POS Transaction"; Tray: Integer; PrDate: Date; PrTime: Time)
//     var
//         Staff: Record "LSC Staff";
//         DSTR1: Text[100];
//         StaffName: Text[30];
//         blankStr: Text[30];

//         Text020: label 'Slip';
//         Text048: label 'Date';
//         Text16022371: label 'Store';
//         Text16022372: label 'POS';
//         Text051: label 'Staff';
//     begin
//         //PrintEFTSubHeader
//         if Tray = 2 then
//             blankStr := POSPrint_CG.StringPad(' ', LineLen_G - 38)
//         else if Tray = 4 then
//             blankStr := POSPrint_CG.StringPad(' ', LineLen_G - 38);

//         Clear(Value);
//         DSTR1 := '#L##### #L#####################';
//         Value[1] := Text020 + ':';
//         Value[2] := POSTransaction."Receipt No.";
//         POSPrint_CG.PrintLine(Tray, POSPrint_CG.FormatLine(POSPrint_CG.FormatStr(Value, DSTR1), false, true, false, false));

//         Clear(Value);
//         DSTR1 := '#L#### #T###### #T###';
//         Value[1] := Text048 + ':';
//         Value[2] := Format(PrDate);
//         Value[3] := Format(PrTime, 5);
//         POSPrint_CG.PrintLine(Tray, POSPrint_CG.FormatLine(POSPrint_CG.FormatStr(Value, DSTR1), false, true, false, false));

//         Clear(Value);
//         DSTR1 := '#L#### #L######' + blankStr + '#L######### #R#########';
//         Value[1] := Text16022371 + ':';
//         Value[2] := Format(POSTransaction."Store No.");
//         Value[3] := Text16022372 + ':';
//         Value[4] := Format(POSTransaction."POS Terminal No.");
//         POSPrint_CG.PrintLine(Tray, POSPrint_CG.FormatLine(POSPrint_CG.FormatStr(Value, DSTR1), false, true, false, false));

//         Clear(Value);
//         DSTR1 := '#L#### #L######' + blankStr + '#L######### #N#########';
//         StaffName := POSTransaction."Staff ID";
//         if Staff.Get(POSTransaction."Staff ID") then
//             StaffName := Staff."Name on Receipt";
//         Value[1] := Text051 + ':';
//         Value[2] := StaffName;
//         Value[3] := '';
//         Value[4] := '';
//         POSPrint_CG.PrintLine(Tray, POSPrint_CG.FormatLine(POSPrint_CG.FormatStr(Value, DSTR1), false, true, false, false));
//         POSPrint_CG.PrintSeperator(Tray);
//     end;



// }