pageextension 50201 "EFT LSC Tender Type Card Ext" extends "LSC Tender Type Card"
{
    layout
    {
        addafter(General)
        {
            group(EFTGroup)
            {
                Caption = 'EFT';
                field("EFT POS"; Rec."EFT POS")
                {
                }
                field("Cashout Limit"; Rec."Cashout Limit")
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