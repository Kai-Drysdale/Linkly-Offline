Table 50207 "EFTPOS Receipt Text"
{
    // MPG1.00 17-06-16 JKT
    //   - New Object

    Caption = 'EFTPOS Receipt Text';

    fields
    {
        field(1; Type; Option)
        {
            Caption = 'Type';
            OptionCaption = 'PCEFTPOS,TYRO,Payment Express';
            OptionMembers = PCEFTPOS,TYRO,"Payment Express";
        }
        field(2; "Store No."; Code[10])
        {
            Caption = 'Store No.';
        }
        field(3; "POS Terminal No."; Code[10])
        {
            Caption = 'POS Terminal No.';
        }
        field(4; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
        }
        field(5; "Receipt No"; Integer)
        {
            Caption = 'Receipt No.';
        }
        field(6; "Event Code"; Integer)
        {
            Caption = 'Event Code';
        }
        field(7; "Receipt Type"; Code[1])
        {
            Caption = 'Receipt Type';
        }
        field(10; "EFTPOS Receipt Text"; Text[50])
        {
            Caption = 'EFTPOS Receipt Text';
        }
        field(11; "Signature Required"; Boolean)
        {
            Caption = 'Signature Required';
        }
        field(12; "Receipt Code"; Code[20])
        {
            Caption = 'Receipt Code';
        }
        field(14; "Event Text"; Text[250])
        {
            Caption = 'Event Text';
        }
        field(15; "Event Text 2"; Text[250])
        {
            Caption = 'Event Text 2';
        }
        field(16; "Event Text 3"; Text[250])
        {
            Caption = 'Event Text 3';
        }
        field(17; "Event Text 4"; Text[250])
        {
            Caption = 'Event Text 4';
        }
        field(18; "Event Text 5"; Text[250])
        {
            Caption = 'Event Text 5';
        }
        field(19; "Date of Receipt"; Date)
        {
            Caption = 'Date of Receipt';
        }
        field(20; "Time of Receipt"; Time)
        {
            Caption = 'Time of Receipt';
        }
    }

    keys
    {
        key(Key1; Type, "Store No.", "POS Terminal No.", "Receipt Code", "Entry No.")
        {
            Clustered = true;
        }
        key(Key2; "Receipt Code")
        {
        }
    }

    fieldgroups
    {
    }
}

