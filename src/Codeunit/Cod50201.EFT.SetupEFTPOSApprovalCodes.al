Codeunit 50201 "EFT Setup EFTPOS ApprovalCodes"
{
    // MPG1.00 17-06-16
    //   Code added to create Approval Codes
    // 
    // MPG1.05 01-05-19 LP
    //   Revisited PC-EFTPOS


    trigger OnRun()
    begin
        EFTSetup.Get;

        AddEFTApprvCode('00', true, false);
        AddEFTApprvCode('01', false, false);
        AddEFTApprvCode('03', false, false);
        AddEFTApprvCode('04', false, false);
        AddEFTApprvCode('08', true, false); //signature required
        AddEFTApprvCode('11', true, false);
        AddEFTApprvCode('12', false, false);
        AddEFTApprvCode('13', false, false);
        AddEFTApprvCode('14', false, false);
        AddEFTApprvCode('21', true, false); //aprrove reversal
        AddEFTApprvCode('36', false, false);
        AddEFTApprvCode('39', false, false);
        AddEFTApprvCode('41', false, false);
        AddEFTApprvCode('42', false, false);
        AddEFTApprvCode('43', false, false);
        AddEFTApprvCode('51', false, false);
        AddEFTApprvCode('52', false, false);
        AddEFTApprvCode('53', false, false);
        AddEFTApprvCode('54', false, false);
        AddEFTApprvCode('55', false, false);
        AddEFTApprvCode('56', false, false);
        AddEFTApprvCode('57', false, false);
        AddEFTApprvCode('58', false, false);
        AddEFTApprvCode('59', false, false);
        AddEFTApprvCode('60', false, false);
        AddEFTApprvCode('61', false, false);
        AddEFTApprvCode('62', false, false);
        AddEFTApprvCode('75', false, false);
        AddEFTApprvCode('91', false, false);
        AddEFTApprvCode('94', false, false);
        AddEFTApprvCode('96', false, false);
        AddEFTApprvCode('97', false, false);
        AddEFTApprvCode('98', false, false);
        AddEFTApprvCode('Q5', false, false);
        AddEFTApprvCode('R1', false, false);
        AddEFTApprvCode('S1', false, false);
        AddEFTApprvCode('Z6', false, false);
        AddEFTApprvCode('Z8', false, false);
        AddEFTApprvCode('Z9', false, false);

        //Terminal response
        AddEFTApprvCode('B5', false, true);
        AddEFTApprvCode('N0', false, false);
        AddEFTApprvCode('N1', false, false);
        AddEFTApprvCode('N2', false, false);
        AddEFTApprvCode('N3', false, false);
        AddEFTApprvCode('PB', false, true);
        AddEFTApprvCode('PF', false, true);
        AddEFTApprvCode('Q6', false, false);
        AddEFTApprvCode('S0', false, true);
        AddEFTApprvCode('S6', false, true);
        AddEFTApprvCode('S8', false, true);
        AddEFTApprvCode('TA', false, true);
        AddEFTApprvCode('TF', false, true);
        AddEFTApprvCode('TI', false, true);
        AddEFTApprvCode('TL', false, true);
        AddEFTApprvCode('TM', false, false);
        AddEFTApprvCode('TO', false, true);
        AddEFTApprvCode('TP', false, true);
        AddEFTApprvCode('TV', false, true);
        AddEFTApprvCode('TX', false, true);
        AddEFTApprvCode('X1', false, true);
        AddEFTApprvCode('X2', false, true);
        AddEFTApprvCode('X3', false, true);
        AddEFTApprvCode('X5', false, true);
        AddEFTApprvCode('X6', false, true);
        AddEFTApprvCode('XB', false, true);
        AddEFTApprvCode('XC', false, true);
        AddEFTApprvCode('XG', false, true);
        AddEFTApprvCode('Z1', false, true);
        AddEFTApprvCode('Z5', false, true);
    end;

    var
        EFTAPPCodes: Record "EFTPOS Approval Code List";
        EFTSetup: Record "EFTPOS Setup";

    local procedure AddEFTApprvCode(ResponseCode: Code[10]; Approve: Boolean; ForceGetLastTrans: Boolean)
    begin
        if not EFTAPPCodes.Get(EFTSetup."Interface Type", EFTSetup."Country Code", EFTSetup."Bank Name", ResponseCode) then begin
            EFTAPPCodes.Init;
            EFTAPPCodes."Interface Type" := EFTSetup."Interface Type";
            EFTAPPCodes."Country Code" := EFTSetup."Country Code";
            EFTAPPCodes."Bank Type" := EFTSetup."Bank Name";
            EFTAPPCodes."Response Codes" := ResponseCode;
            EFTAPPCodes.Approve := Approve;
            EFTAPPCodes."Force Get Last Transaction" := ForceGetLastTrans;
            EFTAPPCodes.Insert;
        end;
    end;
}

