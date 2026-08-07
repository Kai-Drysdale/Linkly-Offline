tableextension 50203 "EFT LSC Store Ext" extends "LSC Store"
{
    fields
    {
        field(50200; "Disable EFT Surcharge"; Boolean)
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