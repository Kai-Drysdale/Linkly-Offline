Table 50200 "EFTPOS Setup"
{
    // MPG1.00 17-06-16 JKT
    //   - New Object
    // 
    // MCS1.09 14-07-20 LP
    //   Re-captioned field "Capture Timeout (x 10 MS)" to "Polling Interval (x 10 ms)"

    Caption = 'EFTPOS Setup';

    fields
    {
        field(1; "Primary Key"; Code[20])
        {
        }
        field(2; "XML Log Path"; Text[250])
        {
            Caption = 'XML Log Path';
        }
        field(3; "Show Processing Page"; Boolean)
        {
            Caption = 'Show Processing Page';
        }
        field(4; "Interface Type"; Option)
        {
            Caption = 'Interface Type';
            OptionCaption = ' ,PCEFTPOS,TYRO,Payment Express';
            OptionMembers = " ",PCEFTPOS,TYRO,"Payment Express";
        }
        field(5; "Save XML To Log"; Boolean)
        {
            Caption = 'Save XML To Log';
        }
        field(6; "Capture Timeout (x 10 MS)"; Integer)
        {
            Caption = 'Polling Interval (x 10 ms)';
        }
        field(7; "Country Code"; Option)
        {
            Caption = 'Country Code';
            OptionCaption = ' ,AU,NZ';
            OptionMembers = " ",AU,NZ;
        }
        field(8; "Bank Name"; Code[10])
        {
            Caption = 'Bank Name';
        }
        field(9; "No. Log Days"; Integer)
        {
            Caption = 'No. Log Days';
        }
        field(10; "Event Timeout (Seconds)"; Integer)
        {
            Caption = 'Event Timeout (Seconds)';
        }
        field(11; "Log Events Received"; Boolean)
        {
            Caption = 'Log Events Received';
        }
        field(12; "Send Display Events"; Boolean)
        {
            Caption = 'Send Display Events';
        }
        field(13; "TYRO Product Vendor"; Text[30])
        {
            Caption = 'TYRO Product Vendor';
        }
        field(14; "TYRO Product Name"; Text[30])
        {
            Caption = 'TYRO Product Name';
        }
        field(15; "TYRO Product Version"; Text[30])
        {
            Caption = 'TYRO Product Version';
        }
        field(100; "Debug Mode"; Boolean)
        {
        }
        field(101; "Status Text"; Text[100])
        {
        }
        field(102; "Log Interval (Seconds)"; Integer)
        {
        }
        field(50001; "Surcharge Sales Account"; Code[10])
        {
            Caption = 'Surcharge Sales Account';
            TableRelation = "G/L Account";
        }
        //MCS.KB 1099:Cash out in POS
        field(50002; "Cashout Item"; Code[20])
        {
            DataClassification = CustomerContent;
            TableRelation = Item;
        }
        field(50003; "EFT Tender"; Code[20])
        {
            DataClassification = CustomerContent;
            TableRelation = "LSC Tender Type".Code;
        }
        field(50004; "Cashout Tender"; Code[20])
        {
            DataClassification = CustomerContent;
            TableRelation = "LSC Tender Type".Code;
        }
    }

    keys
    {
        key(Key1; "Primary Key")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
    }

    var
        Text001: label 'Initialise POS Commands?';
        Text002: label 'Initialise Aborted!';
        Text003: label 'Initialise Complete';
        PC: Record "LSC POS Command";


    procedure Initialise()
    begin
        if not Confirm(Text001, false) then
            Error(Text002);

        AddPC('TPW_ABOUT', 'Show About Box (PCEFTPOS)');
        AddPC('TPW_FINSET', 'Do Settlement (Finalisation)');
        AddPC('TPW_LSTREC', 'Get Last Receipt From EFTPOS');
        AddPC('TPW_PRESET', 'Do Settlement (Pre-Settlement)');
        AddPC('TPW_RESET', 'Reset Connection (PCEFTPOS)');
        AddPC('TPW_STEST', 'DO EFTPOS Self Test');
        AddPC('TPW_TRANS', 'Get Last Trans. From EFTPOS');
        AddPC('TPW_LOGON', 'Perform EFTPOS Logon');
        AddPC('TPW_TMSLOGON', 'Perform EFTPOS TMS Logon');
        Message(Text003);
    end;


    procedure AddPC("Code": Code[20]; Desc: Text[50])
    begin
        if not PC.Get(Code) then begin
            PC.Init;
            PC."Function Code" := Code;
            PC.Insert;
        end;

        PC.Prompt := Desc;
        PC.Description := Desc;
        PC."Menu Function" := true;
        PC."Parameter Type" := PC."parameter type"::" ";
        PC."Manager Key" := false;
        PC."Scanner Action" := PC."scanner action"::Disable;
        PC."MSR Action" := PC."msr action"::Disable;
        PC."Function Type" := PC."function type"::"POS Internal";
        PC."Description Text" := '';
        PC."Run Codeunit" := 0;
        PC."Set POS State" := '';
        PC."Table Link" := 0;
        PC."Field Link" := 0;
        PC."POS Module" := '';
        PC.Modify(true);
    end;
}

