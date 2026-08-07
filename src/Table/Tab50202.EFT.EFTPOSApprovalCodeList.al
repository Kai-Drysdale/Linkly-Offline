Table 50202 "EFTPOS Approval Code List"
{
    // MPG1.00 17-06-16 JKT
    //   - New Object
    // MCS1.02 21-06-20 KK
    //   JIRA PS-1755 Added field Print Merchant Copy

    Caption = 'EFTPOS Approval Code List';

    fields
    {
        field(1; "Interface Type"; Option)
        {
            Caption = 'Interface Type';
            OptionCaption = ' ,PCEFTPOS,TYRO,Payment Express';
            OptionMembers = " ",PCEFTPOS,TYRO,"Payment Express";
        }
        field(2; "Country Code"; Option)
        {
            Caption = 'Country Code';
            OptionCaption = ' ,AU,NZ';
            OptionMembers = " ",AU,NZ;
        }
        field(3; "Bank Type"; Code[10])
        {
            Caption = 'Bank Type';
            DataClassification = CustomerContent;
        }
        field(4; "Response Codes"; Code[10])
        {
            Caption = 'Response Codes';
            NotBlank = true;
            DataClassification = CustomerContent;
        }
        field(5; Approve; Boolean)
        {
            Caption = 'Approve';
            DataClassification = CustomerContent;
        }
        field(6; "Force Get Last Transaction"; Boolean)
        {
            Caption = 'Force Get Last Transaction';
            DataClassification = CustomerContent;
        }
        field(7; "Response Text"; Text[50])
        {
            Caption = 'Response Text';
            DataClassification = CustomerContent;
        }
        field(8; Date; Date)
        {
            Caption = 'Date';
            DataClassification = CustomerContent;
        }
        field(9; "Print Merchant Copy"; Boolean)
        {
            DataClassification = CustomerContent;
            Description = 'MCS1.02';
        }
    }

    keys
    {
        key(Key1; "Interface Type", "Country Code", "Bank Type", "Response Codes")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
    }
}

