// codeunit 50206 "EFT EFTPOS Events"
// {


//     var
//         //EFT Variables
//         // gCashOutAmt: Decimal;
//         gRefund: Boolean;
//         Text095: label 'This Tender Type may not be used';
//         Text096: label 'This Tender Type may not be used\in training mode';
//         Text097: label 'Payment not allowed in this state!';
//         //EFT Variables
//         TenderType_TG: Record "LSC Tender Type";
//         Store_TG: Record "LSC Store";
//         POSTransaction_GC: Codeunit "LSC POS Transaction";
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
//         EFTSetup_LT: Record "EFTPOS Setup";
//     begin
//         case POSMenuLine.Command of
//             'EFTPOS':
//                 begin
//                     //EFTPOS(POSTransaction, POSMenuLine);
//                     EFTPOSv2(POSTransaction, POSMenuLine);
//                 end;
//             'CASHOUT':
//                 begin
//                     //MCS.KB 1099:Cash out in POS
//                     isHandled := true;
//                     if EFTSetup_LT.Get() then;
//                     if EFTSetup_LT."Cashout Item" = '' then begin
//                         POSTransaction_GC.PosErrorBanner('Cashout Item cannot be empty in EFT POS Setup.');
//                         exit;
//                     end;
//                     POSTransaction_GC.OpenNumericKeyboard('Enter Cashout Amount', '0', 50130);
//                 end;
//         // 'EFTPOS_DOLASTRANS':
//         //     begin
//         //         EFTPOSDoLastTrans(POSTransaction, false);
//         //     end;
//         // 'EFTPOS_LSTREC':
//         //     begin
//         //         EFTPOSPrintLastReceipt(POSTransaction, POSMenuLine);
//         //     end;
//         // 'EFTPOS_PRESET':
//         //     begin
//         //         EFTPOSSettlement(POSTransaction, POSMenuLine, 1);
//         //     end;
//         // 'EFTPOS_FINSET':
//         //     begin
//         //         EFTPOSSettlement(POSTransaction, POSMenuLine, 2);
//         //     end;
//         // 'EFTPOS_RESET':
//         //     begin
//         //         EFTPOSDoReset(POSTransaction, POSMenuLine);
//         //     end;
//         // 'EFTPOS_ABOUT':
//         //     begin
//         //         EFTPOSDoAbout(POSTransaction, POSMenuLine);
//         //     end;
//         // 'EFTPOS_LOGON':
//         //     begin
//         //         EFTPOSLogon(POSTransaction, POSMenuLine);
//         //     end;
//         // 'EFTPOS_TMSLOGON':
//         //     begin
//         //         EFTPOSLogon(POSTransaction, POSMenuLine);
//         //     end;

//         end;
//     end;

//     // procedure EFTPOS(POSTransaction_TP: Record "LSC POS Transaction"; MenuLine: Record "LSC POS Menu Line") lCloseCommand: Code[20]
//     // var
//     //     EFTPOSPopup: Codeunit "EFTPOS POS Popup";
//     //     RespCode: Code[20];
//     //     EFTPOSCaptureResp_LC: Codeunit "EFTPOS Capture";
//     //     EFTRespCodes: Record "EFTPOS Approval Code List";
//     //     EFTSetup: Record "EFTPOS Setup";
//     //     LOCCardEntry: Record "LSC POS Card Entry";
//     //     LPAYAmt: Decimal;
//     //     lTmp: Record "LSC Report Temp Table";
//     //     lOldCurrInput: Decimal;
//     //     NewBalance: Decimal;
//     //     lPOSTransLine_Exp: Record "LSC POS Trans. Line";
//     //     AmountInCurrencyOut_L: Decimal;
//     //     PaymentAmountOut_L: Decimal;
//     //     BalanceOut_L: Decimal;
//     //     // Currency_TL: Record Currency;

//     //     PaymentAmount_L: Decimal;
//     //     PCashoutEnabled: Boolean;
//     //     CCSPCT: Decimal;
//     //     SurChargeTender: Code[10];
//     //     SurChargeAmount: Decimal;
//     // begin
//     //     // MPG1.00
//     //     //EFTPOS
//     //     Store_TG.Get(POSTransaction_TP."Store No.");
//     //     EFTSetup.Get;
//     //     EFTSetup.TestField("Capture Timeout (x 10 MS)");
//     //     TenderType_TG.Get(Store_TG."No.", 'CR_EFTPOS');

//     //     POSTransaction_CG.GetAmtAndBalance(AmountInCurrencyOut_L, PaymentAmountOut_L, BalanceOut_L);
//     //     LPAYAmt := BalanceOut_L;
//     //     gCashOutAmt := 0;

//     //     lCloseCommand := '';
//     //     RespCode := '';

//     //     Clear(EFTPOSPopup);
//     //     Clear(EFTPOSCaptureResp_LC);
//     //     EFTPOSCaptureResp_LC.SetMode(0); //PurchaseAutorisation/DoTransaction
//     //     EFTPOSCaptureResp_LC.SetPOSTrans(POSTransaction_TP);
//     //     if EFTPOSCaptureResp_LC.CheckRequest() then
//     //         exit(EFTPOSDoLastTrans(POSTransaction_TP, false));


//     //     //ERROR(EFTPOSTxt001,REC."Receipt No.");

//     //     //kevin
//     //     // if Store_TG."No." <> POSTransaction_TP."Store No." then
//     //     //     Error(Text296, REC.FieldCaption(REC."Store No."), REC."Store No.");

//     //     //POSTransaction_CG.CalcTotals;
//     //     //Clear(Currency_TL);
//     //     //Clear(CardEntry_TG);
//     //     //InitNewLine(POSTransaction_TP);
//     //     // CustomerOrCardNo := '';
//     //     // ReadFromMSR := false;
//     //     // ChangeTender := false;
//     //     if not TenderType_TG."May Be Used" then begin
//     //         POSTransaction_CG.ErrorBeep(Text095);
//     //         exit;
//     //     end;
//     //     if POSView_CG.GetTrainingMode() and (TenderType_TG."Function" = TenderType_TG."function"::Card) then begin
//     //         POSTransaction_CG.ErrorBeep(Text096);
//     //         exit;
//     //     end;
//     //     if POSTransaction_CG.GetPosState() <> 'PAYMENT' then begin
//     //         POSTransaction_CG.ErrorBeep(Text097);
//     //         exit;
//     //     end;

//     //     if (POSTransaction_TP."Sale Is Return Sale") and (BalanceOut_L > 0) then
//     //         gRefund := true;
//     //     if (POSTransaction_TP."Sale Is Return Sale") and (BalanceOut_L < 0) then
//     //         gRefund := false;

//     //     if (not POSTransaction_TP."Sale Is Return Sale") and (BalanceOut_L < 0) then
//     //         gRefund := true;
//     //     if (not POSTransaction_TP."Sale Is Return Sale") and (BalanceOut_L > 0) then
//     //         gRefund := false;

//     //     //MCS Added Surcharge Changes++
//     //     lPOSTransLine_Exp.Reset;
//     //     lPOSTransLine_Exp.SetRange("Receipt No.", POSTransaction_TP."Receipt No.");
//     //     lPOSTransLine_Exp.SetRange("Entry Type", lPOSTransLine_Exp."entry type"::IncomeExpense);
//     //     lPOSTransLine_Exp.SetRange(Number, TenderType_TG."Charge to Account No.");
//     //     if lPOSTransLine_Exp.FindFirst then
//     //         lPOSTransLine_Exp.Delete;

//     //     //kevin
//     //     // if ((LPAYAmt >= 3) and (gRefund = false)) then begin
//     //     //     TenderChargeSelect := TenderCharge(POSTransaction_TP."Store No.", TenderType, CurrInput, lTmp, CardType);
//     //     //     if TenderChargeSelect = -1 then
//     //     //         exit;

//     //     //     case TenderChargeSelect of
//     //     //         0: //CHARGE_ZERO
//     //     //             ;
//     //     //         1: //CHARGE_ACCEPTED
//     //     //             begin
//     //     //                 if CurrInput <> '' then begin
//     //     //                     if not Evaluate(lOldCurrInput, CurrInput) then begin
//     //     //                         ErrorBeep(Text101);
//     //     //                         exit;
//     //     //                     end;
//     //     //                 end else
//     //     //                     lOldCurrInput := 0;

//     //     //                 CurrInput := Format(lTmp.Amount3); //Charge

//     //     //                 if lTmp.Amount3 <> 0 then
//     //     //                     IncExpPressed(lTmp."Sort Code");   //Charge Account

//     //     //                 if lOldCurrInput > lTmp."Sales Amount" then
//     //     //                     CurrInput := Format(lOldCurrInput)
//     //     //                 else
//     //     //                     CurrInput := Format(lTmp."Sales Amount");
//     //     //                 PaymentAmount := lTmp."Sales Amount";
//     //     //             end;
//     //     //         2: //CHARGE_CANCEL
//     //     //             exit;
//     //     //         else begin
//     //     //             ErrorBeep(Text719);
//     //     //             exit;
//     //     //         end;
//     //     //     end;
//     //     // end;

//     //     NewBalance := ROUND(BalanceOut_L, 0.01, '=');
//     //     //MCS Added Surcharge++

//     //     EFTPOSPopup.SETGlobalVar(POSTransaction_TP."Receipt No.", NewBalance, gCashOutAmt, POSTransaction_TP, gRefund, PCashoutEnabled, CCSPCT, SurChargeTender);
//     //     if MenuLine.Parameter = '' then
//     //         lCloseCommand := EFTPOSPopup.ShowPanel;

