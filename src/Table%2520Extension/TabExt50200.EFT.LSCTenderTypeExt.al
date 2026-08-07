tableextension 50200 "EFT LSC Tender Type Ext" extends "LSC Tender Type"
{
    fields
    {
        field(50200; "EFT POS"; Boolean)
        {
            DataClassification = CustomerContent;
        }
        field(50201; "Cashout Limit"; Decimal)
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