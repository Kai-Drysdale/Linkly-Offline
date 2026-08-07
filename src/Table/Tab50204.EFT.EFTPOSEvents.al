Table 50204 "EFTPOS Events"
{
    // MPG1.00 17-06-16 JKT
    //   - New Object

    Caption = 'EFTPOS Events';

    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
        }
        field(2; "Response Type"; Option)
        {
            Caption = 'Response Type';
            OptionCaption = ' ,Transaction,KeyDown,Print,Display,GetLastReceipt,CardSwipe,QueryCard,Settlement,SelfTest,LastTransaction,DisplaySettlement';
            OptionMembers = " ",Transaction,KeyDown,Print,Display,GetLastReceipt,CardSwipe,QueryCard,Settlement,SelfTest,LastTransaction,DisplaySettlement;
        }
        field(3; "Response Code"; Text[250])
        {
            Caption = 'Response Code';
        }
        field(4; "Response Text"; Text[250])
        {
            Caption = 'Response Text';
        }
        field(5; "Response Success"; Boolean)
        {
            Caption = 'Response Success';
        }
        field(6; "Receipt Length"; Integer)
        {
            Caption = 'Receipt Length';
        }
        field(7; "Receipt Lines"; Integer)
        {
            Caption = 'Receipt Lines';
        }
        field(8; "XML File Name"; Text[250])
        {
            Caption = 'XML File Name';

            trigger OnLookup()
            begin
                Hyperlink("XML File Name");
            end;
        }
    }

    keys
    {
        key(Key1; "Entry No.")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
    }
}