//     //     //update:kevin
//     //     // if lCloseCommand = 'OK' then begin
//     //     //     EFTPOSPopup.GETGlobalVar(POSTransaction_TP."Receipt No.", BalanceOut_L, gCashOutAmt, POSTransaction_TP, gRefund, PCashoutEnabled, SurChargeAmount, SurChargeTender);
//     //     //     Clear(RespCode);
//     //     //     EFTPOSCaptureResp.SetParamsPurchAuth(BalanceOut_L, gCashOutAmt, gRefund, not EFTSetup."Debug Mode");
//     //     //     //MCS1.07 Jira 1787>>>
//     //     //     //EFTPOSCaptureResp.RUNMODAL;
//     //     //     EFTPOSCaptureResp.Run;
//     //     //     //MCS1.07 Jira 1787<<<
//     //     //     RespCode := EFTPOSCaptureResp.GetResponse;
//     //     // end;

//     //     // if lCloseCommand = 'CANCEL' then begin
//     //     //     //MCS Added++
//     //     //     lPOSTransLine_Exp.Reset;
//     //     //     lPOSTransLine_Exp.SetRange("Receipt No.", POSTransaction_TP."Receipt No.");
//     //     //     lPOSTransLine_Exp.SetRange("Entry Type", lPOSTransLine_Exp."entry type"::IncomeExpense);
//     //     //     lPOSTransLine_Exp.SetRange(Number, TenderType_TG."Charge to Account No.");
//     //     //     if lPOSTransLine_Exp.FindFirst then
//     //     //         lPOSTransLine_Exp.Delete;
//     //     //     //MCS Added++
//     //     //     EFTPOSPopup.RevertBalance(LPAYAmt);
//     //     //     //Balance := LPAYAmt;
//     //     //     gCashOutAmt := 0;
//     //     // end;

//     //     // if EFTRespCodes.Get(EFTSetup."Interface Type", EFTSetup."Country Code", EFTSetup."Bank Name", RespCode) then begin
//     //     //     if EFTRespCodes.Approve then begin
//     //     //         CardEntry_TG.Reset;
//     //     //         CardEntry_TG.SetCurrentkey("Store No.", "POS Terminal No.", "Receipt No.");
//     //     //         CardEntry_TG.SetRange("Store No.", POSTransaction_TP."Store No.");
//     //     //         CardEntry_TG.SetRange("POS Terminal No.", POSTransaction_TP."POS Terminal No.");
//     //     //         CardEntry_TG.SetRange("Receipt No.", POSTransaction_TP."Receipt No.");
//     //     //         if CardEntry_TG.FindLast then begin
//     //     //             if gRefund and POSTransaction_TP."Sale Is Return Sale" then
//     //     //                 PaymentAmount_L := -CardEntry_TG.Amount
//     //     //             else
//     //     //                 PaymentAmount_L := CardEntry_TG.Amount;
//     //     //         end;

//     //     //         PaymentAmount_L := POSFunction_CG.RoundTender(TenderType_TG, PaymentAmount_L);
//     //     //         AdjustAmountToShow(PaymentAmount_L);

//     //     //         POSTransaction_CG.TenderKeyPressedEx(TenderType_TG.Code, Format(PaymentAmount_L));
//     //     //         exit(lCloseCommand);
//     //     //     end
//     //     //     else begin
//     //     //         EFTPOSPopup.RevertBalance(LPAYAmt);
//     //     //         //Balance := LPAYAmt;
//     //     //         gCashOutAmt := 0;
//     //     //     end;
//     //     // end;

//     //     exit(lCloseCommand);
//     // end;

//     // procedure EFTPOSDoLastTrans(POSTransaction_TP: Record "LSC POS Transaction"; RunFromStartup: Boolean) lCloseCommand: Code[20]
//     // var
//     //     EFTPOSPopup: Codeunit "EFT EFTPOS POS Popup";
//     //     RespCode: Code[20];
//     //     EFTPOSCaptureResp: Codeunit "EFT EFTPOS Capture";
//     //     EFTRespCodes: Record "EFTPOS Approval Code List";
//     //     EFTSetup: Record "EFTPOS Setup";
//     //     LOCCardEntry: Record "LSC POS Card Entry";
//     //     LPAYAmt: Decimal;
//     //     PaymentAmount_L: Decimal;
//     // begin
//     //     // MPG1.00
//     //     if not EFTSetup.Get then
//     //         exit;
//     //     lCloseCommand := '';
//     //     RespCode := '';
//     //     Store_TG.Get(POSTransaction_TP."Store No.");
//     //     TenderType_TG.Get(Store_TG."No.", 'CR_EFTPOS');
//     //     Clear(EFTPOSCaptureResp);
//     //     EFTPOSCaptureResp.SetMode(4);
//     //     EFTPOSCaptureResp.SetPOSTrans(POSTransaction_TP);
//     //     if EFTPOSCaptureResp.CheckRequest then begin
//     //         /*IF NOT PosConfirm(EFTPOSTxt002,FALSE) THEN BEGIN
//     //           lCloseCommand := 'CANCEL';
//     //           EXIT(lCloseCommand);
//     //         END;*/
//     //         //MCS1.07 Jira 1787>>>>
//     //         //EFTPOSCaptureResp.RUNMODAL;
//     //         EFTPOSCaptureResp.Run;
//     //         //MCS1.07 Jira 1787<<<<
//     //         RespCode := EFTPOSCaptureResp.GetResponse;
//     //     end
//     //     else begin
//     //         RespCode := '';
//     //         if not RunFromStartup then
//     //             POSTransaction_CG.PosMessage('No request found');
//     //         lCloseCommand := 'CANCEL';
//     //         exit(lCloseCommand);
//     //     end;

//     //     if (RespCode = '00') or (RespCode = '08') then begin
//     //         lCloseCommand := 'OK';
//     //     end;

//     //     if EFTRespCodes.Get(EFTSetup."Interface Type", EFTSetup."Country Code", EFTSetup."Bank Name", RespCode) then begin
//     //         if EFTRespCodes.Approve then begin
//     //             CardEntry_TG.Reset;
//     //             CardEntry_TG.SetCurrentkey("Store No.", "POS Terminal No.", "Receipt No.");
//     //             CardEntry_TG.SetRange("Store No.", POSTransaction_TP."Store No.");
//     //             CardEntry_TG.SetRange("POS Terminal No.", POSTransaction_TP."POS Terminal No.");
//     //             CardEntry_TG.SetRange("Receipt No.", POSTransaction_TP."Receipt No.");
//     //             if CardEntry_TG.FindLast then begin
//     //                 if gRefund and POSTransaction_TP."Sale Is Return Sale" then
//     //                     PaymentAmount_L := -CardEntry_TG.Amount
//     //                 else
//     //                     PaymentAmount_L := CardEntry_TG.Amount;
//     //             end;
//     //             //gInsertTmpPayment := false;
//     //             if EFTRespCodes."Force Get Last Transaction" then;

//     //             // InitNewLine;
//     //             // InsertPaymentLine;
//     //             POSTransaction_CG.TenderKeyPressedEx(TenderType_TG.Code, Format(PaymentAmount_L));
//     //             exit(lCloseCommand);
//     //         end;
//     //     end;
//     //     //CalcTotals;

//     //     exit(lCloseCommand);

//     // end;

//     // procedure EFTPOSPrintLastReceipt(POSTransaction_TP: Record "LSC POS Transaction"; MenuLine: Record "LSC POS Menu Line") lCloseCommand: Code[20]
//     // var
//     //     EFTPOSCaptureResp: Codeunit "EFT EFTPOS Capture";
//     //     RespCode: Code[20];
//     // begin
//     //     // MPG1.00
//     //     Clear(EFTPOSCaptureResp);
//     //     lCloseCommand := '';
//     //     RespCode := '';
//     //     EFTPOSCaptureResp.SetMode(3);
//     //     EFTPOSCaptureResp.SetPOSTrans(POSTransaction_TP);
//     //     //MCS1.07 Jira 1787>>>>
//     //     //EFTPOSCaptureResp.RUNMODAL;
//     //     EFTPOSCaptureResp.Run;
//     //     //MCS1.07 Jira 1787<<<<
//     //     RespCode := EFTPOSCaptureResp.GetResponse;

//     //     lCloseCommand := 'OK';

//     //     exit(lCloseCommand);
//     // end;

//     // procedure EFTPOSSettlement(POSTransaction_TP: Record "LSC POS Transaction"; MenuLine: Record "LSC POS Menu Line"; PreSettleOrSettle: Integer) lCloseCommand: Code[20]
//     // var
//     //     EFTPOSCaptureResp: Codeunit "EFT EFTPOS Capture";
//     //     RespCode: Code[20];
//     // begin
//     //     // MPG1.00
//     //     // Run EFTPOS Settlement for PreSettle or Settle depending on the option passed.
//     //     Clear(EFTPOSCaptureResp);
//     //     lCloseCommand := '';
//     //     RespCode := '';
//     //     // Presettlement = 1 , Settlement = 2
//     //     EFTPOSCaptureResp.SetMode(PreSettleOrSettle);
//     //     EFTPOSCaptureResp.SetPOSTrans(POSTransaction_TP);
//     //     //MCS1.07 Jira 1787>>>>
//     //     //EFTPOSCaptureResp.RUNMODAL;
//     //     EFTPOSCaptureResp.Run;
//     //     //MCS1.07 Jira 1787<<<<
//     //     RespCode := EFTPOSCaptureResp.GetResponse;

//     //     lCloseCommand := 'OK';

//     //     exit(lCloseCommand);
//     // end;

//     // procedure EFTPOSDoReset(POSTransaction_TP: Record "LSC POS Transaction"; MenuLine: Record "LSC POS Menu Line") lCloseCommand: Code[20]
//     // var
//     //     EFTPOSCaptureResp: Codeunit "EFT EFTPOS Capture";
//     //     RespCode: Code[20];
//     // begin
//     //     // MPG1.00
//     //     Clear(EFTPOSCaptureResp);
//     //     lCloseCommand := '';
//     //     RespCode := '';
//     //     EFTPOSCaptureResp.SetMode(6);
//     //     EFTPOSCaptureResp.SetPOSTrans(POSTransaction_TP);
//     //     //MCS1.07 Jira 1787>>>>
//     //     //EFTPOSCaptureResp.RUNMODAL;
//     //     EFTPOSCaptureResp.Run;
//     //     //MCS1.07 Jira 1787<<<<
//     //     RespCode := EFTPOSCaptureResp.GetResponse;

