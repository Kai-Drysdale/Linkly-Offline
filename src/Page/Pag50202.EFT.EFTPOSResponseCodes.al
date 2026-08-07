Page 50202 "EFTPOS Response Codes"
{
    // MPG1.00 17-06-16
    //   - New Object
    // 
    // MCS1.02 21-06-20 KK
    //   Jira PS-1755 Added a field Print Merchant Copy

    ApplicationArea = Basic;
    Caption = 'EFTPOS Response Codes';
    PageType = List;
    SourceTable = "EFTPOS Approval Code List";
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Interface Type"; Rec."Interface Type")
                {
                    ApplicationArea = Basic;
                }
                field("Country Code"; Rec."Country Code")
                {
                    ApplicationArea = Basic;
                }
                field("Bank Type"; Rec."Bank Type")
                {
                    ApplicationArea = Basic;
                }
                field("Response Codes"; Rec."Response Codes")
                {
                    ApplicationArea = Basic;
                }
                field(Approve; Rec.Approve)
                {
                    ApplicationArea = Basic;
                }
                field("Print Merchant Copy"; Rec."Print Merchant Copy")
                {
                    ApplicationArea = Basic;
                }
                field("Force Get Last Transaction"; Rec."Force Get Last Transaction")
                {
                    ApplicationArea = Basic;
                }
                field("Response Text"; Rec."Response Text")
                {
                    ApplicationArea = Basic;
                }
                field(Date; Rec.Date)
                {
                    ApplicationArea = Basic;
                }
            }
        }
    }

    actions
    {
    }
}

