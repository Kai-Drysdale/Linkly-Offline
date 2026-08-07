Page 50200 "EFTPOS Setup"
{
    // MPG1.00 17-06-16 JKT
    //   - New Object

    ApplicationArea = Basic;
    Caption = 'EFTPOS Setup';
    PageType = Card;
    SourceTable = "EFTPOS Setup";
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                field("Interface Type"; Rec."Interface Type")
                {
                    ApplicationArea = Basic;
                }
                field("XML Log Path"; Rec."XML Log Path")
                {
                    ApplicationArea = Basic;
                }
                field("Save XML To Log"; Rec."Save XML To Log")
                {
                    ApplicationArea = Basic;
                }
                field("Show Processing Page"; Rec."Show Processing Page")
                {
                    ApplicationArea = Basic;
                }
                field("Log Events Received"; Rec."Log Events Received")
                {
                    ApplicationArea = Basic;
                }
                field("Send Display Events"; Rec."Send Display Events")
                {
                    ApplicationArea = Basic;
                }
                field("No. Log Days"; Rec."No. Log Days")
                {
                    ApplicationArea = Basic;
                }
                field("EFT Tender"; Rec."EFT Tender")
                {
                    ApplicationArea = all;
                }
                field("Cashout Item"; Rec."Cashout Item")
                {

                    ApplicationArea = all;
                }
                field("Cashout Tender"; Rec."Cashout Tender")
                {
                    ApplicationArea = all;
                }
            }
            group(Banks)
            {
                Caption = 'Banks';
                field("Country Code"; Rec."Country Code")
                {
                    ApplicationArea = Basic;
                }
                field("Bank Name"; Rec."Bank Name")
                {
                    ApplicationArea = Basic;
                }
            }
            group(Timeout)
            {
                Caption = 'Timeout';
                field("Capture Timeout (x 10 MS)"; Rec."Capture Timeout (x 10 MS)")
                {
                    ApplicationArea = Basic;
                }
                field("Event Timeout (Seconds)"; Rec."Event Timeout (Seconds)")
                {
                    ApplicationArea = Basic;
                }
                field("Log Interval (Seconds)"; Rec."Log Interval (Seconds)")
                {
                    ApplicationArea = Basic;
                }
            }
            // group(TYRO)
            // {
            //     Caption = 'TYRO';
            //     field("TYRO Product Vendor"; Rec."TYRO Product Vendor")
            //     {
            //         ApplicationArea = Basic;
            //     }
            //     field("TYRO Product Name"; Rec."TYRO Product Name")
            //     {
            //         ApplicationArea = Basic;
            //     }
            //     field("TYRO Product Version"; Rec."TYRO Product Version")
            //     {
            //         ApplicationArea = Basic;
            //     }
            // }
        }
    }

    actions
    {
        area(processing)
        {
            action("Initialise POS Commands")
            {
                ApplicationArea = Basic;
                Image = "Action";

                trigger OnAction()
                begin
                    Rec.Initialise;
                end;
            }
        }
    }

    trigger OnOpenPage()
    begin
        Rec.Reset;
        if not Rec.Get then begin
            Rec.Init;
            Rec.Insert;
        end;
    end;
}

