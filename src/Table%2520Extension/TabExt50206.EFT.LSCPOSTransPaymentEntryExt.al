tableextension 50206 "LSC Trans. Payment Entry Ext" extends "LSC Trans. Payment Entry"
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