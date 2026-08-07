tableextension 50202 "EFT Tender Type Card Setup Ext" extends "LSC Tender Type Card Setup"
{
    fields
    {
        field(50200; "Group Card No."; Code[10])
        {
            Caption = 'Group Card No.';
            DataClassification = CustomerContent;
            Description = 'MPG1.00';
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