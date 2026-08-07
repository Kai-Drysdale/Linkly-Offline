codeunit 50206 "EFT EFTPOS Events"
{


    var
        //EFT Variables
        // gCashOutAmt: Decimal;
        gRefund: Boolean;
        Text095: label 'This Tender Type may not be used';
        Text096: label 'This Tender Type may not be used\in training mode';
        Text097: label 'Payment not allowed in this state!';
        //EFT Variables
        TenderType_TG: Record "LSC Tender Type";
        Store_TG: Record "LSC Store";
        POSTransaction_GC: Codeunit "LSC POS Transaction";
        POSFunction_CG: Codeunit "LSC POS Functions";
        POSSession_CG: Codeunit "LSC POS Session";
        POSView_CG: Codeunit "LSC POS View";
        NewLine_TG: Record "LSC POS Trans. Line";
        CardEntry_TG: Record "LSC POS Card Entry";
        POSPrint_CG: Codeunit "LSC POS Print Utility";
        LineLen_G: Integer;
        Value: array[10] of Text;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS Transaction Events", 'OnBeforeRunCommand', '', true, true)]
    procedure OnBeforeRunCommand(var POSTransaction: Record "LSC POS Transaction"; var POSTransLine: Record "LSC POS Trans. Line"; var CurrInput: Text; var POSMenuLine: Record "LSC POS Menu Line"; var isHandled: Boolean; TenderType: Record "LSC Tender Type"; var CusomterOrCardNo: Code[20])
    var
        EFTSetup_LT: Record "EFTPOS Setup";
    begin
        case POSMenuLine.Command of
            'EFTPOS':
                begin
                    //EFTPOS(POSTransaction, POSMenuLine);
                    EFTPOSv2(POSTransaction, POSMenuLine);
                end;
            'CASHOUT':
                begin
                    //MCS.KB 1099:Cash out in POS
                    isHandled := true;
                    if EFTSetup_LT.Get() then;
                    if EFTSetup_LT."Cashout Item" = '' then begin
                        POSTransaction_GC.PosErrorBanner('Cashout Item cannot be empty in EFT POS Setup.');
                        exit;
                    end;
                    POSTransaction_GC.OpenNumericKeyboard('Enter Cashout Amount', '0', 50130);
                end;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS Transaction Events", 'OnBeforeVoidTransaction', '', true, true)]
    procedure OnBeforeVoidTransaction(var POSTransaction: Record "LSC POS Transaction"; var IsHandled: Boolean)
    begin
        EFTPOSCheckVoidLine(POSTransaction."Receipt No.", 0);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS Transaction Events", 'OnBeforeVoidLinePressedEx', '', true, true)]
    procedure OnBeforeVoidLinePressedEx(var POSTrans: Record "LSC POS Transaction"; var POSTransLine: Record "LSC POS Trans. Line")
    var
        EFTSetup_LT: Record "EFTPOS Setup";
        OtherEFTPayment_L: Decimal;
    begin
        if EFTSetup_LT.Get() then;
        EFTPOSCheckVoidLine(POSTrans."Receipt No.", POSTransLine."Line No.");
        if (POSTransLine."Entry Type" = POSTransLine."Entry Type"::Item) and (POSTransLine.Number = EFTSetup_LT."Cashout Item") then begin
            OtherEFTPayment_L := GetPaymentAmount(POSTrans, EFTSetup_LT."EFT Tender", true);
            if OtherEFTPayment_L <> 0 then begin
                POSTransaction_GC.ErrorBeep('You cannot cancel Cashout item if payment has been made.');
            end;
        end;
    end;

    procedure EFTPOSCheckVoidLine(ReceiptNo: Code[20]; LineNo_P: Integer)
    var
        PosTransLine_LT: Record "LSC POS Trans. Line";
        EFTPOSTxt003: label 'You cannot void a payment line when the payment is already processed.';
        EFTSetup_LT: Record "EFTPOS Setup";
    begin
        if EFTSetup_LT.Get() then;
        // MPG1.00
        PosTransLine_LT.Reset;
        PosTransLine_LT.SetRange("Receipt No.", ReceiptNo);
        PosTransLine_LT.SetRange("Entry Type", PosTransLine_LT."Entry Type"::Payment);
        PosTransLine_LT.SetRange("Entry Status", PosTransLine_LT."Entry Status"::" ");
        PosTransLine_LT.SetRange(Number, EFTSetup_LT."EFT Tender");
        if LineNo_P <> 0 then
            PosTransLine_LT.SetRange("Line No.", LineNo_P);
        if PosTransLine_LT.FindFirst() then begin
            POSTransaction_GC.ErrorBeep(EFTPOSTxt003);
            Error(EFTPOSTxt003);
        end;
    end;

    procedure EFTPOSV2(POSTransaction_PT: Record "LSC POS Transaction"; MenuLine: Record "LSC POS Menu Line") lCloseCommand: Code[20]
    var

        NewBalance_L: Decimal;
        AmountInCurrencyOut_L: Decimal;
        PaymentAmountOut_L: Decimal;
        BalanceOut_L: Decimal;

        PaymentAmount_L: Decimal;
        CashoutEnabled_L: Boolean;
        CCSPCT_L: Decimal;
        SurChargeTender_L: Code[10];
        SurChargeAmount: Decimal;

        EFTSetup_LT: Record "EFTPOS Setup";
        EFTPOSCaptureResp_LC: Codeunit "EFT EFTPOS Capture";
        TenderType_TL: Record "LSC Tender Type";
        Refund_L: Boolean;
        EFTPOSPopup_LC: Codeunit "EFT EFTPOS POS Popup";
        CashOutAmt_L: Decimal;
        OtherEFTPayment_L: Decimal;
    begin
        Store_TG.Get(POSTransaction_PT."Store No.");
        EFTSetup_LT.Get;
        EFTSetup_LT.TestField("Capture Timeout (x 10 MS)");
        TenderType_TL.Get(Store_TG."No.", EFTSetup_LT."EFT Tender");

        Clear(EFTPOSCaptureResp_LC);
        EFTPOSCaptureResp_LC.SetMode(0); //PurchaseAutorisation/DoTransaction
        EFTPOSCaptureResp_LC.SetPOSTrans(POSTransaction_PT);
        EFTPOSCaptureResp_LC.InitRequest();
        //if EFTPOSCaptureResp_LC.CheckRequest() then
        //    exit(EFTPOSDoLastTrans(POSTransaction_TP, false));

        if not TenderType_TL."May Be Used" then begin
            POSTransaction_GC.ErrorBeep(Text095);
            exit;
        end;
        if POSView_CG.GetTrainingMode() and (TenderType_TL."Function" = TenderType_TL."function"::Card) then begin
            POSTransaction_GC.ErrorBeep(Text096);
            exit;
        end;
        if POSTransaction_GC.GetPosState() <> 'PAYMENT' then begin
            POSTransaction_GC.ErrorBeep(Text097);
            exit;
        end;

        POSTransaction_GC.GetAmtAndBalance(AmountInCurrencyOut_L, PaymentAmountOut_L, BalanceOut_L);
        NewBalance_L := ROUND(BalanceOut_L, 0.01, '=');

        if (POSTransaction_PT."Sale Is Return Sale") and (BalanceOut_L > 0) then
            Refund_L := true;
        if (POSTransaction_PT."Sale Is Return Sale") and (BalanceOut_L < 0) then
            Refund_L := false;

        if (not POSTransaction_PT."Sale Is Return Sale") and (BalanceOut_L < 0) then
            Refund_L := true;
        if (not POSTransaction_PT."Sale Is Return Sale") and (BalanceOut_L > 0) then
            Refund_L := false;

        //MCS.KB 1099:Cash out in POS
        CashOutAmt_L := GetCashoutAmount(POSTransaction_PT);
        if CashOutAmt_L <> 0 then begin
            OtherEFTPayment_L := GetPaymentAmount(POSTransaction_PT, EFTSetup_LT."EFT Tender", true);
            CashOutAmt_L := CashOutAmt_L - OtherEFTPayment_L;
        end;
        NewBalance_L := NewBalance_L - CashOutAmt_L;

        Clear(EFTPOSPopup_LC);
        EFTPOSPopup_LC.SETGlobalVar(POSTransaction_PT."Receipt No.", NewBalance_L, CashOutAmt_L, POSTransaction_PT, Refund_L, CashoutEnabled_L, CCSPCT_L, SurChargeTender_L);
        EFTPOSPopup_LC.ShowPanel;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS Print Utility", 'OnAfterPrintSlips', '', true, true)]
    procedure OnAfterPrintSlips(var Transaction: Record "LSC Transaction Header"; var PrintBuffer: Record "LSC POS Print Buffer"; var PrintBufferIndex: Integer; var LinesPrinted: Integer; var MsgTxt: Text[50]; PrintSlip: Boolean; var ReturnValue: Boolean)
    var
        EFTReceiptData_LT: Record "EFTPOS Receipt Text";
        EFTReceipt_LT: Record "EFTPOS Receipt Text";
        POSPrint_LC: Codeunit "LSC POS Print Utility";
        DSTR1_L: Text[100];
        LineLength_L: Integer;
        Tray_L: Integer;
    begin
        Tray_L := 2;
        if not PrintSlip then
            exit;
        EFTReceiptData_LT.RESET;
        EFTReceiptData_LT.SETRANGE("Receipt Code", Transaction."Receipt No.");
        IF EFTReceiptData_LT.FINDFIRST THEN BEGIN
            POSPrint_LC.WindowInitialize();
            if not POSPrint_LC.OpenReceiptPrinter(Tray_L, 'SALES', '', Transaction."Transaction No.", Transaction."Receipt No.") then
                exit;

            EFTReceipt_LT.Reset;
            EFTReceipt_LT.SetRange("Store No.", Transaction."Store No.");
            EFTReceipt_LT.SetRange("POS Terminal No.", Transaction."POS Terminal No.");
            EFTReceipt_LT.SetRange("Receipt Code", Transaction."Receipt No.");
            if EFTReceipt_LT.FindFirst then begin
                LineLength_L := 40;
                repeat
                    DSTR1_L := CopyStr('#C##############################', 1, LineLength_L);
                    Value[1] := CopyStr(EFTReceipt_LT."EFTPOS Receipt Text", 1, LineLength_L);
                    POSPrint_LC.PrintLine(Tray_L, POSPrint_LC.FormatLine(POSPrint_LC.FormatStr(Value, DSTR1_L), false, false, false, false));
                until EFTReceipt_LT.Next = 0;
                POSPrint_LC.PrintSeperator(2);
            end;
            if not POSPrint_LC.ClosePrinter(Tray_L) then
                exit;
        END;
    end;


    //MCS.KB 1099:Cash out in POS
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS Transaction", 'OnAfterKeyboardTriggerToProcess', '', false, false)]
    local procedure OnAfterKeyboardTriggerToProcess(InputValue: Text; KeyboardTriggerToProcess: Integer; var Rec: Record "LSC POS Transaction"; var IsHandled: Boolean)
    var
        EFTPOSSetup_LT: Record "EFTPOS Setup";
        POSTransaction_LC: Codeunit "LSC POS Transaction";
        POSSession_LC: Codeunit "LSC POS Session";
        CashoutAmount_L: Decimal;
        ErrorLbl_L: Label 'Please enter valid amount';
    begin
        case KeyboardTriggerToProcess of
            50130:
                begin
                    IsHandled := true;
                    if InputValue = '' then begin
                        POSTransaction_LC.PosErrorBanner(ErrorLbl_L);
                        exit;
                    end;
                    if not Evaluate(CashoutAmount_L, InputValue) then begin
                        POSTransaction_LC.PosErrorBanner(ErrorLbl_L);
                        exit;
                    end;
                    EFTPOSSetup_LT.Get();
                    POSSession_LC.SetValue('CASHOUT_AMOUNT', InputValue);
                    POSTransaction_LC.PluKeyPressed(EFTPOSSetup_LT."Cashout Item");
                end;
        end;
    end;

    //MCS.KB 1099:Cash out in POS
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS Transaction Events", 'OnAfterInsertItemLine', '', false, false)]
    procedure OnAfterInsertItemLine(var POSTransaction: Record "LSC POS Transaction"; var POSTransLine: Record "LSC POS Trans. Line"; var CurrInput: Text)
    var
        EFTPOSSetup_LT: Record "EFTPOS Setup";
        POSSession_LC: Codeunit "LSC POS Session";
        POSTransaction_LC: Codeunit "LSC POS Transaction";
        CashoutAmount_L: Text;
        CashoutAmountDec_L: Decimal;
    begin
        EFTPOSSetup_LT.Get();
        if EFTPOSSetup_LT."Cashout Item" = POSTransLine.Number then begin
            CashoutAmount_L := POSSession_LC.GetValue('CASHOUT_AMOUNT');
            // if Evaluate(CashoutAmountDec_L, CashoutAmount_L) then begin
            //     POSTransLine."EFT Cashout Amount" := CashoutAmountDec_L;
            //     POSTransLine.Modify();
            // end;
            if CashoutAmount_L <> '' then begin
                if Evaluate(CashoutAmountDec_L, CashoutAmount_L) then;
                POSTransaction_LC.ChangePricePressed(CashoutAmount_L);
                POSSession_LC.SetValue('CASHOUT_AMOUNT', '');
                POSTransLine."EFT Cashout Amount" := CashoutAmountDec_L;
                POSTransLine.Modify();
            end;
        end;
    end;

    //MCS.KB 1099:Cash out in POS
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS Transaction Events", 'OnBeforeInsertPaymentLine', '', false, false)]
    local procedure OnBeforeInsertPaymentLine(var POSTransaction: Record "LSC POS Transaction"; var POSTransLine: Record "LSC POS Trans. Line"; var CurrInput: Text; var TenderTypeCode: Code[10]; Balance: decimal; PaymentAmount: Decimal; STATE: Code[10]; var isHandled: Boolean)
    var
        CardEntry_LT: Record "LSC POS Card Entry";
        POSTransaction_LC: Codeunit "LSC POS Transaction";
        EFTSetup_LT: Record "EFTPOS Setup";
        Cashamount_L: Decimal;
        OtherEFTPayment_L: Decimal;
        OtherNonEFTPayment_L: Decimal;
        GrossNetOfCashOut_L: Decimal;
        EFTTender_L: Code[20];
        OverPaymentErrLbl_L: Label 'Overpayment not allowed. Total payment should be %1';
        MinPaymentErrLbl_L: Label 'Minimum payment should be %1';
    begin
        if EFTSetup_LT.Get() then;
        EFTTender_L := EFTSetup_LT."EFT Tender";

        if TenderTypeCode = EFTTender_L then begin
            CardEntry_LT.Reset;
            CardEntry_LT.SetCurrentkey("Store No.", "POS Terminal No.", "Receipt No.");
            CardEntry_LT.SetRange("Store No.", POSTransaction."Store No.");
            CardEntry_LT.SetRange("POS Terminal No.", POSTransaction."POS Terminal No.");
            CardEntry_LT.SetRange("Receipt No.", POSTransaction."Receipt No.");
            if CardEntry_LT.FindLast then begin
                POSTransLine."Card Type" := CardEntry_LT."Card Type";
            end;
        end;

        Cashamount_L := GetCashoutAmount(POSTransaction);
        if Cashamount_L <> 0 then begin
            if TenderTypeCode = EFTTender_L then begin
                OtherEFTPayment_L := GetPaymentAmount(POSTransaction, EFTTender_L, true);
                if (OtherEFTPayment_L + PaymentAmount) < Cashamount_L then begin
                    POSTransaction_LC.ErrorBeep(StrSubstNo(MinPaymentErrLbl_L, Cashamount_L - OtherEFTPayment_L));
                    isHandled := true;
                    exit;
                end;
            end else begin
                GrossNetOfCashOut_L := POSTransaction."Gross Amount" - Cashamount_L;
                OtherNonEFTPayment_L := GetPaymentAmount(POSTransaction, EFTTender_L, false);
                if (OtherNonEFTPayment_L + PaymentAmount) > GrossNetOfCashOut_L then begin
                    OtherEFTPayment_L := GetPaymentAmount(POSTransaction, EFTTender_L, true);
                    if OtherEFTPayment_L < Cashamount_L then begin
                        POSTransaction_LC.ErrorBeep(StrSubstNo(OverPaymentErrLbl_L, GrossNetOfCashOut_L));
                        isHandled := true;
                        exit;
                    end;
                end;
            end;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS Transaction Events", 'OnBeforeInsertLineInsertPaymentLine', '', false, false)]
    internal procedure OnBeforeInsertLineInsertPaymentLine(var POSTransaction: Record "LSC POS Transaction"; var POSTransLine: Record "LSC POS Trans. Line"; var CurrInput: Text; var TenderTypeCode: Code[10]; Balance: decimal; PaymentAmount: Decimal; STATE: Code[10]; var isHandled: Boolean)
    var
        EFTSetup_LT: Record "EFTPOS Setup";
        Cashamount_L: Decimal;
    begin
        if EFTSetup_LT.Get() then;
        if TenderTypeCode <> EFTSetup_LT."Cashout Tender" then
            exit;
        Cashamount_L := GetCashoutAmount(POSTransaction);
        if Cashamount_L <> 0 then begin
            if POSSession_CG.GetValue('EFTCASHOUT') = '1' then begin
                POSTransLine."EFT Cashout Amount" := Cashamount_L;
            end;
        end;

    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS Transaction Events", 'OnAfterInsertPaymentLine', '', false, false)]
    internal procedure OnAfterInsertPaymentLine(var POSTransaction: Record "LSC POS Transaction"; var POSTransLine: Record "LSC POS Trans. Line"; var CurrInput: Text; var TenderTypeCode: Code[10]; var SkipCommit: Boolean)
    var
        POSTransLine_LT: Record "LSC POS Trans. Line";
        EFTSetup_LT: Record "EFTPOS Setup";
        Cashamount_L: Decimal;
        POSTransaction_LC: Codeunit "LSC POS Transaction";
        POSTransLine_LC: Codeunit "LSC POS Trans. Lines";
        Gross_L: Decimal;
        Payment_L: Decimal;
        Balance_L: Decimal;
    begin
        if EFTSetup_LT.Get() then;
        if (POSTransLine."EFT Cashout Amount" <> 0) and (EFTSetup_LT."Cashout Tender" = TenderTypeCode) then begin
            SkipCommit := true;
            exit;
        end;

        if TenderTypeCode <> EFTSetup_LT."EFT Tender" then
            exit;

        POSTransaction_LC.GetAmtAndBalance(Gross_L, Payment_L, Balance_L);
        if (Balance_L - Payment_L) <= 0 then begin
            Cashamount_L := GetCashoutAmount(POSTransaction);
            if Cashamount_L <> 0 then begin
                POSTransLine_LT.Reset();
                POSTransLine_LT.SetRange("Receipt No.", POSTransaction."Receipt No.");
                POSTransLine_LT.SetRange("Entry Type", POSTransLine_LT."Entry Type"::Item);
                POSTransLine_LT.SetRange("Entry Status", POSTransLine_LT."Entry Status"::" ");
                POSTransLine_LT.SetRange(Number, EFTSetup_LT."Cashout Item");
                if POSTransLine_LT.Find('-') then begin
                    repeat
                        POSTransLine_LT.Validate(Price, 0);
                        POSTransLine_LT.UpdateAmounts();
                        POSTransLine_LT.Modify();
                    until POSTransLine_LT.Next() = 0;
                    //POSTransLine_LC.SetCurrentLine(POSTransLine);
                end;

                POSTransLine_LT.Reset();
                POSTransLine_LT.SetRange("Receipt No.", POSTransaction."Receipt No.");
                POSTransLine_LT.SetFilter("EFT Cashout Amount", '<>%1', 0);
                POSTransLine_LT.SetRange("Entry Type", POSTransLine_LT."Entry Type"::Payment);
                POSTransLine_LT.SetRange("Entry Status", POSTransLine_LT."Entry Status"::" ");
                POSTransLine_LT.SetRange(Number, EFTSetup_LT."Cashout Tender");
                if POSTransLine_LT.FindFirst() then begin
                    POSTransLine_LT.VoidLine();
                end;
                POSSession_CG.SetValue('EFTCASHOUT', '1');
                POSTransaction_GC.TenderKeyPressedEx(EFTSetup_LT."Cashout Tender", Format(Cashamount_L));
                POSSession_CG.SetValue('EFTCASHOUT', '0');
            end;
        end;


    end;

    //MCS.KB 1099:Cash out in POS
    // [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS Transaction", 'OnBeforeOpenNumericKeyboardOnTenderKey', '', false, false)]
    // procedure OnBeforeOpenNumericKeyboardOnTenderKey(var REC: Record "LSC POS Transaction"; TenderTypeCode: Code[10]; var PaymentAmount: Decimal)
    // var
    //     EFTSetup_LT: Record "EFTPOS Setup";
    //     Cashamount_L: Decimal;
    //     OtherEFTPayment_L: Decimal;
    // begin
    //     if EFTSetup_LT.Get() then;

    //     if TenderTypeCode <> EFTSetup_LT."EFT Tender" then
    //         exit;
    //     Cashamount_L := GetCashoutAmount(REC);
    //     if Cashamount_L = 0 then
    //         exit;
    //     OtherEFTPayment_L := GetPaymentAmount(REC, EFTSetup_LT."EFT Tender", true);
    //     PaymentAmount := Cashamount_L - OtherEFTPayment_L;
    // end;

    //MCS.KB 1099:Cash out in POS
    local procedure GetPaymentAmount(POSTransaction_PT: Record "LSC POS Transaction"; EFTTender_P: Code[20]; isEFTTender_P: Boolean): Decimal
    var
        POSTransLine_LT: Record "LSC POS Trans. Line";
        PaymentAmount_L: Decimal;
    begin
        POSTransLine_LT.Reset();
        POSTransLine_LT.SetRange("Receipt No.", POSTransaction_PT."Receipt No.");
        POSTransLine_LT.SetRange("Store No.", POSTransaction_PT."Store No.");
        POSTransLine_LT.SetRange("POS Terminal No.", POSTransaction_PT."POS Terminal No.");
        POSTransLine_LT.SetRange("Entry Status", POSTransLine_LT."Entry Status"::" ");
        POSTransLine_LT.SetRange("Entry Type", POSTransLine_LT."Entry Type"::Payment);
        if isEFTTender_P then begin
            POSTransLine_LT.SetRange(Number, EFTTender_P);
        end else begin
            POSTransLine_LT.SetFilter(Number, '<>%1', EFTTender_P);
        end;
        POSTransLine_LT.CalcSums(Amount);
        PaymentAmount_L := POSTransLine_LT.Amount;
        exit(PaymentAmount_L);
    end;

    //MCS.KB 1099:Cash out in POS
    local procedure GetCashoutAmount(POSTransaction_PT: Record "LSC POS Transaction"): Decimal
    var
        POSTransLine_LT: Record "LSC POS Trans. Line";
        EFTPOSSetup_LT: Record "EFTPOS Setup";
        Amount_L: Decimal;
    begin
        EFTPOSSetup_LT.Get();
        POSTransLine_LT.SetRange("Receipt No.", POSTransaction_PT."Receipt No.");
        POSTransLine_LT.SetRange("Store No.", POSTransaction_PT."Store No.");
        POSTransLine_LT.SetRange("POS Terminal No.", POSTransaction_PT."POS Terminal No.");
        POSTransLine_LT.SetRange("Entry Status", POSTransLine_LT."Entry Status"::" ");
        POSTransLine_LT.SetRange("Entry Type", POSTransLine_LT."Entry Type"::Item);
        POSTransLine_LT.SetRange(Number, EFTPOSSetup_LT."Cashout Item");
        POSTransLine_LT.CalcSums("EFT Cashout Amount");
        Amount_L := POSTransLine_LT."EFT Cashout Amount";
        exit(Amount_L);
    end;

    //MCS.KB 1099:Cash out in POS
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS Print Utility", 'OnBeforePrintTotal', '', false, false)]
    procedure OnBeforePrintTotal(var Transaction: Record "LSC Transaction Header"; var PrintBuffer: Record "LSC POS Print Buffer"; var PrintBufferIndex: Integer; var LinesPrinted: Integer; var DSTR1: Text[100]; var IsHandled: Boolean; var ReturnValue: Boolean; var PeriodicDiscountInfoTEMP: Record "LSC Periodic Discount" temporary; var SubTotal: Decimal; var Tray: Integer)
    begin
        POSSession_CG.SetValue('PRINT_RECEIPTNO', Transaction."Receipt No.");
        POSSession_CG.SetValue('PRINT_STORENO', Transaction."Store No.");
        POSSession_CG.SetValue('PRINT_TERMINALNO', Transaction."POS Terminal No.");
    end;

    //MCS.KB 1099:Cash out in POS
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS Print Utility", 'OnBeforeSumTotalAmountToText', '', false, false)]
    procedure OnBeforeSumTotalAmountToText(var TotalAmountText: Text[100]; TotalAmount: Decimal; var IsHandled: Boolean)
    var
        TranSalesEntry_LT: Record "LSC Trans. Sales Entry";
        EFTPOSetup_LT: Record "EFTPOS Setup";
        POSFunctions_LC: Codeunit "LSC POS Functions";
        TotalCashOut_L: Decimal;
    begin
        if EFTPOSetup_LT.Get() then;
        if EFTPOSetup_LT."Cashout Item" = '' then
            exit;
        TranSalesEntry_LT.SetRange("Receipt No.", POSSession_CG.GetValue('PRINT_RECEIPTNO'));
        TranSalesEntry_LT.SetRange("Store No.", POSSession_CG.GetValue('PRINT_STORENO'));
        TranSalesEntry_LT.SetRange("POS Terminal No.", POSSession_CG.GetValue('PRINT_TERMINALNO'));
        TranSalesEntry_LT.SetRange("Item No.", EFTPOSetup_LT."Cashout Item");
        if TranSalesEntry_LT.Find('-') then begin
            repeat
                TotalCashOut_L += (-(TranSalesEntry_LT."Total Rounded Amt."));
            until TranSalesEntry_LT.Next() = 0;
        end;
        if TotalCashOut_L <> 0 then begin
            IsHandled := true;
            TotalAmount -= TotalCashOut_L;
            TotalAmountText := POSFunctions_LC.FormatAmount(TotalAmount);
            POSSession_CG.SetValue('PRINT_RECEIPTNO', '');
            POSSession_CG.SetValue('PRINT_STORENO', '');
            POSSession_CG.SetValue('PRINT_TERMINALNO', '');
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS Print Utility", 'OnBeforePrintXZLines', '', false, false)]
    internal procedure OnBeforePrintXZLines(sender: Codeunit "LSC POS Print Utility"; var StaffID_p: Code[20]; var PrintBuffer: Record "LSC POS Print Buffer"; var PrintBufferIndex: Integer; var LinesPrinted: Integer; var DSTR1: Text[100]; var IsHandled: Boolean)
    var
        TenderType_LT: Record "LSC Tender Type";
        PaymEntry_LT: Record "LSC Trans. Payment Entry";
        Terminal_LT: Record "LSC POS Terminal";
        POSSession_LC: Codeunit "LSC POS Session";
        POSFunctions_LC: Codeunit "LSC POS Functions";
        SCode_L: Code[20];
        FieldValue_L: array[10] of Text[100];
        DSTR1_L: Text[100];
    begin
        if StaffID_p <> '' then begin
            Terminal_LT.Reset();
            Terminal_LT.SetRange("Store No.", POSSession_LC.StoreNo());
            Terminal_LT.SetRange("No.", POSSession_LC.TerminalNo());
            if Terminal_LT.FindFirst() then;

            SCode_L := POSFunctions_LC.GetStatementCode;
            TenderType_LT.SetCurrentKey("Store No.");
            TenderType_LT.SetRange("Store No.", POSSession_LC.StoreNo);
            TenderType_LT.SetFilter("Function", '<>%1', TenderType_LT."Function"::"Tender Remove/Float");
            TenderType_LT.SetRange("Foreign Currency", false);
            if TenderType_LT.FindSet() then
                repeat
                    DSTR1_L := '#L################# #R##################';
                    Clear(FieldValue_L);
                    PaymEntry_LT.Reset();
                    PaymEntry_LT.SetCurrentKey("Statement Code", "Z-Report ID", "Tender Type", "Currency Code", "Card No.");
                    PaymEntry_LT.SetRange("Statement Code", SCode_L);
                    PaymEntry_LT.SetRange("Z-Report ID", '');
                    if Terminal_LT."Terminal Statement" or (Terminal_LT."Statement Method" = Terminal_LT."Statement Method"::"POS Terminal") then
                        PaymEntry_LT.SetRange("POS Terminal No.", Terminal_LT."No.");
                    PaymEntry_LT.SetRange("Tender Type", TenderType_LT.Code);
                    PaymEntry_LT.SetRange("Staff ID", StaffID_p);
                    PaymEntry_LT.SetRange("Card No.");
                    PaymEntry_LT.SetFilter("EFT Cashout Amount", '<>%1', 0);
                    if PaymEntry_LT.Find('-') then begin
                        PaymEntry_LT.CalcSums("Amount Tendered");
                        FieldValue_L[1] := 'Cashout';
                        FieldValue_L[2] := POSFunctions_LC.FormatAmount(PaymEntry_LT."Amount Tendered");
                        sender.PrintLine(2, sender.FormatLine(sender.FormatStr(FieldValue_L, DSTR1_L), false, false, false, false));
                    end;
                until TenderType_LT.Next = 0;
        end;

    end;

    //MCS.KB 1099:Cash out in POS
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS Print Utility", 'OnBeforePrintPaymInfo', '', false, false)]
    procedure OnBeforePrintPaymInfo(sender: Codeunit "LSC POS Print Utility"; var Transaction: Record "LSC Transaction Header"; var PrintBuffer: Record "LSC POS Print Buffer"; var PrintBufferIndex: Integer; var LinesPrinted: Integer; var DSTR1: Text[100]; var IsHandled: Boolean; var Tray: Integer)
    var
        //TranSalesEntry_LT: Record "LSC Trans. Sales Entry";
        TransPaymentEntry_LT: Record "LSC Trans. Payment Entry";
        EFTPOSetup_LT: Record "EFTPOS Setup";
        POSFunctions_LC: Codeunit "LSC POS Functions";
        DSTR1_L: Text[100];
        TotalCashOut_L: Decimal;
    begin
        if EFTPOSetup_LT.Get() then;
        if EFTPOSetup_LT."Cashout Item" = '' then
            exit;
        TransPaymentEntry_LT.SetRange("Receipt No.", Transaction."Receipt No.");
        TransPaymentEntry_LT.SetRange("Store No.", Transaction."Store No.");
        TransPaymentEntry_LT.SetRange("POS Terminal No.", Transaction."POS Terminal No.");
        TransPaymentEntry_LT.SetRange("Transaction No.", Transaction."Transaction No.");
        if TransPaymentEntry_LT.Find('-') then begin
            repeat
                TotalCashOut_L += TransPaymentEntry_LT."EFT Cashout Amount";
            until TransPaymentEntry_LT.Next() = 0;
        end;

        if TotalCashOut_L <> 0 then begin
            DSTR1_L := '#L################## #R## #R#########   ';
            Value[1] := 'Cash Back';
            Value[2] := '';
            Value[3] := POSFunctions_LC.FormatAmount(TotalCashOut_L);
            sender.PrintLine(Tray, sender.FormatLine(sender.FormatStr(Value, DSTR1_L), false, false, false, false));
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC Statement-Calculate", 'OnAfterCalcByDateTime', '', false, false)]
    procedure OnAfterCalcByDateTime(var Statement: Record "LSC Statement")
    var
        StatementLine_LT: Record "LSC Statement Line";
        EFTPOSSetup_LT: Record "EFTPOS Setup";
    begin
        if EFTPOSSetup_LT.Get() then;
        if EFTPOSSetup_LT."EFT Tender" = '' then
            exit;
        StatementLine_LT.SetRange("Store No.", Statement."Store No.");
        StatementLine_LT.SetRange("Statement No.", Statement."No.");
        StatementLine_LT.SetRange("Tender Type", EFTPOSSetup_LT."EFT Tender");
        if StatementLine_LT.Find('-') then begin
            repeat
                StatementLine_LT.Validate("Counted Amount", StatementLine_LT."Trans. Amount");
                StatementLine_LT.Modify();
            until StatementLine_LT.Next() = 0;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS Post Utility", 'OnBeforeInsertPaymentEntryV2', '', false, false)]
    procedure OnBeforeInsertPaymentEntryV2(var POSTransaction: Record "LSC POS Transaction"; var POSTransLineTemp: Record "LSC POS Trans. Line" temporary; var TransPaymentEntry: Record "LSC Trans. Payment Entry")
    begin
        TransPaymentEntry."EFT Cashout Amount" := POSTransLineTemp."EFT Cashout Amount";
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS Transaction Events", 'OnBeforeProcessPostingByState2', '', false, false)]
    procedure OnBeforeProcessPostingByState2(var POSTransaction: Record "LSC POS Transaction"; var POSTransPostingStateTemp: Record "LSC POS Trans. Posting State" temporary; var IsHandled: Boolean)
    var
        EFTPOSSetup_LT: Record "EFTPOS Setup";
        POSPaymentEntry_LT: Record "LSC POS Trans. Line";
        POSTransLine_LT: Record "LSC POS Trans. Line";
        POSTransaction_LC: Codeunit "LSC POS Transaction";
    begin
        if POSTransPostingStateTemp."Posting State" = POSTransPostingStateTemp."Posting State"::Posting then begin
            if EFTPOSSetup_LT.Get() then;
            if EFTPOSSetup_LT."EFT Tender" = '' then
                exit;
            if EFTPOSSetup_LT."Cashout Item" = '' then
                exit;

            POSTransLine_LT.Reset();
            POSTransLine_LT.SetRange("Receipt No.", POSTransaction."Receipt No.");
            POSTransLine_LT.SetRange("Entry Type", POSPaymentEntry_LT."Entry Type"::Item);
            POSTransLine_LT.SetRange("Entry Status", POSPaymentEntry_LT."Entry Status"::" ");
            POSTransLine_LT.SetRange(Number, EFTPOSSetup_LT."Cashout Item");
            if POSTransLine_LT.FindFirst() then begin
                POSPaymentEntry_LT.Reset();
                POSPaymentEntry_LT.SetRange("Receipt No.", POSTransaction."Receipt No.");
                POSPaymentEntry_LT.SetRange("Entry Type", POSPaymentEntry_LT."Entry Type"::Payment);
                POSPaymentEntry_LT.SetRange("Entry Status", POSPaymentEntry_LT."Entry Status"::" ");
                POSPaymentEntry_LT.SetRange(Number, EFTPOSSetup_LT."EFT Tender");
                if POSPaymentEntry_LT.FindFirst() then begin
                    POSTransPostingStateTemp."Open Default Drawer" := true;
                    POSTransPostingStateTemp.Modify();
                end;
            end;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS Print Utility", 'OnBeforeBufferTenderDeclEntry', '', false, false)]
    internal procedure OnBeforeBufferTenderDeclEntry(var TempTendDeclEntry: Record "LSC Trans. Tender Declar. Entr" temporary; TendDeclEntry: Record "LSC Trans. Tender Declar. Entr"; var IsHandled: Boolean)
    var
        EFTPOSSetup_LT: Record "EFTPOS Setup";
        PaymEntry_LT: Record "LSC Trans. Payment Entry";
        Terminal_LT: Record "LSC POS Terminal";
        POSSession_LC: Codeunit "LSC POS Session";
        POSFunctions_LC: Codeunit "LSC POS Functions";
        SCode_L: Code[20];
        CashOutAmount_L: Decimal;
    begin
        // IsHandled := true;
        // if EFTPOSSetup_LT.Get() then;

        // Clear(CashOutAmount_L);
        // if TendDeclEntry."Tender Type" = EFTPOSSetup_LT."Cashout Tender" then begin
        //     SCode_L := POSFunctions_LC.GetStatementCode();
        //     PaymEntry_LT.Reset();
        //     PaymEntry_LT.SetCurrentKey("Statement Code", "Z-Report ID", "Tender Type", "Currency Code", "Card No.");
        //     PaymEntry_LT.SetRange("Statement Code", SCode_L);
        //     PaymEntry_LT.SetRange("Z-Report ID", '');
        //     if Terminal_LT."Terminal Statement" or (Terminal_LT."Statement Method" = Terminal_LT."Statement Method"::"POS Terminal") then
        //         PaymEntry_LT.SetRange("POS Terminal No.", Terminal_LT."No.");
        //     PaymEntry_LT.SetRange("Tender Type", EFTPOSSetup_LT."Cashout Tender");
        //     PaymEntry_LT.SetRange("Card No.");
        //     PaymEntry_LT.SetFilter("EFT Cashout Amount", '<>%1', 0);
        //     if PaymEntry_LT.Find('-') then begin
        //         PaymEntry_LT.CalcSums("Amount Tendered");
        //         CashOutAmount_L := PaymEntry_LT."Amount Tendered";
        //     end;
        // end;

        // TempTendDeclEntry.SetRange("Statement Code", TendDeclEntry."Statement Code");
        // TempTendDeclEntry.SetRange("Z-Report ID", TendDeclEntry."Z-Report ID");
        // TempTendDeclEntry.SetRange("Tender Type", TendDeclEntry."Tender Type");
        // TempTendDeclEntry.SetRange("Currency Code", TendDeclEntry."Currency Code");
        // TempTendDeclEntry.SetRange("Card No.", TendDeclEntry."Card No.");
        // if TempTendDeclEntry.Find then begin
        //     TempTendDeclEntry."Amount Tendered" += TendDeclEntry."Amount Tendered";
        //     TempTendDeclEntry."Amount Tendered" += CashOutAmount_L;
        //     TempTendDeclEntry.Quantity += TendDeclEntry.Quantity;
        //     TempTendDeclEntry."Amount in Currency" += TendDeclEntry."Amount in Currency";
        //     TempTendDeclEntry."Amount in Currency" += CashOutAmount_L;
        //     TempTendDeclEntry.Modify;
        // end else begin
        //     TempTendDeclEntry := TendDeclEntry;
        //     TempTendDeclEntry."Amount Tendered" += CashOutAmount_L;
        //     TempTendDeclEntry."Amount in Currency" += CashOutAmount_L;
        //     TempTendDeclEntry.Insert;
        // end;

    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS Functions", 'OnBeforeIsPurgeOverDue', '', false, false)]
    local procedure OnBeforeIsPurgeOverDue(PosTrans: Record "LSC POS Transaction"; var IsHandled: Boolean; var ReturnValue: Boolean)
    var
        EFTLog: Record "EFTPOS Log";
        POSSession: Codeunit "LSC POS Session";
        PosFuncProfile: Record "LSC POS Func. Profile";
        RefDate: Date;
    begin
        PosFuncProfile.Get(POSSESSION.FunctionalityProfileID);
        if PosFuncProfile."EFT Days EFT Log Exists" <> 0 then begin
            RefDate := Today;
            EFTLog.Reset;
            EFTLog.SetRange("Store No.", POSSESSION.StoreNo);
            EFTLog.SetRange("POS terminal No.", POSSESSION.TerminalNo());
            EFTLog.SetRange("Log Date", 0D, RefDate - PosFuncProfile."EFT Days EFT Log Exists");
            if EFTLog.FindFirst() then begin
                ReturnValue := true;
                IsHandled := true;
            end;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS Transaction Events", 'OnAfterPurgeOldTransactions', '', false, false)]
    internal procedure OnAfterPurgeOldTransactions()
    var
        EFTLog: Record "EFTPOS Log";
        PosFuncProfile: Record "LSC POS Func. Profile";
        POSSession: Codeunit "LSC POS Session";
        RefDate: Date;
    begin
        PosFuncProfile.Get(POSSESSION.FunctionalityProfileID);
        if PosFuncProfile."EFT Days EFT Log Exists" <> 0 then begin
            RefDate := Today;
            EFTLog.Reset;
            EFTLog.SetRange("Log Date", 0D, RefDate - PosFuncProfile."EFT Days EFT Log Exists");
            EFTLog.SetRange("Store No.", POSSESSION.StoreNo);
            EFTLog.SetRange("POS terminal No.", POSSESSION.TerminalNo());
            if not EFTLog.IsEmpty() then
                EFTLog.DeleteAll(true);
        end;
    end;
}