Table 50205 "EFTPOS Request"
{
    // MPG1.00 17-06-16 JKT
    //   - New Object

    Caption = 'EFTPOS Request';

    fields
    {
        field(1; "Store No."; Code[10])
        {
            Caption = 'Store No.';
        }
        field(2; "POS Terminal No."; Code[10])
        {
            Caption = 'POS Terminal No.';
        }
        field(3; "Receipt No."; Code[20])
        {
            Caption = 'Receipt No.';
        }
        field(4; Date; Date)
        {
            Caption = 'Date';
        }
        field(5; Time; Time)
        {
            Caption = 'Time';
        }
        field(6; "Purchase Amount"; Decimal)
        {
            Caption = 'Purchase Amount';
        }
        field(7; "Cashout Amount"; Decimal)
        {
            Caption = 'Cashout Amount';
        }
        field(8; "Refund Amount"; Decimal)
        {
            Caption = 'Refund Amount';
        }
    }

    keys
    {
        key(Key1; "Store No.", "POS Terminal No.", "Receipt No.")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
    }
}