//     //     lCloseCommand := 'OK';
//     // end;


//     // procedure EFTPOSDoAbout(POSTransaction_TP: Record "LSC POS Transaction"; MenuLine: Record "LSC POS Menu Line") lCloseCommand: Code[20]
//     // var
//     //     EFTPOSCaptureResp: Codeunit "EFT EFTPOS Capture";
//     //     RespCode: Code[20];
//     // begin
//     //     // MPG1.00
//     //     // Doesn't actually return anything from PCEFTPOS. Added just in case
//     //     Clear(EFTPOSCaptureResp);
//     //     lCloseCommand := '';
//     //     RespCode := '';
//     //     EFTPOSCaptureResp.SetMode(7);
//     //     EFTPOSCaptureResp.SetPOSTrans(POSTransaction_TP);
//     //     //MCS1.07 Jira 1787>>>>
//     //     //EFTPOSCaptureResp.RUNMODAL;
//     //     EFTPOSCaptureResp.Run;
//     //     //MCS1.07 Jira 1787<<<<
//     //     RespCode := EFTPOSCaptureResp.GetResponse;

//     //     lCloseCommand := 'OK';
//     // end;


//     // procedure EFTPOSLogon(POSTransaction_TP: Record "LSC POS Transaction"; MenuLine: Record "LSC POS Menu Line") lCloseCommand: Code[20]
//     // var
//     //     EFTPOSCaptureResp: Codeunit "EFT EFTPOS Capture";
//     //     RespCode: Code[20];
//     // begin
//     //     // MPG1.00
//     //     Clear(EFTPOSCaptureResp);
//     //     lCloseCommand := '';
//     //     RespCode := '';
//     //     EFTPOSCaptureResp.SetMode(5);
//     //     EFTPOSCaptureResp.SetPOSTrans(POSTransaction_TP);
//     //     //MCS1.07 Jira 1787>>>>
//     //     //EFTPOSCaptureResp.RUNMODAL;
//     //     EFTPOSCaptureResp.Run;
//     //     //MCS1.07 Jira 1787<<<<
//     //     RespCode := EFTPOSCaptureResp.GetResponse;

//     //     lCloseCommand := 'OK';
//     // end;


//     // procedure EFTPOSTendLastEFT(POSTransaction_TP: Record "LSC POS Transaction"; MenuLine: Record "LSC POS Menu Line") lCloseCommand: Code[20]
//     // var
//     //     EFTPOSCaptureResp: Codeunit "EFT EFTPOS Capture";
//     //     RespCode: Code[20];
//     // begin
//     //     // MPG1.00
//     //     Clear(EFTPOSCaptureResp);
//     //     lCloseCommand := '';
//     //     RespCode := '';
//     //     EFTPOSCaptureResp.SetMode(8);
//     //     EFTPOSCaptureResp.SetPOSTrans(POSTransaction_TP);
//     //     //MCS1.07 Jira 1787>>>>
//     //     //EFTPOSCaptureResp.RUNMODAL;
//     //     EFTPOSCaptureResp.Run;
//     //     //MCS1.07 Jira 1787<<<<
//     //     RespCode := EFTPOSCaptureResp.GetResponse;

//     //     lCloseCommand := 'OK';
//     // end;
//     // procedure InitNewLine(POSTransaction_P: Record "LSC POS Transaction")
//     // var
//     //     MenuTypeRec: Record "LSC Restaurant Menu Type";
//     // begin
//     //     Clear(NewLine_TG);
//     //     NewLine_TG."Store No." := POSTransaction_P."Store No.";
//     //     NewLine_TG."POS Terminal No." := POSTransaction_P."POS Terminal No.";
//     //     NewLine_TG."Receipt No." := POSTransaction_P."Receipt No.";

//     // end;

//     // procedure AdjustAmountToShow(var Value: Decimal)
//     // var
//     //     PosFuncProfile_LT: Record "LSC POS Func. Profile";
//     // begin
//     //     //Function to adjust amount to show on pop-up tender/qty form on the POS
//     //     PosFuncProfile_LT.Get(POSSession_CG.FunctionalityProfileID());
//     //     if PosFuncProfile_LT."Decimals in Entry" > 0 then
//     //         Value := Round(Value * Power(10, PosFuncProfile_LT."Decimals in Entry"));
//     // end;


//     [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS Transaction Events", 'OnBeforeVoidTransaction', '', true, true)]
//     procedure OnBeforeVoidTransaction(var POSTransaction: Record "LSC POS Transaction"; var IsHandled: Boolean)
//     begin
//         EFTPOSCheckVoidLine(POSTransaction."Receipt No.", 0);
//     end;

//     [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS Transaction Events", 'OnBeforeVoidLinePressedEx', '', true, true)]
//     procedure OnBeforeVoidLinePressedEx(var POSTrans: Record "LSC POS Transaction"; var POSTransLine: Record "LSC POS Trans. Line")
//     var
//         EFTSetup_LT: Record "EFTPOS Setup";
//         OtherEFTPayment_L: Decimal;
//     begin
//         if EFTSetup_LT.Get() then;
//         EFTPOSCheckVoidLine(POSTrans."Receipt No.", POSTransLine."Line No.");
//         if (POSTransLine."Entry Type" = POSTransLine."Entry Type"::Item) and (POSTransLine.Number = EFTSetup_LT."Cashout Item") then begin
//             OtherEFTPayment_L := GetPaymentAmount(POSTrans, EFTSetup_LT."EFT Tender", true);
//             if OtherEFTPayment_L <> 0 then begin
//                 POSTransaction_GC.ErrorBeep('You cannot cancel Cashout item if payment has been made.');
//             end;
//         end;
//     end;

//     procedure EFTPOSCheckVoidLine(ReceiptNo: Code[20]; LineNo_P: Integer)
//     var
//         PosTransLine_LT: Record "LSC POS Trans. Line";
//         EFTPOSTxt003: label 'You cannot void a payment line when the payment is already processed.';
//         EFTSetup_LT: Record "EFTPOS Setup";
//     begin
//         if EFTSetup_LT.Get() then;
//         // MPG1.00
//         PosTransLine_LT.Reset;
//         PosTransLine_LT.SetRange("Receipt No.", ReceiptNo);
//         PosTransLine_LT.SetRange("Entry Type", PosTransLine_LT."Entry Type"::Payment);
//         PosTransLine_LT.SetRange("Entry Status", PosTransLine_LT."Entry Status"::" ");
//         PosTransLine_LT.SetRange(Number, EFTSetup_LT."EFT Tender");
//         if LineNo_P <> 0 then
//             PosTransLine_LT.SetRange("Line No.", LineNo_P);
//         if PosTransLine_LT.FindFirst() then begin
//             POSTransaction_GC.ErrorBeep(EFTPOSTxt003);
//             Error(EFTPOSTxt003);
//         end;
//     end;

//     // procedure PrintEFTReceipt(Tray: Integer; var POSTrans: Record "LSC POS Transaction"; SubHeader: Boolean; MerchantCopyOnly: Boolean; FromEntryNo: Integer): Boolean
//     // var
//     //     POSEFTReceipt: Record "EFTPOS Receipt Text";
//     //     DSTR1: Text[100];
//     //     LineLength2: Integer;

//     //     QRPath: Text;
//     // begin
//     //     //MPG1.00
//     //     //PrintEFTREceipt
//     //     //PCEFTPOS-EDD6.2

//     //     //MCS1.09: PS-1890: Added parameters MerchantCopyOnly, FromEntryNo

//     //     //WindowInitialize();
//     //     if Tray = 2 then
//     //         LineLength2 := 40;
//     //     LineLen_G := 40;

//     //     POSEFTReceipt.Reset;
//     //     POSEFTReceipt.SetRange("Store No.", POSTrans."Store No.");
//     //     POSEFTReceipt.SetRange("POS Terminal No.", POSTrans."POS Terminal No.");
//     //     POSEFTReceipt.SetRange("Receipt Code", POSTrans."Receipt No.");
//     //     //>>MCS1.09: PS-1890
//     //     if FromEntryNo <> 0 then
//     //         POSEFTReceipt.SetFilter("Entry No.", '>%1', FromEntryNo);
//     //     if MerchantCopyOnly then
//     //         //<<MCS1.09: PS-1890
//     //         POSEFTReceipt.SetRange("Signature Required", true);//MCS1.02 JIRA PS-1755
//     //     //POSEFTReceipt.SETFILTER("EFTPOS Receipt Text",'<>%1','');
//     //     //MCS1.00 JIRA PS-1414>>>>
//     //     if not (POSEFTReceipt.Count > 1) then
//     //         exit(false);
//     //     //MCS1.00 JIRA PS-1414<<<<<
//     //     if POSEFTReceipt.FindFirst then begin
//     //         if not POSPrint_CG.OpenReceiptPrinter(2, 'SALES', '', 0, POSTrans."Receipt No.") then
//     //             exit(false);
//     //         if POSTrans."Receipt No." <> '' then
//     //             if SubHeader then begin
//     //                 POSPrint_CG.PrintBitmap(Tray, QRPath, 1);
//     //                 POSPrint_CG.PrintSeperator(2);
//     //                 PrintEFTSubHeader(POSTrans, 2, POSTrans."Trans. Date", POSTrans."Trans Time");
//     //             end;
//     //         repeat
//     //             DSTR1 := CopyStr('#C##############################', 1, LineLength2);//MCS1.00 JIRA PS-1414
//     //             Value[1] := CopyStr(POSEFTReceipt."EFTPOS Receipt Text", 1, 30);
//     //             POSPrint_CG.PrintLine(Tray, POSPrint_CG.FormatLine(POSPrint_CG.FormatStr(Value, DSTR1), false, false, false, false));
//     //         until POSEFTReceipt.Next = 0;
//     //         POSPrint_CG.PrintSeperator(2);
//     //         if not POSPrint_CG.ClosePrinter(2) then
//     //             exit(false);
//     //     end;

