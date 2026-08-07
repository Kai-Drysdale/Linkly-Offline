Table 50201 "EFTPOS Log"
{
    // MPG1.00 17-06-16 JKT
    //   - New Object

    Caption = 'EFTPOS Log';

    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
        }
        field(2; "Entry Type"; Option)
        {
            Caption = 'Entry Type';
            OptionCaption = 'Log,Detail';
            OptionMembers = Log,Detail;
        }
        field(3; "Event Type"; Option)
        {
            Caption = 'Event Type';
            OptionCaption = ' ,Transaction,KeyDown,Print,Display,GetLastReceipt,CardSwipe,QueryCard,Settlement,SelfTest,LastTransaction,DisplaySettlement';
            OptionMembers = " ",Transaction,KeyDown,Print,Display,GetLastReceipt,CardSwipe,QueryCard,Settlement,SelfTest,LastTransaction,DisplaySettlement;
        }
        field(4; "Event Code"; Text[250])
        {
            Caption = 'Event Code';
        }
        field(5; "Event Text"; Text[250])
        {
            Caption = 'Event Text';
        }
        field(6; "Event Success"; Boolean)
        {
            Caption = 'Event Success';
        }
        field(7; "Receipt Length"; Integer)
        {
            Caption = 'Receipt Length';
        }
        field(8; "Receipt Lines"; Integer)
        {
            Caption = 'Receipt Lines';
        }
        field(9; "Receipt No."; Code[20])
        {
            Caption = 'Receipt No.';
        }
        field(10; "Log Date"; Date)
        {
            Caption = 'Log Date';
        }
        field(11; "Log Time"; Time)
        {
            Caption = 'Log Time';
        }
        field(12; "Has Detail"; Boolean)
        {
            Caption = 'Has Detail';
        }
        field(13; "Account Type"; Code[20])
        {
            Caption = 'Account Type';
        }
        field(14; AIIC; Code[20])
        {
            Caption = 'AIIC';
        }
        field(15; "Cash Amount"; Decimal)
        {
            Caption = 'Cash Amount';
        }
        field(16; "Purchase Amount"; Decimal)
        {
            Caption = 'Purchase Amount';
        }
        field(17; "Refund Amount"; Decimal)
        {
            Caption = 'Refund Amount';
        }
        field(18; CAID; Code[20])
        {
            Caption = 'CAID';
        }
        field(19; "Card Type"; Code[20])
        {
            Caption = 'Card Type';
        }
        field(20; "Card Name"; Code[20])
        {
            Caption = 'Card Name';
        }
        field(21; "Cat ID"; Code[20])
        {
            Caption = 'Cat ID';
        }
        field(22; "Cut Receipt"; Boolean)
        {
            Caption = 'Cut Receipt';
        }
        field(23; "Response Date"; Text[30])
        {
            Caption = 'Response Date';
        }
        field(24; "Date Settlement"; Text[30])
        {
            Caption = 'Date Settlement';
        }
        field(25; "Message Type"; Integer)
        {
            Caption = 'Message Type';
        }
        field(26; "Reset Totals"; Boolean)
        {
            Caption = 'Reset Totals';
        }
        field(27; "Response Type"; Text[30])
        {
            Caption = 'Response Type';
        }
        field(28; "Settle Card Count"; Integer)
        {
            Caption = 'Settle Card Count';
        }
        field(29; "Settle Card Totals"; Text[250])
        {
            Caption = 'Settle Card Totals';
        }
        field(30; "Response Time"; Text[30])
        {
            Caption = 'Response Time';
        }
        field(31; STAN; Text[30])
        {
            Caption = 'STAN';
        }
        field(32; "Txn Ref"; Text[30])
        {
            Caption = 'Txn Ref';
        }
        field(33; "Txn Type"; Text[30])
        {
            Caption = 'Txn Type';
        }
        field(34; "Last Txn Success"; Boolean)
        {
            Caption = 'Last Txn Success';
        }
        field(35; "Pan Source"; Text[30])
        {
            Caption = 'Pan Source';
        }
        field(36; "Response Source"; Integer)
        {
            Caption = 'Response Source';
        }
        field(37; "Receipt Auto Print"; Boolean)
        {
            Caption = 'Receipt Auto Print';
        }
        field(38; "Display Line 1"; Text[250])
        {
            Caption = 'Display Line 1';
        }
        field(39; "Display Line 2"; Text[250])
        {
            Caption = 'Display Line 2';
        }
        field(40; Merchant; Integer)
        {
            Caption = 'Merchant';
        }
        field(41; Tag; Text[250])
        {
            Caption = 'Tag';
        }
        field(42; "Receipt Type"; Text[250])
        {
            Caption = 'Receipt Type';
        }
        field(43; "XML Data"; Blob)
        {
            Caption = 'XML Data';
        }
        field(44; "Line No."; Integer)
        {
            Caption = 'Line No.';
        }
        field(45; "Store No."; Code[10])
        {
            Caption = 'Store No.';
        }
        field(46; "POS Terminal No."; Code[10])
        {
            Caption = 'POS Terminal No.';
        }
        field(47; Date; Date)
        {
            Caption = 'Date';
        }
        field(48; Time; Time)
        {
            Caption = 'Time';
        }
        field(49; Description; Text[250])
        {
            Caption = 'Description';
        }
        field(50; "Receipt Amount"; Decimal)
        {
            Caption = 'Receipt Amount';
        }
        field(51; "Signature Required"; Boolean)
        {
            Caption = 'Signature Required';
        }
        field(52; "Auth.code"; Text[9])
        {
            Caption = 'Auth.code';
            DataClassification = ToBeClassified;
        }
        field(53; RRN; Text[20])
        {
            DataClassification = ToBeClassified;
        }
        field(54; PAN; Text[20])
        {
            DataClassification = ToBeClassified;
        }
    }

    keys
    {
        key(Key1; "Entry No.")
        {
            Clustered = true;
        }
        key(Key2; "Store No.", "POS Terminal No.", "Log Date")
        {
        }
    }

    fieldgroups
    {
    }
}

