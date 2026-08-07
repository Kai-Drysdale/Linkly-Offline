tableextension 50204 "LSC POS Hardware Profile Ext" extends "LSC POS Hardware Profile"
{
    fields
    {
        field(50200; "PCEFTPOS Active"; Boolean)
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