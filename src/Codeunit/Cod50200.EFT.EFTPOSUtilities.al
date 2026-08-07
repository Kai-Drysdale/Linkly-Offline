Codeunit 50200 "EFTPOS Utilities"
{
    // MPG1.00 PAYMENT GATEWAY
    //   New object
    // 
    // MPG1.05 01-05-19 LP
    //   Revisited PC-EFTPOS
    // 
    // MCS1.00 04-06-20 KK JIRA PS-1414
    //   EFTPOS Receipt Changes
    // MCS1.02 17-06-20 KK
    //   JIRA PS-1755: Removed changes made by MCS1.00 and Added Code to Print Merchant Copy


    trigger OnRun()
    begin
    end;

    var
        EFTPOSSetup: Record "EFTPOS Setup";
        POSTrans: Record "LSC POS Transaction";
        ResponseStatus: Text[250];
        ResponseResult: Text[250];
        ResponseCardType: Text[20];
        ReponseTransRef: Text[30];
        TransID: Text[250];
        ResponseAuthCode: Text[250];
        AmtPurch: Decimal;
        AmtCashout: Decimal;
        ReceiptText: Text[250];
        SignatureRequired: Boolean;
        ReceiptNo: Code[20];
        IsRefund: Boolean;
        IsTransactionStarted: Boolean;
        SetupRead: Boolean;


    procedure PurgeLog()
    var
        EFTLog: Record "EFTPOS Log";
        EndDate: Date;
        DateExp: Text[30];
    begin
        EFTPOSSetup.Get;

        if EFTPOSSetup."Interface Type" <> EFTPOSSetup."interface type"::PCEFTPOS then
            exit;
        if EFTPOSSetup."No. Log Days" = 0 then
            exit;

        DateExp := '-' + Format(EFTPOSSetup."No. Log Days") + 'D';
        EndDate := CalcDate(DateExp, WorkDate);

        EFTLog.Reset;
        EFTLog.SetCurrentkey("Log Date");
        EFTLog.SetFilter("Log Date", '<%1', EndDate);
        if EFTLog.FindSet then
            EFTLog.DeleteAll;
    end;


    procedure SetParameters(var _PosTrans: Record "LSC POS Transaction"; _ReceiptNo: Code[20]; PurchaseAmt: Decimal; CashOutAmt: Decimal; Refund: Boolean)
    begin
        POSTrans := _PosTrans;
        ReceiptNo := _ReceiptNo;
        AmtPurch := PurchaseAmt;
        AmtCashout := CashOutAmt;
        IsRefund := Refund;
    end;


    procedure GetNextEFTPOSEntry() EntryNo: Integer
    var
        EFTPOSLog: Record "EFTPOS Log";
    begin
        EFTPOSLog.Reset;
        EFTPOSLog.LockTable;
        if EFTPOSLog.FindLast then
            exit(EFTPOSLog."Entry No.")
        else
            exit(0);
    end;


    procedure NextCardEntryNo(): Integer
    var
        LocCardEntry: Record "LSC POS Card Entry";
    begin
        LocCardEntry.Reset;
        LocCardEntry.SetRange("Store No.", POSTrans."Store No.");
        LocCardEntry.SetRange("POS Terminal No.", POSTrans."POS Terminal No.");
        if LocCardEntry.FindLast then
            exit(LocCardEntry."Entry No." + 1)
        else
            exit(1);
    end;


    procedure AddRequestLog()
    var
        EFTPOSRequest: Record "EFTPOS Request";
    begin
        if not EFTPOSRequest.Get(POSTrans."Store No.", POSTrans."POS Terminal No.", POSTrans."Receipt No.") then begin
            EFTPOSRequest.Init;
            EFTPOSRequest."Store No." := POSTrans."Store No.";
            EFTPOSRequest."POS Terminal No." := POSTrans."POS Terminal No.";
            EFTPOSRequest."Receipt No." := POSTrans."Receipt No.";
            EFTPOSRequest.Date := Today;
            EFTPOSRequest.Time := Time;
            if not IsRefund then
                EFTPOSRequest."Purchase Amount" := AmtPurch
            else
                EFTPOSRequest."Refund Amount" := -AmtPurch;
            EFTPOSRequest."Cashout Amount" := AmtCashout;
            EFTPOSRequest.Insert(true);
        end;
    end;


    procedure RemoveRequestLog()
    var
        EFTPOSRequest: Record "EFTPOS Request";
    begin
        if EFTPOSRequest.Get(POSTrans."Store No.", POSTrans."POS Terminal No.", POSTrans."Receipt No.") then begin
            EFTPOSRequest.Delete(true);
        end;
    end;


    procedure AddReceiptLine(LineNo: Integer; NewText: Text[50]; SignatureRequired: Boolean; PrintMerchantCopy: Boolean)
    var
        ReceiptLine: Record "EFTPOS Receipt Text";
    begin
        //MCS1.02 Jira PS-1755>>>
        // if SignatureRequired then
        //     if not PrintMerchantCopy then
        //         exit;
        //MCS1.02 Jira PS-1755<<<
        ReceiptLine.Init;
        ReceiptLine.Type := ReceiptLine.Type::PCEFTPOS;
        ReceiptLine."Store No." := POSTrans."Store No.";
        ReceiptLine."POS Terminal No." := POSTrans."POS Terminal No.";
        ReceiptLine."Receipt Code" := POSTrans."Receipt No.";
        ReceiptLine."Entry No." := LineNo;
        ReceiptLine."Receipt No" := 0;
        ReceiptLine."EFTPOS Receipt Text" := StrSubstNo('%1', NewText);
        ReceiptLine."Signature Required" := SignatureRequired;
        ReceiptLine."Date of Receipt" := Today;
        ReceiptLine."Time of Receipt" := Time;
        ReceiptLine.Insert;
    end;


    procedure NextReceiptEntryNo(): Integer
    var
        ReceiptLine: Record "EFTPOS Receipt Text";
    begin
        ReceiptLine.Reset;
        ReceiptLine.SetFilter("Store No.", '%1|%2', POSTrans."Store No.", '');
        ReceiptLine.SetFilter("POS Terminal No.", '%1|%2', POSTrans."POS Terminal No.", '');
        ReceiptLine.SetRange("Receipt Code", POSTrans."Receipt No.");
        if ReceiptLine.FindLast then
            exit(ReceiptLine."Entry No.")
        else
            exit(0);
    end;


    procedure AddEFTPOSLog(EntryType: Option TransComplete,TransError,ReceiptLine,TransStart; EntryNo: Integer; NewText: Text[250]; NewResponse: dotnet EFTPOSData)
    var
        EFTPOSLog: Record "EFTPOS Log";
        TempBlob: Codeunit "Temp Blob";
        FileMgt: Codeunit "File Management";
        TempPath: Text;
        //[RunOnClient]
        NewResponseLocal: dotnet EFTPOSData;
        testboolean: Boolean;
        OutStream_L: OutStream;
    begin
        //UPDATE: KUSHAL: Local DotNet Variable
        ///NewResponse := NewResponse.EFTPOSData();
        NewResponseLocal := NewResponse.EFTPOSData();// Call Constructor
        //testboolean := NewResponseLocal.SaveXMLToFile('C:\\PC_EFT\test.xml'); // :)
        //NewResponseLocal.ResponseCode := 'OK';
        // The below code does not run because the variable NewResponse is not an object in memory when passed through
        // codeunhits. Instead pass it by datatype
        //MESSAGE(FORMAT(testboolean));

        with EFTPOSLog do begin

            EntryNo += 1;
            Init;
            "Entry No." := EntryNo;
            "Line No." := 0;

            "Entry Type" := EFTPOSLog."entry type"::Log;
            if EntryType = Entrytype::ReceiptLine then
                "Event Type" := "event type"::Print
            else
                "Event Type" := "event type"::Transaction;
            if not IsNull(NewResponse) then begin
                "Event Code" := NewResponse.ResponseCode;
                "Event Text" := CopyStr(NewResponse.ResponseText, 1, 250);
                "Event Success" := NewResponse.Success;

                "Response Source" := NewResponse.ResponseSource;

                case NewResponse.ResponseSource of
                    0, //Transaction
                    9: //GetLastTransaction
                        begin
                            "Card Type" := NewResponse.CardType;
                            "Card Name" := NewResponse.CardType;
                            "Txn Ref" := NewResponse.TxnRef;
                            "Txn Type" := NewResponse.TxnType;
                            CAID := CopyStr(NewResponse.Caid, 1, MaxStrLen(CAID));
                            STAN := Format(NewResponse.Stan);
                            "Auth.code" := NewResponse.AuthCode;
                            PAN := NewResponse.PAN;
                            Merchant := NewResponse.Merchant;
                            "Account Type" := NewResponse.AccountType;
                            if NewResponse.ResponseSource = 9 then
                                "Last Txn Success" := NewResponse.LastTxnSuccess;
                        end;
                    2, //Receipt
                    4: //GetLastReceipt
                        begin
                            "Receipt Length" := NewResponse.ReceiptLength;
                            "Receipt Lines" := NewResponse.ReceiptLineCount;
                            "Receipt Type" := CopyStr(NewResponse.ReceiptType, 1, MaxStrLen("Receipt Type"));
                        end;
                end;

            end;

            //Amount
            if IsRefund then
                "Refund Amount" := AmtPurch
            else
                "Purchase Amount" := AmtPurch;
            "Cash Amount" := AmtCashout;

            "Store No." := POSTrans."Store No.";
            "POS Terminal No." := POSTrans."POS Terminal No.";

            "Receipt No." := ReceiptNo;
            "Log Date" := Today;
            "Log Time" := Time;
            Tag := TransID;
            "Display Line 1" := NewText;
            if Insert(true) then;


            //Save XML file to BLOB
            if not SetupRead then
                EFTPOSSetup.Get;
            if EFTPOSSetup."XML Log Path" <> '' then begin
                TempPath := EFTPOSSetup."XML Log Path" + Format(EntryNo) + '.xml';
                //UPDATE: KUSHAL: Local DotNet Variable
                NewResponseLocal.SaveXMLToFile(TempPath);
                if EFTPOSSetup."Save XML To Log" then begin
                    FileMgt.BLOBImportFromServerFile(TempBlob, TempPath);
                    TempBlob.CreateOutStream(OutStream_L);
                    "XML Data".CreateOutStream(OutStream_L);
                    if Modify(true) then;
                end;

            end else begin
                if EFTPOSSetup."Save XML To Log" then begin
                    //EFTPOS Dotnet run on client
                    //kevin //Removed code temporarily
                    // TempPath := FileMgt.ClientTempFileName('xml');
                    // //UPDATE: KUSHAL: Local DotNet Variable
                    // NewResponseLocal.SaveXMLToFile(TempPath);
                    // FileMgt.BLOBImport(TempBlob, TempPath);
                    // TempBlob.CreateOutStream(OutStream_L);
                    // "XML Data".CreateOutStream(OutStream_L);
                    // if Modify(true) then;
                    // FileMgt.DeleteClientFile(TempPath);
                    //kevin
                end;
            end;

            Commit;
        end;
    end;

    local procedure GetDateTime(DateTimeTxt: Text[50]; var dateOut: Text; var timeOut: Text)
    begin
        dateOut := '';
        timeOut := '';
        if DateTimeTxt = '' then
            exit;

        dateOut := CopyStr(DateTimeTxt, 1, 8);
        timeOut := CopyStr(DateTimeTxt, 9);
    end;


    procedure AddCardEntry(NewResponse: dotnet EFTPOSData; NewPurchaseAmount: Decimal; PageMode: Option PurchAuthorisation,PreSettlement,Settlement,PrintLastReceipt,DoLastTransaction,DoLogon,DoReset,DoAbout,TendLastEFT,PayCardSurcharge)
    var
        CardEntry: Record "LSC POS Card Entry";
        StoreTender: Record "LSC Tender Type";
        CardLine: Integer;
        LocTendType: Record "LSC Tender Type Card Setup";
        DateTimeTxt: Text[50];
        AuthorisedOK: Boolean;
    begin
        with CardEntry do begin
            AmtPurch := NewPurchaseAmount;
            Reset;
            LockTable;
            SetFilter("Store No.", '%1|%2', POSTrans."Store No.", '');
            SetFilter("POS Terminal No.", '%1|%2', POSTrans."POS Terminal No.", '');
            SetRange("Receipt No.", POSTrans."Receipt No.");

            if FindLast then
                CardLine := "Entry No."
            else
                CardLine := 0;

            CardLine += 1000;
            Init;
            "Res.code" := CopyStr(StrSubstNo('%1', NewResponse.ResponseCode), 1, 20);

            StoreTender.Reset;
            StoreTender.SetRange("Store No.", POSTrans."Store No.");
            StoreTender.SetRange("EFT POS", true);
            if StoreTender.FindFirst then
                CardEntry."Tender Type" := StoreTender.Code;

            "Store No." := POSTrans."Store No.";
            "POS Terminal No." := POSTrans."POS Terminal No.";
            "Entry No." := NextCardEntryNo();
            "Receipt No." := POSTrans."Receipt No.";
            "Line No." := CardLine;

            Date := POSTrans."Trans. Date";
            Time := POSTrans."Trans Time";


            Evaluate("EFT Trans. Date", StrSubstNo('%1', NewResponse.ResponseDate));
            Evaluate("EFT Trans. Time", StrSubstNo('%1', NewResponse.ResponseTime));

            //9 = GetLastTransaction
            if (NewResponse.ResponseSource = 9) then begin
                //the NewResponse.Success only means that the request returns OK
                //check for LastTxnSuccess to see of last transaction's authorisation is OK
                if ("Receipt No." = NewResponse.TxnRef) and
                   (NewResponse.Success) and (NewResponse.LastTxnSuccess) then begin
                    "Extra Data" := 'DGLT';
                    AuthorisedOK := true;
                end else
                    AuthorisedOK := false;
            end else
                AuthorisedOK := NewResponse.Success;

            //"Authorisation Ok" := NewResponse.Success;
            "Authorisation Ok" := AuthorisedOK;
            "EFT Auth.code" := CopyStr(NewResponse.AuthCode, 1, MaxStrLen("EFT Auth.code"));

            if "Authorisation Ok" then begin
                "EFO EFT Stan" := Format(NewResponse.Stan); //System Trace Audit Number
                "EFO EFT Caid" := CopyStr(NewResponse.Caid, 1, MaxStrLen("EFO EFT Caid")); //Merchant Id
            end;

            //DateTimeTxt := NewResponse.DateTimeTransaction; //Format: YYMMDDDDHHMMSS
            GetDateTime(DateTimeTxt, "EFT Trans. Date", "EFT Trans. Time");

            ResponseCardType := NewResponse.CardType;

            LocTendType.Reset;
            LocTendType.SetRange("Store No.", POSTrans."Store No.");
            LocTendType.SetRange("Tender Type Code", CardEntry."Tender Type");
            //LocTendType.SETRANGE("PAYEX Card Type",UPPERCASE(ResponseCardType));
            if LocTendType.FindFirst then begin
                "Card Type" := LocTendType."Card No.";
                if LocTendType."Group Card No." <> '' then begin
                    "EFO Actual Card Type" := CardEntry."Card Type";
                    "Card Type" := LocTendType."Group Card No.";
                end;
            end;

            "Card Type" := NewResponse.CardType;
            "Card Type Name" := NewResponse.CardType;//"Card Type";

            "Res.code" := CopyStr(NewResponse.ResponseCode, 1, MaxStrLen("Res.code"));
            Message := CopyStr(NewResponse.ResponseText, 1, MaxStrLen(Message));

            "EFT Trans. No." := CopyStr(NewResponse.TxnRef, 1, MaxStrLen("EFT Trans. No."));
            "EFT Batch No." := CopyStr("EFT Trans. No.", 1, MaxStrLen("EFT Batch No."));

            if IsRefund then begin
                "Transaction Type" := CardEntry."transaction type"::Refund;
                Validate(Amount, -Abs(AmtPurch));
            end
            else begin
                "Transaction Type" := CardEntry."transaction type"::Sale;
                Validate(Amount, Abs(AmtPurch));
            end;

            Validate(Cashback, AmtCashout);

            "Auth. Source Code" := 'T';

            "EFO EFT Request Type" := PageMode + 1;

            Insert(true);
            Commit;

        end;
    end;

    procedure SetEFTPOSSetup(_EFTPOSSetup: Record "EFTPOS Setup")
    begin
        EFTPOSSetup := _EFTPOSSetup;
        SetupRead := true;
    end;

    procedure AddEFTPOSLogV2(EntryType: Option TransComplete,TransError,ReceiptLine,TransStart; EntryNo: Integer; NewText: Text[250]; NewResponse: dotnet EFTDataLS)
    var
        EFTPOSLog: Record "EFTPOS Log";
        TempBlob: Codeunit "Temp Blob";
        FileMgt: Codeunit "File Management";
        TempPath: Text;
        //[RunOnClient]
        NewResponseLocal: dotnet EFTDataLS;
        testboolean: Boolean;
        OutStream_L: OutStream;
    begin
        //UPDATE: KUSHAL: Local DotNet Variable
        ///NewResponse := NewResponse.EFTPOSData();
        NewResponseLocal := NewResponse.EFTDataLS();// Call Constructor
        //testboolean := NewResponseLocal.SaveXMLToFile('C:\\PC_EFT\test.xml'); // :)
        //NewResponseLocal.ResponseCode := 'OK';
        // The below code does not run because the variable NewResponse is not an object in memory when passed through
        // codeunhits. Instead pass it by datatype
        //MESSAGE(FORMAT(testboolean));

        with EFTPOSLog do begin

            EntryNo += 1;
            Init;
            "Entry No." := EntryNo;
            "Line No." := 0;

            "Entry Type" := EFTPOSLog."entry type"::Log;
            if EntryType = Entrytype::ReceiptLine then
                "Event Type" := "event type"::Print
            else
                "Event Type" := "event type"::Transaction;
            if not IsNull(NewResponse) then begin
                "Event Code" := NewResponse.ResponseCode;
                "Event Text" := CopyStr(NewResponse.ResponseText, 1, 250);
                "Event Success" := NewResponse.Success;

                "Response Source" := NewResponse.ResponseSource;

                case NewResponse.ResponseSource of
                    0, //Transaction
                    9: //GetLastTransaction
                        begin
                            "Card Type" := NewResponse.CardType;
                            "Card Name" := NewResponse.CardType;
                            "Txn Ref" := NewResponse.TxnRef;
                            "Txn Type" := NewResponse.TxnType;
                            CAID := CopyStr(NewResponse.Caid, 1, MaxStrLen(CAID));
                            STAN := Format(NewResponse.Stan);
                            "Auth.code" := NewResponse.AuthCode;
                            PAN := NewResponse.PAN;
                            Merchant := NewResponse.Merchant;
                            "Account Type" := NewResponse.AccountType;
                            if NewResponse.ResponseSource = 9 then
                                "Last Txn Success" := NewResponse.LastTxnSuccess;
                        end;
                    2, //Receipt
                    4: //GetLastReceipt
                        begin
                            "Receipt Length" := NewResponse.ReceiptLength;
                            "Receipt Lines" := NewResponse.ReceiptLineCount;
                            "Receipt Type" := CopyStr(NewResponse.ReceiptType, 1, MaxStrLen("Receipt Type"));
                        end;
                end;

            end;

            //Amount
            if IsRefund then
                "Refund Amount" := AmtPurch
            else
                "Purchase Amount" := AmtPurch;
            "Cash Amount" := AmtCashout;

            "Store No." := POSTrans."Store No.";
            "POS Terminal No." := POSTrans."POS Terminal No.";

            "Receipt No." := ReceiptNo;
            "Log Date" := Today;
            "Log Time" := Time;
            Tag := TransID;
            "Display Line 1" := NewText;
            if Insert(true) then;


            //Save XML file to BLOB
            if not SetupRead then
                EFTPOSSetup.Get;
            if EFTPOSSetup."XML Log Path" <> '' then begin
                TempPath := EFTPOSSetup."XML Log Path" + Format(EntryNo) + '.xml';
                //UPDATE: KUSHAL: Local DotNet Variable
                NewResponseLocal.SaveXMLToFile(TempPath);
                if EFTPOSSetup."Save XML To Log" then begin
                    FileMgt.BLOBImportFromServerFile(TempBlob, TempPath);
                    TempBlob.CreateOutStream(OutStream_L);
                    "XML Data".CreateOutStream(OutStream_L);
                    if Modify(true) then;
                end;

            end else begin
                if EFTPOSSetup."Save XML To Log" then begin
                    //EFTPOS Dotnet run on client
                    //kevin //Removed code temporarily
                    // TempPath := FileMgt.ClientTempFileName('xml');
                    // //UPDATE: KUSHAL: Local DotNet Variable
                    // NewResponseLocal.SaveXMLToFile(TempPath);
                    // FileMgt.BLOBImport(TempBlob, TempPath);
                    // TempBlob.CreateOutStream(OutStream_L);
                    // "XML Data".CreateOutStream(OutStream_L);
                    // if Modify(true) then;
                    // FileMgt.DeleteClientFile(TempPath);
                    //kevin
                end;
            end;

            Commit;
        end;
    end;

    procedure AddCardEntryV2(NewResponse: dotnet EFTDataLS; NewPurchaseAmount: Decimal; PageMode: Option PurchAuthorisation,PreSettlement,Settlement,PrintLastReceipt,DoLastTransaction,DoLogon,DoReset,DoAbout,TendLastEFT,PayCardSurcharge)
    var
        CardEntry: Record "LSC POS Card Entry";
        StoreTender: Record "LSC Tender Type";
        CardLine: Integer;
        LocTendType: Record "LSC Tender Type Card Setup";
        DateTimeTxt: Text[50];
        AuthorisedOK: Boolean;
    begin
        with CardEntry do begin
            AmtPurch := NewPurchaseAmount;
            Reset;
            LockTable;
            SetFilter("Store No.", '%1|%2', POSTrans."Store No.", '');
            SetFilter("POS Terminal No.", '%1|%2', POSTrans."POS Terminal No.", '');
            SetRange("Receipt No.", POSTrans."Receipt No.");

            if FindLast then
                CardLine := "Entry No."
            else
                CardLine := 0;

            CardLine += 1000;
            Init;
            "Res.code" := CopyStr(StrSubstNo('%1', NewResponse.ResponseCode), 1, 20);

            StoreTender.Reset;
            StoreTender.SetRange("Store No.", POSTrans."Store No.");
            StoreTender.SetRange("EFT POS", true);
            if StoreTender.FindFirst then
                CardEntry."Tender Type" := StoreTender.Code;

            "Store No." := POSTrans."Store No.";
            "POS Terminal No." := POSTrans."POS Terminal No.";
            "Entry No." := NextCardEntryNo();
            "Receipt No." := POSTrans."Receipt No.";
            "Line No." := CardLine;

            //Date := POSTrans."Trans. Date";
            Date := POSTrans."Original Date";
            Time := POSTrans."Trans Time";


            Evaluate("EFT Trans. Date", StrSubstNo('%1', NewResponse.ResponseDate));
            Evaluate("EFT Trans. Time", StrSubstNo('%1', NewResponse.ResponseTime));

            //9 = GetLastTransaction
            if (NewResponse.ResponseSource = 9) then begin
                //the NewResponse.Success only means that the request returns OK
                //check for LastTxnSuccess to see of last transaction's authorisation is OK
                if ("Receipt No." = NewResponse.TxnRef) and
                   (NewResponse.Success) and (NewResponse.LastTxnSuccess) then begin
                    "Extra Data" := 'DGLT';
                    AuthorisedOK := true;
                end else
                    AuthorisedOK := false;
            end else
                AuthorisedOK := NewResponse.Success;

            //"Authorisation Ok" := NewResponse.Success;
            "Authorisation Ok" := AuthorisedOK;
            "EFT Auth.code" := CopyStr(NewResponse.AuthCode, 1, MaxStrLen("EFT Auth.code"));

            if "Authorisation Ok" then begin
                "EFO EFT Stan" := Format(NewResponse.Stan); //System Trace Audit Number
                "EFO EFT Caid" := CopyStr(NewResponse.Caid, 1, MaxStrLen("EFO EFT Caid")); //Merchant Id
            end;

            //DateTimeTxt := NewResponse.DateTimeTransaction; //Format: YYMMDDDDHHMMSS
            GetDateTime(DateTimeTxt, "EFT Trans. Date", "EFT Trans. Time");

            ResponseCardType := CopyStr(NewResponse.CardType, 1, 20);

            LocTendType.Reset;
            LocTendType.SetRange("Store No.", POSTrans."Store No.");
            LocTendType.SetRange("Tender Type Code", CardEntry."Tender Type");
            //LocTendType.SETRANGE("PAYEX Card Type",UPPERCASE(ResponseCardType));
            if LocTendType.FindFirst then begin
                "Card Type" := LocTendType."Card No.";
                if LocTendType."Group Card No." <> '' then begin
                    "EFO Actual Card Type" := CardEntry."Card Type";
                    "Card Type" := LocTendType."Group Card No.";
                end;
            end;

            //"Card Type" := CopyStr(NewResponse.CardType, 1, MaxStrLen("Card Type"));
            "Card Type" := Format(NewResponse.CardName);
            "Card Type Name" := NewResponse.CardType;//"Card Type";

            "Res.code" := CopyStr(NewResponse.ResponseCode, 1, MaxStrLen("Res.code"));
            Message := CopyStr(NewResponse.ResponseText, 1, MaxStrLen(Message));

            "EFT Trans. No." := CopyStr(NewResponse.TxnRef, 1, MaxStrLen("EFT Trans. No."));
            "EFT Batch No." := CopyStr("EFT Trans. No.", 1, MaxStrLen("EFT Batch No."));

            if IsRefund then begin
                "Transaction Type" := CardEntry."transaction type"::Refund;
                Validate(Amount, -Abs(AmtPurch));
            end
            else begin
                "Transaction Type" := CardEntry."transaction type"::Sale;
                Validate(Amount, Abs(AmtPurch));
            end;

            Validate(Cashback, AmtCashout);

            "Auth. Source Code" := 'T';

            "EFO EFT Request Type" := PageMode + 1;

            Insert(true);
            Commit;

        end;
    end;


}