//     //     POSEFTReceipt.Reset;
//     //     POSEFTReceipt.SetRange("Store No.", POSTrans."Store No.");
//     //     POSEFTReceipt.SetRange("POS Terminal No.", POSTrans."POS Terminal No.");
//     //     POSEFTReceipt.SetRange("Receipt Code", POSTrans."Receipt No.");
//     //     //>>MCS1.09: PS-1890
//     //     if FromEntryNo <> 0 then
//     //         POSEFTReceipt.SetFilter("Entry No.", '>%1', FromEntryNo);
//     //     if MerchantCopyOnly then
//     //         //<<MCS1.09: PS-1890
//     //         POSEFTReceipt.SetRange("Signature Required", true);//MCS1.02 Jira PS-1755
//     //     if POSEFTReceipt.FindFirst then
//     //         POSEFTReceipt.DeleteAll;
//     //     exit(true);
//     // end;

//     // procedure PrintEFTSubHeader(var POSTransaction: Record "LSC POS Transaction"; Tray: Integer; PrDate: Date; PrTime: Time)
//     // var
//     //     Staff: Record "LSC Staff";
//     //     DSTR1: Text[100];
//     //     StaffName: Text[30];
//     //     blankStr: Text[30];

//     //     Text020: label 'Slip';
//     //     Text048: label 'Date';
//     //     Text16022371: label 'Store';
//     //     Text16022372: label 'POS';
//     //     Text051: label 'Staff';
//     // begin
//     //     //PrintEFTSubHeader
//     //     if Tray = 2 then
//     //         blankStr := POSPrint_CG.StringPad(' ', LineLen_G - 38)
//     //     else if Tray = 4 then
//     //         blankStr := POSPrint_CG.StringPad(' ', LineLen_G - 38);

//     //     Clear(Value);
//     //     DSTR1 := '#L##### #L#####################';
//     //     Value[1] := Text020 + ':';
//     //     Value[2] := POSTransaction."Receipt No.";
//     //     POSPrint_CG.PrintLine(Tray, POSPrint_CG.FormatLine(POSPrint_CG.FormatStr(Value, DSTR1), false, true, false, false));

//     //     Clear(Value);
//     //     DSTR1 := '#L#### #T###### #T###';
//     //     Value[1] := Text048 + ':';
//     //     Value[2] := Format(PrDate);
//     //     Value[3] := Format(PrTime, 5);
//     //     POSPrint_CG.PrintLine(Tray, POSPrint_CG.FormatLine(POSPrint_CG.FormatStr(Value, DSTR1), false, true, false, false));

//     //     Clear(Value);
//     //     DSTR1 := '#L#### #L######' + blankStr + '#L######### #R#########';
//     //     Value[1] := Text16022371 + ':';
//     //     Value[2] := Format(POSTransaction."Store No.");
//     //     Value[3] := Text16022372 + ':';
//     //     Value[4] := Format(POSTransaction."POS Terminal No.");
//     //     POSPrint_CG.PrintLine(Tray, POSPrint_CG.FormatLine(POSPrint_CG.FormatStr(Value, DSTR1), false, true, false, false));

//     //     Clear(Value);
//     //     DSTR1 := '#L#### #L######' + blankStr + '#L######### #N#########';
//     //     StaffName := POSTransaction."Staff ID";
//     //     if Staff.Get(POSTransaction."Staff ID") then
//     //         StaffName := Staff."Name on Receipt";
//     //     Value[1] := Text051 + ':';
//     //     Value[2] := StaffName;
//     //     Value[3] := '';
//     //     Value[4] := '';
//     //     POSPrint_CG.PrintLine(Tray, POSPrint_CG.FormatLine(POSPrint_CG.FormatStr(Value, DSTR1), false, true, false, false));
//     //     POSPrint_CG.PrintSeperator(Tray);
//     // end;

//     procedure EFTPOSV2(POSTransaction_PT: Record "LSC POS Transaction"; MenuLine: Record "LSC POS Menu Line") lCloseCommand: Code[20]
//     var

//         NewBalance_L: Decimal;
//         AmountInCurrencyOut_L: Decimal;
//         PaymentAmountOut_L: Decimal;
//         BalanceOut_L: Decimal;

//         PaymentAmount_L: Decimal;
//         CashoutEnabled_L: Boolean;
//         CCSPCT_L: Decimal;
//         SurChargeTender_L: Code[10];
//         SurChargeAmount: Decimal;

//         EFTSetup_LT: Record "EFTPOS Setup";
//         EFTPOSCaptureResp_LC: Codeunit "EFT EFTPOS Capture";
//         TenderType_TL: Record "LSC Tender Type";
//         Refund_L: Boolean;
//         EFTPOSPopup_LC: Codeunit "EFT EFTPOS POS Popup";
//         CashOutAmt_L: Decimal;
//         OtherEFTPayment_L: Decimal;
//     begin
//         Store_TG.Get(POSTransaction_PT."Store No.");
//         EFTSetup_LT.Get;
//         EFTSetup_LT.TestField("Capture Timeout (x 10 MS)");
//         TenderType_TL.Get(Store_TG."No.", EFTSetup_LT."EFT Tender");

//         Clear(EFTPOSCaptureResp_LC);
//         EFTPOSCaptureResp_LC.SetMode(0); //PurchaseAutorisation/DoTransaction
//         EFTPOSCaptureResp_LC.SetPOSTrans(POSTransaction_PT);
//         EFTPOSCaptureResp_LC.InitRequest();
//         //if EFTPOSCaptureResp_LC.CheckRequest() then
//         //    exit(EFTPOSDoLastTrans(POSTransaction_TP, false));

//         if not TenderType_TL."May Be Used" then begin
//             POSTransaction_GC.ErrorBeep(Text095);
//             exit;
//         end;
//         if POSView_CG.GetTrainingMode() and (TenderType_TL."Function" = TenderType_TL."function"::Card) then begin
//             POSTransaction_GC.ErrorBeep(Text096);
//             exit;
//         end;
//         if POSTransaction_GC.GetPosState() <> 'PAYMENT' then begin
//             POSTransaction_GC.ErrorBeep(Text097);
//             exit;
//         end;

//         POSTransaction_GC.GetAmtAndBalance(AmountInCurrencyOut_L, PaymentAmountOut_L, BalanceOut_L);
//         NewBalance_L := ROUND(BalanceOut_L, 0.01, '=');

//         if (POSTransaction_PT."Sale Is Return Sale") and (BalanceOut_L > 0) then
//             Refund_L := true;
//         if (POSTransaction_PT."Sale Is Return Sale") and (BalanceOut_L < 0) then
//             Refund_L := false;

//         if (not POSTransaction_PT."Sale Is Return Sale") and (BalanceOut_L < 0) then
//             Refund_L := true;
//         if (not POSTransaction_PT."Sale Is Return Sale") and (BalanceOut_L > 0) then
//             Refund_L := false;

//         //MCS.KB 1099:Cash out in POS
//         CashOutAmt_L := GetCashoutAmount(POSTransaction_PT);
//         if CashOutAmt_L <> 0 then begin
//             OtherEFTPayment_L := GetPaymentAmount(POSTransaction_PT, EFTSetup_LT."EFT Tender", true);
//             CashOutAmt_L := CashOutAmt_L - OtherEFTPayment_L;
//         end;
//         NewBalance_L := NewBalance_L - CashOutAmt_L;

//         Clear(EFTPOSPopup_LC);
//         EFTPOSPopup_LC.SETGlobalVar(POSTransaction_PT."Receipt No.", NewBalance_L, CashOutAmt_L, POSTransaction_PT, Refund_L, CashoutEnabled_L, CCSPCT_L, SurChargeTender_L);
//         EFTPOSPopup_LC.ShowPanel;
//     end;

//     // procedure LogMessage(Message: Text[500])
//     //     FormattedDateTime: Text[200]
//     // begin
//     //     Commit();
//     //     FormattedDateTime := FORMAT(CurrentDateTime, 0, '<Day,2>/<Month,2>/<Year4> <Hours24,2>:<Minutes,2>:<Seconds,2>.<Thousands,3>');
//     //     LogEntry.Init();
//     //     LogEntry.FormattedDateTime := FormattedDateTime;
//     //     LogEntry."CreatedDateTime" := CurrentDateTime();
//     //     LogEntry."Message" := Message;
//     //     LogEntry.Insert();
//     // end;

//     // [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS Print Utility", 'OnBeforeSalesSlipPrintFooter', '', true, true)]
//     // procedure OnBeforeSalesSlipPrintFooter(var TransactionHeader: Record "LSC Transaction Header"; var POSPrintBuffer: Record "LSC POS Print Buffer"; var PrintBufferIndex: Integer; var LinesPrinted: Integer);
//     // var
//     //     EFTReceiptData: Record "EFTPOS Receipt Text";
//     //     PosSetup: Record "LSC POS Hardware Profile";
//     // begin
//     //     EFTReceiptData.RESET;
//     //     EFTReceiptData.SETRANGE("Receipt Code", TransactionHeader."Receipt No.");
//     //     //MCS.EC.25022025.1 Devops 897 POS _ Issue while Printing slips during card (EFTPOS) payment
//     //     IF EFTReceiptData.FINDFIRST THEN BEGIN
//     //         PrintBufferIndex += 5; //20
//     //         LinesPrinted += 5; //20
//     //         PrintEFTInfo(TransactionHeader, POSPrintBuffer, PrintBufferIndex, LinesPrinted);
//     //     END;
//     // end;

