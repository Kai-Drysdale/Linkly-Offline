Page 50201 "EFTPOS Log"
{
    // MPG1.00 17-06-16
    //   New Object
    // 
    // MPG1.05 01-05-19 LP
    //   Revisited PC-EFTPOS

    ApplicationArea = Basic;
    Caption = 'EFTPOS Log';
    Editable = false;
    PageType = List;
    SourceTable = "EFTPOS Log";
    UsageCategory = Lists;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Entry No."; Rec."Entry No.")
                {
                    ApplicationArea = Basic;
                }
                field("Entry Type"; Rec."Entry Type")
                {
                    ApplicationArea = Basic;
                }
                field("Event Type"; Rec."Event Type")
                {
                    ApplicationArea = Basic;
                }
                field("Event Code"; Rec."Event Code")
                {
                    ApplicationArea = Basic;
                }
                field("Event Text"; Rec."Event Text")
                {
                    ApplicationArea = Basic;
                }
                field("Event Success"; Rec."Event Success")
                {
                    ApplicationArea = Basic;
                }
                field("Receipt Length"; Rec."Receipt Length")
                {
                    ApplicationArea = Basic;
                }
                field("Receipt Lines"; Rec."Receipt Lines")
                {
                    ApplicationArea = Basic;
                }
                field("Receipt No."; Rec."Receipt No.")
                {
                    ApplicationArea = Basic;
                }
                field("Log Date"; Rec."Log Date")
                {
                    ApplicationArea = Basic;
                }
                field("Log Time"; Rec."Log Time")
                {
                    ApplicationArea = Basic;
                }
                field("Has Detail"; Rec."Has Detail")
                {
                    ApplicationArea = Basic;
                }
                field("Account Type"; Rec."Account Type")
                {
                    ApplicationArea = Basic;
                }
                field(AIIC; Rec.AIIC)
                {
                    ApplicationArea = Basic;
                }
                field("Cash Amount"; Rec."Cash Amount")
                {
                    ApplicationArea = Basic;
                }
                field("Purchase Amount"; Rec."Purchase Amount")
                {
                    ApplicationArea = Basic;
                }
                field("Refund Amount"; Rec."Refund Amount")
                {
                    ApplicationArea = Basic;
                }
                field(CAID; Rec.CAID)
                {
                    ApplicationArea = Basic;
                }
                field("Card Type"; Rec."Card Type")
                {
                    ApplicationArea = Basic;
                }
                field("Card Name"; Rec."Card Name")
                {
                    ApplicationArea = Basic;
                }
                field("Cat ID"; Rec."Cat ID")
                {
                    ApplicationArea = Basic;
                }
                field("Cut Receipt"; Rec."Cut Receipt")
                {
                    ApplicationArea = Basic;
                }
                field("Response Date"; Rec."Response Date")
                {
                    ApplicationArea = Basic;
                }
                field("Date Settlement"; Rec."Date Settlement")
                {
                    ApplicationArea = Basic;
                }
                field("Message Type"; Rec."Message Type")
                {
                    ApplicationArea = Basic;
                }
                field("Reset Totals"; Rec."Reset Totals")
                {
                    ApplicationArea = Basic;
                }
                field("Response Type"; Rec."Response Type")
                {
                    ApplicationArea = Basic;
                }
                field("Settle Card Count"; Rec."Settle Card Count")
                {
                    ApplicationArea = Basic;
                }
                field("Settle Card Totals"; Rec."Settle Card Totals")
                {
                    ApplicationArea = Basic;
                }
                field("Response Time"; Rec."Response Time")
                {
                    ApplicationArea = Basic;
                }
                field(STAN; Rec.STAN)
                {
                    ApplicationArea = Basic;
                }
                field("Txn Ref"; Rec."Txn Ref")
                {
                    ApplicationArea = Basic;
                }
                field("Txn Type"; Rec."Txn Type")
                {
                    ApplicationArea = Basic;
                }
                field("Last Txn Success"; Rec."Last Txn Success")
                {
                    ApplicationArea = Basic;
                }
                field("Pan Source"; Rec."Pan Source")
                {
                    ApplicationArea = Basic;
                }
                field("Response Source"; Rec."Response Source")
                {
                    ApplicationArea = Basic;
                }
                field("Receipt Auto Print"; Rec."Receipt Auto Print")
                {
                    ApplicationArea = Basic;
                }
                field("Display Line 1"; Rec."Display Line 1")
                {
                    ApplicationArea = Basic;
                }
                field("Display Line 2"; Rec."Display Line 2")
                {
                    ApplicationArea = Basic;
                }
                field(Merchant; Rec.Merchant)
                {
                    ApplicationArea = Basic;
                }
                field(Tag; Rec.Tag)
                {
                    ApplicationArea = Basic;
                }
                field("Receipt Type"; Rec."Receipt Type")
                {
                    ApplicationArea = Basic;
                }
                field("XML Data"; Rec."XML Data")
                {
                    ApplicationArea = Basic;
                }
                field("Line No."; Rec."Line No.")
                {
                    ApplicationArea = Basic;
                }
                field("Store No."; Rec."Store No.")
                {
                    ApplicationArea = Basic;
                }
                field("POS Terminal No."; Rec."POS Terminal No.")
                {
                    ApplicationArea = Basic;
                }
            }
        }
    }

    actions
    {
        area(navigation)
        {
            action("View Log")
            {
                ApplicationArea = Basic;
                Image = ViewDetails;
                Visible = false;
                trigger OnAction()
                begin
                    //ViewLog;
                end;
            }
        }
    }

    var
        Text001: label 'View Log Data XML?';
        Text002: label 'XML Data Missing ';
        Text003: label 'Unable to Export XML';


    // procedure ViewLog()
    // var
    //     FileMgt: Codeunit "File Management";
    //     TempPath: Text;
    //     InS: InStream;
    //     XMLDoc: dotnet XmlDocument;
    //     ServerTempFileName: Text;
    // begin
    //     if not Confirm(Text001, false) then
    //         exit;

    //     Rec.CalcFields("XML Data");
    //     if not Rec."XML Data".Hasvalue then
    //         Error(Text002);

    //     //TempPath := ENVIRON('TEMP') + 'LogEntry' + FORMAT("Entry No.") + '.xml';
    //     Rec."XML Data".CreateInstream(InS);
    //     XMLDoc := XMLDoc.XmlDocument();
    //     XMLDoc.Save(InS);

    //     ServerTempFileName := FileMgt.ServerTempFileName('xml');
    //     XMLDoc.Save(ServerTempFileName);
    //     TempPath := FileMgt.ClientTempFileName('xml');
    //     FileMgt.DownloadToFile(ServerTempFileName, TempPath);
    //     if FILE.Exists(TempPath) then
    //         Hyperlink(TempPath)
    //     else
    //         Error(Text003);
    // end;
}

