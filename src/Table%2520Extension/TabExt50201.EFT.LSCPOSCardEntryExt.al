tableextension 50201 "EFT LSC POS Card Entry Ext" extends "LSC POS Card Entry"
{
    fields
    {
        field(50200; "EFO Actual Card Type"; Code[20])
        {
            Caption = 'Actual Card Type';
            DataClassification = CustomerContent;
            Description = 'MPG1.00';
        }
        field(50201; "EFO TYRO Res. Code"; Code[20])
        {
            Caption = 'Res.code';
            DataClassification = CustomerContent;
            Description = 'MPG1.00';
        }
        field(50202; "EFO EFT Request Type"; Option)
        {
            Caption = 'EFT Request Type';
            DataClassification = CustomerContent;
            Description = 'MPG1.05';
            OptionCaption = ' ,PurchAuthorisation,PreSettlement,Settlement,PrintLastReceipt,DoLastTransaction,DoLogon,DoReset,DoAbout,TendLastEFT,PayCardSurcharge';
            OptionMembers = " ",PurchAuthorisation,PreSettlement,Settlement,PrintLastReceipt,DoLastTransaction,DoLogon,DoReset,DoAbout,TendLastEFT,PayCardSurcharge;
        }
        field(50203; "EFO EFT Stan"; Text[30])
        {
            Caption = 'EFT Stan';
            DataClassification = CustomerContent;
            Description = 'MPG1.05';
        }
        field(50204; "EFO EFT Caid"; Code[20])
        {
            Caption = 'EFT Caid';
            DataClassification = CustomerContent;
            Description = 'MPG1.05';
        }
    }

    keys
    {
        // Add changes to keys here
    }

    fieldgroups
    {
        // Add changes to field groups here
    }

    var
        myInt: Integer;
}