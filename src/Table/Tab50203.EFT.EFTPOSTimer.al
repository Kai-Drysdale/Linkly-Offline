Table 50203 "EFTPOS Timer"
{
    // MPG1.00 17-06-16 JKT
    //   - New Object

    Caption = 'EFTPOS Timer';

    fields
    {
        field(1; "Receipt No."; Code[20])
        {
            Caption = 'Receipt No.';
        }
        field(10; Entry; Integer)
        {
            Caption = 'Entry';
        }
        field(20; Date; Date)
        {
            Caption = 'Date';
        }
        field(21; Time; Time)
        {
            Caption = 'Time';
        }
    }

    keys
    {
        key(Key1; "Receipt No.", Entry)
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
    }
}

