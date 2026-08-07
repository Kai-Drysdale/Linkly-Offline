Codeunit 50205 "EFT EFTPOS POS Popup"
{
    // MPG1.00 17-06-16
    //  New Object
    // 
    // MPG1.05 01-05-19 LP
    //   Revisited PC-EFTPOS
    // MCS1.00 02-06-20 KK
    //   JIRA PS-1414 EFTPOS receipt changes

    SingleInstance = true;
    TableNo = "LSC POS Menu Line";

    trigger OnRun()
    var
        TenderType: Record "LSC Tender Type";
    begin
        if Rec.Command = 'EFTPOS' then begin
            //Clear(CurrInput);
            Rec.Processed := true;

            Commit;
            //>> MPG1.05
            //CASE Parameter OF
            case UpperCase(Rec.Parameter) of
                //<< MPG1.05
                'CHANGEAMOUNT':
                    begin
                        OpenNumericKeyboard(StrSubstNo(Text008, Text003), PosFunc.FormatAmountToShow(GPayment), 50200);
                        // CurrInput := OpenNumericKeyboard(StrSubstNo(Text008, Text003), 0, PosFunc.FormatAmountToShow(GPayment), '');
                        // //MCS1.00 JIRA PS-1414>>>>
                        // if GRefunds then
                        //     CurrInput := '-' + CurrInput;
                        // //MCS1.00 JIRA PS-1414<<<<<
                        // if Evaluate(GPayment, CurrInput) then begin
                        //     // Do checks
                        //     if (Abs(GPayment) > Abs(GBalance)) then begin
                        //         Message(Text101, GPayment, GBalance);
                        //         GPayment := GBalance;
                        //     end;
                        //     if (not GRefunds) and (GPayment < 0) then begin
                        //         Message(Text102);
                        //         GPayment := GBalance;
                        //     end;

                        //     if (GRefunds) and (GPayment > 0) then begin
                        //         Message(Text102);
                        //         GPayment := GBalance;
                        //     end;
                        //     GBalance := GPayment + GCashOut;
                        // end;
                        // UpdateSurcharge;
                        // ShowInfo; // Refreshes the panel with updated info.
                    end;

                'CHANGECASHOUT':
                    begin
                        // CurrInput := OpenNumericKeyboard(StrSubstNo(Text008, Text003), 0, PosFunc.FormatAmountToShow(GCashOut), '');
                        // if Evaluate(GCashOut, CurrInput) then begin
                        //     // Run Checks
                        //     if TenderType.Get(GTrans."Store No.", 'CR_EFTPOS') and (GCashOut > TenderType."Cashout Limit") then begin
                        //         Message(Text103, Format(GCashOut), Format(TenderType."Cashout Limit"));
                        //         GCashOut := 0;
                        //     end;
                        // end
                        // else
                        //     GCashOut := 0;
                        // GBalance := GPayment + GCashOut;
                        // UpdateSurcharge;
                        // ShowInfo; // Refreshes the panel with updated info.
                    end;

                'OK':
                    begin
                        ClosePanel('OK');
                    end;

                'CANCEL':
                    begin
                        ClearInfo;
                        ClosePanel('CANCEL');
                    end;

                else
                    Rec.Processed := false;
            end;
        end;
    end;

    var
        CloseCommand_g: Code[20];
        PosCtrl_g: Codeunit "LSC POS Control Interface";
        PosFunc: Codeunit "LSC POS Functions";
        ValueDec: Decimal;
        POSSession: Codeunit "LSC POS Session";
        Text001: label 'Refund';
        Text002: label 'Payment';
        Text003: label 'Pay Amount';
        Text004: label 'Cash Out';
        Text005: label 'Surcharge';
        Text006: label 'AMEX';
        Text007: label 'DINERS';
        GReceipt: Code[20];
        GBalance: Decimal;
        GCashOut: Decimal;
        GTrans: Record "LSC POS Transaction";
        GRefunds: Boolean;
        GPayment: Decimal;
        GCashoutEnabled: Boolean;
        POSGUI: Codeunit "LSC POS GUI";
        Text008: label 'Change %1';

        PanelRunning: Boolean;
        Text101: label 'Payment Amount %1 cannot be greater than the Balance Amount %2';
        Text102: label 'Payment Amount cannot be negative.';
        Text103: label 'Cashout amount %1 exceeds allowed Limit  %2';
        Text104: label 'Payment Amount cannot be positive.';
        GSurTender: Code[10];
        GSurPct: Decimal;
        SurchargeAmount: Decimal;
        GStore: Record "LSC Store";


    procedure ShowPanel(): Code[20]
    begin
        ShowInfo;
        CloseCommand_g := '';

        if GRefunds then begin
            //kevin
            // if PosCtrl_g.ShowPanelModal('#EFTPOSREFUND') then
            //     exit(CloseCommand_g);
            PosCtrl_g.ShowPanelModal('#EFTPOSREFUND');
        end
        else begin
            // if PosCtrl_g.ShowPanelModal('#EFTPOSPURCH') then
            //     exit(CloseCommand_g);
            //kevin
            PosCtrl_g.ShowPanelModal('#EFTPOSPURCH');
        end;

        exit(CloseCommand_g);
    end;


    procedure ClosePanel(pCloseCommand: Code[20])
    var
        EFTPOSPopup_LC: Codeunit "EFT EFTPOS POS Popup";
        //POSTransaction_LT: Record "LSC POS Transaction";
        POSTransaction_LC: Codeunit "LSC POS Transaction";
        BalanceOut_L: Decimal;
        EFTSetup_LT: Record "EFTPOS Setup";
        RespCode_L: Code[20];
        EFTPOSCaptureResp_LC: Codeunit "EFT EFTPOS Capture";
        EFTRespCodes_LT: Record "EFTPOS Approval Code List";
        CardEntry_LT: Record "LSC POS Card Entry";
        PaymentAmount_L: Decimal;
        POSFunction_LC: Codeunit "LSC POS Functions";
        TenderType_LT: Record "LSC Tender Type";
        POSSession_LC: Codeunit "LSC POS Session";
    begin
        if EFTSetup_LT.Get() then;
        CloseCommand_g := pCloseCommand;
        TenderType_LT.Get(POSSession_LC.StoreNo(), EFTSetup_LT."EFT Tender");

        //update:kevin
        if CloseCommand_g = 'OK' then begin
            // if statement added by Kai to fix 0 EFTPOS issue
            if (GPayment = 0) and (GCashOut = 0) then begin
                Message('The EFTPOS ammount must be greater than zero');
                exit;
            end;
            Clear(RespCode_L);
            Clear(EFTPOSCaptureResp_LC);
            EFTPOSCaptureResp_LC.SetPOSTrans(GTrans);
            EFTPOSCaptureResp_LC.SetParamsPurchAuth(GPayment, GCashOut, GRefunds, not EFTSetup_LT."Debug Mode"); //changed to GPayment
            EFTPOSCaptureResp_LC.DoTransactionV2();
            RespCode_L := EFTPOSCaptureResp_LC.GetResponse;
        end;

        if CloseCommand_g = 'CANCEL' then begin

        end;

        if EFTRespCodes_LT.Get(EFTSetup_LT."Interface Type", EFTSetup_LT."Country Code", EFTSetup_LT."Bank Name", RespCode_L) then begin
            if EFTRespCodes_LT.Approve then begin
                CardEntry_LT.Reset;
                CardEntry_LT.SetCurrentkey("Store No.", "POS Terminal No.", "Receipt No.");
                CardEntry_LT.SetRange("Store No.", GTrans."Store No.");
                CardEntry_LT.SetRange("POS Terminal No.", GTrans."POS Terminal No.");
                CardEntry_LT.SetRange("Receipt No.", GTrans."Receipt No.");
                if CardEntry_LT.FindLast then begin
                    if GRefunds and GTrans."Sale Is Return Sale" then
                        PaymentAmount_L := -CardEntry_LT.Amount
                    else
                        PaymentAmount_L := CardEntry_LT.Amount;
                end;

                PaymentAmount_L := POSFunction_LC.RoundTender(TenderType_LT, PaymentAmount_L);
                AdjustAmountToShow(PaymentAmount_L);

                POSTransaction_LC.TenderKeyPressedEx(TenderType_LT.Code, Format(PaymentAmount_L));

            end;
        end;
        if GRefunds then
            PosCtrl_g.HidePanel('#EFTPOSREFUND', true)
        else
            PosCtrl_g.HidePanel('#EFTPOSPURCH', true);
    end;

    local procedure ShowInfo()
    var
        POSContext_CL: Codeunit "LSC POS Context";
        EPOSCtrl_CL: Codeunit "LSC POS Control Interface";
    begin
        if GRefunds then
            POSSession.SetValue('MU_Heading1', Text001)
        else
            POSSession.SetValue('MU_Heading1', Text002); //Heading
        POSSession.SetValue('MU_InfoText1', Text003);
        POSSession.SetValue('MU_InfoText2', Text004);
        POSSession.SetValue('MU_InfoText3', Text005);
        POSSession.SetValue('MU_InfoText4', Text006 + 'or' + Text007 + Format(GSurPct));
        POSSession.SetValue('MU_InfoText5', Text007);
        POSSession.SetValue('Payment', Format(GPayment, 0, '<Integer Thousand><Decimals,3>'));
        POSSession.SetValue('EFTBalance', Format(GBalance, 0, '<Integer Thousand><Decimals,3>'));
        POSSession.SetValue('CashOut', Format(GCashOut, 0, '<Integer Thousand><Decimals,3>'));

        POSContext_CL.SetKeyValue('<#EFTBalance>', Format(GPayment + GCashOut, 0, '<Integer Thousand><Decimals,3>'));
        EPOSCtrl_CL.SendContext(POSContext_CL);
    end;


    procedure SETGlobalVar(var PReceipt: Code[20]; var PBalance: Decimal; var PCashOut: Decimal; var PTrans: Record "LSC POS Transaction"; var PRefunds: Boolean; var PCashoutEnabled: Boolean; var PSurPCT: Decimal; var PSurTended: Code[10])
    begin
        Clear(GReceipt);
        Clear(GBalance);
        Clear(GCashOut);
        Clear(GTrans);
        Clear(GRefunds);
        Clear(GPayment);
        Clear(GCashoutEnabled);
        Clear(GSurTender);
        Clear(GSurPct);
        GReceipt := PReceipt;
        GBalance := PBalance;
        GCashOut := PCashOut;
        GTrans := PTrans;
        GRefunds := PRefunds;
        GPayment := PBalance;
        GCashoutEnabled := PCashoutEnabled;
        GSurTender := PSurTended;
        GSurPct := PSurPCT;
    end;


    procedure GETGlobalVar(PReceipt: Code[20]; var PBalance: Decimal; var PCashOut: Decimal; var PTrans: Record "LSC POS Transaction"; var PRefunds: Boolean; var PCashoutEnabled: Boolean; var PRSurAmount: Decimal; var PRSurTender: Code[10])
    begin
        if PReceipt = GReceipt then begin
            PCashOut := GCashOut;
            PTrans := GTrans;
            PRefunds := GRefunds;
            PBalance := GPayment;
            PCashoutEnabled := GCashoutEnabled;

            PRSurAmount := SurchargeAmount;
            PRSurTender := GSurTender;
            ClearInfo;
        end;
    end;


    procedure OpenNumericKeyboard(Caption: Text; DefaultValue: Text; TriggerNo_P: Integer): Text
    var
        Result: action;
        POSTrans_CL: Codeunit "LSC POS Transaction";
    begin
        //OpenNumericKeyboard
        Commit;
        //kevin
        // exit(POSGUI.OpenNumericKeyboard(Caption, KeybType, DefaultValue, 0, Result));
        POSTrans_CL.OpenNumericKeyboard(Caption, DefaultValue, TriggerNo_P);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS Transaction", 'OnAfterKeyboardTriggerToProcess', '', false, false)]
    local procedure OnAfterKeyboardTriggerToProcess(InputValue: Text; KeyboardTriggerToProcess: Integer; var Rec: Record "LSC POS Transaction"; var IsHandled: Boolean)
    var
        CurrInput_l: Text;
    begin
        case KeyboardTriggerToProcess of
            50200:
                begin
                    CurrInput_l := InputValue;
                    if GRefunds then
                        CurrInput_l := '-' + InputValue;
                    //MCS1.00 JIRA PS-1414<<<<<
                    if Evaluate(GPayment, CurrInput_l) then begin
                        // Do checks
                        if (Abs(GPayment) > Abs(GBalance)) then begin
                            Message(Text101, GPayment, GBalance);
                            GPayment := GBalance;
                        end;
                        if (not GRefunds) and (GPayment < 0) then begin
                            Message(Text102);
                            GPayment := GBalance;
                        end;

                        if (GRefunds) and (GPayment > 0) then begin
                            Message(Text102);
                            GPayment := GBalance;
                        end;
                        //GBalance := GPayment + GCashOut; removed by Kai in version 24.4.0.2 to fix double charge cash out split payment
                    end;
                    UpdateSurcharge;
                    ShowInfo;
                    IsHandled := true;
                end;
        end;
    end;

    local procedure ClearInfo()
    begin
        POSSession.SetValue('Payment', '0.00');
        POSSession.SetValue('CashOut', '0.00');
    end;

    local procedure UpdateSurcharge()
    begin
        GStore.Get(GTrans."Store No.");
        if GStore."Disable EFT Surcharge" then begin
            GSurPct := 0;
            SurchargeAmount := 0;
        end else begin
            SurchargeAmount := ROUND(GSurPct * GPayment / 100, 0.01);
        end;
    end;


    procedure RevertBalance(OriginalBalance: Decimal)
    begin
        POSSession.SetValue('Balance', Format(OriginalBalance, 0, '<Integer Thousand><Decimals,3>'));
    end;

    procedure AdjustAmountToShow(var Value: Decimal)
    var
        PosFuncProfile_LT: Record "LSC POS Func. Profile";
        POSSession_CL: Codeunit "LSC POS Session";
    begin
        //Function to adjust amount to show on pop-up tender/qty form on the POS
        PosFuncProfile_LT.Get(POSSession_CL.FunctionalityProfileID());
        if PosFuncProfile_LT."Decimals in Entry" > 0 then
            Value := Round(Value * Power(10, PosFuncProfile_LT."Decimals in Entry"));
    end;
}

