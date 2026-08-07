Codeunit 50203 "EFT EFTPOS Capture"
{
    // MCS1.07 07-07-20 KK
    //   Jira PS-1787 Created Codeunit instead of Page 50463 EFTPOS Capture
    // 
    // MCS1.09 14-07-20 LP
    //   Jira PS-1890: Receipt is not printed when PIN is incorrect
    //   Jira PS-1753: performance issue on printing EFTPOS info


    // trigger OnRun()
    // var
    //     EFTReceipt: Record "EFTPOS Receipt Text";
    //     ReceiptLineNo: Integer;
    //     ReceiptLineCount: Integer;
    //     i: Integer;
    //     EFTPOSApprovalCodeList: Record "EFTPOS Approval Code List";
    //     PrintMerchantCopy: Boolean;
    //     WaitTime: Integer;
    //     FirstReceiptLineNo: Integer;
    //     responseSource: Integer;
    // begin
    //     EFTPOSSetup.Get;
    //     WaitforSignature := false;

    //     if EFTPOSSetup."Capture Timeout (x 10 MS)" > 0 then
    //         timer2 := EFTPOSSetup."Capture Timeout (x 10 MS)"
    //     else
    //         timer2 := 10; // ms

    //     //Note: TimeOut is BC time out, not EFTPOS timeout
    //     //EFTPOS timeout cannot be set and is currently 30s
    //     if EFTPOSSetup."Event Timeout (Seconds)" > 0 then
    //         TimeOut := EFTPOSSetup."Event Timeout (Seconds)"
    //     else
    //         TimeOut := 60;


    //     CallInterface();

    //     //>> MCS1.09: PS-1753
    //     WaitTime := timer2 * 100;
    //     //TimeOut := TimeOut * ROUND(1000/WaitTime,1,'>');
    //     //<< MCS1.09: PS-1753

    //     //>> MCS1.09: PS-1753
    //     //FOR counter2 := 1 TO TimeOut DO BEGIN
    //     //SLEEP(1000);
    //     counter2 := 0;
    //     while (counter2 <= TimeOut) do begin
    //         Sleep(1000);
    //         counter2 += 1;
    //         //<< MCS1.09: PS-1753

    //         //counter2 += 1;
    //         if isReady then begin //must check if it is ready to retrieve the data, i.e. after you complete the insertion into NAV tables
    //             isReady := false; //set to false first to avoid the next timer_tick and data has not been completed insertion into NAV tables
    //                               //IF NOT ISNULL(PcEftPos.EventData()) THEN
    //             Clear(pcEftPosResponse);
    //             pcEftPosResponse := PcEftPos.EventData();
    //             if not IsNull(pcEftPosResponse) then begin
    //                 //Response source
    //                 //0 Transaction,
    //                 //1 KeyDown,
    //                 //2 Print,
    //                 //3 Display,
    //                 //4 GetLastReceipt,
    //                 //5 CardSwipe,
    //                 //6 QueryCard,
    //                 //7 Settlement,
    //                 //8 SelfTest,
    //                 //9 LastTransaction,
    //                 //10 DisplaySettlement
    //                 responseSource := pcEftPosResponse.ResponseSource;
    //                 if (pcEftPosResponse.ResponseSource = 2) or // Print
    //                    (pcEftPosResponse.ResponseSource = 3) or // Display
    //                    (pcEftPosResponse.ResponseSource = 7) or // Settlement
    //                    (pcEftPosResponse.ResponseSource = 4)    // GetLastReceipt
    //                 then begin //receipt - may occur multiple times

    //                     if (PageMode = Pagemode::DoLogon) then
    //                         ReceiptLineCount := 0
    //                     else
    //                         ReceiptLineCount := pcEftPosResponse.ReceiptLineCount;

    //                     //MCS1.02 Jira PS-1755>>>
    //                     PrintMerchantCopy := false;
    //                     EFTPOSApprovalCodeList.Reset;
    //                     if EFTPOSApprovalCodeList.Get(EFTPOSSetup."Interface Type", EFTPOSSetup."Country Code", EFTPOSSetup."Bank Name", pcEftPosResponse.ResponseCode) then
    //                         if EFTPOSApprovalCodeList."Print Merchant Copy" then
    //                             PrintMerchantCopy := true;
    //                     //MCS1.02 Jira PS-175<<<<

    //                     //it is a zero index
    //                     if ReceiptLineCount <> 0 then begin
    //                         ReceiptLineNo := EFTPOSFunctions.NextReceiptEntryNo;
    //                         FirstReceiptLineNo := ReceiptLineNo;
    //                         for i := 0 to (ReceiptLineCount - 1) do begin
    //                             ReceiptLineNo += 1;
    //                             //MCS1.02 Jira PS-1755>>>
    //                             //EFTPOSFunctions.AddReceiptLine(ReceiptLineNo,pcEftPosResponse.ReceiptLine(i),pcEftPosResponse.MerchantCopy);
    //                             if PageMode in [Pagemode::PreSettlement, Pagemode::Settlement] then
    //                                 EFTPOSFunctions.AddReceiptLine(ReceiptLineNo, pcEftPosResponse.ReceiptLine(i), false, PrintMerchantCopy)
    //                             else
    //                                 EFTPOSFunctions.AddReceiptLine(ReceiptLineNo, pcEftPosResponse.ReceiptLine(i), pcEftPosResponse.MerchantCopy, PrintMerchantCopy);

    //                             //MCS1.02 Jira PS-1755<<<<
    //                             EFTPOSFunctions.AddEFTPOSLog(2, EFTPOSFunctions.GetNextEFTPOSEntry(), pcEftPosResponse.ReceiptLine(i), pcEftPosResponse);
    //                         end;
    //                         pcEftPosResponse.ResetReceiptText;
    //                     end;
    //                     if not (PageMode in [Pagemode::PreSettlement, Pagemode::Settlement]) then
    //                         if pcEftPosResponse.MerchantCopy then begin
    //                             //printing a deposit slip for custoner to sign
    //                             //may need to reset counter2 OR set a flag to ignore timeout as we do not want timeout in this case (waiting for customer to sign)
    //                             Clear(EFTPOSEvent_CG);
    //                             //POSPrint.PrintEFTReceipt(2,POSTrans,TRUE);//MCS1.00 Jira PS1414
    //                             //>> MCS1.09: PS-1890
    //                             //POSPrint.PrintEFTReceipt(2,POSTrans,TRUE);//MCS1.02 Jira PS1755 - Returned back to standard
    //                             EFTPOSEvent_CG.PrintEFTReceipt(2, POSTrans, true, true, FirstReceiptLineNo);
    //                             counter2 := 0;
    //                             //<< MCS1.09: PS-1890

    //                             //counter2 := 0;//MCS1.04 Jira PS1753
    //                             //WaitforSignature := TRUE; //MCS1.04 Jira PS1753
    //                             //TimeOut := 1860;//MCS1.04 Jira PS1753
    //                         end;

    //                     if (PageMode = Pagemode::PrintLastReceipt) or
    //                        (PageMode = Pagemode::PreSettlement) or
    //                        (PageMode = Pagemode::Settlement) or
    //                        (PageMode = Pagemode::DoLastTransaction) then begin
    //                         Clear(EFTPOSEvent_CG);
    //                         //MCS1.00 JIRA PS-1414>>>>
    //                         //Removed
    //                         EFTPOSEvent_CG.PrintEFTReceipt(2, POSTrans, true, false, FirstReceiptLineNo);

    //                         counter2 := 0;
    //                         EFTReceipt.Reset;
    //                         EFTReceipt.SetRange("Receipt Code", POSTrans."Receipt No.");
    //                         EFTReceipt.SetRange("Store No.", POSTrans."Store No.");
    //                         EFTReceipt.SetRange("POS Terminal No.", POSTrans."POS Terminal No.");
    //                         if EFTReceipt.FindFirst then
    //                             EFTReceipt.DeleteAll;
    //                         //MCS1.00 JIRA PS-1414<<<<
    //                     end;
    //                 end;

    //                 //PrintLastReceipt
    //                 if pcEftPosResponse.ResponseSource = 4 then begin
    //                     if EFTPOSSetup."Debug Mode" then
    //                         Message('Response Code: %1\Response Text: %2\Auth %3\Response Source %4',
    //                           pcEftPosResponse.ResponseCode, pcEftPosResponse.ResponseText, pcEftPosResponse.AuthCode,
    //                           pcEftPosResponse.ResponseSource);
    //                     WaitforSignature := false;
    //                     EFTPOSFunctions.AddEFTPOSLog(0, EFTPOSFunctions.GetNextEFTPOSEntry(), StrSubstNo('EFTPOS %1 Finish', Format(PageMode)), pcEftPosResponse);
    //                     ResponseCode := pcEftPosResponse.ResponseCode;
    //                     PcEftPos.FinishEvents(); //clean-up resource to avoid memory leak as OCX control is used in the .NET dll
    //                                              //CurrPage.CLOSE;
    //                     exit;
    //                 end;

    //                 //settlement - occurs when settlement done
    //                 if pcEftPosResponse.ResponseSource = 7 then begin

    //                     if EFTPOSSetup."Debug Mode" then
    //                         Message('Response Code: %1\Response Text: %2\Auth %3\Response Source %4',
    //                           pcEftPosResponse.ResponseCode, pcEftPosResponse.ResponseText, pcEftPosResponse.AuthCode,
    //                           pcEftPosResponse.ResponseSource);
    //                     WaitforSignature := false;

    //                     EFTPOSFunctions.AddEFTPOSLog(0, EFTPOSFunctions.GetNextEFTPOSEntry(), StrSubstNo('EFTPOS %1 Finish', Format(PageMode)), pcEftPosResponse);
    //                     ResponseCode := pcEftPosResponse.ResponseCode;
    //                     PcEftPos.FinishEvents(); //clean-up resource to avoid memory leak as OCX control is used in the .NET dll
    //                                              //CurrPage.CLOSE;
    //                     exit;
    //                 end;

    //                 //DoLogon = 12
    //                 if pcEftPosResponse.ResponseSource = 12 then begin
    //                     WaitforSignature := false;
    //                     if EFTPOSSetup."Debug Mode" then
    //                         Message('Response Code: %1\Response Text: %2\Auth %3\Response Source %4', pcEftPosResponse.ResponseCode, pcEftPosResponse.ResponseText, pcEftPosResponse.AuthCode,
    //                         pcEftPosResponse.ResponseSource);

    //                     EFTPOSFunctions.AddEFTPOSLog(0, EFTPOSFunctions.GetNextEFTPOSEntry(), StrSubstNo('EFTPOS %1 Finish', Format(PageMode)), pcEftPosResponse);
    //                     EFTPOSFunctions.RemoveRequestLog;
    //                     ResponseCode := pcEftPosResponse.ResponseCode;
    //                     PcEftPos.FinishEvents(); //clean-up resource to avoid memory leak as OCX control is used in the .NET dll
    //                                              //CurrPage.CLOSE;
    //                     exit;
    //                 end;

    //                 //complete - occurs when "purch authorisation transaction" is finished
    //                 if pcEftPosResponse.ResponseSource = 0 then begin
    //                     WaitforSignature := false;
    //                     if EFTPOSSetup."Debug Mode" then
    //                         Message('Response Code: %1\Response Text: %2\Auth %3\Response Source %4',
    //                           pcEftPosResponse.ResponseCode, pcEftPosResponse.ResponseText, pcEftPosResponse.AuthCode,
    //                           pcEftPosResponse.ResponseSource);

    //                     EFTPOSFunctions.AddEFTPOSLog(0, EFTPOSFunctions.GetNextEFTPOSEntry(), StrSubstNo('EFTPOS %1 Finish', Format(PageMode)), pcEftPosResponse);
    //                     if (PageMode = Pagemode::DoLastTransaction) then begin
    //                         if not FindCardEntry() then
    //                             EFTPOSFunctions.AddCardEntry(pcEftPosResponse, EFTPOSRequest."Purchase Amount" + EFTPOSRequest."Cashout Amount", PageMode);
    //                     end
    //                     else
    //                         EFTPOSFunctions.AddCardEntry(pcEftPosResponse, PurchaseAmount + CashOutAmount, PageMode);
    //                     EFTPOSFunctions.RemoveRequestLog();
    //                     ResponseCode := pcEftPosResponse.ResponseCode;
    //                     PcEftPos.FinishEvents(); //clean-up resource to avoid memory leak as OCX control is used in the .NET dll

    //                     //Print the receipt for un-authorised response
    //                     //55=Incorrect PIN
    //                     //Z9=Signature declined (N/A)
    //                     //TL=Signature declined by Operator
    //                     if (ResponseCode = '55') or (ResponseCode = 'Z9') or (ResponseCode = 'TL') then begin
    //                         Clear(EFTPOSEvent_CG);
    //                         //>>MCS1.09: PS-1890
    //                         //POSPrint.PrintEFTReceipt(2,POSTrans,TRUE);
    //                         //counter2 := 0;
    //                         EFTPOSEvent_CG.PrintEFTReceipt(2, POSTrans, true, false, FirstReceiptLineNo);
    //                         //<<MCS1.09: PS-1890
    //                         EFTReceipt.Reset;
    //                         EFTReceipt.SetRange("Receipt Code", POSTrans."Receipt No.");
    //                         EFTReceipt.SetRange("Store No.", POSTrans."Store No.");
    //                         EFTReceipt.SetRange("POS Terminal No.", POSTrans."POS Terminal No.");
    //                         EFTReceipt.SetFilter("Entry No.", '>%1', FirstReceiptLineNo);
    //                         if EFTReceipt.FindFirst then
    //                             EFTReceipt.DeleteAll;
    //                     end;
    //                     //CurrPage.CLOSE;
    //                     exit;
    //                 end;

    //                 // Dolasttransaction
    //                 if pcEftPosResponse.ResponseSource = 9 then begin
    //                     WaitforSignature := false;

    //                     if not pcEftPosResponse.LastTxnSuccess then begin
    //                         if not SkipMessage then
    //                             Message('Last Transaction was not authorised, nothing to process!');
    //                     end else begin
    //                         if not SkipMessage then
    //                             Message('Last Transaction , Attempting To Process For Receipt No. "%1"', pcEftPosResponse.TxnRef);
    //                     end;

    //                     if EFTPOSSetup."Debug Mode" then
    //                         Message('Response Code: %1\Response Text: %2\Auth %3\Response Source %4',
    //                           pcEftPosResponse.ResponseCode, pcEftPosResponse.ResponseText, pcEftPosResponse.AuthCode,
    //                           pcEftPosResponse.ResponseSource);

    //                     ResponseCode := pcEftPosResponse.ResponseCode;

    //                     EFTPOSFunctions.AddEFTPOSLog(0, EFTPOSFunctions.GetNextEFTPOSEntry(), StrSubstNo('EFTPOS %1 Finish', Format(PageMode)), pcEftPosResponse);
    //                     if not FindCardEntry() then
    //                         EFTPOSFunctions.AddCardEntry(pcEftPosResponse, EFTPOSRequest."Purchase Amount" + EFTPOSRequest."Cashout Amount", PageMode);
    //                     EFTPOSFunctions.RemoveRequestLog();
    //                     PcEftPos.FinishEvents(); //clean-up resource to avoid memory leak as OCX control is used in the .NET dll
    //                                              //CurrPage.CLOSE;
    //                     exit;
    //                 end;
    //             end;

    //             //timeout does not exist in payment express - it is set to 30s inside the OCX control
    //             //if timeout - the transaction will have response code and success to False (but check to see how we can simulate the timeout testing)
    //             //we only check timeout if the device is unplugged in the middle of transaction
    //             //I tried to unplug when signature required is popup, and plugged it back, the middle transaction is still waiting for customer to sign
    //             //  IF (counter2 > 30) THEN BEGIN //is greater than 30s (from EFTPOSSetup)

    //             if (counter2 > TimeOut) then begin //is greater than 30s (from EFTPOSSetup)
    //                 if Confirm('Time out. Do you wish to wait?', true) then
    //                     counter2 := 0
    //                 else begin
    //                     Message('Time Out');
    //                     //CurrPage.CLOSE;
    //                     exit;
    //                 end;
    //             end;
    //             //MCS.KB
    //             //IF NOT ISNULL(pcEftPosResponse) THEN
    //             //CLEAR(pcEftPosResponse);
    //             isReady := true; //set it to true, so that it is ready for the next data retrieval
    //         end;
    //     end;
    // end;



    var
        POSTransaction_GT: Record "LSC POS Transaction";
        EFTPOSRequest: Record "EFTPOS Request";
        EFTPOSSetup: Record "EFTPOS Setup";
        //Trans: Record "EFTPOS Events";
        EFTPOSFunctions: Codeunit "EFTPOS Utilities";
        // POSPrint: Codeunit "LSC POS Print Utility";
        PageMode: Option PurchAuthorisation,PreSettlement,Settlement,PrintLastReceipt,DoLastTransaction,DoLogon,DoReset,DoAbout,TendLastEFT,PayCardSurcharge;
        //timer2: Integer;
        //counter2: Integer;
        //[RunOnClient]
        //PcEftPosRequest: dotnet EFTPOSData;
        //[RunOnClient]
        //pcEftPosResponse: dotnet EFTPOSData;
        //[RunOnClient]
        //[WithEvents]
        //PcEftPos: dotnet EFTPOS;
        //wrapper: DotNet STAWrapper;
        //isReady: Boolean;
        Refund_G: Boolean;
        PurchaseAmount_G: Decimal;
        CashOutAmount_G: Decimal;
        //ReceiptNo: Code[20];
        ResponseCode_G: Text[250];
        //WaitforSignature: Boolean;
        //TimeOut: Integer;
        SkipMessage_G: Boolean;
        EFTPOSReceiptNo: Code[20];

        //v2
        //EFTPOSEvent_CG: Codeunit "EFT EFTPOS Events";
        EFTPOSFunctions_CG: Codeunit "EFTPOS Utilities";

    procedure SetMode(NewMode: Integer)
    begin
        //0 = PurchAuthorisation,
        //1 = PreSettlement,
        //2 = Settlement,
        //3 = PrintLastReceipt,
        //4 = DoLastTransaction,
        //5 = DoLogon
        //6 = DoReset
        //7 = DoAbout
        //8 = TendLastEFT
        //9 = PayCardSurcharge
        PageMode := NewMode;
    end;


    // procedure CallInterface()
    // var
    //     TranSet: Boolean;
    //     _AmountInCents: Integer;
    //     _CashOutInCents: Integer;
    // begin
    //     Clear(EFTPOSFunctions);

    //     EFTPOSFunctions.SetEFTPOSSetup(EFTPOSSetup);

    //     case PageMode of
    //         Pagemode::PurchAuthorisation:
    //             begin
    //                 //>>MCS1.09: PS-1753
    //                 //EFTPOS Events is not used
    //                 //IF Trans.FINDSET THEN
    //                 //  Trans.DELETEALL;
    //                 //IF Trans.FINDLAST THEN
    //                 //  EntryNo := Trans."Entry No." + 1;
    //                 //<<MCS1.09: PS-1753

    //                 EFTPOSFunctions.SetParameters(POSTrans, POSTrans."Receipt No.", PurchaseAmount, CashOutAmount, Refund);
    //                 EFTPOSFunctions.AddRequestLog();

    //                 if IsNull(PcEftPosRequest) then
    //                     PcEftPosRequest := PcEftPosRequest.EFTPOSData();
    //                 PcEftPosRequest.TimeOut := TimeOut;

    //                 if Refund then begin
    //                     PcEftPosRequest.AmtPurchase := Abs(PurchaseAmount);
    //                     PcEftPosRequest.TxnType := 'R';
    //                     PcEftPosRequest.TxnRef := EFTPOSReceiptNo;
    //                 end
    //                 else begin
    //                     PcEftPosRequest.AmtPurchase := Abs(PurchaseAmount);
    //                     PcEftPosRequest.AmtCash := Abs(CashOutAmount);
    //                     PcEftPosRequest.TxnType := 'P';
    //                     PcEftPosRequest.TxnRef := EFTPOSReceiptNo;
    //                 end;

    //                 //MESSAGE(POSTrans."Receipt No.");
    //                 if IsNull(PcEftPos) then
    //                     PcEftPos := PcEftPos.EFTPOS();
    //                 PcEftPos.DoTransaction(PcEftPosRequest);
    //                 //wrapper.RunDoTransactionThread(PcEftPosRequest, PcEftPos);
    //                 EFTPOSFunctions.AddEFTPOSLog(3, EFTPOSFunctions.GetNextEFTPOSEntry(), StrSubstNo('EFTPOS %1 %2 Start', Format(PageMode), PcEftPosRequest.TxnType), pcEftPosResponse);
    //             end;

    //         Pagemode::PreSettlement:
    //             begin
    //                 //>>MCS1.09: PS-1753
    //                 //EFTPOS Events is not used
    //                 //IF Trans.FINDLAST THEN
    //                 //  EntryNo := Trans."Entry No." + 1;
    //                 //<<MCS1.09: PS-1753
    //                 EFTPOSFunctions.SetParameters(POSTrans, POSTrans."Receipt No.", 0, 0, false);
    //                 if IsNull(PcEftPosRequest) then
    //                     PcEftPosRequest := PcEftPosRequest.EFTPOSData();

    //                 PcEftPosRequest.CutReceipt := false;
    //                 PcEftPosRequest.ReceiptAutoPrint := false;
    //                 PcEftPosRequest.TxnType := 'P';
    //                 PcEftPosRequest.ResetTotals := false;
    //                 EFTPOSFunctions.AddEFTPOSLog(3, EFTPOSFunctions.GetNextEFTPOSEntry(), StrSubstNo('EFTPOS %1 Start', Format(PageMode)), pcEftPosResponse);
    //                 if IsNull(PcEftPos) then //MCS.KB
    //                     PcEftPos := PcEftPos.EFTPOS();
    //                 PcEftPos.DoSettlement(PcEftPosRequest);
    //             end;

    //         Pagemode::Settlement:
    //             begin
    //                 //>>MCS1.09: PS-1753
    //                 //EFTPOS Events is not used
    //                 //IF Trans.FINDLAST THEN
    //                 //  EntryNo := Trans."Entry No." + 1;
    //                 //<<MCS1.09: PS-1753
    //                 EFTPOSFunctions.SetParameters(POSTrans, POSTrans."Receipt No.", 0, 0, false);
    //                 if IsNull(PcEftPosRequest) then
    //                     PcEftPosRequest := PcEftPosRequest.EFTPOSData();

    //                 PcEftPosRequest.CutReceipt := false;
    //                 PcEftPosRequest.ReceiptAutoPrint := false;
    //                 PcEftPosRequest.TxnType := 'S';
    //                 PcEftPosRequest.ResetTotals := false;

    //                 EFTPOSFunctions.AddEFTPOSLog(3, EFTPOSFunctions.GetNextEFTPOSEntry(), StrSubstNo('EFTPOS %1 Start', Format(PageMode)), pcEftPosResponse);
    //                 if IsNull(PcEftPos) then //MCS.KB
    //                     PcEftPos := PcEftPos.EFTPOS();
    //                 PcEftPos.DoSettlement(PcEftPosRequest);
    //             end;

    //         Pagemode::PrintLastReceipt:
    //             begin
    //                 //>>MCS1.09: PS-1753
    //                 //EFTPOS Events is not used
    //                 //IF Trans.FINDLAST THEN
    //                 //  EntryNo := Trans."Entry No." + 1;
    //                 //<<MCS1.09: PS-1753
    //                 EFTPOSFunctions.SetParameters(POSTrans, POSTrans."Receipt No.", 0, 0, false);
    //                 EFTPOSFunctions.AddEFTPOSLog(3, EFTPOSFunctions.GetNextEFTPOSEntry(), StrSubstNo('EFTPOS %1 Start', Format(PageMode)), pcEftPosResponse);
    //                 PcEftPosRequest := PcEftPosRequest.EFTPOSData();
    //                 PcEftPos := PcEftPos.EFTPOS();
    //                 PcEftPos.DoGetLastReceipt(PcEftPosRequest);
    //             end;

    //         Pagemode::DoLastTransaction:
    //             begin

    //                 //>>MCS1.09: PS-1753
    //                 //EFTPOS Events is not used
    //                 //IF Trans.FINDSET THEN
    //                 //  Trans.DELETEALL;

    //                 //IF Trans.FINDLAST THEN
    //                 //  EntryNo := Trans."Entry No." + 1;
    //                 //<<MCS1.09: PS-1753
    //                 if CheckRequest() then begin
    //                     if EFTPOSRequest."Refund Amount" <> 0 then
    //                         EFTPOSFunctions.SetParameters(POSTrans, POSTrans."Receipt No.", -EFTPOSRequest."Refund Amount", 0, true)
    //                     else
    //                         EFTPOSFunctions.SetParameters(POSTrans, POSTrans."Receipt No.", EFTPOSRequest."Purchase Amount", EFTPOSRequest."Cashout Amount", false);

    //                     PcEftPosRequest := PcEftPosRequest.EFTPOSData();
    //                     PcEftPos := PcEftPos.EFTPOS();
    //                     PcEftPos.DoGetLastTransaction(PcEftPosRequest);
    //                     EFTPOSFunctions.AddEFTPOSLog(3, EFTPOSFunctions.GetNextEFTPOSEntry(), StrSubstNo('EFTPOS %1 Start', Format(PageMode)), pcEftPosResponse);

    //                 end
    //                 else begin
    //                     //CurrPage.CLOSE;
    //                     exit;
    //                 end;
    //             end;

    //         Pagemode::DoLogon:
    //             begin
    //                 EFTPOSFunctions.SetParameters(POSTrans, POSTrans."Receipt No.", 0, 0, Refund);
    //                 PcEftPosRequest := PcEftPosRequest.EFTPOSData();
    //                 PcEftPos := PcEftPos.EFTPOS();
    //                 PcEftPos.DoLogon(PcEftPosRequest);
    //             end;

    //         Pagemode::DoReset:
    //             begin
    //                 PcEftPos := PcEftPos.EFTPOS();
    //                 PcEftPos.DoReset();
    //             end;

    //         Pagemode::DoAbout:
    //             begin
    //                 PcEftPos := PcEftPos.EFTPOS();
    //                 PcEftPos.DoAbout();
    //             end;

    //         Pagemode::TendLastEFT:
    //             begin

    //             end;

    //     end;

    //     isReady := true;
    // end;


    procedure SetParamsPurchAuth(Amount_P: Decimal; CashOutAmount_P: Decimal; Refund_P: Boolean; SkipMessage_P: Boolean)
    begin
        PurchaseAmount_G := Amount_P;
        CashOutAmount_G := CashOutAmount_P;
        Refund_G := Refund_P;
        SkipMessage_G := SkipMessage_P;
    end;


    procedure SetPOSTrans(POSTransaction_PT: Record "LSC POS Transaction")
    begin
        POSTransaction_GT := POSTransaction_PT;
        // EFTPOS only allows 16 characters on their receipt.
        EFTPOSReceiptNo := DelChr(UpperCase(POSTransaction_GT."Receipt No."), '=', 'ABCDEFGHIJKLMNOPQRSTUVWXYZ-');
        EFTPOSReceiptNo := CopyStr(EFTPOSReceiptNo, StrLen(POSTransaction_GT."Receipt No.") - 10, 10);
    end;


    procedure GetResponse(): Text[250]
    begin
        exit(ResponseCode_G);
    end;

    // local procedure ConvertDatetoText(NewDate: Date) DateYYYYMMDD: Text
    // var
    //     YearInt: Integer;
    //     MonthInt: Integer;
    //     DayInt: Integer;
    //     MonthTxt: Text;
    //     DayTxt: Text;
    // begin
    //     DayInt := Date2dmy(NewDate, 1);
    //     MonthInt := Date2dmy(NewDate, 2);
    //     YearInt := Date2dmy(NewDate, 3);
    //     if DayInt < 10 then
    //         DayTxt := '0' + Format(DayInt)
    //     else
    //         DayTxt := Format(DayInt);
    //     if MonthInt < 10 then
    //         MonthTxt := '0' + Format(MonthInt)
    //     else
    //         MonthTxt := Format(MonthInt);

    //     exit(Format(YearInt) + MonthTxt + DayTxt);
    // end;


    // procedure CheckRequest() RequestFound: Boolean
    // begin
    //     if EFTPOSRequest.Get(POSTrans."Store No.", POSTrans."POS Terminal No.", POSTrans."Receipt No.") then
    //         exit(true)
    //     else begin
    //         EFTPOSRequest.Init;
    //         exit(false);
    //     end;
    // end;

    procedure InitRequest()
    begin
        EFTPOSRequest.Init;
    end;

    // local procedure FindCardEntry(): Boolean
    // var
    //     POSCardEntry: Record "LSC POS Card Entry";
    //     StanTxt: Text;
    // begin
    //     POSCardEntry.Reset;
    //     POSCardEntry.SetCurrentkey("Store No.", "POS Terminal No.", "Receipt No.");
    //     POSCardEntry.SetRange("Store No.", EFTPOSRequest."Store No.");
    //     POSCardEntry.SetRange("POS Terminal No.", EFTPOSRequest."POS Terminal No.");
    //     POSCardEntry.SetRange("Receipt No.", EFTPOSRequest."Receipt No.");
    //     POSCardEntry.SetRange("Authorisation Ok", true);
    //     //>> MPG1.05
    //     //Check for Stan (System trace audit number)
    //     StanTxt := Format(pcEftPosResponse.Stan);
    //     POSCardEntry.SetRange("EFO EFT Stan", StanTxt);
    //     //<< MPG1.05
    //     if POSCardEntry.FindLast then
    //         exit(true)
    //     else
    //         exit(false);
    // end;

    procedure DoTransactionV2(): Boolean
    var
        EFTRequest_L: dotnet EFTDataLS;
        EFTResponse_L: dotnet EFTDataLS;
        EFT_TCPIP_L: dotnet EFT_TCPIP;
        EFTPOSSetup_LT: Record "EFTPOS Setup";
        TimeOut_L: Integer;
        Counter_L: Integer;
        isReady_L: Boolean;
        ReceiptLineCount_L: Integer;
        ReceiptLineNo_L: Integer;
        FirstReceiptLineNo_L: Integer;
        i: Integer;
        PrintMerchantCopy_L: Boolean;
        EFTPOSApprovalCodeList_LT: Record "EFTPOS Approval Code List";
    begin
        if IsNull(EFTRequest_L) then
            EFTRequest_L := EFTRequest_L.EFTDataLS();
        if Refund_G then begin
            EFTRequest_L.AmtPurchase := Abs(PurchaseAmount_G);
            EFTRequest_L.TxnType := 'R';
            EFTRequest_L.TxnRef := EFTPOSReceiptNo;
        end
        else begin
            EFTRequest_L.AmtPurchase := Abs(PurchaseAmount_G);
            EFTRequest_L.AmtCash := Abs(CashOutAmount_G);
            EFTRequest_L.TxnType := 'P';
            EFTRequest_L.TxnRef := EFTPOSReceiptNo;
        end;
        EFTPOSFunctions_CG.SetParameters(POSTransaction_GT, POSTransaction_GT."Receipt No.", PurchaseAmount_G, CashOutAmount_G, Refund_G);
        EFTPOSFunctions_CG.AddRequestLog();

        if IsNull(EFT_TCPIP_L) then
            EFT_TCPIP_L := EFT_TCPIP_L.LSFunctionsV2();
        EFT_TCPIP_L.DoTransaction(EFTRequest_L);
        isReady_L := true;

        EFTPOSSetup_LT.Get();
        if EFTPOSSetup_LT."Event Timeout (Seconds)" > 0 then
            TimeOut_L := EFTPOSSetup_LT."Event Timeout (Seconds)"
        else
            TimeOut_L := 60;

        while (Counter_L <= TimeOut_L) do begin
            Sleep(1000);
            Counter_L += 1;
            if isReady_L then begin
                isReady_L := false;
                Clear(EFTResponse_L);
                EFTResponse_L := EFT_TCPIP_L.EventData();
                if not IsNull(EFTResponse_L) then begin
                    ReceiptLineCount_L := EFTResponse_L.ReceiptLineCount;

                    PrintMerchantCopy_l := FALSE;
                    EFTPOSApprovalCodeList_LT.RESET;
                    IF EFTPOSApprovalCodeList_LT.GET(EFTPOSSetup."Interface Type", EFTPOSSetup."Country Code", EFTPOSSetup."Bank Name", EFTResponse_L.ResponseCode) THEN
                        IF EFTPOSApprovalCodeList_LT."Print Merchant Copy" THEN
                            PrintMerchantCopy_l := TRUE;

                    IF ReceiptLineCount_L <> 0 THEN BEGIN
                        ReceiptLineNo_L := EFTPOSFunctions_CG.NextReceiptEntryNo;
                        FirstReceiptLineNo_L := ReceiptLineNo_L;
                        FOR i := 0 TO (ReceiptLineCount_L - 1) DO BEGIN
                            ReceiptLineNo_L += 1;
                            //MCS1.02 Jira PS-1755>>>
                            IF PageMode IN [PageMode::PreSettlement, PageMode::Settlement] THEN
                                EFTPOSFunctions_CG.AddReceiptLine(ReceiptLineNo_L, EFTResponse_L.ReceiptLine(i), FALSE, PrintMerchantCopy_l)
                            ELSE
                                EFTPOSFunctions_CG.AddReceiptLine(ReceiptLineNo_L, EFTResponse_L.ReceiptLine(i), EFTResponse_L.MerchantCopy, PrintMerchantCopy_l);

                            //MCS1.02 Jira PS-1755<<<<
                            EFTPOSFunctions_CG.AddEFTPOSLogV2(2, EFTPOSFunctions_CG.GetNextEFTPOSEntry(), EFTResponse_L.ReceiptLine(i), EFTResponse_L);
                        END;
                        //EFTPOSFunctions.ResetReceiptText;
                    END;

                    if EFTResponse_L.ResponseSource = 0 then begin
                        EFTPOSFunctions_CG.AddEFTPOSLogV2(3, EFTPOSFunctions.GetNextEFTPOSEntry(), StrSubstNo('EFTPOS %1 %2 Start', PageMode::PurchAuthorisation, EFTRequest_L.TxnType), EFTResponse_L);
                        ResponseCode_G := EFTResponse_L.ResponseCode;
                        EFTPOSFunctions_CG.AddCardEntryV2(EFTResponse_L, PurchaseAmount_G + CashOutAmount_G, PageMode);
                        EFTPOSFunctions_CG.RemoveRequestLog();
                        exit;
                    end;
                end;
                if (Counter_L > TimeOut_L) then begin //is greater than 30s (from EFTPOSSetup)
                    if Confirm('Time out. Do you wish to wait?', true) then
                        Counter_L := 0
                    else begin
                        Message('Time Out');
                        //CurrPage.CLOSE;
                        exit;
                    end;
                end;
                isReady_L := true;
            end;
        end;


        exit(true);
    end;

}