//     // [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS Print Utility", 'OnAfterPrintSalesSlip', '', true, true)]
//     // procedure OnAfterPrintSalesSlip(var TransactionHeader: Record "LSC Transaction Header"; var POSPrintBuffer: Record "LSC POS Print Buffer"; var PrintBufferIndex: Integer; var LinesPrinted: Integer; Var VoidedVoucher: Boolean; Var FieldValue: array[10] of Text[100]; Var NodeName: array[32] of Text[50]; ActiveTray: Integer; Var POSFunctions: Codeunit "LSC POS Functions"; Var CpnPrinting: Boolean; Var Globals: Codeunit "LSC POS Session"; Var CpnBarcodeMaskSymbology: Text[30]; Var CouponPrinting: Boolean)
//     // var
//     //     EFTReceiptData: Record "EFTPOS Receipt Text";
//     //     PosSetup: Record "LSC POS Hardware Profile";
//     // begin
//     //     EFTReceiptData.RESET;
//     //     EFTReceiptData.SETRANGE("Receipt Code", TransactionHeader."Receipt No.");
//     //     //MCS.EC.25022025.1 Devops 897 POS _ Issue while Printing slips during card (EFTPOS) payment
//     //     IF EFTReceiptData.FINDFIRST THEN BEGIN
//     //         PrintBufferIndex += 1; //20
//     //         LinesPrinted += 1; //20
//     //         PrintEFTInfo(TransactionHeader, POSPrintBuffer, PrintBufferIndex, LinesPrinted);
//     //     END;
//     // end;

//     // procedure PrintEFTInfo(var TransactionHeader: Record "LSC Transaction Header"; var POSPrintBuffer: Record "LSC POS Print Buffer"; var PrintBufferIndex: Integer; var LinesPrinted: Integer)
//     // var
//     //     EFTReceiptL: Record "EFTPOS Receipt Text";
//     //     DSTR1: Text[100];
//     //     LineLength: Integer;
//     //     POSPrint_LC: Codeunit "LSC POS Print Utility";
//     // begin
//     //     //PrintEFtInfo
//     //     //PCEFTPOS-EDD6.2

//     //     LineLength := 30;

//     //     EFTReceiptL.Reset;
//     //     EFTReceiptL.SetRange("Store No.", TransactionHeader."Store No.");
//     //     EFTReceiptL.SetRange("POS Terminal No.", TransactionHeader."POS Terminal No.");
//     //     EFTReceiptL.SetRange("Receipt Code", TransactionHeader."Receipt No.");

//     //     if EFTReceiptL.FindFirst then begin
//     //         repeat
//     //             DSTR1 := CopyStr('#C##############################', 1, LineLength); //TEC2.12//MCS1.00 JIRA PS-1414

//     //             Value[1] := CopyStr(EFTReceiptL."EFTPOS Receipt Text", 1, 30); //TEC2.12

//     //             AddPrintLine(POSPrintBuffer, PrintBufferIndex, LinesPrinted, 2, POSPrint_LC.FormatLine(POSPrint_LC.FormatStr(Value, DSTR1), false, false, false, false), false);
//     //         until EFTReceiptL.Next = 0;
//     //         PrintBufferIndex += 1;
//     //         LinesPrinted += 1;
//     //         //MCS.EC.25022025.1 Devops 897 POS _ Issue while Printing slips during card (EFTPOS) payment
//     //         AddPrintLine(POSPrintBuffer, PrintBufferIndex, LinesPrinted, 2, '', true);
//     //         //PrintSeperator(2);
//     //     end;

//     //     // EFTReceiptL.Reset;
//     //     // EFTReceiptL.SetRange("Store No.", TransactionHeader."Store No.");
//     //     // EFTReceiptL.SetRange("POS Terminal No.", TransactionHeader."POS Terminal No.");
//     //     // EFTReceiptL.SetRange("Receipt Code", TransactionHeader."Receipt No.");
//     //     // if EFTReceiptL.FindFirst then
//     //     //     EFTReceiptL.DeleteAll;
//     // end;

//     procedure AddPrintLine(
//         var POSPrintBuffer: Record "LSC POS Print Buffer";
//         var PrintBufferIndex: Integer;
//         var LinesPrinted: integer;
//         Tray: Integer;
//         TxtLine: Text;
//         CutPrinter_P: Boolean)
//     var
//         CurrentPrinter: Record "LSC POS Printer";
//         DesignTxt: Text;
//         DeviceID: Code[20];
//         i: Integer;
//         DesignPos: Integer;
//         NoOfLinesOnInvoice: Integer;
//         IsHandled: Boolean;
//         Text097: Label 'Please insert new page in printer.';
//         //POSPrintBuffer_l: Record "LSC POS Print Buffer" temporary;
//         LastEntryNo_l: Integer;
//     begin
//         DesignPos := StrPos(TxtLine, '<#DESN>');
//         if DesignPos > 0 then begin
//             DesignTxt := CopyStr(TxtLine, DesignPos + 7);
//             TxtLine := CopyStr(TxtLine, 1, DesignPos - 1);
//         end;
//         // PrintBufferIndex += 1;
//         POSPrintBuffer.Init;
//         POSPrintBuffer."Buffer Index" := PrintBufferIndex;
//         POSPrintBuffer."Station No." := Tray;
//         POSPrintBuffer."Page No." := 0;
//         POSPrintBuffer."Entry No." := 1;
//         POSPrintBuffer."Printed Line No." := LinesPrinted;
//         POSPrintBuffer.LineType := POSPrintBuffer.LineType::PrintLine;
//         if CutPrinter_P then
//             POSPrintBuffer.LineType := POSPrintBuffer.LineType::EndTransaction
//         else
//             POSPrintBuffer.LineType := POSPrintBuffer.LineType::PrintLine;
//         POSPrintBuffer.Text := TxtLine;
//         POSPrintBuffer.FontType := POSPrintBuffer.FontType::Normal;
//         POSPrintBuffer.DesignText := DesignTxt;
//         POSPrintBuffer.Insert;
//         //LinesPrinted := LinesPrinted + 1;
//     end;

//     // procedure AddPrintLine(
//     //     var POSPrintBuffer: Record "LSC POS Print Buffer";
//     //     var PrintBufferIndex: Integer;
//     //     var LinesPrinted: integer;
//     //     Tray: Integer;
//     //     TxtLine: Text;
//     //     CutPrinter: Boolean)
//     // var
//     //     CurrentPrinter: Record "LSC POS Printer";
//     //     DesignTxt: Text;
//     //     DeviceID: Code[20];
//     //     i: Integer;
//     //     DesignPos: Integer;
//     //     NoOfLinesOnInvoice: Integer;
//     //     IsHandled: Boolean;
//     //     Text097: Label 'Please insert new page in printer.';
//     //     //POSPrintBuffer_l: Record "LSC POS Print Buffer" temporary;
//     //     LastEntryNo_l: Integer;
//     //     POSPrintBuffer_L: Record "LSC POS Print Buffer" temporary;
//     // begin

//     //     DesignPos := StrPos(TxtLine, '<#DESN>');
//     //     if DesignPos > 0 then begin
//     //         DesignTxt := CopyStr(TxtLine, DesignPos + 7);
//     //         TxtLine := CopyStr(TxtLine, 1, DesignPos - 1);
//     //     end;
//     //     PrintBufferIndex += 1;
//     //     POSPrintBuffer_L.Reset();
//     //     POSPrintBuffer_L.DeleteAll();
//     //     POSPrintBuffer_L.Init;

//     //     POSPrintBuffer_L."Buffer Index" := PrintBufferIndex;
//     //     POSPrintBuffer_L."Station No." := POSPrintBuffer."Station No.";
//     //     POSPrintBuffer_L."Page No." := POSPrintBuffer."Page No.";
//     //     POSPrintBuffer_L."Printed Line No." := LinesPrinted;
//     //     if CutPrinter then
//     //         POSPrintBuffer_L.LineType := POSPrintBuffer_L.LineType::EndTransaction
//     //     else
//     //         POSPrintBuffer_L.LineType := POSPrintBuffer_L.LineType::PrintLine;
//     //     POSPrintBuffer_L.Text := TxtLine;
//     //     POSPrintBuffer_L.FontType := POSPrintBuffer_L.FontType::Normal;
//     //     POSPrintBuffer_L.DesignText := DesignTxt;
//     //     POSPrintBuffer.TransferFields(POSPrintBuffer_L);
//     //     POSPrintBuffer.Insert();
//     //     LinesPrinted := LinesPrinted + 1;
//     // end;

//     [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS Print Utility", 'OnAfterPrintSlips', '', true, true)]
//     procedure OnAfterPrintSlips(var Transaction: Record "LSC Transaction Header"; var PrintBuffer: Record "LSC POS Print Buffer"; var PrintBufferIndex: Integer; var LinesPrinted: Integer; var MsgTxt: Text[50]; PrintSlip: Boolean; var ReturnValue: Boolean)
//     var
//         EFTReceiptData_LT: Record "EFTPOS Receipt Text";
//         EFTReceipt_LT: Record "EFTPOS Receipt Text";
//         POSPrint_LC: Codeunit "LSC POS Print Utility";
//         DSTR1_L: Text[100];
//         LineLength_L: Integer;
//         Tray_L: Integer;
//     begin
//         Tray_L := 2;
//         if not PrintSlip then
//             exit;
//         EFTReceiptData_LT.RESET;
//         EFTReceiptData_LT.SETRANGE("Receipt Code", Transaction."Receipt No.");
//         IF EFTReceiptData_LT.FINDFIRST THEN BEGIN
//             POSPrint_LC.WindowInitialize();
//             if not POSPrint_LC.OpenReceiptPrinter(Tray_L, 'SALES', '', Transaction."Transaction No.", Transaction."Receipt No.") then
//                 exit;

//             EFTReceipt_LT.Reset;
//             EFTReceipt_LT.SetRange("Store No.", Transaction."Store No.");
//             EFTReceipt_LT.SetRange("POS Terminal No.", Transaction."POS Terminal No.");
//             EFTReceipt_LT.SetRange("Receipt Code", Transaction."Receipt No.");
//             if EFTReceipt_LT.FindFirst then begin
//                 LineLength_L := 40;
//                 repeat
//                     DSTR1_L := CopyStr('#C##############################', 1, LineLength_L);
//                     Value[1] := CopyStr(EFTReceipt_LT."EFTPOS Receipt Text", 1, LineLength_L);
//                     POSPrint_LC.PrintLine(Tray_L, POSPrint_LC.FormatLine(POSPrint_LC.FormatStr(Value, DSTR1_L), false, false, false, false));
//                 until EFTReceipt_LT.Next = 0;
//                 POSPrint_LC.PrintSeperator(2);
//             end;
//             if not POSPrint_LC.ClosePrinter(Tray_L) then
//                 exit;
//         END;
//     end;


