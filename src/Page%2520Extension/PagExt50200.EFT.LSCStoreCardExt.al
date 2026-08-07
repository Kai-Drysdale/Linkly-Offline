pageextension 50200 "EFT LSC Store Card Ext" extends "LSC Store Card"
{
    layout
    {
        addafter(General)
        {
            group(EFTGroup)
            {
                Caption = 'EFT';
                field("Disable EFT Surcharge"; Rec."Disable EFT Surcharge")
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