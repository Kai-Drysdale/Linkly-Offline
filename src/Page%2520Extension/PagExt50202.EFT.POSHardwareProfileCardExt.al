pageextension 50202 "POS Hardware Profile Card Ext" extends "LSC POS Hardware Profile Card"
{
    layout
    {
        addafter(General)
        {
            group(PCEFTPOSGrp)
            {
                Caption = 'PCEFTPOS';
                field("PCEFTPOS Active"; Rec."PCEFTPOS Active")
                {
                }
            }
        }
    }

    actions
    {
        // Add changes to page actions here
    }

    var
        myInt: Integer;
}