//     //MCS.KB 1099:Cash out in POS
//     [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS Transaction", 'OnAfterKeyboardTriggerToProcess', '', false, false)]
//     local procedure OnAfterKeyboardTriggerToProcess(InputValue: Text; KeyboardTriggerToProcess: Integer; var Rec: Record "LSC POS Transaction"; var IsHandled: Boolean)
//     var
//         EFTPOSSetup_LT: Record "EFTPOS Setup";
//         POSTransaction_LC: Codeunit "LSC POS Transaction";
//         POSSession_LC: Codeunit "LSC POS Session";
//         CashoutAmount_L: Decimal;
//         ErrorLbl_L: Label 'Please enter valid amount';
//     begin
//         case KeyboardTriggerToProcess of
//             50130:
//                 begin
//                     IsHandled := true;
//                     if InputValue = '' then begin
//                         POSTransaction_LC.PosErrorBanner(ErrorLbl_L);
//                         exit;
//                     end;
//                     if not Evaluate(CashoutAmount_L, InputValue) then begin
//                         POSTransaction_LC.PosErrorBanner(ErrorLbl_L);
//                         exit;
//                     end;
//                     EFTPOSSetup_LT.Get();
//                     POSSession_LC.SetValue('CASHOUT_AMOUNT', InputValue);
//                     POSTransaction_LC.PluKeyPressed(EFTPOSSetup_LT."Cashout Item");
//                 end;
//         end;
//     end;

//     //MCS.KB 1099:Cash out in POS
//     [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS Transaction Events", 'OnAfterInsertItemLine', '', false, false)]
//     procedure OnAfterInsertItemLine(var POSTransaction: Record "LSC POS Transaction"; var POSTransLine: Record "LSC POS Trans. Line"; var CurrInput: Text)
//     var
//         EFTPOSSetup_LT: Record "EFTPOS Setup";
//         POSSession_LC: Codeunit "LSC POS Session";
//         POSTransaction_LC: Codeunit "LSC POS Transaction";
//         CashoutAmount_L: Text;
//         CashoutAmountDec_L: Decimal;
//     begin
//         EFTPOSSetup_LT.Get();
//         if EFTPOSSetup_LT."Cashout Item" = POSTransLine.Number then begin
//             CashoutAmount_L := POSSession_LC.GetValue('CASHOUT_AMOUNT');
//             // if Evaluate(CashoutAmountDec_L, CashoutAmount_L) then begin
//             //     POSTransLine."EFT Cashout Amount" := CashoutAmountDec_L;
//             //     POSTransLine.Modify();
//             // end;
//             if CashoutAmount_L <> '' then begin
//                 if Evaluate(CashoutAmountDec_L, CashoutAmount_L) then;
//                 POSTransaction_LC.ChangePricePressed(CashoutAmount_L);
//                 POSSession_LC.SetValue('CASHOUT_AMOUNT', '');
//                 POSTransLine."EFT Cashout Amount" := CashoutAmountDec_L;
//                 POSTransLine.Modify();
//             end;
//         end;
//     end;

//     //MCS.KB 1099:Cash out in POS
//     [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS Transaction Events", 'OnBeforeInsertPaymentLine', '', false, false)]
//     local procedure OnBeforeInsertPaymentLine(var POSTransaction: Record "LSC POS Transaction"; var POSTransLine: Record "LSC POS Trans. Line"; var CurrInput: Text; var TenderTypeCode: Code[10]; Balance: decimal; PaymentAmount: Decimal; STATE: Code[10]; var isHandled: Boolean)
//     var
//         CardEntry_LT: Record "LSC POS Card Entry";
//         POSTransaction_LC: Codeunit "LSC POS Transaction";
//         EFTSetup_LT: Record "EFTPOS Setup";
//         Cashamount_L: Decimal;
//         OtherEFTPayment_L: Decimal;
//         OtherNonEFTPayment_L: Decimal;
//         GrossNetOfCashOut_L: Decimal;
//         EFTTender_L: Code[20];
//         OverPaymentErrLbl_L: Label 'Overpayment not allowed. Total payment should be %1';
//         MinPaymentErrLbl_L: Label 'Minimum payment should be %1';
//     begin
//         if EFTSetup_LT.Get() then;
//         EFTTender_L := EFTSetup_LT."EFT Tender";

//         if TenderTypeCode = EFTTender_L then begin
//             CardEntry_LT.Reset;
//             CardEntry_LT.SetCurrentkey("Store No.", "POS Terminal No.", "Receipt No.");
//             CardEntry_LT.SetRange("Store No.", POSTransaction."Store No.");
//             CardEntry_LT.SetRange("POS Terminal No.", POSTransaction."POS Terminal No.");
//             CardEntry_LT.SetRange("Receipt No.", POSTransaction."Receipt No.");
//             if CardEntry_LT.FindLast then begin
//                 POSTransLine."Card Type" := CardEntry_LT."Card Type";
//             end;
//         end;

//         Cashamount_L := GetCashoutAmount(POSTransaction);
//         if Cashamount_L <> 0 then begin
//             if TenderTypeCode = EFTTender_L then begin
//                 OtherEFTPayment_L := GetPaymentAmount(POSTransaction, EFTTender_L, true);
//                 if (OtherEFTPayment_L + PaymentAmount) < Cashamount_L then begin
//                     POSTransaction_LC.ErrorBeep(StrSubstNo(MinPaymentErrLbl_L, Cashamount_L - OtherEFTPayment_L));
//                     isHandled := true;
//                     exit;
//                 end;
//             end else begin
//                 GrossNetOfCashOut_L := POSTransaction."Gross Amount" - Cashamount_L;
//                 OtherNonEFTPayment_L := GetPaymentAmount(POSTransaction, EFTTender_L, false);
//                 if (OtherNonEFTPayment_L + PaymentAmount) > GrossNetOfCashOut_L then begin
//                     OtherEFTPayment_L := GetPaymentAmount(POSTransaction, EFTTender_L, true);
//                     if OtherEFTPayment_L < Cashamount_L then begin
//                         POSTransaction_LC.ErrorBeep(StrSubstNo(OverPaymentErrLbl_L, GrossNetOfCashOut_L));
//                         isHandled := true;
//                         exit;
//                     end;
//                 end;
//             end;
//         end;
//     end;

//     [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS Transaction Events", 'OnBeforeInsertLineInsertPaymentLine', '', false, false)]
//     internal procedure OnBeforeInsertLineInsertPaymentLine(var POSTransaction: Record "LSC POS Transaction"; var POSTransLine: Record "LSC POS Trans. Line"; var CurrInput: Text; var TenderTypeCode: Code[10]; Balance: decimal; PaymentAmount: Decimal; STATE: Code[10]; var isHandled: Boolean)
//     var
//         EFTSetup_LT: Record "EFTPOS Setup";
//         Cashamount_L: Decimal;
//     begin
//         if EFTSetup_LT.Get() then;
//         if TenderTypeCode <> EFTSetup_LT."Cashout Tender" then
//             exit;
//         Cashamount_L := GetCashoutAmount(POSTransaction);
//         if Cashamount_L <> 0 then begin
//             if POSSession_CG.GetValue('EFTCASHOUT') = '1' then begin
//                 POSTransLine."EFT Cashout Amount" := Cashamount_L;
//             end;
//         end;

//     end;

//     [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS Transaction Events", 'OnAfterInsertPaymentLine', '', false, false)]
//     internal procedure OnAfterInsertPaymentLine(var POSTransaction: Record "LSC POS Transaction"; var POSTransLine: Record "LSC POS Trans. Line"; var CurrInput: Text; var TenderTypeCode: Code[10]; var SkipCommit: Boolean)
//     var
//         POSTransLine_LT: Record "LSC POS Trans. Line";
//         EFTSetup_LT: Record "EFTPOS Setup";
//         Cashamount_L: Decimal;
//     begin
//         if EFTSetup_LT.Get() then;
//         if (POSTransLine."EFT Cashout Amount" <> 0) and (EFTSetup_LT."Cashout Tender" = TenderTypeCode) then begin
//             SkipCommit := true;
//             exit;
//         end;
//         if TenderTypeCode <> EFTSetup_LT."EFT Tender" then
//             exit;

//         Cashamount_L := GetCashoutAmount(POSTransaction);
//         if Cashamount_L <> 0 then begin
//             POSTransLine_LT.Reset();
//             POSTransLine_LT.SetRange("Receipt No.", POSTransaction."Receipt No.");
//             POSTransLine_LT.SetFilter("EFT Cashout Amount", '<>%1', 0);
//             POSTransLine_LT.SetRange("Entry Type", POSTransLine_LT."Entry Type"::Payment);
//             POSTransLine_LT.SetRange("Entry Status", POSTransLine_LT."Entry Status"::" ");
//             POSTransLine_LT.SetRange(Number, EFTSetup_LT."Cashout Tender");
//             if POSTransLine_LT.FindFirst() then begin
//                 POSTransLine_LT.VoidLine();
//             end;
//             POSSession_CG.SetValue('EFTCASHOUT', '1');
//             POSTransaction_GC.TenderKeyPressedEx(EFTSetup_LT."Cashout Tender", Format(Cashamount_L));
//             POSSession_CG.SetValue('EFTCASHOUT', '0');
//         end;
//     end;

//     //MCS.KB 1099:Cash out in POS
//     // [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS Transaction", 'OnBeforeOpenNumericKeyboardOnTenderKey', '', false, false)]
//     // procedure OnBeforeOpenNumericKeyboardOnTenderKey(var REC: Record "LSC POS Transaction"; TenderTypeCode: Code[10]; var PaymentAmount: Decimal)
//     // var
//     //     EFTSetup_LT: Record "EFTPOS Setup";
//     //     Cashamount_L: Decimal;
//     //     OtherEFTPayment_L: Decimal;
//     // begin
//     //     if EFTSetup_LT.Get() then;

