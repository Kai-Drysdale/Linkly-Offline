pageextension 50203 "EFT LSCPOSFuncProfileCard" extends "LSC POS Func. Profile Card"
{
    layout
    {
        addafter("Trans. Delete Reminder")
        {
            field("EFT Days EFT Log Exists"; Rec."EFT Days EFT Log Exists")
            {
                ApplicationArea = All;
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