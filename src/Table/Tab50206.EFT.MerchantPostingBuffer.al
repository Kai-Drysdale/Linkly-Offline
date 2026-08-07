Table 50206 "Merchant Posting Buffer"
{
    // TRM1.0
    // JR : 20-03-2013 : New Object added for Tectura Retail Merchant Banking Functionality

    Caption = 'Merchant Posting Buffer';

    fields
    {
        field(1; "Statement No."; Code[10])
        {
            Caption = 'Statement No.';
        }
        field(2; "Line No."; Integer)
        {
            Caption = 'Line No.';
        }
        field(3; "Tender Type"; Code[10])
        {
            Caption = 'Tender Type';
        }
        field(4; "Clearing Tender Type"; Code[10])
        {
            Caption = 'Clearing Tender Type';
        }
        field(5; "Clearing Amount"; Decimal)
        {
            Caption = 'Clearing Amount';
        }
        field(6; Commision; Boolean)
        {
            Caption = 'Commision';
        }
        field(7; "Commision Amount"; Decimal)
        {
            Caption = 'Commision Amount';
        }
        field(8; "Commision Account"; Code[10])
        {
            Caption = 'Commision Account';
        }
        field(9; "Clearing Bank Account"; Code[20])
        {
            Caption = 'Clearing Bank Account';
        }
        field(10; "Tender Type Card"; Code[10])
        {
            Caption = 'Tender Type Card';
        }
        field(15; Posted; Boolean)
        {
            Caption = 'Posted';
        }
        field(16; "GL Account"; Code[10])
        {
            Caption = 'GL Account';
        }
        field(17; "Posting Description"; Text[30])
        {
            Caption = 'Posting Description';
        }
    }

    keys
    {
        key(Key1; "Statement No.", "Tender Type", "Tender Type Card")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
    }
}

