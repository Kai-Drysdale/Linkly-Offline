tableextension 50205 "LSC POS Trans. Line Ext" extends "LSC POS Trans. Line"
{
    fields
    {
        field(50200; "EFT Cashout Amount"; Decimal)
        {
            DataClassification = CustomerContent;
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