//     //     if TenderTypeCode <> EFTSetup_LT."EFT Tender" then
//     //         exit;
//     //     Cashamount_L := GetCashoutAmount(REC);
//     //     if Cashamount_L = 0 then
//     //         exit;
//     //     OtherEFTPayment_L := GetPaymentAmount(REC, EFTSetup_LT."EFT Tender", true);
//     //     PaymentAmount := Cashamount_L - OtherEFTPayment_L;
//     // end;

//     //MCS.KB 1099:Cash out in POS
//     local procedure GetPaymentAmount(POSTransaction_PT: Record "LSC POS Transaction"; EFTTender_P: Code[20]; isEFTTender_P: Boolean): Decimal
//     var
//         POSTransLine_LT: Record "LSC POS Trans. Line";
//         PaymentAmount_L: Decimal;
//     begin
//         POSTransLine_LT.Reset();
//         POSTransLine_LT.SetRange("Receipt No.", POSTransaction_PT."Receipt No.");
//         POSTransLine_LT.SetRange("Store No.", POSTransaction_PT."Store No.");
//         POSTransLine_LT.SetRange("POS Terminal No.", POSTransaction_PT."POS Terminal No.");
//         POSTransLine_LT.SetRange("Entry Status", POSTransLine_LT."Entry Status"::" ");
//         POSTransLine_LT.SetRange("Entry Type", POSTransLine_LT."Entry Type"::Payment);
//         if isEFTTender_P then begin
//             POSTransLine_LT.SetRange(Number, EFTTender_P);
//         end else begin
//             POSTransLine_LT.SetFilter(Number, '<>%1', EFTTender_P);
//         end;
//         POSTransLine_LT.CalcSums(Amount);
//         PaymentAmount_L := POSTransLine_LT.Amount;
//         exit(PaymentAmount_L);
//     end;

//     //MCS.KB 1099:Cash out in POS
//     local procedure GetCashoutAmount(POSTransaction_PT: Record "LSC POS Transaction"): Decimal
//     var
//         POSTransLine_LT: Record "LSC POS Trans. Line";
//         EFTPOSSetup_LT: Record "EFTPOS Setup";
//         Amount_L: Decimal;
//     begin
//         EFTPOSSetup_LT.Get();
//         POSTransLine_LT.SetRange("Receipt No.", POSTransaction_PT."Receipt No.");
//         POSTransLine_LT.SetRange("Store No.", POSTransaction_PT."Store No.");
//         POSTransLine_LT.SetRange("POS Terminal No.", POSTransaction_PT."POS Terminal No.");
//         POSTransLine_LT.SetRange("Entry Status", POSTransLine_LT."Entry Status"::" ");
//         POSTransLine_LT.SetRange("Entry Type", POSTransLine_LT."Entry Type"::Item);
//         POSTransLine_LT.SetRange(Number, EFTPOSSetup_LT."Cashout Item");
//         POSTransLine_LT.CalcSums("EFT Cashout Amount");
//         Amount_L := POSTransLine_LT."EFT Cashout Amount";
//         exit(Amount_L);
//     end;

//     //MCS.KB 1099:Cash out in POS
//     [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS Print Utility", 'OnBeforePrintTotal', '', false, false)]
//     procedure OnBeforePrintTotal(var Transaction: Record "LSC Transaction Header"; var PrintBuffer: Record "LSC POS Print Buffer"; var PrintBufferIndex: Integer; var LinesPrinted: Integer; var DSTR1: Text[100]; var IsHandled: Boolean; var ReturnValue: Boolean; var PeriodicDiscountInfoTEMP: Record "LSC Periodic Discount" temporary; var SubTotal: Decimal; var Tray: Integer)
//     begin
//         POSSession_CG.SetValue('PRINT_RECEIPTNO', Transaction."Receipt No.");
//         POSSession_CG.SetValue('PRINT_STORENO', Transaction."Store No.");
//         POSSession_CG.SetValue('PRINT_TERMINALNO', Transaction."POS Terminal No.");
//     end;

//     //MCS.KB 1099:Cash out in POS
//     [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS Print Utility", 'OnBeforeSumTotalAmountToText', '', false, false)]
//     procedure OnBeforeSumTotalAmountToText(var TotalAmountText: Text[100]; TotalAmount: Decimal; var IsHandled: Boolean)
//     var
//         TranSalesEntry_LT: Record "LSC Trans. Sales Entry";
//         EFTPOSetup_LT: Record "EFTPOS Setup";
//         POSFunctions_LC: Codeunit "LSC POS Functions";
//         TotalCashOut_L: Decimal;
//     begin
//         if EFTPOSetup_LT.Get() then;
//         if EFTPOSetup_LT."Cashout Item" = '' then
//             exit;
//         TranSalesEntry_LT.SetRange("Receipt No.", POSSession_CG.GetValue('PRINT_RECEIPTNO'));
//         TranSalesEntry_LT.SetRange("Store No.", POSSession_CG.GetValue('PRINT_STORENO'));
//         TranSalesEntry_LT.SetRange("POS Terminal No.", POSSession_CG.GetValue('PRINT_TERMINALNO'));
//         TranSalesEntry_LT.SetRange("Item No.", EFTPOSetup_LT."Cashout Item");
//         if TranSalesEntry_LT.Find('-') then begin
//             repeat
//                 TotalCashOut_L += (-(TranSalesEntry_LT."Total Rounded Amt."));
//             until TranSalesEntry_LT.Next() = 0;
//         end;
//         if TotalCashOut_L <> 0 then begin
//             IsHandled := true;
//             TotalAmount -= TotalCashOut_L;
//             TotalAmountText := POSFunctions_LC.FormatAmount(TotalAmount);
//             POSSession_CG.SetValue('PRINT_RECEIPTNO', '');
//             POSSession_CG.SetValue('PRINT_STORENO', '');
//             POSSession_CG.SetValue('PRINT_TERMINALNO', '');
//         end;
//     end;

//     [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS Print Utility", 'OnBeforePrintXZLines', '', false, false)]
//     internal procedure OnBeforePrintXZLines(sender: Codeunit "LSC POS Print Utility"; var StaffID_p: Code[20]; var PrintBuffer: Record "LSC POS Print Buffer"; var PrintBufferIndex: Integer; var LinesPrinted: Integer; var DSTR1: Text[100]; var IsHandled: Boolean)
//     var
//         TenderType_LT: Record "LSC Tender Type";
//         PaymEntry_LT: Record "LSC Trans. Payment Entry";
//         Terminal_LT: Record "LSC POS Terminal";
//         POSSession_LC: Codeunit "LSC POS Session";
//         POSFunctions_LC: Codeunit "LSC POS Functions";
//         SCode_L: Code[20];
//         FieldValue_L: array[10] of Text[100];
//         DSTR1_L: Text[100];
//     begin
//         if StaffID_p <> '' then begin
//             Terminal_LT.Reset();
//             Terminal_LT.SetRange("Store No.", POSSession_LC.StoreNo());
//             Terminal_LT.SetRange("No.", POSSession_LC.TerminalNo());
//             if Terminal_LT.FindFirst() then;

//             SCode_L := POSFunctions_LC.GetStatementCode;
//             TenderType_LT.SetCurrentKey("Store No.");
//             TenderType_LT.SetRange("Store No.", POSSession_LC.StoreNo);
//             TenderType_LT.SetFilter("Function", '<>%1', TenderType_LT."Function"::"Tender Remove/Float");
//             TenderType_LT.SetRange("Foreign Currency", false);
//             if TenderType_LT.FindSet() then
//                 repeat
//                     DSTR1_L := '#L################# #R##################';
//                     Clear(FieldValue_L);
//                     PaymEntry_LT.Reset();
//                     PaymEntry_LT.SetCurrentKey("Statement Code", "Z-Report ID", "Tender Type", "Currency Code", "Card No.");
//                     PaymEntry_LT.SetRange("Statement Code", SCode_L);
//                     PaymEntry_LT.SetRange("Z-Report ID", '');
//                     if Terminal_LT."Terminal Statement" or (Terminal_LT."Statement Method" = Terminal_LT."Statement Method"::"POS Terminal") then
//                         PaymEntry_LT.SetRange("POS Terminal No.", Terminal_LT."No.");
//                     PaymEntry_LT.SetRange("Tender Type", TenderType_LT.Code);
//                     PaymEntry_LT.SetRange("Staff ID", StaffID_p);
//                     PaymEntry_LT.SetRange("Card No.");
//                     PaymEntry_LT.SetFilter("EFT Cashout Amount", '<>%1', 0);
//                     if PaymEntry_LT.Find('-') then begin
//                         PaymEntry_LT.CalcSums("Amount Tendered");
//                         FieldValue_L[1] := 'Cashout';
//                         FieldValue_L[2] := POSFunctions_LC.FormatAmount(PaymEntry_LT."Amount Tendered");
//                         sender.PrintLine(2, sender.FormatLine(sender.FormatStr(FieldValue_L, DSTR1_L), false, false, false, false));
//                     end;
//                 until TenderType_LT.Next = 0;
//         end;

//     end;

