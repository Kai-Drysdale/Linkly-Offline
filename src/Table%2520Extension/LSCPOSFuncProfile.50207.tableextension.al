tableextension 50207 "EFT LSCPOSFuncProfile" extends "LSC POS Func. Profile"
{
    fields
    {
        field(50201; "EFT Days EFT Log Exists"; integer)
        {
            DataClassification = CustomerContent;
            Caption = 'Days Linkly Log Exists';
            MinValue = 0;
            BlankZero = true;
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