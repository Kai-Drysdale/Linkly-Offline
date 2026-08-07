Codeunit 50204 "EFT EFTPOS Setup Data"
{
    // MPG1.00 17-06-16
    //    New Object
    // 
    // MPG1.05 01-05-19 LP
    //   Revisited for PC-EFTPOS


    trigger OnRun()
    begin
        EFTPOSSetup.Get;
        if EFTPOSSetup."Interface Type" <> EFTPOSSetup."interface type"::PCEFTPOS then
            Error(Text001, Format(EFTPOSSetup."interface type"::PCEFTPOS));

        AddTimerAddin;
        UpdatePOSCommand;
        UpdatePOSMenus;
        UpdatePOSButtonPadControl;
        UpdatePOSPanels;
        UpdatePOSPanelRowColumn;
        CreatePOSPanelControlLines;
    end;

    var
        Window: Dialog;
        EFTPOSSetup: Record "EFTPOS Setup";
        Text001: label 'EFTPOS Setup must be %1';

    local procedure AddTimerAddin()
    var
        ClientAddin: Record "Add-in";
    begin
        if not ClientAddin.Get('FreddyK.TimerControl.NE', '71fbd598f735baa3') then begin
            ClientAddin.Init;
            ClientAddin."Add-in Name" := 'FreddyK.TimerControl.NE';
            ClientAddin."Public Key Token" := '71fbd598f735baa3';
            ClientAddin.Category := ClientAddin.Category::"DotNet Control Add-in";
            ClientAddin.Description := 'NAV Timer Control No Event Thread';
            ClientAddin.Insert;
        end else begin
            if ClientAddin.Category <> ClientAddin.Category::"DotNet Control Add-in" then begin
                ClientAddin.Category := ClientAddin.Category::"DotNet Control Add-in";
                ClientAddin.Modify;
            end;
        end;
    end;

    local procedure UpdatePOSCommand()
    var
        POSCommand: Record "LSC POS Command";
    begin
        if not POSCommand.Get('EFTPOS') then
            CreatePOSCommand('EFTPOS', 'EFTPOS Functions');

        if not POSCommand.Get('EFTPOS_DOLASTRANS') then
            CreatePOSCommand('EFTPOS_DOLASTRANS', 'EFTPOS Get Last Transaction');

        if not POSCommand.Get('EFTPOS_LSTREC') then
            CreatePOSCommand('EFTPOS_LSTREC', 'EFTPOS Print Last Receipt');

        if not POSCommand.Get('EFTPOS_PRESET') then
            CreatePOSCommand('EFTPOS_PRESET', 'EFTPOS Pre Settlement');

        if not POSCommand.Get('EFTPOS_FINSET') then
            CreatePOSCommand('EFTPOS_FINSET', 'EFTPOS Settlement ');

        if not POSCommand.Get('EFTPOS_RESET') then
            CreatePOSCommand('EFTPOS_RESET', 'EFTPOS Do Log On');

        if not POSCommand.Get('EFTPOS_ABOUT') then
            CreatePOSCommand('EFTPOS_ABOUT', 'EFTPOS Do Log On');

        if not POSCommand.Get('EFTPOS_LASTEFT') then
            CreatePOSCommand('EFTPOS_LASTEFT', 'EFTPOS Do Tender Last EFT');

        if not POSCommand.Get('EFTPOS_LOGON') then
            CreatePOSCommand('EFTPOS_LOGON', 'EFTPOS Do Log On');

        if not POSCommand.Get('EFTPOS_TMSLOGON') then
            CreatePOSCommand('EFTPOS_TMSLOGON', 'EFTPOS Do Log On');

        if not POSCommand.Get('MCS_CARDSC') then
            CreatePOSCommand('MCS_CARDSC', 'MCS Card Surcharge');
    end;

    local procedure CreatePOSCommand(NewCode: Code[20]; NewDescription: Text[50])
    var
        POSCommand: Record "LSC POS Command";
    begin
        with POSCommand do begin
            Init;
            "Function Code" := NewCode;
            Description := NewDescription;
            "Menu Function" := true;
            Insert(true);
        end;
    end;

    local procedure UpdatePOSMenus()
    var
        POSMenuHeader: Record "LSC POS Menu Header";
    begin
        if not POSMenuHeader.Get('##DEFAULT', 'PURCH_AMT') then begin
            POSMenuHeader.Init;
            POSMenuHeader."Profile ID" := '##DEFAULT';
            POSMenuHeader."Menu ID" := 'PURCH_AMT';
            POSMenuHeader."Menu Type" := POSMenuHeader."menu type"::Menu;
            POSMenuHeader.Description := 'Enter Purchase Amount';
            POSMenuHeader.Columns := 1;
            POSMenuHeader.Rows := 1;
            POSMenuHeader."Button Spacing" := 1;
            POSMenuHeader."Sliding Speed" := 5;
            POSMenuHeader.Insert(true);
        end;

        if not POSMenuHeader.Get('##DEFAULT', '#EFTPOSOK_CANCEL') then begin
            POSMenuHeader.Init;
            POSMenuHeader."Profile ID" := '##DEFAULT';
            POSMenuHeader."Menu ID" := '#EFTPOSOK_CANCEL';
            POSMenuHeader."Menu Type" := POSMenuHeader."menu type"::Menu;
            POSMenuHeader.Description := 'OK Cancel horizontal';
            POSMenuHeader.Columns := 2;
            POSMenuHeader.Rows := 1;
            POSMenuHeader."Button Spacing" := 1;
            POSMenuHeader."Sliding Speed" := 5;
            POSMenuHeader.Insert(true);
        end;

        if not POSMenuHeader.Get('##DEFAULT', 'EFTPOSCASHOUT') then begin
            POSMenuHeader.Init;
            POSMenuHeader."Profile ID" := '##DEFAULT';
            POSMenuHeader."Menu ID" := 'EFTPOSCASHOUT';
            POSMenuHeader."Menu Type" := POSMenuHeader."menu type"::Menu;
            POSMenuHeader.Description := 'Cash Out Amount';
            POSMenuHeader.Columns := 2;
            POSMenuHeader.Rows := 1;
            POSMenuHeader."Button Spacing" := 1;
            POSMenuHeader."Sliding Speed" := 5;
            POSMenuHeader.Insert(true);
        end;

        if not POSMenuHeader.Get('##DEFAULT', 'EFTPOSTOTAL') then begin
            POSMenuHeader.Init;
            POSMenuHeader."Profile ID" := '##DEFAULT';
            POSMenuHeader."Menu ID" := 'EFTPOSTOTAL';
            POSMenuHeader."Menu Type" := POSMenuHeader."menu type"::Menu;
            POSMenuHeader.Description := 'Total Amount';
            POSMenuHeader.Columns := 2;
            POSMenuHeader.Rows := 1;
            POSMenuHeader."Button Spacing" := 1;
            POSMenuHeader."Sliding Speed" := 5;
            POSMenuHeader.Insert(true);
        end;

        if not POSMenuHeader.Get('##DEFAULT', '#INFO-3') then begin
            POSMenuHeader.Init;
            POSMenuHeader."Profile ID" := '##DEFAULT';
            POSMenuHeader."Menu ID" := '#INFO-3';
            POSMenuHeader."Menu Type" := POSMenuHeader."menu type"::Menu;
            POSMenuHeader.Description := 'Information 3 (Multiple Use)';
            POSMenuHeader.Columns := 1;
            POSMenuHeader.Rows := 1;
            POSMenuHeader."Button Spacing" := 1;
            POSMenuHeader."Sliding Speed" := 5;
            POSMenuHeader.Insert(true);
        end;

        if not POSMenuHeader.Get('##DEFAULT', '#INFO-4') then begin
            POSMenuHeader.Init;
            POSMenuHeader."Profile ID" := '##DEFAULT';
            POSMenuHeader."Menu ID" := '#INFO-4';
            POSMenuHeader."Menu Type" := POSMenuHeader."menu type"::Menu;
            POSMenuHeader.Description := 'Information 4 (Multiple Use)';
            POSMenuHeader.Columns := 1;
            POSMenuHeader.Rows := 1;
            POSMenuHeader."Button Spacing" := 1;
            POSMenuHeader."Sliding Speed" := 5;
            POSMenuHeader.Insert(true);
        end;
        AddPOSMenuLines;
    end;

    local procedure AddPOSMenuLines()
    var
        POSMenuLine: Record "LSC POS Menu Line";
    begin
        with POSMenuLine do begin
            if not Get('##DEFAULT', 'PURCH_AMT', 1) then begin
                Init;
                "Profile ID" := '##DEFAULT';
                "Menu ID" := 'PURCH_AMT';
                Validate("Key No.", 1);
                Description := '<#Payment>';
                Validate(Command, 'EFTPOS');
                Validate(Parameter, 'CHANGEAMOUNT');
                Insert(true);
            end;

            if not Get('##DEFAULT', '#EFTPOSOK_CANCEL', 1) then begin
                Init;
                "Profile ID" := '##DEFAULT';
                "Menu ID" := '#EFTPOSOK_CANCEL';
                Validate("Key No.", 1);
                Description := 'PROCESS';
                Validate(Command, 'EFTPOS');
                Validate(Parameter, 'OK');
                Insert(true);
            end;
            if not Get('##DEFAULT', '#EFTPOSOK_CANCEL', 2) then begin
                Init;
                "Profile ID" := '##DEFAULT';
                "Menu ID" := '#EFTPOSOK_CANCEL';
                Validate("Key No.", 2);
                Description := 'CANCEL';
                Validate(Command, 'EFTPOS');
                Validate(Parameter, 'CANCEL');
                Insert(true);
            end;
            if not Get('##DEFAULT', 'EFTPOSCASHOUT', 1) then begin
                Init;
                "Profile ID" := '##DEFAULT';
                "Menu ID" := 'EFTPOSCASHOUT';
                Validate("Key No.", 1);
                Description := '<#CashOut>';
                Validate(Command, 'EFTPOS');
                Validate(Parameter, 'CHANGECASHOUT');
                Glyph := Glyph::Text;
                "Glyph Text" := 'Cash Out';
                "Glyph Text 2" := 'Click to change Amount';
                "Glyph Offset" := 10;
                "Glyph Position" := "glyph position"::TopLeft;
                "Glyph 2 Position" := "glyph 2 position"::TopLeft;
                "Glyph Text Font" := '#TF_LARGE';
                Insert(true);
            end;
            if not Get('##DEFAULT', 'EFTPOSTOTAL', 1) then begin
                Init;
                "Profile ID" := '##DEFAULT';
                "Menu ID" := 'EFTPOSTOTAL';
                Validate("Key No.", 1);
                Description := '<#Balance>';
                Glyph := Glyph::Text;
                "Glyph Text" := 'Total Amount';
                "Glyph Text 2" := 'Total Amount';
                "Glyph Offset" := 10;
                "Glyph Position" := "glyph position"::TopLeft;
                Font := '#CO_START';
                "Glyph Text Font" := '#DT_FREE';
                Insert(true);
            end;
            if not Get('##DEFAULT', '#INFO-3', 1) then begin
                Init;
                "Profile ID" := '##DEFAULT';
                "Menu ID" := '#INFO-3';
                Validate("Key No.", 1);
                Description := '<#MU_InfoText3>';
                Insert(true);
            end;
            if not Get('##DEFAULT', '#INFO-4', 1) then begin
                Init;
                "Profile ID" := '##DEFAULT';
                "Menu ID" := '#INFO-4';
                Validate("Key No.", 1);
                Description := '<#MU_InfoText4>';
                Insert(true);
            end;
        end;
    end;

    local procedure UpdatePOSPanels()
    var
        POSPanel: Record "LSC POS Panel";
    begin
        with POSPanel do begin
            if not Get('##DEFAULT', '#EFTPOSPURCH') then begin
                Init;
                "Interface Profile ID" := '##DEFAULT';
                "Control ID" := '#EFTPOSPURCH';
                Validate(Columns, 4);
                Validate(Rows, 5);
                Width := 900;
                Height := 700;
                Description := 'EFTPOS Purchase';
                Codeunit := 16022398;
                "Signal Enter Pressed" := true;
                "Border Width" := 2;
                Insert(true);
            end;

            if not Get('##DEFAULT', '#EFTPOSREFUND') then begin
                Init;
                "Interface Profile ID" := '##DEFAULT';
                "Control ID" := '#EFTPOSREFUND';
                Validate(Columns, 4);
                Validate(Rows, 3);
                Width := 900;
                Height := 700;
                Description := 'EFTPOS Refund';
                Codeunit := 16022398;
                "Signal Enter Pressed" := true;
                "Border Width" := 2;
                Insert(true);
            end;
        end;
    end;

    local procedure CreatePOSPanelControlLines()
    var
        POSPanelControlLine: Record "LSC POS Panel Control Line";
    begin
        with POSPanelControlLine do begin
            if not Get('##DEFAULT', '#EFTPOSPURCH', 1) then begin
                Init;
                "Interface Profile ID" := '##DEFAULT';
                "Panel Control ID" := '#EFTPOSPURCH';
                "Line No." := 1;
                Validate(Column, 1);
                Validate(Row, 1);
                "Column Span" := 4;
                Validate("Control ID", '#EFTPOSHEADING');
                //"Border Width" := 2;
                Insert(true);
            end;

            if not Get('##DEFAULT', '#EFTPOSPURCH', 20) then begin
                Init;
                "Interface Profile ID" := '##DEFAULT';
                "Panel Control ID" := '#EFTPOSPURCH';
                "Line No." := 20;
                Validate(Column, 1);
                Validate(Row, 2);
                "Column Span" := 0;
                Validate("Control ID", '#INFO1');
                //"Border Width" := 2;
                Insert(true);
            end;

            if not Get('##DEFAULT', '#EFTPOSPURCH', 21) then begin
                Init;
                "Interface Profile ID" := '##DEFAULT';
                "Panel Control ID" := '#EFTPOSPURCH';
                "Line No." := 21;
                Validate(Column, 2);
                Validate(Row, 2);
                "Column Span" := 0;
                Validate("Control ID", '#EFTPOSPURCHAMT');
                //"Border Width" := 2;
                Insert(true);
            end;

            if not Get('##DEFAULT', '#EFTPOSPURCH', 22) then begin
                Init;
                "Interface Profile ID" := '##DEFAULT';
                "Panel Control ID" := '#EFTPOSPURCH';
                "Line No." := 22;
                Validate(Column, 3);
                Validate(Row, 2);
                "Column Span" := 2;
                Validate("Control ID", '#EFTPOSTOTAL');
                //"Border Width" := 2;
                Insert(true);
            end;

            if not Get('##DEFAULT', '#EFTPOSPURCH', 30) then begin
                Init;
                "Interface Profile ID" := '##DEFAULT';
                "Panel Control ID" := '#EFTPOSPURCH';
                "Line No." := 30;
                Validate(Column, 1);
                Validate(Row, 3);
                "Column Span" := 0;
                Validate("Control ID", '#INFO2');
                //"Border Width" := 2;
                Insert(true);
            end;

            if not Get('##DEFAULT', '#EFTPOSPURCH', 31) then begin
                Init;
                "Interface Profile ID" := '##DEFAULT';
                "Panel Control ID" := '#EFTPOSPURCH';
                "Line No." := 31;
                Validate(Column, 2);
                Validate(Row, 3);
                "Column Span" := 3;
                Validate("Control ID", '#EFTPOSCASHOUT');
                //"Border Width" := 2;
                Insert(true);
            end;

            if not Get('##DEFAULT', '#EFTPOSPURCH', 40) then begin
                Init;
                "Interface Profile ID" := '##DEFAULT';
                "Panel Control ID" := '#EFTPOSPURCH';
                "Line No." := 40;
                Validate(Column, 1);
                Validate(Row, 4);
                "Column Span" := 1;
                Validate("Control ID", '#INFO3');
                //"Border Width" := 2;
                Insert(true);
            end;
            if not Get('##DEFAULT', '#EFTPOSPURCH', 41) then begin
                Init;
                "Interface Profile ID" := '##DEFAULT';
                "Panel Control ID" := '#EFTPOSPURCH';
                "Line No." := 41;
                Validate(Column, 2);
                Validate(Row, 4);
                "Column Span" := 3;
                Validate("Control ID", '#INFO4');
                //"Border Width" := 2;
                Insert(true);
            end;
            if not Get('##DEFAULT', '#EFTPOSPURCH', 100) then begin
                Init;
                "Interface Profile ID" := '##DEFAULT';
                "Panel Control ID" := '#EFTPOSPURCH';
                "Line No." := 100;
                Validate(Column, 1);
                Validate(Row, 5);
                "Column Span" := 4;
                Validate("Control ID", '#EFTPOSOK_CANCEL');
                //"Border Width" := 2;
                Insert(true);
            end;

            if not Get('##DEFAULT', '#EFTPOSREFUND', 1) then begin
                Init;
                "Interface Profile ID" := '##DEFAULT';
                "Panel Control ID" := '#EFTPOSREFUND';
                "Line No." := 1;
                Validate(Column, 1);
                Validate(Row, 1);
                "Column Span" := 4;
                Validate("Control ID", '#EFTPOSHEADING');
                //"Border Width" := 2;
                Insert(true);
            end;

            if not Get('##DEFAULT', '#EFTPOSREFUND', 20) then begin
                Init;
                "Interface Profile ID" := '##DEFAULT';
                "Panel Control ID" := '#EFTPOSREFUND';
                "Line No." := 20;
                Validate(Column, 1);
                Validate(Row, 2);
                "Column Span" := 0;
                Validate("Control ID", '#INFO1');
                //"Border Width" := 2;
                Insert(true);
            end;

            if not Get('##DEFAULT', '#EFTPOSREFUND', 21) then begin
                Init;
                "Interface Profile ID" := '##DEFAULT';
                "Panel Control ID" := '#EFTPOSREFUND';
                "Line No." := 21;
                Validate(Column, 2);
                Validate(Row, 2);
                "Column Span" := 0;
                Validate("Control ID", '#EFTPOSPURCHAMT');
                //"Border Width" := 2;
                Insert(true);
            end;

            if not Get('##DEFAULT', '#EFTPOSREFUND', 22) then begin
                Init;
                "Interface Profile ID" := '##DEFAULT';
                "Panel Control ID" := '#EFTPOSREFUND';
                "Line No." := 22;
                Validate(Column, 3);
                Validate(Row, 2);
                "Column Span" := 2;
                Validate("Control ID", '#EFTPOSTOTAL');
                //"Border Width" := 2;
                Insert(true);
            end;

            if not Get('##DEFAULT', '#EFTPOSREFUND', 100) then begin
                Init;
                "Interface Profile ID" := '##DEFAULT';
                "Panel Control ID" := '#EFTPOSREFUND';
                "Line No." := 100;
                Validate(Column, 1);
                Validate(Row, 3);
                "Column Span" := 4;
                Validate("Control ID", '#EFTPOSOK_CANCEL');
                //"Border Width" := 2;
                Insert(true);
            end;
        end;
    end;

    local procedure UpdatePOSPanelRowColumn()
    var
        POSPanelRowColumn: Record "LSC POS Panel Row/Column";
    begin
        with POSPanelRowColumn do begin
            if not Get('##DEFAULT', '#EFTPOSPURCH', Type::Column, 1) then begin
                Init;
                "Interface Profile ID" := '##DEFAULT';
                "Panel Control ID" := '#EFTPOSPURCH';
                Type := Type::Column;
                Validate("No.", 1);
                Validate("Size Type", "size type"::Autosize);
            end;
            if not Get('##DEFAULT', '#EFTPOSPURCH', Type::Column, 2) then begin
                Init;
                "Interface Profile ID" := '##DEFAULT';
                "Panel Control ID" := '#EFTPOSPURCH';
                Type := Type::Column;
                Validate("No.", 2);
                Validate("Size Type", "size type"::Autosize);
            end;
            if not Get('##DEFAULT', '#EFTPOSPURCH', Type::Column, 3) then begin
                Init;
                "Interface Profile ID" := '##DEFAULT';
                "Panel Control ID" := '#EFTPOSPURCH';
                Type := Type::Column;
                Validate("No.", 3);
                Validate("Size Type", "size type"::Autosize);
            end;
            if not Get('##DEFAULT', '#EFTPOSPURCH', Type::Column, 4) then begin
                Init;
                "Interface Profile ID" := '##DEFAULT';
                "Panel Control ID" := '#EFTPOSPURCH';
                Type := Type::Column;
                Validate("No.", 4);
                Validate("Size Type", "size type"::Autosize);
            end;

            if not Get('##DEFAULT', '#EFTPOSPURCH', Type::Row, 1) then begin
                Init;
                "Interface Profile ID" := '##DEFAULT';
                "Panel Control ID" := '#EFTPOSPURCH';
                Type := Type::Row;
                Validate("No.", 1);
                Validate("Size Type", "size type"::Percent);
                Size := 10;
            end;

            if not Get('##DEFAULT', '#EFTPOSPURCH', Type::Row, 2) then begin
                Init;
                "Interface Profile ID" := '##DEFAULT';
                "Panel Control ID" := '#EFTPOSPURCH';
                Type := Type::Row;
                Validate("No.", 2);
                Validate("Size Type", "size type"::Percent);
                Size := 10;
            end;

            if not Get('##DEFAULT', '#EFTPOSPURCH', Type::Row, 3) then begin
                Init;
                "Interface Profile ID" := '##DEFAULT';
                "Panel Control ID" := '#EFTPOSPURCH';
                Type := Type::Row;
                Validate("No.", 3);
                Validate("Size Type", "size type"::Percent);
                Size := 10;
            end;

            if not Get('##DEFAULT', '#EFTPOSPURCH', Type::Row, 4) then begin
                Init;
                "Interface Profile ID" := '##DEFAULT';
                "Panel Control ID" := '#EFTPOSPURCH';
                Type := Type::Row;
                Validate("No.", 4);
                Validate("Size Type", "size type"::Percent);
                Size := 10;
            end;

            if not Get('##DEFAULT', '#EFTPOSREFUND', Type::Column, 1) then begin
                Init;
                "Interface Profile ID" := '##DEFAULT';
                "Panel Control ID" := '#EFTPOSREFUND';
                Type := Type::Column;
                Validate("No.", 1);
                Validate("Size Type", "size type"::Autosize);
            end;
            if not Get('##DEFAULT', '#EFTPOSREFUND', Type::Column, 2) then begin
                Init;
                "Interface Profile ID" := '##DEFAULT';
                "Panel Control ID" := '#EFTPOSREFUND';
                Type := Type::Column;
                Validate("No.", 2);
                Validate("Size Type", "size type"::Autosize);
            end;
            if not Get('##DEFAULT', '#EFTPOSREFUND', Type::Column, 3) then begin
                Init;
                "Interface Profile ID" := '##DEFAULT';
                "Panel Control ID" := '#EFTPOSREFUND';
                Type := Type::Column;
                Validate("No.", 3);
                Validate("Size Type", "size type"::Autosize);
            end;
            if not Get('##DEFAULT', '#EFTPOSREFUND', Type::Column, 4) then begin
                Init;
                "Interface Profile ID" := '##DEFAULT';
                "Panel Control ID" := '#EFTPOSREFUND';
                Type := Type::Column;
                Validate("No.", 4);
                Validate("Size Type", "size type"::Autosize);
            end;

            if not Get('##DEFAULT', '#EFTPOSREFUND', Type::Row, 1) then begin
                Init;
                "Interface Profile ID" := '##DEFAULT';
                "Panel Control ID" := '#EFTPOSREFUND';
                Type := Type::"Row";
                Validate("No.", 1);
                Validate("Size Type", "size type"::Percent);
                Size := 10;
            end;

            if not Get('##DEFAULT', '#EFTPOSREFUND', Type::"Row", 2) then begin
                Init;
                "Interface Profile ID" := '##DEFAULT';
                "Panel Control ID" := '#EFTPOSREFUND';
                Type := Type::"Row";
                Validate("No.", 2);
                Validate("Size Type", "size type"::Percent);
                Size := 10;
            end;

            if not Get('##DEFAULT', '#EFTPOSREFUND', Type::"Row", 3) then begin
                Init;
                "Interface Profile ID" := '##DEFAULT';
                "Panel Control ID" := '#EFTPOSREFUND';
                Type := Type::"Row";
                Validate("No.", 3);
                Validate("Size Type", "size type"::Percent);
                Size := 10;
            end;
        end;
    end;

    local procedure UpdatePOSButtonPadControl()
    var
        POSButtonPadControl: Record "LSC POS ButtonPad Control";
    begin
        with POSButtonPadControl do begin
            if not Get('##DEFAULT', '#EFTPOSHEADING') then begin
                Init;
                "Interface Profile ID" := '##DEFAULT';
                "Control ID" := '#EFTPOSHEADING';
                Insert(true);
                Validate("Menu ID", '#HEADING1');
                Modify(true);
            end;

            if not Get('##DEFAULT', '#INFO1') then begin
                Init;
                "Interface Profile ID" := '##DEFAULT';
                "Control ID" := '#INFO1';
                Insert(true);
                Validate("Menu ID", '#INFO-1');
                Modify(true);
            end;

            if not Get('##DEFAULT', '#EFTPOSPURCHAMT') then begin
                Init;
                "Interface Profile ID" := '##DEFAULT';
                "Control ID" := '#EFTPOSPURCHAMT';
                Insert(true);
                Validate("Menu ID", 'PURCH_AMT');
                Modify(true);
            end;

            if not Get('##DEFAULT', '#EFTPOSTOTAL') then begin
                Init;
                "Interface Profile ID" := '##DEFAULT';
                "Control ID" := '#EFTPOSTOTAL';
                Insert(true);
                Validate("Menu ID", 'EFTPOSTOTAL');
                Modify(true);
            end;

            if not Get('##DEFAULT', '#INFO2') then begin
                Init;
                "Interface Profile ID" := '##DEFAULT';
                "Control ID" := '#INFO2';
                Insert(true);
                Validate("Menu ID", '#INFO-2');
                Modify(true);
            end;

            if not Get('##DEFAULT', '#INFO3') then begin
                Init;
                "Interface Profile ID" := '##DEFAULT';
                "Control ID" := '#INFO3';
                Insert(true);
                Validate("Menu ID", '#INFO-3');
                Modify(true);
            end;

            if not Get('##DEFAULT', '#INFO4') then begin
                Init;
                "Interface Profile ID" := '##DEFAULT';
                "Control ID" := '#INFO4';
                Insert(true);
                Validate("Menu ID", '#INFO-4');
                Modify(true);
            end;

            if not Get('##DEFAULT', '#EFTPOSCASHOUT') then begin
                Init;
                "Interface Profile ID" := '##DEFAULT';
                "Control ID" := '#EFTPOSCASHOUT';
                Insert(true);
                Validate("Menu ID", 'EFTPOSCASHOUT');
                Modify(true);
            end;

            if not Get('##DEFAULT', '#EFTPOSOK_CANCEL') then begin
                Init;
                "Interface Profile ID" := '##DEFAULT';
                "Control ID" := '#EFTPOSOK_CANCEL';
                Insert(true);
                Validate("Menu ID", '#EFTPOSOK_CANCEL');
                Modify(true);
            end;
        end;
    end;
}