//     //MCS.KB 1099:Cash out in POS
//     [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS Print Utility", 'OnBeforePrintPaymInfo', '', false, false)]
//     procedure OnBeforePrintPaymInfo(sender: Codeunit "LSC POS Print Utility"; var Transaction: Record "LSC Transaction Header"; var PrintBuffer: Record "LSC POS Print Buffer"; var PrintBufferIndex: Integer; var LinesPrinted: Integer; var DSTR1: Text[100]; var IsHandled: Boolean; var Tray: Integer)
//     var
//         //TranSalesEntry_LT: Record "LSC Trans. Sales Entry";
//         TransPaymentEntry_LT: Record "LSC Trans. Payment Entry";
//         EFTPOSetup_LT: Record "EFTPOS Setup";
//         POSFunctions_LC: Codeunit "LSC POS Functions";
//         DSTR1_L: Text[100];
//         TotalCashOut_L: Decimal;
//     begin
//         if EFTPOSetup_LT.Get() then;
//         if EFTPOSetup_LT."Cashout Item" = '' then
//             exit;
//         TransPaymentEntry_LT.SetRange("Receipt No.", Transaction."Receipt No.");
//         TransPaymentEntry_LT.SetRange("Store No.", Transaction."Store No.");
//         TransPaymentEntry_LT.SetRange("POS Terminal No.", Transaction."POS Terminal No.");
//         TransPaymentEntry_LT.SetRange("Transaction No.", Transaction."Transaction No.");
//         if TransPaymentEntry_LT.Find('-') then begin
//             repeat
//                 TotalCashOut_L += TransPaymentEntry_LT."EFT Cashout Amount";
//             until TransPaymentEntry_LT.Next() = 0;
//         end;

//         if TotalCashOut_L <> 0 then begin
//             DSTR1_L := '#L################## #R## #R#########   ';
//             Value[1] := 'Cash Back';
//             Value[2] := '';
//             Value[3] := POSFunctions_LC.FormatAmount(TotalCashOut_L);
//             sender.PrintLine(Tray, sender.FormatLine(sender.FormatStr(Value, DSTR1_L), false, false, false, false));
//         end;
//     end;

//     // [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC Statement-Calculate", 'OnBeforeInsertStatementLine', '', false, false)]
//     // procedure OnBeforeInsertStatementLine(var StatementLine: Record "LSC Statement Line"; Store: Record "LSC Store"; POSTerminal: Record "LSC POS Terminal")
//     // var
//     //     EFTPOSSetup_LT: Record "EFTPOS Setup";
//     // begin
//     //     if EFTPOSSetup_LT.Get() then;
//     //     if StatementLine."Tender Type" = EFTPOSSetup_LT."EFT Tender" then begin
//     //         StatementLine.Validate("Counted Amount", StatementLine."Trans. Amount");
//     //     end;
//     // end;


//     [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC Statement-Calculate", 'OnAfterCalcByDateTime', '', false, false)]
//     procedure OnAfterCalcByDateTime(var Statement: Record "LSC Statement")
//     var
//         StatementLine_LT: Record "LSC Statement Line";
//         EFTPOSSetup_LT: Record "EFTPOS Setup";
//     begin
//         if EFTPOSSetup_LT.Get() then;
//         if EFTPOSSetup_LT."EFT Tender" = '' then
//             exit;
//         StatementLine_LT.SetRange("Store No.", Statement."Store No.");
//         StatementLine_LT.SetRange("Statement No.", Statement."No.");
//         StatementLine_LT.SetRange("Tender Type", EFTPOSSetup_LT."EFT Tender");
//         if StatementLine_LT.Find('-') then begin
//             repeat
//                 StatementLine_LT.Validate("Counted Amount", StatementLine_LT."Trans. Amount");
//                 StatementLine_LT.Modify();
//             until StatementLine_LT.Next() = 0;
//         end;
//     end;

//     [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS Post Utility", 'OnBeforeInsertPaymentEntryV2', '', false, false)]
//     procedure OnBeforeInsertPaymentEntryV2(var POSTransaction: Record "LSC POS Transaction"; var POSTransLineTemp: Record "LSC POS Trans. Line" temporary; var TransPaymentEntry: Record "LSC Trans. Payment Entry")
//     begin
//         TransPaymentEntry."EFT Cashout Amount" := POSTransLineTemp."EFT Cashout Amount";
//     end;

//     // [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS Post Utility", 'OnAfterInsertTransHeader', '', false, false)]
//     // procedure OnAfterInsertTransHeader(var Transaction: Record "LSC Transaction Header"; var POSTrans: Record "LSC POS Transaction");
//     // var
//     //     EFTPOSSetup_LT: Record "EFTPOS Setup";
//     //     POSPaymentEntry_LT: Record "LSC POS Trans. Line";
//     //     POSTransLine_LT: Record "LSC POS Trans. Line";
//     // begin
//     //     if EFTPOSSetup_LT.Get() then;
//     //     if EFTPOSSetup_LT."EFT Tender" = '' then
//     //         exit;
//     //     if EFTPOSSetup_LT."Cashout Item" = '' then
//     //         exit;

//     //     POSTransLine_LT.Reset();
//     //     POSTransLine_LT.SetRange("Receipt No.", POSTrans."Receipt No.");
//     //     POSTransLine_LT.SetRange("Entry Type", POSPaymentEntry_LT."Entry Type"::Item);
//     //     POSTransLine_LT.SetRange("Entry Status", POSPaymentEntry_LT."Entry Status"::" ");
//     //     POSTransLine_LT.SetRange(Number, EFTPOSSetup_LT."Cashout Item");
//     //     if POSTransLine_LT.FindFirst() then begin
//     //         POSPaymentEntry_LT.Reset();
//     //         POSPaymentEntry_LT.SetRange("Receipt No.", POSTrans."Receipt No.");
//     //         POSPaymentEntry_LT.SetRange("Entry Type", POSPaymentEntry_LT."Entry Type"::Payment);
//     //         POSPaymentEntry_LT.SetRange("Entry Status", POSPaymentEntry_LT."Entry Status"::" ");
//     //         POSPaymentEntry_LT.SetRange(Number, EFTPOSSetup_LT."EFT Tender");
//     //         if POSPaymentEntry_LT.FindFirst() then begin
//     //             Transaction."Open Drawer" := true;
//     //         end;
//     //     end;
//     // end;

//     // [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS Post Utility", 'OnAfterInsertTransaction', '', false, false)]
//     // procedure OnAfterInsertTransaction(var POSTrans: Record "LSC POS Transaction"; var Transaction: Record "LSC Transaction Header")
//     // var
//     //     EFTPOSSetup_LT: Record "EFTPOS Setup";
//     //     POSPaymentEntry_LT: Record "LSC POS Trans. Line";
//     //     POSTransLine_LT: Record "LSC POS Trans. Line";
//     //     POSTransaction_LC: Codeunit "LSC POS Transaction";
//     // begin
//     //     if EFTPOSSetup_LT.Get() then;
//     //     if EFTPOSSetup_LT."EFT Tender" = '' then
//     //         exit;
//     //     if EFTPOSSetup_LT."Cashout Item" = '' then
//     //         exit;

//     //     POSTransLine_LT.Reset();
//     //     POSTransLine_LT.SetRange("Receipt No.", POSTrans."Receipt No.");
//     //     POSTransLine_LT.SetRange("Entry Type", POSPaymentEntry_LT."Entry Type"::Item);
//     //     POSTransLine_LT.SetRange("Entry Status", POSPaymentEntry_LT."Entry Status"::" ");
//     //     POSTransLine_LT.SetRange(Number, EFTPOSSetup_LT."Cashout Item");
//     //     if POSTransLine_LT.FindFirst() then begin
//     //         POSPaymentEntry_LT.Reset();
//     //         POSPaymentEntry_LT.SetRange("Receipt No.", POSTrans."Receipt No.");
//     //         POSPaymentEntry_LT.SetRange("Entry Type", POSPaymentEntry_LT."Entry Type"::Payment);
//     //         POSPaymentEntry_LT.SetRange("Entry Status", POSPaymentEntry_LT."Entry Status"::" ");
//     //         POSPaymentEntry_LT.SetRange(Number, EFTPOSSetup_LT."EFT Tender");
//     //         if POSPaymentEntry_LT.FindFirst() then begin
//     //             POSTransaction_LC.OpenDrawerEx('', true);
//     //         end;
//     //     end;
//     // end;
//     [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS Transaction Events", 'OnBeforeProcessPostingByState2', '', false, false)]
//     procedure OnBeforeProcessPostingByState2(var POSTransaction: Record "LSC POS Transaction"; var POSTransPostingStateTemp: Record "LSC POS Trans. Posting State" temporary; var IsHandled: Boolean)
//     var
//         EFTPOSSetup_LT: Record "EFTPOS Setup";
//         POSPaymentEntry_LT: Record "LSC POS Trans. Line";
//         POSTransLine_LT: Record "LSC POS Trans. Line";
//         POSTransaction_LC: Codeunit "LSC POS Transaction";
//     begin
//         if POSTransPostingStateTemp."Posting State" = POSTransPostingStateTemp."Posting State"::Posting then begin
//             if EFTPOSSetup_LT.Get() then;
//             if EFTPOSSetup_LT."EFT Tender" = '' then
//                 exit;
//             if EFTPOSSetup_LT."Cashout Item" = '' then
//                 exit;

//             POSTransLine_LT.Reset();
//             POSTransLine_LT.SetRange("Receipt No.", POSTransaction."Receipt No.");
//             POSTransLine_LT.SetRange("Entry Type", POSPaymentEntry_LT."Entry Type"::Item);
//             POSTransLine_LT.SetRange("Entry Status", POSPaymentEntry_LT."Entry Status"::" ");
//             POSTransLine_LT.SetRange(Number, EFTPOSSetup_LT."Cashout Item");
//             if POSTransLine_LT.FindFirst() then begin
//                 POSPaymentEntry_LT.Reset();
//                 POSPaymentEntry_LT.SetRange("Receipt No.", POSTransaction."Receipt No.");
//                 POSPaymentEntry_LT.SetRange("Entry Type", POSPaymentEntry_LT."Entry Type"::Payment);
//                 POSPaymentEntry_LT.SetRange("Entry Status", POSPaymentEntry_LT."Entry Status"::" ");
//                 POSPaymentEntry_LT.SetRange(Number, EFTPOSSetup_LT."EFT Tender");
//                 if POSPaymentEntry_LT.FindFirst() then begin
//                     POSTransPostingStateTemp."Open Default Drawer" := true;
//                     POSTransPostingStateTemp.Modify();
//                 end;
//             end;
//         end;
//     end;
// }